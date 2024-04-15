#!/usr/bin/env bash

# Το παρόν πρόγραμμα μετατρέπει τα αρχεία "ipalilos.txt" και "metavoli.txt"
# σε μορφή τέτοια που να μπορούν να φορτωθούν στις databases "erpota1" και
# "erpota2". Τα αρχεία "ipalilos.txt" και "metavoli.txt" παράγονται στον
# database server του ΟΠΣΟΥ και αντιγράφονται στον οικείο server (kartel)
# μέσω scp. Τα αρχεία μεταφέρονται καθημερινά περίπου στις 01:00 μετά τα
# μεσάνυχτα με πρωτοβουλία του database server του ΟΠΣΟΥ.
#
# Το παρόν «τρέχει» αυτόματα, κάθε μέρα στις 02:11 μετά τα μεσάνυχτα μέσω
# cron. Η διαδικασία διαρκεί ελάχιστα δευτερόλεπτα, επομένως τα αρχεία θα
# είναι διαθέσιμα στη μορφή που πρέπει ώστε να φορτωθούν στις databases
# "erpota1" ή "epota2". Θυμίζουμε ότι οι δύο databases ενημερώνονται
# εναλλάξ από xron job που «τρέχει» καθημερινά στις 03:11 μετά τα
# μεσάνυχτα από cronjob του χρήστη "kartel".

progname="$(basename $0)"

usage() {
	echo "usage: ${progname}" >&2
	exit 1
}

errs=

while getopts ":" opt
do
	case "${opt}" in
	\:)
		echo "${progname}: -${OPTARG}: missing argument" >&2
		errs=1
		;;
	\?)
		echo "${progname}: -${OPTARG}: invalid option" >&2
		errs=1
		;;
	esac
done

[ -n "${errs}" ] && usage

shift $(expr ${OPTIND} - 1)
[ $# -ne 0 ] && usage

datadir="/home/np"
cd "${datadir}" || exit 2

txt2tsv.sh -c 9 -d 5 ipalilos.txt >ipalilos.tmp || exit 2
txt2tsv.sh -c 8 -d 5,6 metavoli.txt >metavoli.tmp || exit 2

[ -s ipalilos.tmp ] || exit 2
[ -s metavoli.tmp ] || exit 2

mv ipalilos.tmp ipalilos.tsv
mv metavoli.tmp metavoli.tsv

exit 0
