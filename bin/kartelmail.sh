#!/usr/bin/env bash

[ -z "${PANDORA_BASEDIR}" ] &&
PANDORA_BASEDIR="/var/opt/pandora"

pd_usagemsg="[OPTIONS] [ARGS...]"
pd_tmpdir="${KARTEL_BASEDIR}/tmp"
pd_tmpmax=2

! . "${PANDORA_BASEDIR}/lib/pandora.sh" &&
exit 1

[ -z "${KARTEL_BASEDIR}" ] &&
KARTEL_BASEDIR="/var/opt/kartel"

pd_seterrcode \
	"norecip" \
	"nomsg" \
	""

tmp1="${pd_tmpname[1]}"
tmp2="${pd_tmpname[2]}"

pd_sigtrap

eval set -- "$(pd_parseopts \
"t:r:s:m:" \
"to:,recipient:,subject:,message:" "$@")"
[ $1 -ne 0 ] && pd_usage
shift

recipient=
mailer="no-reply@thessaloniki.gr"
subject=
message=
message_set=

error=

for arg in "$@"
do

	case "${arg}" in
	-t|-r|--to|--recipient)
		recipient="$2"
		shift 2
		;;

	-s|--subject)
		subject="$2"
		shift 2
		;;

	-m|--message)
		message="$2"
		message_set="yes"
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

[ -z "${recipient}" ] &&
pd_errmsg "no recipient address" &&
pd_exit "norecip"

[ -z "${subject}" ] &&
subject="Ενημέρωση"

if [ -z "${message_set}" ]; then
	cat $*
else
	echo "${message}"
fi >"${tmp1}"

[ ! -s "${tmp1}" ] &&
pd_errmsg "null message body" &&
pd_exit "nomsg"

cat >"${tmp2}" <<+++
To: ${recipient}
From: ${mailer}
Subject: ${subject}
MIME-Version: 1.0
Content-Type: text/html; charset=UTF-8
Content-Disposition: inline
<html>
<body>
+++

cat "${tmp1}" >>${tmp2}

echo "</pre>
</body>
</html>" >>${tmp2}

! sendmail -t <"${tmp2}" &&
pd_errmsg "sendmail failure" &&
pd_exit "mailerr"

pd_exit 0
