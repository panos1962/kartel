#!/usr/bin/env bash

# Το παρόν πρόγραμμα παίρνει tsv backup από τον πίνακα `erpota`.`prosvasi` και
# το αποθηκεύει στο directory "local/data/erpota". Στο ίδιο directory μεταφέρει
# επίσης τα τρέχοντα αρχεία "ipalilos.tsv" και "metavoli.tsv" που λαμβάνονται
# από το ΟΠΣΟΥ σε ημερήσια βάση μέσω του cron και τα οποία αποθηκεύονται στο
# directory "erpota" στο home directory του αρμόδιου χρήστη. Αν το όνομα του εν
# λόγω χρήστη δεν είναι "kartel", τότε θα πρέπει να δοθεί ως παράμετρος στο
# command line.

case $# in
0)
	user="kartel"
	;;
1)
	user="$1"
	;;
*)
	echo "usage: $0 [user-name]"
	;;
esac

sourcedir="/home/${user}/erpota"
targetdir="local/data/erpota"

backup_opsoi() {
	local err=
	local i=

	[ ! -d "${sourcedir}" ] &&
	echo "$0: ${sourcedir}: missing directory" >&2 &&
	err="yes"

	[ ! -r "${sourcedir}" ] &&
	echo "$0: ${sourcedir}: cannot read directory" >&2 &&
	err="yes"

	[ ! -x "${sourcedir}" ] &&
	echo "$0: ${sourcedir}: cannot access directory" >&2 &&
	err="yes"

	for i in ipalilos.tsv metavoli.tsv
	do
		i="${sourcedir}/${i}"

		[ -s "${i}" ] &&
		[ -r "${i}" ] &&
		cp "${i}" "${targetdir}"
	done
}

# Backup ΟΠΣΟΥ

backup_opsoi

# Backup `erpota`.`prosvasi`

awk \
-v pd_progname="$0" \
-i "${PANDORA_BASEDIR}/lib/pandora.awk" \
-i "${KARTEL_BASEDIR}/lib/karteldb.awk" \
-f install/backup/prosvasi.awk >"${targetdir}/prosvasi.tsv"
