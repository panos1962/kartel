#!/usr/bin/env awk

# Το παρόν script παράγει ημερήσια δεδομένα παρουσίας για συγκεκριμένους
# υπαλλήλους ή υπηρεσίες. Οι κωδικοί υπαλλήλων ή υπηρεσιών μπορούν να
# καθοριστούν στο command line, ή να δοθούν ως input εφόσον δεν έχουν
# καθοριστεί στο command line.

@load "spawk.so"
@include "pandora.awk"
@include "karteldb.awk"

BEGIN {
	OFS = "\t"
	spawk_verbose = 1

	if (!pd_progname)
	pd_progname = "imerisio"

	imerominia_check()
	ipalilos_check()
	ipiresia_check()

	# Αν έχουν καθοριστεί υπάλληλοι/υπηρεσίες στο command
	# line, τότε το πρόγραμμα δεν διαχειρίζεται ενδεχόμενο
	# input.

	if (input_not_allowed)
	exit(0)
}

# Αν δεν έχουν καθοριστεί υπάλληλοι/υπηρεσίες στο command line,
# τότε το πρόγραμμα διαβάζει κωδικούς υπαλλήλων/υπηρεσιών από
# το standard input ή από τα input files.

{
	parse_input()
}

# Η function "parse_input" αναλύει τα input lines και αποσπά
# κωδικούς υπαλλήλων/υπηρεσιών. Για κάθε κωδικό, εκτυπώνει τα
# σχετικά συμβάντα.

function parse_input(			n, a) {
	n = split($0, a, /\W+/)

	if (n <= 0)
	return

	do {
		if (pd_isinteger(a[n]))
		proc_ipalilos(a[n])

		else
		proc_ipiresia(a[n])
	} while (--n > 0)
}

function imerominia_check(		d) {
	if (!imerominia)
	return (imerominia = strftime("%Y-%m-%d"))

	d = imerominia
	gsub(/-/, " ", d)

	d = mktime(d " 00 00 00")

	if (d < 0)
	pd_fatal(imerominia ": λανθασμένη ημερομηνία (\"YYYY-MM-DD\")")

	imerominia = strftime("%Y-%m-%d", d)
}

function ipiresia_check(			a, n) {
	if (!ipiresia)
	return

	input_check("υπηρεσίες")
	n = split(ipiresia, a, /\W+/)

	if (n <= 0)
	return

	do
	proc_ipiresia(a[n])
	while (--n > 0)
}

function proc_ipiresia(kodipir,			ipalilos) {
	if (ipiresia_push(kodipir))
	return

	if (!ipalilos_list_created)
	ipalilos_list_create()

	for (ipalilos in ipalilos_list)
	proc_ipalilos(ipalilos, 1)
}

function ipiresia_push(ipiresia,		query) {
	if (!ipiresia)
	return 1

	if (ipiresia_list[ipiresia]++ > 0)
	return 1

	query = "SELECT 1 FROM " kartel_erpotadb("ipiresia") \
		" WHERE `kodikos` = " spawk_escape(ipiresia)

	if (spawk_submit(query) != 3)
	pd_fatal("αδυναμία επιλογής υπηρεσίας")

	if (!spawk_fetchone())
	pd_errmsg(ipiresia ": δεν υπάρχει υπηρεσία")

	return 0
}

function ipalilos_list_create(			query, ipalilos) {
	query = "SELECT `kodikos` FROM " kartel_erpotadb("ipalilos")

	if (spawk_submit(query) != 3)
	pd_fatal("αδυναμία επιλογής υπαλλήλων")

	while (spawk_fetchrow(ipalilos))
	ipalilos_list[ipalilos[1]]

	ipalilos_list_created = 1
}

function proc_ipalilos(kodipal, ipiresia_check,		ipalilos, query, istoriko) {
	if (!kodipal)
	return

	if (ipalilos_done[kodipal]++)
	return

	if (pd_notinteger(kodipal))
	return pd_errmsg(kodipal ": λανθασμένος κωδικός υπαλλήλου")

	query = "SELECT * FROM " kartel_erpotadb("ipalilos") \
	      " WHERE `kodikos` = " kodipal
	
	if (spawk_submit(query, "ASSOC") != 3)
	return

	if (!spawk_fetchone(ipalilos))
	return pd_errmsg(kodipal ": δεν βρέθηκε υπάλληλος")

	ipalilos["dateFetch"] = imerominia
	kartel_ipalilos_metavoli_fetch(ipalilos)

	# if (!ipalilos["orario"])
	if (!ipalilos["karta"])
	return

	if (ipiresia_check &&
	(!(ipalilos["ipidie"] in ipiresia_list)) &&
	(!(ipalilos["ipitmi"] in ipiresia_list)))
	return ipalilos_done[kodipal]--

	query = "SELECT * FROM `kartel`.`istoriko` " \
		"WHERE (`karta` = " ipalilos["karta"] ") " \
		"AND (`meraora` >= " spawk_escape(imerominia) ") " \
		"AND (`meraora` < (" spawk_escape(imerominia) " + INTERVAL 1 DAY))"

	if (spawk_submit(query, "ASSOC") != 3)
	return

	while (spawk_fetchrow(istoriko))
	print ipalilos["ipidie"], ipalilos["ipitmi"], \
		ipalilos["kodikos"], ipalilos["eponimo"], \
		ipalilos["onoma"], ipalilos["patronimo"], \
		istoriko["kodikos"], istoriko["meraora"], \
		istoriko["perigrafi"]
}

function ipalilos_check(		a, n, x) {
	if (!ipalilos)
	return

	input_check("υπάλληλοι")
	n = split(ipalilos, a, /\W+/)

	if (n <= 0)
	return

	do
	proc_ipalilos(a[n])
	while (--n > 0)
}

function input_check(ipip) {
	if (ARGC > 1)
	pd_fatal("καθορίστηκαν " ipip " στο command line ΚΑΙ input files")

	input_not_allowed = 1
}
