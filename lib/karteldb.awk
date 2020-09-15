#!/usr/bin/env awk

# Το παρόν αποτελεί SPAWK utility functions library για τις τοπικές βάσεις
# δεδομένων 'kartel' και 'erpota'.

@load "spawk.so"

# Global αντικείμενα

# string kartel_basedir
# string kartel_dbconf_file
# string kartel_database

# Functions

# void kartel_erpota12_update(erpota12)
# int kartel_erpota12_fetch()
# void kartel_dbconf_fetch()
# void kartel_usedb([database])
# string kartel_erpotadb([object])
# int kartel_ipalilos_fetch(array)
# int kartel_ipalilos_metavoli_fetch(array)
# int kartel_ipalilos_adia(array)

BEGIN {
	kartel_basedir = ENVIRON["KARTEL_BASEDIR"]

	if (!kartel_basedir)
	kartel_basedir = (ENVIRON["KARTEL_BASEDIR"] = "/var/opt/kartel")

	if (!kartel_dbconf_file)
	kartel_dbconf_file = kartel_basedir "/lib/conf/karteldb.cf"

	kartel_dbconf_fetch()

	spawk_verbose = 1
	spawk_sesami["dbname"] = kartel_dbconf["karteldb"]
	spawk_sesami["dbuser"] = kartel_dbconf["dbuser"]
	spawk_sesami["dbpassword"] = kartel_dbconf["dbpassword"]
	spawk_sesami["dbcharset"] = "utf8"

	kartel_dbconf["erpota12"] = kartel_erpota12_fetch()

	# By default θεωρείται ως τρέχουσα βάση δεδομένων η database
	# "karteldb". Αν επιθυμούμε ως τρέχουσα βάση δεδομένων την
	# τρέχουσα version της βάσης δεδομένων "erpota", τότε αυτό
	# θα πρέπει να δηλωθεί στο awk command line μέσω τής global
	# μεταβλητής "kartel_database".

	if (!kartel_database)
	kartel_database = "kartel"

	if (kartel_database == "erpota")
	spawk_sesami["dbname"] = kartel_dbconf["erpotadb"] kartel_dbconf["erpota12"]

	else if (kartel_database == "kartel")
	spawk_sesami["dbname"] = kartel_dbconf["karteldb"]

	else
	pd_fatal(kartel_database ": invalid database tag name")
}

function kartel_dbconf_fetch(		s, a, f) {
	delete kartel_dbconf

	close(kartel_dbconf_file)
	while ((getline s <kartel_dbconf_file) > 0) {
		if (split(s, a, "=") != 2)
		continue

		if (sub("^\"", "", a[2]))
		sub("\"$", "", a[2])

		kartel_dbconf[a[1]] = a[2]
	}

	if (close(kartel_dbconf_file))
	pd_fatal(kartel_dbconf_file \
		": cannot read 'karteldb' configuration file")
}

# Η τρέχουσα έκδοση της database `erpota` μπορεί να είναι "1" ή "2" και
# περιέχεται στην παράμετρο "erpota12" του πίνακα `kartel`.`parametros`.

function kartel_erpota12_update(erpota12,		query) {
	if (pd_integerck(erpota12, 1, 2))
	pd_fatal(erpota12 ": invalid 'erpota' version")

	kartel_parametros_set("erpota12", erpota12)
}

function kartel_erpota12_fetch(			query, row) {
	query = "SELECT `timi` FROM `kartel`.`parametros` " \
		"WHERE `kodikos` = 'erpota12'"

	if (spawk_submit(query) != 3)
	pd_fatal("erpota12: cannot locate parameter")

	if (!spawk_fetchone(row))
	pd_fatal("erpota12: parameter not found")

	if (pd_integerck(row[1], 1, 2))
	pd_fatal(row[1] ": invalid 'erpota' version'")

	return row[1] + 0
}

# Η function "karteldb_usedb" χρησιμοποιείται όταν επιθυμούμε να θέσουμε ή να
# αλλάξουμε την default database. Η default database τίθεται αρχικά να είναι η
# "karteldb", αλλά σε ορισμένα προγράμματα μπορεί να είναι βολικότερη ως default
# database η τρέχουσα έκδοση της database "erpotadb". Ως παράμετρο μπορούμε να
# περάσουμε "kartel", "erpota"· αν δεν περαστεί κάποια παράμετρος, υποτίθεται η
# database "karteldb".

function kartel_usedb(database) {
	# Αν δεν περάσουμε database tag, τότε υποτίθεται το "kartel".

	if (!database)
	database = "kartel"

	if (database == kartel_database)
	return

	kartel_database = database

	if (database == "kartel")
	database = kartel_dbconf["karteldb"]

	else if (database == "erpota")
	database = kartel_dbconf["erpotadb"] kartel_dbconf["erpota12"]

	else
	pd_fatal(dbname ": invalid database tag name")

	if (spawk_submit("USE `" database "`") != 2)
	pd_fatal(database ": database connect failed")
}

function kartel_erpotadb(object,		db) {
	db = kartel_dbconf["erpotadb"] kartel_dbconf["erpota12"]

	if (object)
	return "`" db "`.`" object "`"

	return db
}

function kartel_parametros_get(kodikos,			query, row) {
	query = "SELECT `timi` FROM `kartel`.`parametros` " \
		"WHERE `kodikos` = " spawk_escape(kodikos)

	if (spawk_submit(query) != 3)
	pd_fatal(kodikos ": cannot locate `kartel`.`parametros`")

	if (!spawk_fetchone(row))
	pd_fatal(kodikos ": `kartel`.`parametros` not found")

	return row[0]
}

function kartel_parametros_set(kodikos, timi,		query, row) {
	query = "UPDATE `kartel`.`parametros` " \
		"SET `timi` = " spawk_escape(timi) \
		" WHERE `kodikos` = " spawk_escape(kodikos)

	if (spawk_submit(query) != 2)
	pd_fatal(kodikos ": cannot set `kartel`.`parametros` to >>" timi "<<")
}

# Η fucntion "kartel_ipalilos_fetch" δέχεται ως παράμετρο ένα array όπου είναι
# συμπληρωμένο το index "kodikos" με τιμή τον κωδικό υπαλλήλου, και επιχειρεί να
# προσπελάσει τον συγκεκριμένο υπάλληλο γεμίζοντας το array με τα υπόλοιπα
# πεδία του υπαλλήλου. Το array το οποίο θα γεμίσει με τα στοιχεία τού
# υπαλλήλου ονομάζεται array επιστροφής.
#
# Προαιρετικά μπορούμε να περάσουμε μέσω του array επιστροφής και τα στοιχεία
# με indices "metavoliFetch" και "adiaFetch", με σκοπό να επιστραφούν ως
# στοιχεία τού array επιστροφής διάφορες παράμετροι του υπαλλήλου που προκύπτουν
# από τον πίνακα μεταβολών σε κάποια συγκεκριμένη ημερομηνία, και οι άδειες του
# υπαλλήλου που εμπλέκονται στη συγκεκριμένη ημερομηνία. Μπορούμε να περάσουμε
# την εν λόγω ημερομηνία στο στοιχείο με index "dateFetch" του array επιστροφής,
# ενώ αν δεν περάσουμε ημερομηνία θα υποτεθεί (και θα συμπληρωθεί στο array) η
# τρέχουσα ημερομηνία.
#
# Σε περίπτωση που δεν εντοπιστεί ο υπάλληλος ή προκύψει οποιοδήποτε πρόβλημα
# κατά την ανάκτηση των στοιχείων του υπαλλήλου, η function επιστρέφει την τιμή
# 1 και το array επιστροφής παραμένει αναλλοίωτο. Αν προκύψει πρόβλημα κατά την
# ανάκτηση των παραμέτρων τού υπαλλήλου που προκύπτουν από τον πίνακα μεταβολών,
# η function επιστρέφει 2, ενώ αν προκύψει πρόβλημα κατά την ανάκτηση των αδειών
# τού υπαλλήλου, η function επιστρέφει 3.
#
# Στην περίπτωση που δεν παρουσιαστεί οποιοδήποτε πρόβλημα, η function
# επιστρέφει 0.

function kartel_ipalilos_fetch(ipalilos,		indata, query) {
	# Αντιγράφουμε το array επιστροφής σε προσωρινό local array
	# και κατόπιν διαγράφουμε όλα τα στοιχεία τού array επιστροφής.

	pd_aclone(indata, ipalilos)
	delete ipalilos

	query = "SELECT * FROM " kartel_erpotadb("ipalilos") \
		" WHERE `kodikos` = " indata["kodikos"]

	# Σε περίπτωση αποτυχίας, επαναφέρουμε το array επιστροφής στην
	# κατάσταση πού το παραλάβαμε και επιστρέφουμε 1.

	if ((spawk_submit(query, 2) != 3) || (!spawk_fetchone(ipalilos))) {
		pd_aclone(ipalilos, indata)
		return 1
	}

	# Αν έχει περαστεί ημερομηνία ανάκτησης των στοιχείων μέσω τού
	# στοιχείου "dateFetch" τού array επιστροφής, τότε χρησιμοποιούμε
	# την συγκεκριμένη ημερομηνία, αλλιώς υποθέτουμε την τρέχουσα
	# ημερομηνία.

	ipalilos["dateFetch"] = ("dateFetch" in indata ?
		indata["dateFetch"] : strftime("%Y-%m-%d"))

	if (("metavoliFetch" in indata) &&
		kartel_ipalilos_metavoli_fetch(ipalilos)) {
		pd_aclone(ipalilos, indata)
		return 2
	}

	if (("adiaFetch" in indata) &&
		kartel_ipalilos_adia_fetch(ipalilos)) {
		pd_aclone(ipalilos, indata)
		return 3
	}

	return 0
}

function kartel_ipalilos_metavoli_fetch(ipalilos,		sdate, \
	metavoli) {

	delete ipalilos["ipidie"]
	delete ipalilos["ipitmi"]
	delete ipalilos["ipigra"]
	delete ipalilos["karta"]
	delete ipalilos["orario"]

	sdate = spawk_escape(ipalilos["dateFetch"])
	query = "SELECT `idos`, `timi`" \
		" FROM " kartel_erpotadb("metavoli") \
		" WHERE `ipalilos` = " ipalilos["kodikos"] \
		" AND `efarmogi` <= " sdate \
		" AND ((`lixi` IS NULL) OR (`lixi` > " sdate "))" \
		" ORDER BY `idos`, `efarmogi`"

	if (spawk_submit(query, 2) != 3)
	return 1

	while (spawk_fetchrow(metavoli)) {
		if (metavoli["idos"] == "ΔΙΕΥΘΥΝΣΗ") {
			ipalilos["ipidie"] = metavoli["timi"]
			continue
		}

		if (metavoli["idos"] == "ΤΜΗΜΑ") {
			ipalilos["ipitmi"] = metavoli["timi"]
			continue
		}

		if (metavoli["idos"] == "ΓΡΑΦΕΙΟ") {
			ipalilos["ipigra"] = metavoli["timi"]
			continue
		}

		if (metavoli["idos"] == "ΚΑΡΤΑ") {
			ipalilos["karta"] = metavoli["timi"]
			continue
		}
	}

	return 0
}

function kartel_ipalilos_adia_fetch(ipalilos,		sdate, adia) {
	delete ipalilos["adia"]
	ipalilos["adia"][""][""]
	delete ipalilos["adia"][""]
	return 0

	sdate = spawk_escape(ipalilos["dateFetch"])

	query = "SELECT `idos`, `apo`, `eos`, `meres`" \
		" FROM " kartel_erpotadb("adiadcd") \
		" WHERE `ipalilos` = " ipalilos["kodikos"] \
		" AND `apo` <= " sdate \
		" AND ((`eos` IS NULL) OR (`eos` >= " sdate "))" \
		" ORDER BY `idos`, `efarmogi`"

	if (spawk_submit(query, 2) != 3)
	return 1

	while (spawk_fetchrow(adia)) {
		ipalilos["prm"][adia["idos"]][""]
		delete ipalilos["prm"][adia["idos"]][""]

		pd_aclone(ipalilos["prm"][adia["idos"]], adia)
		delete ipalilos["prm"][adia["idos"]]["idos"]
	}

	return 0
}
