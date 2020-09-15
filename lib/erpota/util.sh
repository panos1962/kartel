#!/usr/bin/env bash

###############################################################################@

[ -z "${PANDORA_BASEDIR}" ] &&
PANDORA_BASEDIR="/var/opt/pandora"

[ -z "${KARTEL_BASEDIR}" ] &&
KARTEL_BASEDIR="/var/opt/kartel"

! . "${KARTEL_BASEDIR}/lib/kartel.sh" &&
exit 2

! . "${KARTEL_BASEDIR}/lib/erpota.sh" &&
exit 2

kartellibdir="${KARTEL_BASEDIR}/lib/kartel"
erpotalibdir="${KARTEL_BASEDIR}/lib/erpota"

###############################################################################@

mode_check() {
	[ -n "${dbload}" ] &&
	return

	[ -n "${keep_file_copy}" ] &&
	return

	[ -n "${print}" ] &&
	return
}

###############################################################################@

get_data_ipalilos() {
	[ -z "${keep_file_copy}" ] &&
	[ -n "${ipalilos_file}" ] &&
	proc_data_ipalilos "${ipalilos_file}" &&
	return

	cat >"${tmp_sqlquery}" <<+++
SET LINESIZE 2000

SET TRANSACTION ISOLATION LEVEL READ COMMITTED
;

SELECT
	TO_NUMBER("KODIKOS") "KODIKOS",
	TRIM("EPONYMO"),
	TRIM("ONOMA"),
	TRIM("PATRONYMO"),
	TO_CHAR("HMGENDATE", 'YYYY-MM-DD'),
	TRIM("AFM"),
	TRIM("EMAIL"),
	TRIM("EMAILESOT"),
	TO_CHAR("ARXPROSLDATE", 'YYYY-MM-DD'),
	TO_CHAR("PROSLDATE", 'YYYY-MM-DD'),
	TO_CHAR("DIORDATE", 'YYYY-MM-DD'),
	TO_CHAR("APOXDATE", 'YYYY-MM-DD'),
	"KATASTASHFLAG"

FROM "MISTERGAZ"

WHERE "COM_ID" = 61
AND "KODIKOS" > 0
+++

	[ -n "${katastasi}" ] &&
	echo "AND \"KATASTASHFLAG\" = 1" >>"${tmp_sqlquery}"

	[ -n "${test}" ] &&
	echo "AND ((ROWNUM <= ${test}) OR (\"KODIKOS\" = 3307))" >>"${tmp_sqlquery}"

	echo ";" >>"${tmp_sqlquery}"

	[ -n "${verbose}" ] &&
	pd_ttymsg "$(pd_tmsg reset dim)Requesting \
'$(pd_tmsg reset bold fblue)ipalilos$(pd_tmsg reset dim)' rows from \
'$(pd_tmsg reset bold fyellow)erpota$(pd_tmsg reset dim)'…$(pd_tmsg)"

	! sqlerpota "${tmp_sqlquery}" >"${tmp_sqloutput}" &&
	pd_exit "sqlerr"

	proc_data_ipalilos "${tmp_sqloutput}"
}

proc_data_ipalilos() {
	local bademail=
	local opts=

	bademail="${KARTEL_BASEDIR}/lib/erpota/bademail"
	[ -r "${bademail}" ] &&
	opts+=" -v bademail=${bademail}"

	! awk ${awkopts} ${opts} \
		-f "${erpotalibdir}/ipalilos.awk" "$@" >"${tmp_ipalilos}" &&
	pd_exit "dataerr"

	[ -z "${keep_file_copy}" ] &&
	return 0

	[ -z "${ipalilos_file}" ] &&
	return 0

	! cat "$@" >"${ipalilos_file}" &&
	pd_exit "filecperr"

	pd_ttymsg "$(wc -l "${ipalilos_file}")"
	return 0

}

get_data_metavoli() {
	[ -z "${keep_file_copy}" ] &&
	[ -n "${metavoli_file}" ] &&
	proc_data_metavoli "${metavoli_file}" &&
	return

	[ -n "${test}" ] &&
	return

	cat >"${tmp_sqlquery}" <<+++
SET LINESIZE 1000

SET TRANSACTION ISOLATION LEVEL READ COMMITTED
;

SELECT
	TRIM("MEZ"."KODIKOS"),				-- κωδικός υπαλλήλου
	TO_NUMBER("MRM"."KODIKOS"),			-- είδος μεταβολής
	TO_NUMBER("MEBD"."MFI_ID"),			-- τύπος είδους μεταβολής
	TRIM("MEBD"."DESCRIPTION"),			-- περιγραφή τύπου είδους μεταβολής
	TO_CHAR("MEB"."BEGINDATE", 'YYYY-MM-DD'),	-- ημερομηνία εφαρμογής
	TO_CHAR("MEB"."ENDDATE", 'YYYY-MM-DD'),		-- ημερομηνία λήξης
	TRIM("MEBD"."NEWVALUE"),			-- τιμή μεταβολής
	TRIM("MEBD"."NEWVALUE_DESCRIPTION")		-- αποκωδικοποίηση τιμής μεταβολής

FROM
	"MISTERGAZ" "MEZ",
	"MISTMETABERGAZ" "MEB",
	"MISTVMETABERGAZDTL" "MEBD",
	"MISTRECMETABOL" "MRM"

WHERE "MEZ"."COM_ID" = 61
AND "MEBD"."MEB_ID" = "MEB"."ID"
AND "MEB"."MEZ_ID" = "MEZ"."ID"
AND "MEB"."MRM_ID" = "MRM"."ID"
AND (TO_NUMBER("MRM"."KODIKOS"), TO_NUMBER("MEBD"."MFI_ID")) IN (
	(26, 2),
	(26, 3),
	(26, 4),
	(200, 342)
)
AND "MEB"."BEGINDATE" IS NOT NULL
AND (("MEB"."ENDDATE" IS NULL) OR
	("MEB"."ENDDATE" > TO_DATE('${kartel_begin_date}','YYYY-MM-DD')))
+++

	[ -n "${katastasi}" ] &&
	cat >>"${tmp_sqlquery}" <<+++
AND "MEB"."MEZ_ID" IN (
	SELECT "MEZ"."ID"
	FROM "MISTERGAZ" "MEZ"
	WHERE "MEZ"."COM_ID" = 61
	AND "MEZ"."KATASTASHFLAG" = 1
)
+++

	[ -n "${test}" ] &&
	echo "AND ROWNUM <= ${test}" >>"${tmp_sqlquery}"

	echo ";" >>"${tmp_sqlquery}"

	[ -n "${verbose}" ] &&
	pd_ttymsg "$(pd_tmsg reset dim)Requesting \
'$(pd_tmsg reset bold fblue)metavoli$(pd_tmsg reset dim)' rows from \
'$(pd_tmsg reset bold fyellow)erpota$(pd_tmsg reset dim)' where \
'$(pd_tmsg reset fcyan)lixi$(pd_tmsg reset dim)' > \
$(pd_tmsg reset fcyan)${kartel_begin_date}$(pd_tmsg reset dim)…$(pd_tmsg)"

	! sqlerpota "${tmp_sqlquery}" >"${tmp_sqloutput}" &&
	pd_exit "sqlerr"

	proc_data_metavoli "${tmp_sqloutput}"
}

proc_data_metavoli() {
	! awk ${awkopts} -v ipiresia="${tmp_ipiresia}" \
		-f "${erpotalibdir}/metavoli.awk" "$@" >"${tmp_metavoli}" &&
	pd_exit "dataerr"

	[ -z "${keep_file_copy}" ] &&
	return 0

	[ -z "${metavoli_file}" ] &&
	return 0

	! cat "$@" >"${metavoli_file}" &&
	pd_exit "filecperr"

	pd_ttymsg "$(wc -l "${metavoli_file}")"
	return 0
}

###############################################################################@

file_name_check() {
	[ -z "${file_copy_dir}" ] &&
	file_copy_dir="."

	[ -n "${ipalilos_file}" ] &&
	[ -z "${ipalilos}" ] &&
	pd_errmsg "${ipalilos_file}: file name unset" &&
	ipalilos_file=

	[ -n "${metavoli_file}" ] &&
	[ -z "${metavoli}" ] &&
	pd_errmsg "${metavoli_file}: file name unset" &&
	metavoli_file=

	[ -n "${ipalilos_file}" ] &&
	[ "${ipalilos_file:0:1}" != "/" ] &&
	[ "${file_copy_dir}" != "." ] &&
	ipalilos_file="${file_copy_dir}/${ipalilos_file}"

	[ -n "${metavoli_file}" ] &&
	[ "${metavoli_file:0:1}" != "/" ] &&
	[ "${file_copy_dir}" != "." ] &&
	metavoli_file="${file_copy_dir}/${metavoli_file}"
}

file_copy_check() {
	local err=

	[ -z "${keep_file_copy}" ] &&
	return

	! [ -w "${file_copy_dir}" ] &&
	pd_errmsg "${file_copy_dir}: no write permission" &&
	pd_exit "filecperr"

	[ -n "${ipalilos_file}" ] &&
	[ -f "${ipalilos_file}" ] &&
	! rm -f "${ipalilos_file}" ] &&
	pd_errmsg "${ipalilos_file}: cannot remove file" &&
	err="yes"

	[ -n "${metavoli_file}" ] &&
	[ -f "${metavoli_file}" ] &&
	! rm -f "${metavoli_file}" ] &&
	pd_errmsg "${metavoli_file}: cannot remove file" &&
	err="yes"

	[ -n "${err}" ] &&
	pd_exit "filecperr"
}

file_load_check() {
	local err=

	[ -n "${keep_file_copy}" ] &&
	return

	! [ -r "${file_copy_dir}" ] &&
	pd_errmsg "${file_copy_dir}: no read permission" &&
	pd_exit "filelderr"

	[ -n "${ipalilos_file}" ] &&
	! [ -r "${ipalilos_file}" ] &&
	pd_errmsg "${ipalilos_file}: cannot read file" &&
	err="yes"

	[ -n "${metavoli_file}" ] &&
	! [ -r "${metavoli_file}" ] &&
	pd_errmsg "${metavoli_file}: cannot read file" &&
	err="yes"

	[ -n "${err}" ] &&
	pd_exit "filelderr"
}

###############################################################################@

# Κατά τη διάρκεια της ενημέρωσης της έκδοσης της τοπικής database "erpota" που
# έχει σειρά να ενημερωθεί (υπάρχουν οι εκδόσεις 1 και 2 που χρησιμοποιούνται
# εκ περιτροπής), θα πρέπει με κάποιον τρόπο να αποφύγουμε δεύτερη, παράλληλη
# ενημέρωση της database "erpota". Για το σκοπό αυτό χρησιμοποιούμε κλείδωμα
# της διαδικασίας με χρήση του directory "dbload.lck".

# Το πλήρες pathname του lock directory περιέχεται στην global μεταβλητή
# "dbload_locker" και μάλιστα κάνουμε την εξής σύμβαση: αν η συγκεκριμένη
# μεταβλητή δεν είναι ορισμένη, τότε δεν υπάρχει ενεργό κλείδωμα, αλλιώς το
# κλείδωμα είναι υπαρκτό και σε περίπτωση βίαιης διακοπής της ενημέρωσης θα
# πρέπει να το αποσύρουμε.

unset dbload_locker

# Η function "dbload_lock" καλέιται κατά την αρχή της διαδικασίας ενημέρωσης
# της τοπικής database "erpota" από την απομεμακρυσμένη ομώνυμη database με
# σκοπό να αποφύγουμε την περίπτωση δεύτερης, παράλληλης ενημέρωσης, όπως
# εξηγήσαμε παραπάνω.

dbload_lock() {
	# Καταχωρούμε στη μεταβλητή "dbload_locker" το όνομα του lock
	# directory, ώστε αν όλα πάνε καλά να γνωρίζουμε ότι υπάρχει
	# ενεργό κλείδωμα.

	dbload_locker="${erpotalibdir}/dbload.lck"

	# Αν καταφέρουμε να δημιουργήσουμε το lock directory, τότε σημαίνει
	# ότι δεν υπάρχει άλλη παρόμοια ενημέρωση σε εξέλιξη.

	mkdir "${dbload_locker}" 2>/dev/null &&
	return 0

	# Η διαδικασία δημιουργίας τού lock directory απέτυχε, πράγμα που
	# σημαίνει ότι το directory υφίσταται ήδη, τουτέστιν υπάρχει άλλη
	# παρόμοια ενημέρωση σε εξέλιξη.

	unset dbload_locker
	pd_errmsg "dbload is already in progress!"
	return 1
}

dbload_unlock() {
	[ -z "${dbload_locker}" ] &&
	return 0

	[ ! -d "${dbload_locker}" ] &&
	unset dbload_locker &&
	return 0

	rmdir "${dbload_locker}" 2>/dev/null

	[ ! -d "${dbload_locker}" ] &&
	unset dbload_locker &&
	return 0

	unset dbload_locker &&
	pd_errmsg "dbload failed to unlock!"
	return 1
}

pd_before_exit() {
	dbload_unlock
	return 0
}

dbload_check() {
	[ -z "${dbload}" ] &&
	return

	# Έχουμε διαπιστώσει ότι το πρόγραμμα θα ενημερώσει την τοπική database
	# "erpota", ή τα τοπικά αρχεία δεδομένων. Η ενημέρωση είναι καθολική,
	# δηλαδή όλοι οι πίνακες της database αδειάζουν (truncate) και κατόπιν
	# φορτώνονται εκ νέου φρέσκα δεδομένα των πινάκων που μας ενδιαφέρουν.

	ipalilos="yes"
	metavoli="yes"

	dbload_lock &&
	return

	pd_exit "lockerr"
}

###############################################################################@

awk_settings() {
	unset awkopts
	awkopts+=" -v pd_progname=${pd_progname}"
	awkopts+=" -v verbose=${verbose}"
	awkopts+=" -v nullwarn=${nullwarn}"
	awkopts+=" -i ${PANDORA_BASEDIR}/lib/pandora.awk"
	awkopts+=" -i ${erpotalibdir}/util.awk"
}

test_set() {
	[ -z "$1" ] &&
	set 10

	! pd_isinteger "$1" 1 &&
	pd_errmsg "$1: invalid number of test lines" &&
	return 1

	test="$1"
	return 0

}

katastasi_set() {
	case "$1" in
	0)
		katastasi=
		;;
	1)
		katastasi=1
		;;
	*)
		pd_errmsg "$1: invalid katastasi"
		return 1
	esac

	return 0
}

sqlerpota() {
	if [ -z "${erpota_dbconf}" ]; then
		[ -z "${erpotadbcf}" ] &&
		erpotadbcf="${KARTEL_BASEDIR}/lib/conf/erpotadb.cf"

		! erpota_dbconf_set "${erpotadbcf}" &&
		pd_exit "conferr"
	fi

	"${PANDORA_BASEDIR}"/bin/pd_sqlplus --conf="${erpota_dbconf}" --batch "$@" &&
	return 0

	pd_errmsg "SQL errors encountered"
	pd_exit "sqlerr"
}

###############################################################################@

print_data() {
	[ -z "${print}" ] &&
	return

	[ -n "${ipalilos}" ] &&
	echo "@ipalilos@" &&
	cat "${tmp_ipalilos}"

	[ -n "${metavoli}" ] &&
	echo "@ipiresia@" &&
	cat "${tmp_ipiresia}" &&
	echo "@metavoli@" &&
	cat "${tmp_metavoli}"
}

load_data() {
	local awkargs=
	local success=

	[ -z "${dbload}" ] &&
	return 0

	awkargs+="${awkopts}"
	awkargs+=" -i ${KARTEL_BASEDIR}/lib/karteldb.awk"
	awkargs+=" -v relations=${erpotalibdir}/relations.sql"
	awkargs+=" -v testmode=${test}"
	awkargs+=" -v ipalilos=${tmp_ipalilos}"
	awkargs+=" -v ipiresia=${tmp_ipiresia}"
	awkargs+=" -v metavoli=${tmp_metavoli}"

	awkargs+=" -f ${erpotalibdir}/dbload.awk"

	# Έχουμε ήδη παραλάβει τα δεδομένα από την απομεμακρυσμένη database
	# "erpota" και ξεκινάμε της διαδικασία «φρεσκαρίσματος» της τοπικής
	# ομώνυμης database. Υπενθυμίζουμε ότι αν η τρέχουσα έκδοση της τοπικής
	# database "erpota" είναι η "1", τότε ενημερώνουμε την έκδοση "2", και
	# το αντίστροφο.

	awk ${awkargs} &&
	dbload_unlock &&
	return 0
	
	pd_errmsg "dbload failed" &&
	pd_exit "dbloaderr"
}
