#!/usr/bin/env bash

[ -z "${PANDORA_BASEDIR}" ] &&
PANDORA_BASEDIR="/var/opt/pandora"

[ -z "${KARTEL_BASEDIR}" ] &&
KARTEL_BASEDIR="/var/opt/kartel"

pd_usagemsg="${pd_progname} [ -a from ] [ -A from ] [ -e to ] [ -E to ] [ -t ] [ -y ]
\t[ -C cards ] [ -k rdtype ] [ -n rows ] [ --separator=sep ] [ -r ] [ -R ] [ -S sqlcmd ]
\t[ -T] [ -d delay ] [ -c count ] [ -q ] [ -s ] [ -b ] [ -B ] [ -l ]
\t[ -M mailcf ] [ -m ] \
\t[ -D {c|r|q|d|a} ] [ -w width ]] [ -h ] [ -H ]\n
Try '${pd_progname} -H' for more information"

parseopts() {
	local err=
	local cnt=
	local arg=

	err=0
	cnt=0

	for arg in "$@"
	do
		case "${arg}" in
		-a|--ge)
			setapo "$2" ">=" || err=1
			shift 2
			((cnt+=2))
			;;
		-A|--gt)
			setapo "$2" ">" || err=1
			shift 2
			((cnt+=2))
			;;
		-e|--lt)
			seteos "$2" "<" || err=1
			shift 2
			((cnt+=2))
			;;
		-E|--le)
			seteos "$2" "<=" || err=1
			shift 2
			((cnt+=2))
			;;
		-t|--today)
			today="yes"
			setdfltdate "$(date "+%Y-%m-%d")"
			shift 1
			((cnt+=1))
			;;
		-y|--yesterday)
			yesterday="yes"
			setdfltdate "$(date -d yesterday "+%Y-%m-%d")"
			shift 1
			((cnt+=1))
			;;
		-C|--cards)
			setcards "$2" || err=1
			shift 2
			((cnt+=2))
			;;
		-k|--rdtype)
			setrdtype "$2" || err=1
			shift 2
			((cnt+=2))
			;;
		-r)
			sqlorder="ASC"
			shift 1
			((cnt+=1))
			;;
		--sqlorder)
			sqlorder="$2"
			shift 2
			((cnt+=2))
			;;
		-R)
			srtorder="r"
			shift 1
			((cnt+=1))
			;;
		--sortorder)
			srtorder="$2"
			shift 2
			((cnt+=2))
			;;
		-n|--rows)
			setrows "$2" || err=1
			shift 2
			((cnt+=2))
			;;
		--separator)
			setofs "$2" || err=1
			shift 2
			((cnt+=2))
			;;
		--poll)
			setpoll "${poll:-1}" || err=1
			shift 1
			((cnt+=1))
			;;
		-d|--delay)
			setpoll "$2" || err=1
			shift 2
			((cnt+=2))
			;;
		-c|--count)
			setcount "$2" || err=1
			shift 2
			((cnt+=2))
			;;
		-q|--quiet)
			quiet="yes"
			shift 1
			((cnt+=1))
			;;
		-m|--mail)
			setmail || err=1
			shift 1
			((cnt+=1))
			;;
		-M|--mailcf)
			setmail "$2" || err=1
			shift 2
			((cnt+=2))
			;;
		--database)
			dbmode="$2"
			shift 2
			((cnt+=2))
			;;
		-b)
			dbmode="INSERT"
			shift 1
			((cnt+=1))
			;;
		-B)
			dbmode="REPLACE"
			shift 1
			((cnt+=1))
			;;
		-l)
			dbmode="LOAD"
			shift 1
			((cnt+=1))
			;;
		-p|--print)
			print="yes"
			shift 1
			((cnt+=1))
			;;
		-s|--silent)
			print=
			shift 1
			((cnt+=1))
			;;
		-v|--verbose)
			verbose=
			shift 1
			((cnt+=1))
			;;
		-S|--sqlcmd)
			sqlcmd="$2"
			shift 2
			((cnt+=2))
			;;
		-T|--test)
			test="yes"
			shift 1
			((cnt+=1))
			;;
		-h|--usage)
			usagemore
			;;
		-H|--help)
			. "${KARTEL_BASEDIR}/lib/kartel/help"
			;;
		-D|--debug)
			setdebug "$2" || err=1
			shift 2
			((cnt+=2))
			;;
		-w|--width)
			setdebugwidth "$2" || err=1
			shift 2
			((cnt+=2))
			;;
		--)
			shift
			((cnt+=1))
			;;
		esac
	done

	echo "${cnt}"
	return ${err}
}

# Η function "isinteger" ελέγχει τη μια και μοναδική παράμετρο
# που δέχεται, ως προς το αν πρόκειται για ακέραιο αριθμό ή όχι.
# Αν η παράμετρος είναι κάποιος ακέραιος αριθμός, η function
# επιστρέφει μηδέν, αλλιώς επιστρέφει τιμή διάφορη του μηδενός.

isinteger() {
	local val="${1}"
	local min="${2}"
	local max="${3}"

	[ "${val}" -eq "${val}" ] 2>/dev/null || return 1

	if [ -n "${min}" ]; then
		[ "${val}" -lt "${min}" 2>/dev/null ] || return 1
	fi

	if [ -n "${max}" ]; then
		[ "${val}" -ge "${max}" 2>/dev/null ] || return 1
	fi

	return 0
}

# Η function "isrealnum" είναι παρόμοια με την "isinteger" αλλά
# ελέγχει αν η παράμετρος είναι δεκτή ως floating point number.

isrealnum() {
	awk -v arg="${1}" -v min="${2}" -v max="${3}" 'BEGIN {
	num = arg + 0

	if (num != arg)
	exit(1)

	if (min != "") {
		lim = min + 0

		if (lim != min)
		exit(1)

		if (num < lim)
		exit(1)
	}

	if (max != "") {
		lim = max + 0

		if (lim != max)
		exit(1)

		if (num >= lim)
		exit(1)
	}

	exit(0)
}'
}

pd_before_exit() {
	[ -n "${poll}" ] ||
	return 0

	protiklisi &&
	return 0

	mailmsg "poll stopped"
	return 0
}

debugfix() {
	local gubed=
	local i=

	[ -z "${debug}" ] && return

	if [[ "${debug}" =~ a ]]; then
		gubed="qcrsd"
	elif [[ "${debug}" =~ A ]]; then
		gubed="QCRSD"
	fi

	if [ -z "${gubed}" ]; then
		for i in Q C R S D
		do
			[[ "${debug}" =~ ${i} ]] &&
			gubed+="${i}" &&
			continue

			i="${i,,}"

			[[ "${debug}" =~ ${i} ]] &&
			gubed+="${i}"
		done
	fi

	debug="${gubed}"
	[ -z "${debug}" ] && return

	opts+=" -D${debug}"

	if [ -t 1 ]; then
		debugwidth="$(tput cols)"
	elif [ -n "${debugwidth}" ]; then
		opts+=" -w${debugwidth}"
	else
		debugwidth="76"
	fi

	debugdebug
}

debugdebug() {
	local mode="DEBUG SELF"

	[[ "${debug}" =~ [dD] ]] || return

	debugsec "${mode}" "BEGIN"
	echo "debug: >>${debug}<<
debugwidth: >>${debugwidth}<<"
	debugsec "${mode}" "END"
	debugexit "D"
}

debugsec() {
	local mode="${1}"
	local begend="${2}"
	local dw="${debugwidth}"
	local msg=
	local s=
	local l=
	local i=
	local w=
	local c=
	local af=
	local ab=

	[ -z "${mode}" ] && return

	case "${begend}" in
	[bB]*)
		begend="BEGIN"
		c="+"
		af=3
		ab=6
		;;
	[eE]*)
		begend="END"
		c="-"
		af=3
		ab=4
		;;
	*)
		begend="SECTION"
		c="*"
		;;
	esac

	msg="${mode} DEBUG ${begend}"
	[ -n "${3}" ] && msg+=" (${3})"
	l="${#msg}"
	w="$(( (dw - l - 2) / 2 ))"

	if [ "${w}" -ge 0 ] 2>/dev/null; then
		s=
		for (( i=0; i<${w}; i++ ))
		do
			s+="${c}"
		done
	else
		s="${c}${c}${c}"
	fi

	echo
	[ -t 1 ] && tput -S <<+++
setaf ${af}
bold
setab ${ab}
+++
	echo -en "${s} ${msg} ${s}"
	[ -t 1 ] && tput sgr0
	echo -e "\n"
}

debugexit() {
	[[ "${debug}" =~ "${1}" ]] &&
	pd_exit
}

setapo() {
	local lim="$(isorio "${1}")"

	if [ -z "${lim}" ]; then
		pd_errmsg "$1: invalid lower limit"
		return 1
	fi

	apo="${lim}"
	apo_op="${2}"

	setdfltdate "${apo}"
	return 0
}

seteos() {
	local lim="$(isorio "${1}")"

	if [ -z "${lim}" ]; then
		pd_errmsg "$1: invalid upper limit"
		return 1
	fi

	eos="${lim}"
	eos_op="${2}"

	setdfltdate "${eos}"
	return 0
}

setrdtype() {
	local err=0
	local i=
	local in=
	local out=
	local access=
	local sep=":"

	for i in $(echo "${1^^}" | sed 's;[^A-Z]\+; ;g')
	do
		if pd_partmatch "${i}" "IN"; then
			[[ "${rdtype}" =~ "I" ]] ||
			in="yes"
			continue
		fi

		if pd_partmatch "${i}" "OUT"; then
			[[ "${rdtype}" =~ "O" ]] ||
			out="yes"
			continue
		fi

		if pd_partmatch "${i}" "ACCESS"; then
			[[ "${rdtype}" =~ "A" ]] ||
			access="yes"
			continue
		fi

		pd_errmsg "${i}: invalid reader type"
		err=1
	done

	[ -z "${rdtype}" ] && sep=
	[ -n "${in}" ] && rdtype+="${sep}I" && sep=":"
	[ -n "${out}" ] && rdtype+="${sep}O" && sep=":"
	[ -n "${access}" ] && rdtype+="${sep}A" && sep=":"

	return "${err}"
}

setrows() {
	if [ "${1}" -ge 0 ] 2>/dev/null; then
		rows="${1}"
		return 0
	fi

	pd_errmsg "$1: invalid rows count"
	return 1
}

# Option "-s" of "sqlcmd" accepts just the first character of
# the specified argument as output column separator.

setofs() {
	local sep=

	sep=$(echo "@$1@" | cut -c2)

	if [ "@${sep}@" = "@${1}@" ]; then
		ofs="${sep}"
		return 0
	fi

	pd_errmsg "$1: invalid separator character"
	return 1
}

setpoll() {
	if isrealnum "${1}" 0.2; then
		poll="${1}"
		return 0
	fi

	pd_errmsg "$1: invalid poll delay"
	return 1
}

setcount() {
	if [ "${1}" -ge 0 ] 2>/dev/null; then
		count="${1}"
		return 0
	fi

	pd_errmsg "$1: invalid poll count"
	return 1
}

mailcf_debug() {
	local i=

	echo "mailcf:" >&2

	for i in "${!kartel_mailcf[@]}"
	do
		echo -e "\t>>${i}<< >>${kartel_mailcf["${i}"]}<<"
	done >&2
}

setmail() {
	kartel_mailcf_set "$1" &&
	mail="yes" &&
	return 0

	unset mail
	return 1
}

abortmail() {
	ismailoff &&
	return 0

	unset mail
	unset kartel_mailcf

	pd_errmsg "mail server malfunction" >&2
	return 0
}

ismailoff() {
	[ -z "${mail}" ]
}

# Η function "mailmsg" εκτελεί αποστολή μηνύματος ηλεκτρονικού
# ταχυδρομείου στον mailer, δηλαδή στον χρήστη του mail server
# που είναι υπεύθυνος για την αποστολή ηλεκτρονικών μηνυμάτων
# που αφορούν στο 'kartel'. Ως πρώτη παράμετρο δέχεται το
# subject του μηνύματος, ενώ εάν δοθεί και δεύτερη παράμετρος
# τότε εκλαμβάνεται ως body του μηνύματος, αλλιώς το μήνυμα
# στερείται κειμένου, πράγμα σύνηθες καθώς η ανά χείρας function
# χρησιμοποιείται κυρίως για απλές ενημερώσεις εκκίνησης ή
# διακοπής του polling.

mailmsg() {
	ismailoff &&
	return 0

	sendmail -t <<+++
To: ${kartel_mailcf["from"]}
From: ${kartel_mailcf["from"]}
Subject: $@
+++
	[ $? -eq 0 ] &&
	return 0

	abortmail
	return 1
}

testfix() {
	[ -z "${test}" ] &&
	return

	sqlcmd="${KARTEL_BASEDIR}/lib/kartel/phonysql"
}

mailfix() {
	local error=

	ismailoff &&
	return 0

	[ -z "${karteldbcf}" ] &&
	karteldbcf="${KARTEL_BASEDIR}/lib/conf/karteldb.cf"

	kartel_dbconf_set "${karteldbcf}"

	[ -z "${kartel_mailcf["from"]}" ] &&
	pd_errmsg "mailer undefined" >&2 &&
	error="yes"

	[ -n "${error}" ] &&
	abortmail &&
	return 1

	[ -z "${poll}" ] &&
	return 0

	protiklisi ||
	return 0

	mailmsg "poll started" &&
	return 0

	abortmail
	return 1
}

maildata() {
	ismailoff &&
	return 0

	awk -v pd_progname="${pd_progname}/${FUNCNAME[0]}" \
		-v fs="${ofs}" \
		-i "${PANDORA_BASEDIR}/lib/pandora.awk" \
		-i "${KARTEL_BASEDIR}/lib/karteldb.awk" \
		-f "${KARTEL_BASEDIR}/lib/kartel/mail/maildata.awk" "$@"
}

mailrecpt() {
	local file=
	local awkopts=

	echo '#!/usr/bin/env bash
checkerr() {
	[ "$1" = "0" ] &&
	return

	echo "${FUNCNAME[0]}: $2: mail error" >&2
	exit 1
}'

	awkopts+=" -v pd_progname=${pd_progname}/${FUNCNAME[0]}"

	file="${KARTEL_BASEDIR}/lib/kartel/mail/message.html"
	[ -s "${file}" ] &&
	[ -r "${file}" ] &&
	awkopts+=" -v messagefile=${file}"

	awkopts+=" -v mailer=${kartel_mailcf["from"]}"
	awkopts+=" -v kartelurl=${kartel_dbconf["kartelurl"]}"
	awkopts+=" -i ${PANDORA_BASEDIR}/lib/pandora.awk"
	awkopts+=" -f ${KARTEL_BASEDIR}/lib/kartel/mail/mailrecpt.awk"

	awk -v FS="${ofs}" ${awkopts} "$@"
}

setdebug() {
	if [[ "${1}" =~ ^[QqCcRrSsDdAa]{1,}$ ]]; then
		debug="${debug}${1}"
		return 0
	fi

	pd_errmsg "$1: invalid debug option"
	return 1
}

setdebugwidth() {
	if [ ! "${1}" -ge 0 ] 2>/dev/null; then
		pd_errmsg "$1: invalid debug page width"
		return 1
	fi

	if [ -t 1 ]; then
		pd_errmsg "$1: debug page width ignored"
		return 0
	fi

	debugwidth="${1}"
	return 0
}

setmaxrid() {
	protiklisi &&
	return 0

	if isrowid "${KARTEL_POLL_MAXRID}"; then
		maxrid="${KARTEL_POLL_MAXRID}"
		return 0
	fi

	pd_errmsg "${KARTEL_POLL_MAXRID}: invalid rowid"
	pd_exit "rowiderr"
}

# Η function "protiklisi" χρησιμοποιείται κυρίως σε poll mode και
# επιστρέφει μηδέν εφόσον πρόκειται για την αρχική κλήση τού
# προγράμματος, αλλιώς επιστρέφει τιμή διάφορη του μηδενός.

protiklisi() {
	[ "${pid}" != "${KARTEL_POLL_PID}" ]
}

# Ελέγχουμε αν βρισκόμαστε σε poll mode, πράγμα που σημαίνει ότι θα
# γίνονται επαναλαμβανόμενες κλήσεις στον WIN-PAK server και με σκοπό
# να λαμβάνουμε τα συμβάντα περίπου online. Προχωρούμε στον έλεγχο των
# παραμέτρων που δεν συνάδουν με το poll mode.

pollfix() {
	if [ -z "${poll}" ]; then
		if [ -n "${count}" ]; then
			[ -n "${quiet}" ] && \
			pd_errmsg "${count}: count ignored (not in poll mode)"
			count=
		fi

		# Αν δεν έχει καθοριστεί πλήθος γραμμών, θέτουμε όριο 10 γραμμές.
		# Όταν βρισκόμαστε σε normal mode και όχι σε poll mode, τότε το
		# μηδενικό πλήθος γραμμών σημαίνει ότι θέλουμε όλες τις γραμμές.

		if [ -z "${rows}" ]; then
			rows="10"
		elif [ "${rows}" = "0" ]; then
			rows=
		fi

		return
	fi

	# Βρισκόμαστε σε poll mode και έχει μεγάλη σημασία να γνωρίζουμε αν πρόκειται
	# για την αρχική κλήση του προγράμματος, ή βρισκόμαστε σε κάποιο από τα επόμενα
	# περάσματα. Αυτό θα μας το δείξει η εσωτερική μεταβλητή "KARTEL_POLL_PID" η
	# οποία στο πρώτο πέρασμα δεν έχει τεθεί, ή ακόμη και αν από λάθος ή από δόλο
	# έχει τεθεί είναι απίθανο να έχει τη σωστή τιμή που είναι το process id τού
	# προγράμματος.

	protiklisi || return

	KARTEL_POLL_PASS="0"		# αύξων αριθμός περάσματος

	if [ "${sqlorder}" = "ASC" ]; then
		pd_errmsg "ascenting SQL order ignored (poll mode)"
		sqlorder="DESC"
	fi

	if [ "${srtorder}" = "r" ]; then
		pd_errmsg "ascenting output order ignored (poll mode)"
		srtorder=
	fi

	[ -z "${rows}" ] && rows="10"
}

tydayfix() {
	if [ -n "${today}" ]; then
		opts+=" -t"

		if [ -z "${apo}" ]; then
			if [ -n "${yesterday}" ]; then
				apo="$(date -d yesterday '+%Y-%m-%d')"
			else
				apo="$(date '+%Y-%m-%d')"
			fi

			apocol="GenTime"
			apo_op=">="
		fi

		if [ -z "${eos}" ]; then
			eos="$(date -d tomorrow '+%Y-%m-%d')"
			eoscol="GenTime"
			eos_op="<"
		fi
	elif [ -n "${yesterday}" ]; then
		opts+=" -y"

		if [ -z "${apo}" ]; then
			apo="$(date -d yesterday '+%Y-%m-%d')"
			apocol="GenTime"
			apo_op=">="
		fi

		if [ -z "${eos}" ]; then
			eos="$(date +'%Y-%m-%d')"
			eoscol="GenTime"
			eos_op="<"
		fi
	fi
}

ofsfix() {
	if [ "${ofs}" != "" ]; then
		opts+=" -s \"${ofs}\""
	else
		ofs="	"	# set to tab character
	fi

	if [[ "${debug}" =~ [sS] ]]; then
		echo "ofs: >>${ofs}<<"
		debugexit "S"
	fi
}

apoeoscol() {
	if [[ "${1}" =~ ^[0-9]+$ ]]; then
		echo "RecordID"
	else
		echo "GenTime"
	fi
}

isplaindate() {
	[[ "${1}" =~ ^[12][0-9]{3}-[0-9]{1,2}-[0-9]{1,2}$ ]]
}

isplaintime() {
	[[ "${1}" =~ ^[0-9]{1,2}:[0-9]{1,2}(:[0-9]{1,2}){0,1}$ ]]
}

isdatetime() {
	[[ "${1}" =~ ^[12][0-9]{3}-[0-9]{1,2}-[0-9]{1,2}\ {1,}[0-9]{1,2}(:[0-9]{1,2}){0,2}$ ]]
}

isrowid() {
	[ "${1}" -gt 0 ] 2>/dev/null
}

# Η function "isorio" ελέγχει τη μια και μοναδική παράμετρο που δέχεται
# ως προς το αν αυτή είναι δεκτή είτε ως χρονικό όριο, είτε ως όριο που
# αφορά σε rowid. Αν η παράμετρος είναι δεκτή, τότε η function την
# εκτυπώνει και επιστρέφει 0, αλλιώς δεν εκτυπώνει τίποτα και επιστρέφει
# μη μηδενική τιμή.

isorio() {
	local val=

	# Αν η παράμετρος έχει τη γενική μορφή ημερομηνίας με ή χωρίς ώρα,
	# τότε ελέγχεται ως προς τη χρονική της ορθότητα.

	if isplaindate "${1}" || isdatetime "${1}"; then
		date -d "${1}" "+%Y-%m-%d" >/dev/null 2>&1 || return 1

		echo "${1}"
		return 0
	fi

	# Αν έχουμε argument που περιέχει μόνο ώρα χωρίς ημερομηνία,
	# τότε συμπληρώνουμε με την default ημερομηνία.

	if isplaintime "${1}"; then
		val="${dfltdate} ${1}"
		date -d "${val}" >/dev/null 2>&1 || return 1

		echo "${val}"
		return 0
	fi

	# Αν πρόκειται για argument που είναι θετικός αριθμός, τότε
	# πρόκειται για rowid και το επιστρέφουμε αναλλοίωτο.

	isrowid "${1}" || return 1

	echo "${1}"
	return 0
}

setdfltdate() {
	local date=

	if isplaindate "${1}"; then
		date="yes"
	elif isdatetime "${1}"; then
		date="yes"
	fi

	[ -z "${date}" ] && return 0

	date="$(date -d "${1}" "+%Y-%m-%d" 2>/dev/null)"
	[ -z "${date}" ] && return 1

	dfltdate="${date}"
	return 0
}

checkapoeos() {
	local arg="${1}"
	local cmp="${2}"
	local msg="${3}"
	local val=

	[ -z "${arg}" ] && return 0

	if isplaindate "${arg}"; then
		case "${cmp}" in
		"<"|">=")
			val="$(date -d "${arg} 00:00:00" "+%Y-%m-%d %H:%M:%S" 2>/dev/null)"
			;;
		*)
			val="$(date -d "${arg} 23:59:59" "+%Y-%m-%d %H:%M:%S" 2>/dev/null)"
			;;
		esac
	elif isdatetime "${arg}"; then
		val="$(date -d "${arg}" "+%Y-%m-%d %H:%M:%S" 2>/dev/null)"
	elif isrowid "${arg}"; then
		val="${arg}"
	else
		val=
	fi

	if [ -n "${val}" ]; then
		echo "${val}"
		return 0
	fi

	pd_errmsg "${arg}: invalid '$2' limit"
	return 1
}

lim2num() {
	local sec=

	case "${1}" in
	RecordID)
		case "${2}" in
		">=")
			expr "${3}" - 1
			;;
		"<=")
			expr "${3}" + 1
			;;
		*)
			echo "${3}"
			;;
		esac
		;;
	*)
		sec="$(date -d "${3}" "+%s")"

		case "${2}" in
		">=")
			expr "${sec}" - 1
			;;
		"<=")
			expr "${sec}" + 1
			;;
		*)
			echo "${sec}"
			;;
		esac
		;;
	esac
}

apoeosdebug() {
	local mode="FROM-TO"

	[[ "${debug}" =~ [rR] ]] || return

	debugsec "${mode}" "BEGIN" "${1}"
	echo -e "${debugbegin}
apocol: >>${apocol}<<
apo_op: >>${apo_op}<<
apo: >>${apo}<<\n
eoscol: >>${eoscol}<<
eos_op: >>${eos_op}<<
eos: >>${eos}<<\n
maxrid: >>${maxrid}<<
${debugend}"
	debugsec "${mode}" "END" "${1}"
	debugexit "R"
}

cmddebug() {
	local mode="POLL COMMAND"

	[[ "${debug}" =~ [cC] ]] || return

	debugsec "${mode}" "BEGIN"

	[ -n "${KARTEL_POLL_PID}" ] && echo "KARTEL_POLL_PID: >>${KARTEL_POLL_PID}<<"
	[ -n "${KARTEL_POLL_PASS}" ] && echo "KARTEL_POLL_PASS: >>${KARTEL_POLL_PASS}<<"
	[ -n "${KARTEL_POLL_MAXRID}" ] && echo "KARTEL_POLL_MAXRID: >>${KARTEL_POLL_MAXRID}<<"
	[ -n "${KARTEL_SQLCMD}" ] && echo "KARTEL_SQLCMD: >>${KARTEL_SQLCMD}<<"

	echo "cmd: >>${cmd}<<"

	debugsec "${mode}" "END"
	debugexit "C"
}

setcards() {
	local arg

	arg="$(echo "${1}" | sed 's;[^0-9];,;g
s;,\+;,;g
s;^,;;
s;,$;;')"

	if [ -z "${arg}" ]; then
		pd_errmsg "$1: invalid card number(s)"
		return 1
	fi

	if [ -z "${cards}" ]; then
		cards="${arg}"
		return 0
	fi

	cards+=",${arg}"
	return 0
}

cardsfix() {
	local sdrac=

	[ -z "${cards}" ] && return

	sdrac="$(awk -v cards="${cards}" 'BEGIN {
	n = split(cards, a, "[^0-9]{1,}")

	if (n < 1)
	exit(0)

	for (i = 1; i <= n; i++)
	sdrac[a[i] + 0]

	delete sdrac[0]
	sep = ""

	for (i in sdrac) {
		printf "%s%s", sep, i
		sep=","
	}
}')"

	if [ -z "${sdrac}" ]; then
		unset -v cards
		return
	fi

	cards="${sdrac}"
}

apoeosfix() {
	local err=
	local opa=
	local soe=
	local cmp=
	local curtime=
	local asfalia="3"	# περιθώριο ασφαλείας χρονικής υπέρβασης

	apo="$(checkapoeos "${apo}" "${apo_op}" "low")" || err="yes"
	eos="$(checkapoeos "${eos}" "${eos_op}" "high")" || err="yes"

	[ -n "${err}" ] &&
	pd_exit "apoeoserr"

	if [ -z "${apo}" ]; then
		apocol=
		apo_op=
		opa=
	else
		apocol="$(apoeoscol "${apo}")"
		opa="$(lim2num "${apocol}" "${apo_op}" "${apo}")"

		if [ \( -n "${poll}" \) -a \( "${apocol}" = "GenTime" \) ]; then
			sleep="$(expr "${opa}" - "$(date "+%s")")"
		fi
	fi

	if [ -z "${eos}" ]; then
		eoscol=
		eos_op=
		soe=
	else
		eoscol="$(apoeoscol "${eos}")"
		soe="$(lim2num "${eoscol}" "${eos_op}" "${eos}")"

		curtime="$(date "+%s")"
		if [ \( -n "${poll}" \) -a \( "${eoscol}" = "GenTime" \) -a \
			\( "${soe}" -lt "$(expr "${curtime}" - "${asfalia}")" \) ]; then
			pd_errmsg "${eos}: [GenTime] upper limit outdated" &&
			pd_exit 0
		fi
	fi

	[ -n "${opa}" ] && [ -n "${soe}" ] &&
	[ "${apocol}" = "${eoscol}" ] &&
	[ "${opa}" -ge "${soe}" ] &&
	pd_errmsg "invalid range" &&
	pd_exit "apoeoserr"

	[ -z "${maxrid}" ] &&
	return

	if [ \( -n "${soe}" \) -a \( "${eoscol}" = "RecordID" \) ]; then
		[ "$(expr "${soe}" - 1)" -le "${maxrid}" ] &&
		pd_errmsg "${eos}: [RecordID] high limit exceeds maximum rowid" &&
		pd_exit 0
	fi

	if [ \( -n "${opa}" \) -a \( "${apocol}" = "RecordID" \) ]; then
		if [ "${opa}" -lt "${maxrid}" ]; then
			apo="${maxrid}"
			apo_op=">"
		fi

		maxrid=
	fi
}

# Η function "sqlapoeos" δέχεται ως πρώτη παράμετρο ένα επάνω ή κάτω
# όριο, ως δεύτερη παράμετρο τον τύπο του ορίου και ως τρίτη παράμετρο
# τον τελεστή ελέγχου (">", ">=", "<", "<=").

sqlapoeos() {
	local val="${1}"
	local col=
	local cmp=

	[ -z "${val}" ] && return 0

	if [ "${#}" -eq 1 ]; then
		col="RecordID"
		cmp=">"
	else
		col="${2}"
		cmp="${3}"

		case "${cmp}" in
		">")
			opts+=" -A \"${val}\""
			;;
		">=")
			opts+=" -a \"${val}\""
			;;
		"<")
			opts+=" -e \"${val}\""
			;;
		"<=")
			opts+=" -E \"${val}\""
			;;
		esac
	fi

	[ "${col}" = "GenTime" ] && val="'${val}'"

	echo "	AND [WIN-PAK PRO].[dbo].[History].[${col}] ${cmp} ${val}"
}

sqlrdtype() {
	local sep="	"

	[ -z "${rdtype}" ] && return

	[[ "${rdtype}" =~ I ]] && \
	[[ "${rdtype}" =~ O ]] && \
	[[ "${rdtype}" =~ A ]] && {
		rdtype=
		return
	}

	opts+=" -k ${rdtype}"

	echo "	AND ("

	if [[ "${rdtype}" =~ I ]]; then
		echo "${sep}[WIN-PAK PRO].[dbo].[HWIndependentDevices].[Name] LIKE '%:IN:%'"
		sep="		OR "
	fi

	if [[ "${rdtype}" =~ O ]]; then
		echo "${sep}[WIN-PAK PRO].[dbo].[HWIndependentDevices].[Name] LIKE '%:OUT:%'"
		sep="		OR "
	fi

	if [[ "${rdtype}" =~ A ]]; then
		echo "${sep}[WIN-PAK PRO].[dbo].[HWIndependentDevices].[Name] LIKE '%:ACCESS:%'"
		sep="		OR "
	fi

	echo "	)"
}

sortrows() {
	sort -t "${ofs}" -k1n${srtorder} "${@}"
}

dbmodefix() {
	[ -z "${dbmode}" ] &&
	return

	dbmode="${dbmode^^}"

	pd_partmatch "${dbmode}" "INSERT" &&
	dbmode="INSERT" &&
	opts+=" -b" &&
	return 0

	pd_partmatch "${dbmode}" "REPLACE" &&
	dbmode="REPLACE" &&
	opts+=" -B" &&
	return 0

	pd_partmatch "${dbmode}" "LOAD" &&
	dbmode="LOAD" &&
	opts+=" -l" &&
	return 0

	pd_errmsg "${dbmode}: invalid local database update mode"
	pd_exit "dberr"
}

databasefix() {
	kartel_dbconf_set &&
	return 0

	unset dbmode
	pd_exit "dberr"
}

procrowsfix() {
	[ -z "${verbose}" ] &&
	opts+=" -v"

	protiklisi ||
	return

	[ -n "${print}" ] &&
	return

	[ -n "${dbmode}" ] &&
	return

	pd_errmsg "WARNING: nor printing neither database mode set"
}

procrows() {
	local input="$1"
	local maxridout="$2"
	local awkargs=

	awkargs+=" -i ${PANDORA_BASEDIR}/lib/pandora.awk"
	awkargs+=" -v pd_progname=${pd_progname}/${FUNCNAME[0]}"
	awkargs+=" -v maxridout=${maxridout}"
	awkargs+=" -v verbose=${verbose}"
	awkargs+=" -v printrow=${print}"

	if [ -n "${dbmode}" ]; then
		awkargs+=" -i ${KARTEL_BASEDIR}/lib/karteldb.awk"
		awkargs+=" -v dbmode=${dbmode}"

		[ "${dbmode}" == "LOAD" ] &&
		awkargs+=" -v datafile=${tmp3}"

	fi

	awkargs+=" -f ${KARTEL_BASEDIR}/lib/kartel/procrows.awk"

	awk -v fs="${ofs}" ${awkargs} <(sortrows "${input}") ||
	pd_exit "procerr"
}

# Ξεκινούμε την κατασκευή τού SQL script ακυρώνοντας μηνύματα σχετικά
# με το πλήθος των affected rows κλπ. Αμέσως μετά εκκινούμε το query
# και κατόπιν προβαίνουμε περιορισμούς, ελέγχους και ταξινομήσεις,
# ανάλογα με τις options που έχουν δοθεί στο command line.

sqlquery() {
	local sep=

	# Υπάρχει περίπτωση να μην συλλεγεί ούτε ένα [History] record με τα
	# κριτήρια που έχουν δοθεί στο command line. Σ' αυτήν την περίπτωση
	# είναι καλό να γνωρίζουμε το μέγιστο [History].[RecordID] ώστε να
	# το χρησιμοποιούμε ως όριο κάθε φορά σε κάθε επόμενο πέρασμα, μέσω
	# της environment variable "KARTEL_POLL_MAXRID, εφόσον το πρόγραμμα
	# τρέχει σε poll mode.

	if [ -n "${poll}" ]; then
		echo "SELECT MAX([History].[RecordID])
FROM [History];
"
	fi

	echo -n "SELECT"
	[ -n "${rows}" ] && echo -n " TOP ${rows}"

	echo -e "
\t[History].[RecordID],
\tCONVERT(VARCHAR, IIF([History].[GenTime] < [History].[RecvTime],
\t\t[History].[GenTime], [History].[RecvTime]), 120),
\t[History].[Param2],
\t[History].[Param3],
\t[HWIndependentDevices].[Name]"

	echo -e "
FROM
\t[History],
\t[HWIndependentDevices]"

	echo -e "
WHERE
\t[History].[Link1] = [HWIndependentDevices].[DeviceID]
\tAND [History].[Type1] = 9
\tAND [HWIndependentDevices].[DeviceType] = 50"

	sqlrdtype
	sqlapoeos "${apo}" "${apocol}" "${apo_op}"
	sqlapoeos "${eos}" "${eoscol}" "${eos_op}"
	[ "${maxrid}" -gt 0 ] 2>/dev/null && sqlapoeos "${maxrid}"

	echo -e "\tAND [History].[Param3] IN (
\t\tSELECT LTRIM([Card].[CardNumber])
\t\tFROM [Card]
\t\tWHERE [Card].[CardStatus] > 0"

	if [ -n "${cards}" ]; then
		echo "${cards}" | awk -f "${KARTEL_BASEDIR}/lib/kartel/sqlcards.awk"
	fi

	echo -e "\t)"

	echo "
ORDER BY [History].[RecordID] ${sqlorder};"
}

sqldebug() {
	local mode="SQL"

	[[ "${debug}" =~ [qQ] ]] || return

	debugsec "${mode}" "BEGIN"
	cat "${1}"
	debugsec "${mode}" "END"
	debugexit "Q"
}

sqlcheck() {
	wpconf="${KARTEL_BASEDIR}/lib/conf/winpak.cf"

	[ -r "${wpconf}" ] &&
	return 0

	pd_errmsg "${wpconf}: cannot read WIN-PAK SQL server configuration file"
	pd_exit "wperr"
}

sqlexec() {
	local i=
	local slist=

	[ ! -x "${sqlcmd}" ] &&
	pd_errmsg "${sqlcmd}: cannot execute" &&
	pd_exit "sqlcmdexec"

	# WARNING!!!
	# **********
	# Δεν χρησιμοποιούμε την option "-o" για το output redirection
	# του "sqlcmd", καθώς στην περίπτωση που χρησιμοποιήσουμε την
	# εν λόγω option, εκτός από το output κατευθύνονται στο output
	# file ΚΑΙ τα error messages, ασχέτως της option "-r"!

	poll="${poll}" \
	rows="${rows}" \
	"${sqlcmd}" --conf="${wpconf}" "$@" ||
	pd_exit "sqlcmderr"
}

monitor() {
	local par=" ("
	local rap=

	[ -z "${poll}" ] && return 0
	[ -n "${quiet}" ] && return 0

	echo -n "$(date +'%Y-%m-%d %H:%M:%S'): "

	if protiklisi; then
		echo -n "initial pass"
	else
		echo -n "pass ${KARTEL_POLL_PASS}"
	fi

	if [ -n "${apo}" ]; then
		echo -n "${par}${apocol} ${apo_op} ${apo}"
		par=" && "
		rap=")"
	fi

	if [ -n "${eos}" ]; then
		echo -n "${par}${eoscol} ${eos_op} ${eos}"
		par=" && "
		rap=")"
	fi

	if [ -n "${maxrid}" ]; then
		echo -n "${par}RecordID > ${maxrid}"
		rap=")"
	fi

	echo "${rap}"
	return 0
}

pollsleep() {
	[ -z "${poll}" ] &&
	return

	if [ -z "${sleep}" ]; then
		sleep="${poll}"
	elif [ "${sleep}" -lt "${poll}" ]; then
		sleep="${poll}"
	elif [ "${sleep}" -lt 30 ]; then
		pd_errmsg "will take a nap for a few seconds"
	elif [ "${sleep}" -lt 60 ]; then
		pd_errmsg "will take a nap for less than a minute"
	elif [ "${sleep}" -lt 120 ]; then
		pd_errmsg "will take a nap for less than two minutes"
	elif [ "${sleep}" -lt 300 ]; then
		pd_errmsg "will take a nap for about $(expr "${sleep}" / 60) minutes"
	else
		pd_errmsg "will take a break until $(date -d "now + ${sleep} seconds" '+%Y-%m-%d %H:%M:%S')"
	fi

	pd_sleep "${sleep}"
}
