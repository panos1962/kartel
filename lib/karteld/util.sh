#!/usr/bin/env bash

is_locked() {
	[ -d "${lckdir}" ]
}

pidget() {
	is_locked &&
	[ -f "${pidfile}" ] &&
	cat "${pidfile}" 2>/dev/null
}

is_running() {
	[ $# -lt 1 ] &&
	set -- "$(pidget)"

	pd_running "$@"
}

logfiles() {
	ls -t "${logdir}"/*.??? | grep -E '\.(out)|(err)$' | head --lines=2
} 

extra_args() {
	[ $# -gt 0 ] &&
	pd_errmsg "extra arguments not allowed in "${mode}" mode" &&
	pd_usage
}

exec_status() {
	local pid=
	local running=

	pd_errlevel=0

	is_locked &&
	printf "\n$(pd_tout dim)Lock:$(pd_tout) " &&
	echo "$(pd_tout bold fblue)${lckdir}$(pd_tout)"

	pid="$(pidget)"

	[ -n "${pid}" ] &&
	printf "\n$(pd_tout dim)PID:$(pd_tout) " &&
	echo "$(pd_tout bold fblue)${pid}$(pd_tout)" &&
	pd_tout reset &&
	ps -fp "${pid}" 2>/dev/null && running="yes" &&
	pd_tout

	pd_tout dim
	echo -e "\nLog files:"
	pd_tout
	exec_logs -oe 2
}

exec_start() {
	local pid=
	local conf="${basedir}/lib/conf/karteld.cf"
	local opts=
	local log=

	pd_ttymsg "$(pd_tmsg reset dim)Starting daemon…$(pd_tmsg)"

	[ -d "${dmndir}" ] &&
	[ -x "${dmndir}" ] &&
	[ -r "${dmndir}" ]

	[ $? -ne 0 ] &&
	pd_errmsg "${dmndir}: no permission" &&
	pd_exit "noperm"

	[ -d "${lckdir}" ] &&
	[ -r "${pidfile}" ] &&
	pid="$(cat "${pidfile}")" &&
	[ -e "/proc/${pid}" ] &&
	pd_errmsg "${pid}: daemon process is running" &&
	pd_exit "dmnerr"

	rm -rf "${lckdir}" 2>/dev/null

	[ -d "${lckdir}" ] &&
	pd_errmsg "daemon process seems to be alive" &&
	pd_exit "dmnerr"

	mkdir "${lckdir}" &&
	chmod 750 "${lckdir}" &&
	echo "$$" >"${pidfile}" &&
	chmod 640 "${pidfile}"

	if [ $? -ne 0 ]; then
		rm -rf "${lckdir}" 2>/dev/null
		pd_errmsg "cannot save daemon process id"
		pd_exit "dmnerr"
	fi

	# Default options για το "kartel". Η μόνη απαραίτητη είναι αυτή που
	# θέτει το "kartel" σε poll mode, ωστόσο το default poll period του
	# ενός δευτερολέπτου είναι πολύ μικρό για τη δουλειά που το θέλουμε,
	# οπότε θέτουμε poll period 10 δευτερόλεπτα. Μπορούμε, βεβαίως, να
	# αλλάξουμε αυτό το χρονικό διάστημα, κάνοντας χρήση του "karteld"
	# configuration file "lib/conf/karteld.cf" στο directory βάσης
	# της εφαρμογής "/var/opt/kartel", ή όπου αλλού έχουμε εγκαταστήσει
	# την εφαρμογή.

	opts="--poll --delay=10"

	[ -r "${conf}" ] &&
	! opts="${opts} $(sed -n '/^-/p' "${conf}")" &&
	pd_exit "conferr"

	log="${logdir}/$(date '+%Y%m%d%H%M%S')"
	nohup nice "${basedir}/bin/kartel" ${opts} "$@" >"${log}.out" 2>"${log}.err" &
	pid="$!"

	sleep 1

	[ ! -e "/proc/${pid}" ] &&
	cat "${log}.err" >&2 &&
	pd_usage

	echo "${pid}" >"${pidfile}"

	pd_ttymsg "$(pd_tmsg reset dim)Process id: $(pd_tmsg reset bold fyellow)${pid}$(pd_tmsg)"
	pd_ttymsg "$(pd_tmsg reset dim)Daemon started!$(pd_tmsg)"
	return 0
}

exec_stop() {
	local pid=

	pd_ttymsg "$(pd_tmsg reset dim)Stopping daemon…$(pd_tmsg)"

	[ -d "${dmndir}" ] &&
	[ -x "${dmndir}" ] &&
	[ -r "${dmndir}" ]

	[ $? -ne 0 ] &&
	pd_errmsg "${dmndir}: no permission" &&
	pd_exit "noperm"

	[ -d "${lckdir}" ] ||
	return 0

	[ -r "${pidfile}" ] &&
	pid="$(cat "${pidfile}")" &&
	[ -e "/proc/${pid}" ] &&
	pd_ttymsg "$(pd_tmsg dim)[ $(pd_tmsg reset bold fred)${pid}$(pd_tmsg reset dim) ]$(pd_tmsg)" &&
	kill -SIGTERM "${pid}" &&
	timeout 5 tail --pid="${pid}" -f /dev/null &&
	[ -e "/proc/${pid}" ] &&
	pd_errmsg "${pid}: cannot stop daemon process" &&
	pd_exit "dmnerr"

	rm -rf "${lckdir}" 2>/dev/null

	[ -d "${lckdir}" ] &&
	pd_errmsg "cannot unlock" &&
	pd_exit "dmnerr"

	pd_ttymsg "$(pd_tmsg reset dim)Daemon stopped!$(pd_tmsg)"
	return 0
}

exec_restart() {
	exec_stop &&
	pd_ttymsg &&
	exec_start "$@"
}

show_log() {
	local log=
	local dec=
	local lines=

	[ -z "$1" ] &&
	return

	[ ! -r "$1" ] &&
	pd_errmsg "$1: cannot read file" &&
	return

	log="$1"
	dec="$2"
	lines="$3"

	[ -z "${lines}" ] &&
	lines=10

	printf "$(pd_tout bold ${dec})${log##*/}$(pd_tout) "
	printf "$(pd_tout dim)[$(pd_tout) "
	printf "$(pd_tout fcyan)$(date +'%a %b %d %Y, %H:%M:%S' -r ${i})$(pd_tout) "
	echo "$(pd_tout dim)]"

	[ "$(head --lines="$((lines+1))" "${log}" | wc -l)" -gt "${lines}" ] &&
	echo "..."

	pd_tout
	tail --lines "${lines}" "${log}"
}

exec_logs() {
	local i=
	local show_out=
	local show_err=
	local lines=
	local out=
	local err=

	eval set -- "$(pd_parseopts "oe" "" "$@")"
	[ $1 -ne 0 ] &&
	errorlevel= &&
	pd_exit "pd_usage"

	shift

	for i in "$@"
	do
		case "${i}" in
		-o)	show_out="yes"; shift;;
		-e)	show_err="yes"; shift;;
		--)	shift; break;;
		esac
	done

	lines="$1"

	for i in $(logfiles)
	do
		if [[ "${i}" =~ \.out$ ]]; then
			out="${i}"
		elif [[ "${i}" =~ \.err$ ]]; then
			err="${i}"
		else
			pd_tout reset bmagenta fcyan
			ls -al "${i}"
			pd_tput
		fi
	done

	[ -n "${show_out}" ] &&
	show_log "${out}" "bblue fwhite" "${lines}"

	[ -n "${show_err}" ] &&
	show_log "${err}" "bred fyellow" "${lines}"
}
