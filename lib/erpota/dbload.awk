#!/usr/bin/env awk

# Το παρόν awk script χρησιμοποιείται μέσω του προγράμματος "erpota" προκειμένου
# να ενημερωθεί η τοπική βάση δεδομένων "erpota" με «φρέσκα» στοιχεία από την
# αντίστοιχη απομεμακρυσμένη βάση δεδομένων "erpota". Επισημαίνουμε ότι η
# ενημέρωση των στοιχείων "erpota" δεν είναι προοδευτική, αλλά καθολική και
# περιλαμβάνει πεδία από όλα τα rows των πινάκων "ipalilos", "metavoli" και
# "adia", ήγουν των πινάκων εκείνων που περιέχουν στοιχεία απαραίτητα για την
# παρακολούθηση της τήρησης τού ωραρίου από τους υπαλλήλους.
#
# Ως γνωστόν, η τοπική βάση δεδομένων "erpota" έχει δύο εκδόσεις "erpota1" και
# "erpota2". Ουσιαστικά πρόκειται για δύο δίδυμες βάσεις δεδομένων που κρατούν
# τα στοιχεία των υπαλλήλων. Οι βάσεις 1 και 2 ενημερώνονται εκ περιτροπής,
# οπότε αν η τρέχουσα βάση δεδομένων είναι η "erpota1", θα ενημερωθεί η βάση
# δεδομένων "erpota2" και θα καταστεί τρέχουσα, ενώ στην επόμενη ενημέρωση θα
# ενημερωθεί η "erpota1" η οποία θα καταστεί τρέχουσα κοκ.
#
# Η τρέχουσα έκδοση της βάσης δεδομένων "erpota" βρίσκεται στο αρχείο "erpota12"
# στο directory "lib" της εφαρμογής· αυτό σημαίνει ότι στο εν λόγω αρχείο γράφει
# τον αριθμό 1 ή τον αριθμό 2.

BEGIN {
	if (verbose)
	spawk_verbose = 1

	kartel_dbconf["erpota12"] = (kartel_dbconf["erpota12"] == 1 ? 2 : 1)
	spawk_sesami["dbname"] = kartel_dbconf["erpotadb"] kartel_dbconf["erpota12"]
	kartel_usedb("erpota")	# πρόκειται για την τρέχουσα version

	drop_relations()
	truncate_tables()
	load_tables()
	add_relations()
	system(letrakdir "/bin/erpotaJSON " kartel_dbconf["erpota12"])

	kartel_erpota12_update(kartel_dbconf["erpota12"])
	ttymsg("Current 'erpota' database version: " kartel_dbconf["erpota12"])

	exit(0)
}

function drop_relations() {
	ttymsg("\nDisabling foreign key constraints…")

	while ((getline <relations) > 0) {
		if (($1 == "--FK--") && (NF == 3))
		drop_relation($2, $3)
	}

	close(relations)
}

function drop_relation(table, fk,		query) {
	if (!table)
	return

	if (!fk)
	return

	ttymsg("Disabling foreign key `" fk "`…")
	query = "ALTER TABLE `" table "` DROP FOREIGN KEY `" fk "`"

	if (spawk_submit(query) != 2)
	fatal_error(fk ": drop foreign key failed")
}

function truncate_tables() {
	ttymsg("\nTruncating tables…")
	truncate_table("metavoli")
	truncate_table("ipalilos")
	truncate_table("ipiresia")
}

function truncate_table(table) {
	ttymsg("Truncating table `" table "`…")

	if (spawk_submit("TRUNCATE `" table "`") != 2)
	fatal_error(table ": truncate table failed")
}

function load_tables() {
	ttymsg("\nLoading data…")
	load_table(ipalilos, "ipalilos", "`kodikos`, `eponimo`, `onoma`, `patronimo`, " \
		"`genisi`, `afm`, `premail`, `ipemail`, " \
		"`arxiki`, `proslipsi`, `diorismos`, `apoxorisi`, `katastasi`")

	if (testmode)
	return

	if (ipiresia)
	load_table(ipiresia, "ipiresia", "`kodikos`, `perigrafi`")

	if (metavoli)
	load_table(metavoli, "metavoli", "`ipalilos`, `idos`, " \
		"`efarmogi`, `lixi`, `timi`")
}

function load_table(infile, table, cols,		query) {
	ttymsg("Loading data into table `" table "`…")
	query = "LOAD DATA LOCAL INFILE '" infile "' " \
		"INTO TABLE `" table "` " \
		"FIELDS TERMINATED BY '\\t' (" cols ")"

	if (spawk_submit(query) != 2)
	fatal_error(table ": load data failed")

	ttymsg("Table `" table "`: " spawk_info)
}

function add_relations(			fk, qon, query) {
	ttymsg("\nEnabling foreign key constraints…")

	while ((getline <relations) > 0) {
		if (($1 == "--FK--") && (NF == 3)) {
			query = ""
			fk = $3
			qon = 1
			continue
		}

		if ($0 == "--KF--") {
			add_relation(fk, query)
			qon = 0
			continue
		}

		if (!qon)
		continue

		sub(/^	+/, "")
		query = query " " $0
	}

	close(relations)
}

function add_relation(fk, query) {
	if (!fk)
	return

	if (!query)
	return

	ttymsg("Enabling `" fk "` foreign key constraint…")

	if (spawk_submit(query) != 2)
	fatal_error(query ": add relation failed")
}

function fatal_error(msg) {
	pd_errmsg(msg)
	exit(1)
}
