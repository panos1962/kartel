#!/usr/bin/env gawk

BEGIN {
	FS = "\t"
	OFS = "\t"

	# Ο μετρητής 'errcount' μετράει τα fatal errors και αν μετά
	# το processing όλων των δεδομένων δεν έχει παραμείνει μηδέν,
	# το πρόγραμμα κάνει exit με μη μηδενική τιμή. Με άλλα λόγια,
	# για να θεωρηθεί το processing πετυχημένο, θα πρέπει να μην
	# παρουσιαστούν fatal errors στα δεδομένα.

	errcnt = 0
	skipcnt = 0
	proccnt = 0
	ncols = 13

	# Το array 'not_null' δεικτοδοτείται με τα ονόματα των πεδίων
	# του πίνακα 'ipalilos', και παίρνει τιμή 1 για τα πεδία που
	# δεν επιτρέπεται να έχουν null τιμή, και τιμή 0 για τα πεδία
	# που δύνανται μεν (από τεχνικής άποψης) νά έχουν null τιμή,
	# αλλά θα έπρεπε να έχουν τιμή. Οι περιπτώσεις 1 λογίζονται
	# ως fatal errors, ενώ οι περιπτώσεις 0 λογίζονται ως
	# warnings αλλά γίνονται δεκτές.
	#
	# *το πεδίο "kodikos" ελέγχεται ad hoc.

	not_null["eponimo"] = 1
	not_null["onoma"] = 1
	not_null["katastasi"] = 1

	not_null["patronimo"] = 0
	not_null["genisi"] = 0
	not_null["afm"] = 0
	not_null["arxiki"] = 0

	read_bademail()
}

NF != ncols {
	errcnt += pd_errmsg($0 ": 'ipalilos' columns count " NF " <> " ncols)
	next
}

skip_ipalilos(ipalilos) {
	skipcnt++
	next
}

{
	print \
	ipalilos["kodikos"], \
	ipalilos["eponimo"], \
	ipalilos["onoma"], \
	ipalilos["patronimo"], \
	pd_nullconvert(ipalilos["genisi"], "\\N"), \
	pd_nullconvert(ipalilos["afm"], "\\N"), \
	pd_nullconvert(ipalilos["premail"], "\\N"), \
	pd_nullconvert(ipalilos["ipemail"], "\\N"), \
	pd_nullconvert(ipalilos["arxiki"], "\\N"), \
	pd_nullconvert(ipalilos["proslipsi"], "\\N"), \
	pd_nullconvert(ipalilos["diorismos"], "\\N"), \
	pd_nullconvert(ipalilos["apoxorisi"], "\\N"), \
	(ipalilos["katastasi"] ? "ΕΝΕΡΓΟΣ" : "ΑΝΕΝΕΡΓΟΣ")

	proccnt++
}

END {
	if (errcnt) {
		ttymsg(errcnt " errors encountered")
		exit(1)
	}

	ttymsg("ipalilos: " proccnt " rows extracted", 1)

	if (skipcnt)
	ttymsg(", " skipcnt " rows skipped", 1)

	ttymsg()
	exit(0)
}

function read_bademail() {
	email_col["premail"]
	email_col["ipemail"]

	bad_email[""]

	if (!bademail)
	return

	while (getline <bademail)
	bad_email[$0]

	close(bademail)
}

function skip_ipalilos(ipalilos) {
	delete ipalilos

	if (proc_ipalilos(ipalilos))
	return 1

	return 0
}

function proc_ipalilos(ipalilos,		i, errs) {
	ipalilos["kodikos"] = $(++i)

	if (ipalilos["kodikos"] == pd_null)
	return null_error($0, "kodikos")

	ipalilos["eponimo"] = $(++i)
	ipalilos["onoma"] = $(++i)
	ipalilos["patronimo"] = $(++i)
	ipalilos["genisi"] = $(++i)
	ipalilos["afm"] = $(++i)
	ipalilos["premail"] = $(++i)
	ipalilos["ipemail"] = $(++i)
	ipalilos["arxiki"] = $(++i)
	ipalilos["proslipsi"] = $(++i)
	ipalilos["diorismos"] = $(++i)
	ipalilos["apoxorisi"] = $(++i)
	ipalilos["katastasi"] = $(++i)

	# Όσον αφορά τις ημερομηνίες πρόσληψης, διορισμού και αρχικής
	# εργασιακής σχέσης με τον Δήμο Θεσσαλονίκης, ακολουθούμε την
	# εξής τακτική: αν δεν έχει συμπληρωθεί ημερομηνία πρόσληψης,
	# τότε τίθεται ίδια με την ημερομηνία διορισμού. Αν δεν έχει
	# συμπληρωθεί ημερομηνία αρχικής εργασιακής σχέσης με τον ΔΘ,
	# τότε τίθεται ίδια με την ημερομηνία πρόσληψης.

	if (ipalilos["proslipsi"] == pd_null)
	ipalilos["proslipsi"] = ipalilos["diorismos"]

	if (ipalilos["arxiki"] == pd_null)
	ipalilos["arxiki"] = ipalilos["proslipsi"]

	for (i in not_null) {
		if (ipalilos[i] != pd_null)
		continue

		if (not_null[i]) {
			pd_errmsg("ERROR: " ipalilos["kodikos"] ": 'ipalilos." i "' null value")
			errs++
			continue
		}

		if (nullwarn)
		pd_errmsg("WARNING: " ipalilos["kodikos"] ": 'ipalilos." i "' null value")
	}

	for (i in email_col) {
		if (ipalilos[i] in bad_email)
		ipalilos[i] = pd_null
	}

	if (errs) {
		errcnt += errs
		return 1
	}

	if (ipalilos["patronimo"] == pd_null)
	ipalilos["patronimo"] = ""

	return 0
}
