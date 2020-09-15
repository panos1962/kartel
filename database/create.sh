#!/usr/bin/env bash

[ -z "${PANDORA_BASEDIR}" ] &&
PANDORA_BASEDIR="/var/opt/pandora"

pd_tmpmax=1
. "${PANDORA_BASEDIR}/lib/pandora.sh" ||
exit 2

pd_progname="${pd_progfull}"

schema="${pd_tmpname[1]}"

pd_sigtrap

pd_usagemsg="[ OPTIONS ]
Options
-------
-d dbadmincf
-c karteldbcf
-e begin_date
-C
-q
"

pd_seterrcode \
	"fserr" \
	"dbadmincferr" \
	"karteldbcferr" \
	"createdberr"

check_data_files() {
	local dir=
	local i=
	local err=

	dir="local/data/kartel"

	[ -d "${dir}" ] &&
	! mkdir --parents "${dir}" &&
	pd_exit "fserr"

	for i in site reader
	do
		i="${dir}/${i}.tsv"

		[ -r "${i}" ] &&
		continue

		>"${i}"

		[ -r "${i}" ] &&
		continue

		err="yes"
	done

	[ -n "${err}" ] &&
	pd_exit "fserr"
}

dbadmincf="local/dbadmin.cf"
karteldbcf="local/karteldb.cf"
ekinisi=
create=
quiet=

error=

while getopts ":d:c:e:Cq" arg
do
	case "${arg}" in
	d)
		dbadmincf="${OPTARG}"
		;;
	c)
		karteldbcf="${OPTARG}"
		;;
	e)
		ekinisi="${OPTARG}"
		;;
	C)
		create="yes"
		;;
	q)
		quiet="
/^\\\! *echo /d"
		;;
	\?)
		pd_errmsg "-${OPTARG}$(pd_terr reset): invalid option"
		error="yes"
		;;
	esac
done

[ -n "${error}" ] &&
pd_usage

shift $((OPTIND-1))

. "${karteldbcf}" ||
pd_exit "karteldbcferr"

[ -z "${karteldb}" ] &&
pd_errmsg "undefined database 'kartel'" &&
error="yes"

[ -z "${erpotadb}" ] &&
pd_errmsg "undefined database 'erpota'" &&
error="yes"

[ -z "${dbuser}" ] &&
pd_errmsg "undefined database user name" &&
error="yes"

[ -z "${dbpassword}" ] &&
pd_errmsg "null database user password" &&
error="yes"

[ -z "${ekinisi}" ] &&
ekinisi="2019-05-01"

[ -n "${error}" ] &&
pd_exit "karteldbcferr"

print_schema() {
	local i=

	sed "/^\-\-/d
/^[ \t]*$/d${quiet}
s;\[\[ERPOTADB\]\];${erpotadb};g
s;\[\[ERPOTA12\]\];${i};g
s;\[\[EKINISI\]\];${ekinisi};g
s;\[\[KARTELDB\]\];${karteldb};g
s;\[\[ERPOTADB\]\];${erpotadb};g
s;\[\[USERNAME\]\];${dbuser};g
s;\[\[USERPASS\]\];${dbpassword};g" "$@"

	return 0
}

[ -z "${create}" ] &&
print_schema "$@" &&
pd_exit 0

# Βρισκόμαστε στο σημείο δημιουργίας των databases, επομένως θα χρειαστούμε
# adminstrative credentials.

. "${dbadmincf}" ||
pd_exit "dbadmincferr"

[ -z "${dbadminname}" ] &&
pd_errmsg "undefined database administrator name" &&
error="yes"

[ -z "${dbadminpass}" ] &&
pd_errmsg "null database administrator password" &&
error="yes"

[ -n "${error}" ] &&
pd_exit "admincferr"

check_data_files

export MYSQL_PWD="${dbadminpass}"
print_schema "$@" | mysql --user="${dbadminname}"

pd_pipefail ||
pd_exit "createdberr"
