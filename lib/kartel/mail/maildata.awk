#!/usr/bin/env gawk

BEGIN {
	FS = fs
	OFS = fs

	erpotadb = kartel_dbconf["erpotadb"] kartel_dbconf["erpota12"]

	bademail[pd_null]
	bademail["info@info.gr"]

	reader_info_list[pd_null]
}

# Ενδεχομένως στα αποτελέσματα να εμπεριέχεται και το max rowid. Πρόκειται για
# θετικό ακέραιο μόνο του στη γραμμή, επομένως εξαιρούμε τέτοιου είδους γραμμές.

$0 ~ /^[0-9]+$/ {
	next
}

parse_data(data) {
	next
}

{
	if (mail_mailbook(data))
	next

	mail_ipalilos(data)
}

# Πρέπει να υπάρχουν τα εξής πεδία:
#
#	[History].[RecordID]
#	[Histrory].[GenTime] or [Histrory].[RecvTime] (which is smaller)
#	[History].[Param2]
#	[Card].[CardNumber]
#	[HWIndependentDevices].[Name]
#
# Η function "parse_data" κάνει έλεγχο της γραμμής και των στοιχείων που
# περιέχονται στη γραμμή, και εφόσον ο έλεγχος είναι επιτυχής, κατασκευάζει
# array το οποίο περνάμε ως πρώτη παράμετρο. Το array είναι associative και
# περιέχει τα στοιχεία του συμβάντος.
#
# Αν παρουσιαστούν προβλήματα, η function επιστρέφει μη μηδενική τιμή, αλλιώς
# επιστρέφει μηδέν.

function parse_data(data,		errs, nf) {
	delete data

	if (NF != 5)
	return pd_errmsg($0 ": syntax error")

	nf = 1

	data["rowid"] = $(nf++) + 0
	data["time"] = $(nf++)
	data["param2"] = $(nf++)
	data["card"] = $(nf++) + 0

	data["reader"] = $(nf++)
	sub(/ .*/, "", data["reader"])

	data["info"] = reader_info(data["reader"])

	if (data["rowid"] !~ /^[0-9]+$/)
	errs += pd_errmsg($0 ": " data["rowid"] ": invalid rowid")

	if (data["card"] !~ /^[0-9]{1,5}$/)
	errs += pd_errmsg($0 ": " data["card"] ": invalid card number")

	return errs
}

function reader_info(reader,		n, a, query, row) {
	if (reader in reader_info_list)
	return reader_info_list[reader]

	reader_info_list[reader]

	n = split(reader, a, ":")

	query = "SELECT `perigrafi` FROM `kartel`.`reader` " \
		"WHERE `kodikos` = " spawk_escape(a[1])

	if (!spawk_submit(query))
	return reader_info_list[reader]

	if (!spawk_fetchone(row))
	return reader_info_list[reader]

	reader_info_list[reader] = row[1]
	return reader_info_list[reader]
}

# Η function "mail_ipalilos" δέχεται ένα array συμβάντος και επιχειρεί να
# αποστείλει ενημερωτικό email στον υπάλληλο που ήταν κάτοχος της κάρτας τη
# στιγμή του συμβάντος.

function mail_ipalilos(data,		ipalilos, query, row, i, email) {
	# Αποσπούμε τον κωδικό υπαλλήλου από τον αριθμό κάρτας λαμβάνοντας
	# υπόψη την ημερομηνία συμβάντος.

	ipalilos = get_ipalilos(data)

	if (!ipalilos)
	return 0

	query = "SELECT `ipemail`, `premail` " \
		"FROM `" erpotadb "`.`ipalilos` " \
		"WHERE `kodikos` = " ipalilos

	if (!spawk_submit(query))
	return 0

	if (!spawk_fetchone(row))
	return 0

	get_prosvasi(ipalilos, data)

	for (i in row) {
		if (row[i] in bademail)
		row[i] = ""
	}

	email = row[1]

	if (!email)
	email = row[2]

	if (!email)
	return 0

	send_mail(email, data)
	return 1
}

function get_ipalilos(data,		query, row) {
	query = "SELECT `ipalilos`" \
		"FROM `" erpotadb "`.`metavoli` " \
		"WHERE (`idos` = 'ΚΑΡΤΑ') " \
		"AND (`timi` = " spawk_escape(data["card"]) ") " \
		"AND (`efarmogi` <= " spawk_escape(data["time"]) ") " \
		"AND ((`lixi` IS NULL) " \
		"OR (`lixi` > " spawk_escape(data["time"]) ")) " \
		"ORDER BY `efarmogi` DESC " \
		"LIMIT 1"

	if (!spawk_submit(query))
	return ""

	if (!spawk_fetchone(row))
	return ""

	return row[1]
}

function get_prosvasi(ipalilos, data,		query, row, tmp) {
	delete data["pubkey"]
	delete data["password"]

	query = "SELECT `pubkey` FROM `erpota`.`prosvasi` " \
		"WHERE `ipalilos` = " ipalilos " LIMIT 1"

	if (!spawk_submit(query))
	return

	if (spawk_fetchone(row)) {
		data["pubkey"] = row[1]
		return
	}

	data["pubkey"] = pd_sha1gen()
	data["password"] = pd_passgen()

	query = "REPLACE INTO `erpota`.`prosvasi` (" \
		"`ipalilos`, `efarmogi`, `ipiresia`, `level`, " \
		"`info`, `pubkey`, `password`) VALUES (" \
		ipalilos ", CURDATE(), NULL, 'VIEW', '', " \
		spawk_escape(data["pubkey"]) ", SHA1(" \
		spawk_escape(data["password"]) "))"

	if (spawk_submit(query) == 2)
	return

	delete data["pubkey"]
	delete data["password"]
}

function mail_mailbook(data,		query, row) {
	query = "SELECT `email` " \
		"FROM `kartel`.`mailbook` " \
		"WHERE `karta` = " data["card"]

	if (!spawk_submit(query))
	return 0

	if (!spawk_fetchone(row))
	return 0

	if (!row[1])
	return 0

	send_mail(row[1], data)
	return 1
}

function send_mail(email, data) {
	printf email \
		OFS data["rowid"] \
		OFS data["card"] \
		OFS data["time"] \
		OFS data["reader"] \
		OFS data["info"]

	if ("pubkey" in data)
	printf OFS data["pubkey"]

	if ("password" in data)
	printf OFS data["password"]

	print ""
}
