#!/usr/bin/env awk

# Το παρόν awk script εκτελείται μέσω του προγράμματος "restore.sh", με σκοπό
# την ανάκτηση των εγγραφών του πίνακα `erpota`.`prosvasi` από tsv backup που
# πρέπει να έχει ληφθεί με το αντίστοιχο πρόγραμμα "backup.sh" και βρίσκεται
# στο directory "local/data/erpota" με όνομα "prosvasi.tsv".

BEGIN {
	truncate_prosvasi()
	dataload_prosvasi()
	exit(0)
}

function truncate_prosvasi() {
	if (spawk_submit("TRUNCATE `erpota`.`prosvasi`") != 2)
	pd_fatal("prosvasi: truncate table failed")
}

function dataload_prosvasi(			query) {
	query = "LOAD DATA LOCAL INFILE '" datafile "' " \
		"REPLACE INTO TABLE `erpota`.`prosvasi` " \
		"FIELDS TERMINATED BY '\\t' (" \
			"`ipalilos`, " \
			"`efarmogi`, " \
			"`ipiresia`, " \
			"`idos`, " \
			"`info`, " \
			"`pubkey`, " \
			"`password`" \
		")"

	if (spawk_submit(query) != 2)
	pd_fatal("prosvasi: load data failed")
}
