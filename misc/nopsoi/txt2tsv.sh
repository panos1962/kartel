#!/usr/bin/env bash

# Το παρόν πρόγραμμα διαχειρίζεται τα πρωτογενή δεδομένα που παίρνουμε από
# το database server του ΟΠΣΟΥ. Τα δεδομένα έρχονται με μορφή που δεν είναι
# άμεσα κατάλληλη για data processing, καθώς εμπεριέχουν επικεφαλίδα,
# στατιστικά κλπ. Εξάλλου, ως διαχωριστής στηλών χρησιμοποιείται το pipe.
#
# Το παρόν πρόγραμμα απαλείφει την επικεφαλίδα (δύο πρώτες γραμμές) και τα
# στατιστικά (τελευταίες δύο γραμμές), ενώ μετατρέπει τον διαχωριστή στηλών
# σε tab, ενώ παράλληλα αφαιρεί τα κενά από την αρχή και το τέλος κάθε στήλης.

progname="$(basename $0)"

usage() {
	echo "usage: ${progname} [ -c columns ] [ files... ]" >&2
	exit 1
}

errs=
cols=
date=

while getopts ":c:d:" opt
do
	case "${opt}" in
	c)
		cols="${OPTARG}"
		;;
	d)
		date="${OPTARG},${date}"
		;;
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

sed '1,2d
s; *| *;	;g
s;^ *;;
s; *$;;' "$@" | awk -v cols="${cols}" -v date="${date}" 'BEGIN {
	FS = "\t"
	OFS = "\t"
	nd = split(date, dt, ",")
}

NF != cols {
	next
}

{
	for (i = 1; i < nd; i++)
	$(dt[i]) = dmy2ymd($(dt[i]))

	print
}

function dmy2ymd(dmy,			a, n, y, m, d) {
	n = split(dmy, a, "[^0-9]")

	if (n != 3)
	return ""

	# Κάποιες ημερομηνίες δίνονται ήδη στη μορφή YYYY-MM-DD. Πρόκειται για
        # μία ακόμη τσαπατσουλιά της Neuropublic που μας παρέχει τα αρχεία.
	# Αποφαινόμαστε ελέγχοντας το πρώτο συστατικό της δοθείσης ημερομηνίας.

	if (a[1] > 31) {
		y = a[1]
		m = a[2]
		d = a[3]
	}
	else {
		y = a[3]
		m = a[2]
		d = a[1]
	}

	return sprintf("%04d-%02d-%02d", y, m, d)
}'
