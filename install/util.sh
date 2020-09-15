#!/usr/bin/env bash

# Το πρόγραμμα πρέπει να εκκινεί από το home directory του αποθετηρίου "kartel"
# με δυνατότητες system administrator, άρα δίνουμε την εντολή:
#
#	sudo ./install/install
#
# ή
#
#	sudo bash install/install
#
# Ακολουθεί έλεγχος για τον τόπο και τον τρόπο κλήσης του παρόντος προγράμματος
# εγκατάστασης της εφαρμογής "kartel".

[[ "${pd_progfull}" =~ ^(\./)?install/${pd_progname}$ ]] ||
pd_exit "$(pd_terr dim)\n
Try:
$(pd_terr reset errmsg)
\tcd "$(echo ${pd_progpath} | sed "s;${pd_progname}$;;")"
$(pd_terr dim)
and retry the installation using:
$(pd_terr reset errmsg)
\t./install/${pd_progname} ...
$(pd_terr dim)
or
$(pd_terr reset errmsg)
\tbash install/${pd_progname} ...
$(pd_terr dim)" "callerr"

[ "$(id -u)" != "0" ] &&
pd_exit "try 'sudo ${pd_progfull}'" "noadmin"

pd_usageprg="sudo ${pd_progname}"
pd_usagemsg="[ -l label ] [ -d directory ]
	[ -u user ] [ -U uid ] [ -g group ] [ -G gid ]
	[ { -W wpconf | -w } ]
	[ { -B dbconf | -b } ]
	[ { -M mailcf | -m } ]
	[ -X  [ -T ] ]"

# Η εφαρμογή "kartel" εγκαθίσταται by default στο directory
#
#	/var/opt/kartel
#
# Ωστόσο μπορούμε να εγκαταστήσουμε την εφαρμογή σε άλλο directory
# χρησιμοποιώντας την option "-d" με παράμετρο το directory της
# αρεσκείας μας, π.χ.
#
#	install/install -d "/var/opt/letrak"
#
# Ίσως ακόμη σημαντικότερη είναι η otpion "-l" με την οποία μπορούμε
# να αλλάξουμε το default όνμομα της εφαρμογής από "kartel" σε άλλο
# όνομα της αρεσκείας μας.

dfltlabel="kartel"

# Τυχόν σφάλματα στην "check_label" είναι σημαντικά και ως εκ τούτου,
# σε περίπτωση σφάλματος, η εκτέλεση του προγράμματος εγκατάστασης τής
# εφαρμογής θα διακοπεί άμεσα.

check_label() {
	[ -z "${label}" ] &&
	label="${dfltlabel}" &&
	return 0

	# Αποφεύγουμε τις ακρότητες στην ονοματοδοσία τής εφαρμογής,
	# καθώς το ίδιο όνομα είναι πιθανό να χρησιμοποιηθεί και ως
	# login name, group name κλπ.

	[[ "${label}" =~ ^[a-zA-Z][a-zA-Z0-9_]*$ ]] ||
	pd_exit "${label}: invalid application label" "label"

	return 0
}

# Τα σφάλματα στην "check_basedir" είναι σημαντικά και ως εκ τούτου,
# σε περίπτωση σφάλματος, η εκτέλεση του προγράμματος εγκατάστασης τής
# εφαρμογής θα διακοπεί άμεσα.

check_basedir() {
	if [ -z "${basedir}" ]; then
		basedir="/var/opt/${label}"
	elif [ "$(echo ${basedir} | wc -w)" -ne 1 ]; then
		pd_exit "${basedir}: invalid base directory" "basedir"
	elif [[ ! "${basedir}" =~ ^/ ]]; then
		pd_exit "${basedir}: base directory must be an absolute pathname" "basedir"
	fi

	[ -d "${basedir}" ] &&
	pd_exit "${basedir}: directory exists" "basedir"

	return 0
}

check_bgdate() {
	local bgfile="local/begin_date"
	local dt=

	dt="${begin_date}"

	[ -z "${dt}" ] &&
	[ -r "${bgfile}" ] &&
	! dt="$(cat "${bgfile}")"

	[ -z "${dt}" ] &&
	pd_errmsg "missing begin date" &&
	return 1

	begin_date="$("${PANDORA_BASEDIR}"/bin/pd_dt2dt \
		-i YMD -o Y-M-D "${dt}")"

	[[ "${begin_date}" == "${dt}" ]] &&
	return 0

	pd_errmsg "${dt}: invalid begin date" &&
	return 1
}

# Η function "check_user" ελέγχει/θέτει το user name και το user id για
# τον χρήστη που θα είναι αρμόδιος για τον έλεγχο των καρτών. Αν δεν
# έχουν καθοριστεί στοιχεία χρήστη, τότε τίθεται αυτόματα το user name
# σύμφωνα με το label της εφαρμογής.

check_user() {
	local ret=

	[ -z "${user}" ] &&
	user="${label}"

	[ "${useradd}" != "1" ] &&
	return 0

	! awk -F: -v user="${user}" '$1 == user { exit(1) }' /etc/passwd &&
	pd_errmsg "${user}: user exists" &&
	ret=1

	[ -z "${uid}" ] &&
	return ${ret}

	[[ ! "${uid}" =~ ^[1-9][0-9]{1,4} ]] &&
	pd_errmsg "${uid}: invalid user id" &&
	return 1

	awk -F: -v uid="${uid}" '$3 == uid { exit(1); }' /etc/passwd &&
	return 0

	pd_errmsg "${uid}: user id exists"
	return 1
}

check_group() {
	local ret=0

	[ -z "${group}" ] &&
	group="${label}"

	[ "${groupadd}" != "1" ] &&
	return 0

	! awk -F: -v group="${group}" '$1 == group { exit(1) }' /etc/group &&
	pd_errmsg "${group}: group exists" &&
	ret=1

	[ -z "${gid}" ] &&
	return ${ret}

	[[ ! "${gid}" =~ ^[1-9][0-9]{1,4}$ ]] &&
	pd_errmsg "${gid}: invalid group id" &&
	return 1

	awk -F: -v gid="${gid}" '$3 == gid { exit(1); }' /etc/group &&
	return 0

	pd_errmsg "${gid}: group id exists"
	return 1
}

check_wpconf() {
	[ -z "${wpconf}" ] &&
	return 0

	[ ! -r "${wpconf}" ] &&
	pd_errmsg "${wpconf}: cannot read WIN-PAK configuration file" &&
	return 1

	return 0
}

check_dbconf() {
	local ret=
	local karteldb=
	local adminname=
	local adminpass=
	local username=
	local userpass=

	[ -z "${dbconf}" ] &&
	return 0

	[ -z "${dbadmcf}" ] &&
	pd_errmsg "missing local database administrator configuration file" &&
	return 1

	[ ! -r "${dbadmcf}" ] &&
	pd_errmsg "${dbadmcf}: cannot read local database administrator configuration file" &&
	return 1

	[ ! -r "${dbconf}" ] &&
	pd_errmsg "${dbconf}: cannot read local database configuration file" &&
	return 1

	! . "${dbadmcf}" &&
	return 1

	! . "${dbconf}" &&
	return 1

	ret=0

	if [ -z "${dbadminname}" ]; then
		adminname="root"
	elif [[ ! "${dbadminname}" =~ ^[a-zA-Z][a-zA-Z0-9_]*$ ]]; then
		pd_errmsg "${dbadminname}: invalid local database administrator name"
		ret=1
	fi

	[ -z "${dbadminpass}" ] &&
	pd_errmsg "password not specified for local database administrator '${dbadminame}'" &&
	ret=1

	if [ -z "${karteldb}" ]; then
		karteldb="${label}"
	elif [[ ! "${karteldb}" =~ ^[a-zA-Z][a-zA-Z0-9_]*$ ]]; then
		pd_errmsg "${karteldb}: invalid local database name"
		ret=1
	fi

	if [ -z "${username}" ]; then
		username="${user}"
	elif [[ ! "${username}" =~ ^[a-zA-Z][a-zA-Z0-9_]*$ ]]; then
		pd_errmsg "${username}: invalid local database user name"
		ret=1
	fi

	[ -z "${userpass}" ] &&
	pd_errmsg "password not specified for local database user '${username}'" &&
	ret=1

	return ${ret}
}

check_mailcf() {
	local domain=
	local mailer=
	local from=

	[ -z "${mailcf}" ] &&
	return 0

	[ ! -r "${mailcf}" ] &&
	pd_errmsg "${mailcf}: cannot read mail configuration file" &&
	return 1

	! . "${mailcf}" &&
	return 1

	[ -z "${domain}" ] &&
	pd_errmsg "mail domain not specified" &&
	return 1

	[ -z "${mailer}" ] &&
	mailer="${label}"

	from="${mailer}@${domain}"

	! pd_isemail "${from}" &&
	pd_errmsg "${from}: invalid email address" &&
	return 1

	return 0
}

check_erpotacf() {
	[ -z "${erpotacf}" ] &&
	return 0

	[ ! -r "${erpotacf}" ] &&
	pd_errmsg "${erpotacf}: cannot read 'erpota' configuration file" &&
	return 1

	return 0
}

display() {
	echo "Basic Configuration Data"

	[ -n "${label}" ]	&& echo -e "\tLabel: ${label}"
	[ -n "${basedir}" ]	&& echo -e "\tLocation: ${basedir}"
	[ -n "${begin_date}" ]	&& echo -e "\tBegin date: ${begin_date}"
	[ -n "${user}" ]	&& echo -e "\tUser name: ${user}"
	[ -n "${uid}" ]		&& echo -e "\tUser id: ${uid}"
	[ -n "${group}" ]	&& echo -e "\tGroup name: ${group}"
	[ -n "${gid}" ]		&& echo -e "\tGroup id: ${gid}"

	display_wpconf
	display_dbconf
	display_mailcf

	return 0
}

display_wpconf() {
	local server=
	local port=
	local karteldb=
	local username=
	local userpass=

	[ -z "${wpconf}" ] &&
	return

	! . "${wpconf}" &&
	pd_exit "fserr"

	echo "
WIN-PAK Configuration Data (${wpconf})"
	[ -n "${server}" ]	&& echo -e "\tWIN-PAK server: ${server} $(name2ip "${server}")"
	[ -n "${port}" ]	&& echo -e "\tWIN-PAK server port: ${port}"
	[ -n "${karteldb}" ]	&& echo -e "\tWIN-PAK database: ${karteldb}"
	[ -n "${username}" ]	&& echo -e "\tWIN-PAK user name: ${username}"
	[ -n "${userpass}" ]	&& echo -e "\tWIN-PAK user password: ${userpass}"
}

display_dbconf() {
	local karteldb=
	local adminname=
	local adminpass=
	local username=
	local userpass=

	[ -z "${dbconf}" ] &&
	return

	! . "${dbconf}" &&
	pd_exit "fserr"

	echo "
Local Database Configuration Data (${dbconf})"
	[ -n "${karteldb}" ]	&& echo -e "\tDatabase name: ${karteldb}"
	[ -n "${adminname}" ]	&& echo -e "\tAdministrator name: ${adminname}"
	[ -n "${adminpass}" ]	&& echo -e "\tAdministrator password: ${adminpass}"
	[ -n "${username}" ]	&& echo -e "\tUser name: ${username}"
	[ -n "${userpass}" ]	&& echo -e "\tUser password: ${userpass}"
}

display_mailcf() {
	[ -z "${mailcf}" ] &&
	return

	! . "${mailcf}" &&
	pd_exit "fserr"

	echo "
Mail Configuration Data (${mailcf})"
	[ -n "${server}" ]	&& echo -e "\tMail server: ${server} $(name2ip "${server}")"
	[ -n "${domain}" ]	&& echo -e "\tMail domain: ${domain}"
	[ -n "${mailer}" ]	&& echo -e "\tMailer: ${mailer}"
}

trysudo() {
	local msg=

	msg="Try 'sudo ${pd_progpath}'"

	[ -n "${pd_progargs}" ] &&
	msg="${msg} ${pd_progargs}"

	msg="${msg}'"

	pd_exit "${msg}" "noadmin"
}

update_sysenv() {
	local sysenvfile="/etc/environment"

	[ -f "${sysenvfile}" ] ||
	return 0

	{
		sed '/^KARTEL_/d' "${sysenvfile}"
		echo "KARTEL_BASEDIR=\"${KARTEL_BASEDIR}\""
	} >"${tmp1}" &&
	mv "${tmp1}" "${sysenvfile}" &&
	return 0

	pd_errmsg "${sysenvfile}: update failed"
	trysudo
} 

update_sysprof() {
	local sysprofdir="/etc/profile.d"
	local sysprofile="${sysprofdir}/kartel.sh"

	[ -d "${sysprofdir}" ] ||
	return 0

	cp lib/profile.sh "${sysprofile}" &&
	chmod 644 "${sysprofile}" &&
	chown root "${sysprofile}" &&
	chgrp root "${sysprofile}" &&
	return 0

	pd_errmsg "${sysprofile}: update failed"
	trysudo
} 

create_group() {
	local cmd=
	local msg=

	awk -v group="${group}" -f install/group/create.awk /etc/group &&
	return 0

	pd_ttymsg "$(pd_tmsg dim)Adding local group '$(pd_tmsg)${group}$(pd_tmsg dim)'…$(pd_tmsg)"

	cmd="groupadd"
	[ -n "${gid}" ] &&
	cmd="${cmd} -g ${gid}"
	cmd="${cmd} ${group}"

	eval "${cmd}" &&
	return 0

	msg="cannot create group ${group}"
	[ -n "${gid}" ] &&
	msg="${msg} with group-id ${gid}"
	pd_errmsg "${msg}"
	trysudo
}

create_user() {
	local cmd=
	local msg=

	awk -v user="${user}" -f install/user/create.awk /etc/passwd &&
	return 0

	pd_ttymsg "$(pd_tmsg dim)Adding local user '$(pd_tmsg)${user}$(pd_tmsg dim)'…$(pd_tmsg)"

	cmd="useradd -m -g ${group}"
	[ -n "${uid}" ] &&
	cmd="${cmd} -u ${uid}"
	cmd="${cmd} ${user}"

	eval "${cmd}" 2>/dev/null &&
	return 0

	msg="cannot create user ${user}"
	[ -n "${uid}" ] &&
	msg="${msg} with user-id ${uid}"
	pd_errmsg "${msg}"
	trysudo
}

checkdir() {
	local dir="$1"
	local mkdiropts=
	local ret=0

	[ -z "${dir}" ] &&
	return 0

	[[ "${dir}" =~ ^/ ]] ||
	dir="${basedir}/${dir}"

	if [ ! -d "${dir}" ]; then
		[[ "${dir}" =~ ^/ ]] &&
		mkdiropts="-p"

		mkdir ${mkdiropts} "${dir}" ||
		ret=1
	fi

	[ "${ret}" -eq 0 ] &&
	chown "${user}" "${dir}" &&
	chgrp "${group}" "${dir}" &&
	chmod "${dirmode}" "${dir}" &&
	return 0

	pd_errmsg "cannot create ${dir}"
	trysudo
}

checkfile() {
	local mode="$1"
	local srctrg="$2"
	local source=
	local target=
	local copy="cat"

	. <(echo "${srctrg}" | awk -F: '{ print "source=\"" $1 "\"\ntarget=\"" $2 "\"" }')

	[ -z "${source}" ] &&
	return 0

	[ -z "${target}" ] &&
	target="${source}"
	target="${basedir}/${target}"

	[ "${target}" = "${source}" ] &&
	pd_errmsg "${source}: identical target (${target})" &&
	return 1

	[[ "${source}" =~ \.sh$ ]] &&
	copy="${rmshcmnt}"

	[ -f "${source}" ] ||
	return 0

	"${copy}" "${source}" >"${target}"
	[ $? -ne 0 ] &&
	pd_errmsg "cannot copy '${source}' to '${target}'" &&
	trysudo

	chown "${user}" "${target}" &&
	chgrp "${group}" "${target}" &&
	chmod "${mode}" "${target}" &&
	return 0

	trysudo
}

# Η function "create_basis" εγκαθιστά τη βασική directory structure
# της εφαρμογής στο directory βάσης της εγκατάστασης.

create_basis() {
	local i=
	local ret=0

	for i in \
		"${basedir}" \
		"tmp" \
		"bin" \
		"lib" \
		"lib/conf" \
		"lib/kartel" \
		"lib/kartel/mail" \
		"lib/karteld" \
		"lib/imerisio" \
		"karteld" \
		"karteld/log" \
		"lib/erpota" \
		"man" \
		"man/man1" \
		""
	do
		checkdir "${i}" ||
		ret=1
	done

	chmod "${tmpmode}" \
		"${basedir}/tmp" \
		"${basedir}/erpota/lib"

	[ "${ret}" -ne 0 ] &&
	return 1

	return ${ret}
}

# Η function "create_files" εγκαθιστά στο directory βάσης, τα αρχεία
# που είναι απαραίτητα για την παραγωγική λειτουργία της εφαρμογής.

create_files() {
	local i=
	local ret=0

	awk '/^--FK--/,/^--KF--$/' database/erpota12.sql >"${tmp1}"

	for i in \
		"lib/karteldb.awk" \
		"" \
		"lib/kartel.sh" \
		"lib/kartel/util.sh" \
		"lib/kartel/sqlcards.awk" \
		"lib/kartel/procrows.awk" \
		"lib/kartel/mail/maildata.awk" \
		"lib/kartel/mail/mailrecpt.awk" \
		"lib/kartel/help" \
		"local/data/kartel/wpdata.tsv:lib/kartel/wpdata.tsv" \
		"" \
		"lib/karteld/util.sh" \
		"lib/karteld/taillog" \
		"" \
		"lib/erpota.sh" \
		"lib/erpota/util.sh" \
		"lib/erpota/util.awk" \
		"lib/erpota/ipalilos.awk" \
		"lib/erpota/metavoli.awk" \
		"lib/erpota/dbload.awk" \
		"${tmp1}:lib/erpota/relations.sql" \
		"lib/erpota/erpota12" \
		"lib/imerisio/select.awk" \
		"" \
		"man/erpota.1:man/man1/erpota.1" \
		"" \
		"${karteldcf}:lib/conf/karteld.cf" \
		"${wpconf}:lib/conf/winpak.cf" \
		"${karteldbcf}:lib/conf/karteldb.cf" \
		"${mailcf}:lib/conf/mail.cf" \
		"${erpotadbcf}:lib/conf/erpotadb.cf" \
		"local/begin_date:lib/begin_date" \
		"local/message.html:lib/kartel/mail/message.html" \
		"local/data/erpota/bademail:lib/erpota/bademail" \
		""
	do
		checkfile "${txtmode}" "${i}" ||
		ret=1
	done

	for i in \
		"lib/kartel/phonysql.sh:lib/kartel/phonysql" \
		"bin/kartel.sh:bin/kartel" \
		"" \
		"bin/karteld" \
		"lib/karteld/taillog" \
		"" \
		"bin/erpota.sh:bin/erpota" \
		""
	do
		checkfile "${excmode}" "${i}" ||
		ret=1
	done

	[ "${ret}" -ne 0 ] &&
	return 1

	return 0
}

create_mail() {
	local i=
	local ret=

	[ -z "${mailcf}" ] &&
	return 0

	pd_ttymsg "$(pd_tmsg dim)Installing local mail components…$(pd_tmsg)"

	! . ${mailcf} &&
	return 1

	return 0
}

create_home() {
	local home=
	local target=

	pd_ttymsg "$(pd_tmsg dim)Checking home directory for user '$(pd_tmsg)${user}$(pd_tmsg dim)'…$(pd_tmsg)"

	home="$(awk -F: -v user="${user}" '$1 == user { print $6; exit(0); }' /etc/passwd)"
	[ -z "${home}" ] &&
	pd_errmsg "no home directory for '${user}'" &&
	return 1

	[ "${useradd}" != "1" ] &&
	return 0

	target="${home}/lib"
	mkdir "${target}" &&
	chown "${user}" "${target}" &&
	chgrp "${group}" "${target}" &&
	chmod "${dirmode}" "${target}"

	[ $? -ne 0 ] &&
	pd_errmsg "${target}: cannot create directory" &&
	return 1

	target="${home}/erpota"
	mkdir "${target}" &&
	chown "${user}" "${target}" &&
	chgrp "${group}" "${target}" &&
	chmod "${dirmode}" "${target}"

	[ $? -ne 0 ] &&
	pd_errmsg "${target}: cannot create directory" &&
	return 1

	target="${home}/lib/crontab"
	cp install/crontab "${target}" &&
	chown "${user}" "${target}" &&
	chgrp "${group}" "${target}" &&
	chmod "${txtmode}" "${target}"

	[ $? -ne 0 ] &&
	pd_errmsg "${target}: cannot create" &&
	return 1

	return 0
}

create_database() {
	[ -z "${karteldbcf}" ] &&
	return 0

	pd_ttymsg "$(pd_tmsg dim)Creating local database…$(pd_tmsg)"
	! database/create.sh -e "${begin_date}" -C &&
	pd_errmsg "cannot create database" &&
	return 1

	return 0
}

name2ip() {
	pd_name2ip "$1" &&
	return 0

	echo "[ *** unknown IP *** ]"
	return 1
}
