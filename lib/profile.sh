[ -z "${KARTEL_BASEDIR}" ] &&
export KARTEL_BASEDIR="/var/opt/kartel"

[ -d "${KARTEL_BASEDIR}" ] &&
[ -r "${KARTEL_BASEDIR}" ] &&
[ -x "${KARTEL_BASEDIR}" ] &&
PATH="${PATH}:${KARTEL_BASEDIR}/bin" &&
export AWKPATH="${AWKPATH}:${KARTEL_BASEDIR}/lib"

[ $? -ne 0 ] &&
unset KARTEL_BASEDIR
