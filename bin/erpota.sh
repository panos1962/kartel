#!/usr/bin/env bash

# Το παρόν πρόγραμμα ενημερώνει την τοπική βάση δεδομένων με στοιχεία τα οποία
# λαμβάνει από το απομεμακρυσμένο πληροφοριακό σύστημα ΟΠΣΟΥ, και συγκεκριμένα
# από την εκεί βάση δεδομένων "erpota". Τα στοιχεία που λαμβάνει δεν είναι
# προοδευτικά, αλλά κάθε φορά λαμβάνει συγκεκριμένα πεδία για όλες τις εγγραφές
# του πίνακα εργαζομένων, όλες τις μεταβολές τύπου 26/2 (ΔΙΕΥΘΥΝΣΗ), 26/3
# (ΤΜΗΜΑ), 26/4 (ΓΡΑΦΕΙΟ), 200/342 (ΑΡ. ΚΑΡΤΑΣ ΕΙΣΟΔΟΥ/ΕΞΟΔΟΥ).
#
# Υπενθυμίζουμε ότι η τοπική βάση δεδομένων είναι MySQL database με default
# όνομα "kartel", ενώ η απομεμακρυσμένη βάση δεδομένων του ΟΠΣΟΥ είναι ORACLE
# database, ενώ το schema που μας ενδιαφέρει είναι το schema "erpota". Για να
# λειτουργήσει το πρόγραμμα, θα πρέπει να υπάρχουν configuration files στα οποία
# να καθορίζονται τα ονόματα των εν λόγω βάσεων δεδομένων και τα σχετικά
# credentials.
#
# Το πρόγραμμα πρέπει να τρέχει σε τακτά χρονικά διαστήματα, ώστε οι πίνακες
# τής τοπικής βάσης δεδομένων, που αφορούν στα στοιχεία προσωπικού που αφορούν
# το ωράριο και τα παρουσιολόγια, να είναι ενημερωμένα τουλάχιστον σε επίπεδο
# ημέρας. Μια καλή επιλογή είναι να τρέχει το πρόγραμμα μέσω του cron, κάπου
# τις πρώτες πρωινές ώρες κάθε ημέρας.

[ -z "${KARTEL_BASEDIR}" ] &&
KARTEL_BASEDIR="/var/opt/kartel"

pd_usagemsg="[OPTIONS] [ARGS...]"
pd_tmpdir="${KARTEL_BASEDIR}/tmp"
pd_tmpmax=5

! . "${KARTEL_BASEDIR}/lib/erpota/util.sh" &&
exit 2

pd_seterrcode \
	"conferr" \
	"sqlerr" \
	"dataerr" \
	"dbloaderr" \
	"filecperr" \
	"filelderr" \
	"lockerr" \
	""

# Θα χρησιμοποιήσουμε αρκετά προσωρινά αρχεία. Πρώτα από όλα ορίζουμε δύο
# αρχεία που αφορούν στα SQL queries που υποβάλλονται στην απομεμακρυσμένη
# database του ΟΠΣΟΥ. Το πρώτο αρχείο θα περιέχει το query, ενώ το δεύτερο
# θα περιέχει τα ζητούμενα στοιχεία.

tmp_sqlquery="${pd_tmpname[1]}"
tmp_sqloutput="${pd_tmpname[2]}"

# Ακολουθούν προσωρινά αρχεία στα οποία θα συλλέγονται τα στοιχεία που θα
# επιστρέφονται από το ΟΠΣΟΥ, αφού πρώτα γίνει ένας πρώτος έλεγχος και μια
# πρώτη επεξεργασία των στοιχείων αυτών. Τα ονόματα των αρχείων αυτών είναι
# ταυτόσημα με τους πίνακες τους οποίους αφορούν.

tmp_ipalilos="${pd_tmpname[3]}"
tmp_metavoli="${pd_tmpname[4]}"
tmp_ipiresia="${pd_tmpname[5]}"

# Καλού-κακού μηδενίζουμε τα αρχεία δεομένων που πρόκειται να παραλάβουμε από
# το ΟΠΣΟΥ.

>"${tmp_ipalilos}"
>"${tmp_metavoli}"
>"${tmp_ipiresia}"

pd_sigtrap

eval set -- "$(pd_parseopts \
"imAk:vqsn:E:K:plt" \
"ipalilos:,metavoli:,all,katastasi:,
file-copy-dir:,keep-file-copy:,
ipalilos-file:,metavoli-file:,
verbose,quiet,silent,nullwarn:,erpotadbcf:,karteldbcf:,
print,dbload,test,lines:" "$@")"
[ $1 -ne 0 ] && pd_usage
shift

ipalilos=
metavoli=
katastasi=

file_copy_dir=
keep_file_copy=
ipalilos_file=
metavoli_file=

verbose="yes"
nullwarn="yes"

erpotadbcf=
karteldbcf=

print=
dbload=
test=

error=

for arg in "$@"
do

	case "${arg}" in
	# Ακολουθούν yes/no flags ποου δείχνουν με ποιους πίνακες θα
	# ασχοληθούμε.

	-i)
		ipalilos="yes"
		shift 1
		;;

	--ipalilos)
		! ipalilos="$(pd_yesno "$2" x)" &&
		pd_errmsg "$1: invalid '${arg}' value" &&
		error="yes"
		shift 2
		;;
	-m)
		metavoli="yes"
		shift 1
		;;
	--metavoli)
		! metavoli="$(pd_yesno "$2" x)" &&
		pd_errmsg "$1: invalid '${arg}' value" &&
		error="yes"
		shift 2
		;;
	-A|--all)
		ipalilos="yes"
		metavoli="yes"
		shift
		;;

	# Η παράμετρος "katastasi" μπορεί να έχει τιμή 1 οπότε περιοριζόμαστε
	# στους «ενεργούς» υπαλλήλους, ή 0 οπότε περιοριζόμαστε στους υπόλοιπους
	# υπαλλήλους. By default η παράμετρος είναι ακαθόριστη, που σημαίνει ότι
	# συμμετέχουν όλοι οι υπάλληλοι, ανεξαρτήτως αν είναι ενεργοί ή όχι.

	-k|--katastasi)
		! katastasi_set "$2" &&
		error="yes"
		shift 2
		;;

	# Υπάρχει περίπτωση να φορτώσουμε ήδη κατεβασμένα δεδομένα τής
	# απομεμακρυσμένης βάσης δεδομένων "erpota". Αυτό καθορίζεται από τις
	# global παραμέτρους "ipalilos_file", "metavoli_file" και "adia_file",
	# οι οποίες τίθενται με τις options "ipalilos-file", "metavoli-file" και
	# "adia-file" αντίστοιχα. Εφόσον, λοιπόν έχουν τεθεί όλες ή κάποιες από
	# τις παραπάνω παραμέτρους, τότε σημαίνει ότι τα δεδομένα των φερωνύμων
	# πινάκων δεν θα ζητηθούν από την remote "erpota" database, αλλά ήδη
	# έχουν παραληφθεί και βρίσκονται στα εν λόγω files.
	#
	# Με την παράμετρο "file_copy_dir" μπορούμε να καθορίσουμε το directory
	# στο οποίο βρίσκονται (ή θα δημιουργηθούν) τα αρχεία δεδομένων, και
	# τίθεται με την option "file-copy-dir". Αν δεν τεθεί, υποτίθεται το
	# directory στο οποίο εκκίνησε το process, ενώ αν τα ονόματα των αρχείων
	# είναι full pathnames, τότε χρησιμοποιούνται αυτούσια. Προκειμένου για
	# το φόρτωμα των δεδομένων, θα πρέπει τόσο το directory όσο και τα
	# αρχεία να είναι προσβάσιμα, ενώ για τη δημιουργία των αρχείων αυτών θα
	# πρέπει να υπάρχει κατάλληλη πρόσβαση στο σχετικό directory.

	--file-copy-dir)
		file_copy_dir="$2"
		shift 2
		;;

	# Η παράμετρος "keep_file_copy" είναι yes/no flag και τίθεται με την
	# option "keep-file-copy". Με την εν λόγω παράμετρο καθορίζουμε αν τα
	# δεδομένα που θα παραληφθούν από την απομεμακρυσμένη βάση δεδομένων
	# "erpota", θα κρατηθούν σε τοπικά αρχεία. Αν η παράμετρος δεν είναι
	# αληθής, τότε δεν θα κρατηθούν δεδομένα σε τοπικά αρχεία, ενώ αν είναι
	# αληθής, τότε θα κρατηθούν δεδομένα στα αρχεία που έχουν καθοριστεί
	# με τις σχετικές options στο command line.
	#
	# Σημαντική παρενέργεια της εν λόγω flag είναι ότι αν έχει τεθεί, τότε
	# θα ζητηθούν δεδομένα από την απομεμακρυσμένη βάση δεδομένων "erpota"
	# και θα κρατηθούν σε αρχεία τα δεδομένα των πινάκων για τα οποία έχουμε
	# καθορίσει ονόματα αρχείων.

	--keep-file-copy)
		! keep_file_copy="$(pd_yesno "$2" x)" &&
		pd_errmsg "$1: invalid '${arg}' value" &&
		error="yes"
		shift 2
		;;

	# Με τις options που ακολουθούν καθορίζουμε τα ονόματα των τοπικών
	# αρχείων στα οποία βρίσκονται, ή πρόκειται να αποθηκευτούν, τα στοιχεία
	# των φερωνύμων πινάκων.

	--ipalilos-file)
		ipalilos_file="$2"
		shift 2
		;;
	--metavoli-file)
		metavoli_file="$2"
		shift 2
		;;

	# Η παράμετρος "verbose" δείχνει αν το πρόγραμμα θα είναι «ομιλητικό»
	# κατά τη λειτουργία του, ή όχι. Αυτό σημαίνει ότι το πρόγραμμα θα
	# εκτυπώνει στην οθόνη του τερματικού μας μηνύματα προόδου των εργασιών
	# που επιτελεί.

	-v|--verbose)
		verbose="yes"
		shift 1
		;;

	-q|-s|--quiet|--silent)
		verbose=
		shift 1
		;;

	# Το πρόγραμμα by default μας ενημερώνει για null τιμές πεδίων που είναι
	# «ύποπτες», π.χ. ΑΦΜ υπαλλήλου, ημερομηνία αρχικής εργασιακής σχέσης
	# του υπαλλήλου με τον οργανισμό κλπ. Αν οι συγκεκριμένες παθογένειες
	# είναι εν γνώσει μας και δεν επιθυμούμε να βλέπουμε ξανά και ξανά τα
	# σχετικά μηνύματα, τότε μπορούμε να θέσουμε ανάλογα την τιμή τής
	# παραμέτρου "nullwarn" με την ομώνυμη option.

	-n|--nullwarn)
		! nullwarn="$(pd_yesno "$2" x)" &&
		pd_errmsg "$1: invalid '${arg}' value" &&
		error="yes"
		shift 2
		;;

	# Ακολουθούν options με τις οποίες καθορίζουμε τα configuration files
	# για την απομεμακρυσμένη βάση δεδομένων "erpota" (ORACLE) και για την
	# τοπική βάση δεδομένων "kartel", "erpota1" και "erpota2" (MySQL).
	# Παραδείγματα των αρχείων αυτών θα βρείτε στο directory "local" με τις
	# default ονομασίες "erpotadb.cf" και "karteldb.cf". Τα configuration
	# files που χρησιμοποιούνται στην πράξη βρίσκονται στο directory "conf",
	# κάτω από το directory "lib" στο directory βάσης τής εφαρμογής, π.χ.
	#
	#	/var/opt/kartel/lib/conf/erpotadb.cf
	#	/var/opt/kartel/lib/conf/karteldb.cf

	-E|--erpotadbcf)
		erpotadbcf="$2"
		shift 2
		;;
	-K|--karteldbcf)
		karteldbcf="$2"
		shift 2
		;;

	# Η παράμετρος "print" τίθεται με την φερώνυμη option και δείχνει αν
	# τα δεδομένα της απομεμακρυσμένης βάσης δεδομένων "erpota" θα
	# εκτυπωθούν στο standard output. Τα δεδομένα εκτυπώνονται για τους
	# πίνακες που έχουν καθοριστεί στο command line και πριν τα δεδομένα
	# εκάστου πίνακα τυπώνεται το όνομα του πίνακα μέσα σε "@".

	-p|--print)
		print="yes"
		shift 1
		;;
	-L|--dbload)
		dbload="yes"
		shift 1
		;;
	-t|--test)
		test_set
		shift
		;;
	--lines)
		test_set "$2"
		shift 2
		;;
	--)
		shift
		;;
	esac
done
unset arg

[ -n "${error}" ] &&
pd_usage

mode_check
dbload_check
file_name_check
file_copy_check
file_load_check
awk_settings

[ -n "${verbose}" ] &&
pd_ttymsg "$(pd_tmsg reset dim)Fetching data from \
'$(pd_tmsg reset bold fyellow)erpota$(pd_tmsg reset dim)'…$(pd_tmsg)"

[ -n "${ipalilos}" ] &&
get_data_ipalilos

[ -n "${metavoli}" ] &&
get_data_metavoli

[ -n "${print}" ] &&
print_data

[ -n "${dbload}" ] &&
load_data

pd_exit
