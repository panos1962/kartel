#!/usr/bin/env bash

[ -z "${PANDORA_BASEDIR}" ] &&
PANDORA_BASEDIR="/var/opt/pandora"

! . "${PANDORA_BASEDIR}/lib/pandora.sh" &&
exit 2

pd_usagemsg="[OPTIONS]"

eval set -- "$(pd_parseopts "" "conf:" "$@")"
[ $1 -ne 0 ] && pd_usage
shift

for arg in "$@"
do
	case "${arg}" in
	-i)
		shift 1
		;;
	-s)
		ofs="$(echo "$2" | cut -c1)"
		shift 2
		;;
	--)
		shift 1
		;;
	esac
done

sample="${KARTEL_BASEDIR}/lib/kartel/wpdata.tsv"

[ -n "${poll}" ] &&
! awk -v maxrid="${KARTEL_POLL_MAXRID}" -v rows="${rows}" '{
	if (--rows < 0)
	exit(0)

	if (($1 += 0) > maxrid)
	maxrid = $1
}

END {
	if (!maxrid)
	maxrid = 1

	print maxrid
}' "${sample}" &&
pd_exit 2

exec awk -v rows="${rows}" '{
	if (rows &&(--rows < 0))
	exit(0)

	print
}' "${sample}"
