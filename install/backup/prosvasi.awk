#!/usr/bin/env awk

# Το παρόν χρησιμοποιείται μέσω του προγράμματος "install/backup/backup.sh" με
# σκοπό τη λήψη tsv backup του πίνακα `erpota`.`prosvasi`. Οι εγγραφές του
# πίνακα εκτυπώνονται στο standard output, σε μορφή κατάλληλη για να γίνει
# restore μέσω της εντολής LOAD DATA της MySQL.

BEGIN {
	OFS = "\t"
	spawk_null = "\\N"

	query = "SELECT `ipalilos`, `efarmogi`, `ipiresia`, `idos`, " \
		"`info`, `pubkey`, `password` FROM `erpota`.`prosvasi`"

	if (spawk_submit(query, 0) != 3)
	pd_fatal(query ": SQL failed")

	while (spawk_fetchrow(prosvasi, 0))
	print prosvasi[0]

	exit(0)
}
