@load "spawk.so"
@include "pandora.awk"
@include "karteldb.awk"

BEGIN {
	OFS = "\t"

	err = 0

	if (!apo)
	pd_fatal("Δεν έχει καθοριστεί ημερομηνία αρχής")

	if (!eos)
	eos = apo
}

$0 ~ /^[ΑΒΓΔ][0-9]+$/ {
	ipiresia[$0]

	if (reqfile)
	print "<li>Υπηρεσία <b>" $0 "</b></li>" >reqfile

	next
}

$0 ~ /^[0-9]+$/ {
	ipalilos[$0]

	if (reqfile)
	print "<li>Υπάλληλος <b>" $0 "</b></li>" >reqfile
	next
}

{
	next
}

END {
	ipiresia_scan()
	ipalilos_scan()
}

function ipiresia_scan(		query, data) {
	query = "SELECT `kodikos` FROM " kartel_erpotadb("ipalilos")

	if (spawk_submit(query, "ASSOC") != 3)
	return

	while (spawk_fetchrow(data)) {
		data["metavoliFetch"]
		kartel_ipalilos_fetch(data)

		if (ipalilos_skip(data)) {
			delete ipalilos["kodikos"]
			continue
		}

		ipalilos[data["kodikos"]]
		onoma[data["kodikos"]] = data["eponimo"] " " data["onoma"] " " data["patronimo"]
		karta[data["kodikos"]] = data["karta"]
	}
}

function ipalilos_skip(data,			i) {
	if (!("karta" in data))
	return 1

	if (!data["karta"])
	return 1

	# θα πρέπει τώρα να ελέγξω αν η διεύθυνση, το τμήμα, ή το γραφείο
	# του υπαλλήλου «ταιριάζει» με κάποια από τις επίμαχες υπηρεσίες.
	# Πράγματι, υπάρχουν παράξενες καταστάσεις που δεν καλύπτονται
	# από τους μέχρι τα τώρα ελέγχους, π.χ. στη Διεύθυνση Δημοτικής
	# Αστυνομίας υφίστανται «υποδιευθύνσεις», όπως "Β0801", "Β0802"
	# κλπ, γεγονός που είναι εκτός γενικού σχεδιασμού.

	for (i in ipiresia) {
		i = "^" i
		if (data["ipidie"] ~ i)
		return 0

		if (data["ipitmi"] ~ i)
		return 0

		if (data["ipigra"] ~ i)
		return 0
	}

	return 1
}

function ipalilos_scan(			i) {
	for (i in ipalilos)
	ipalilos_print(i)
}

function ipalilos_print(ipalilos,		query, data) {
	query = "SELECT DATE_FORMAT(`meraora`, '%d‑%m‑%Y')," \
		" DATE_FORMAT(`meraora`, '%H:%i:%S')" \
		" FROM `kartel`.`event`" \
		" WHERE (`karta` = " karta[ipalilos] ")" \
		" AND (`meraora` >= '" apo " 00:00:00')" \
		" AND (`meraora` <= '" eos " 23:59:59')" \
		" ORDER BY `meraora`"

	if (spawk_submit(query, 1) != 3)
	return

	while (spawk_fetchrow(data))
	print ipalilos, onoma[ipalilos], data[1], data[2]
}
