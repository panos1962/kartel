#!/usr/bin/env bash

datafile="local/data/erpota/prosvasi.tsv"

[ -s "${datafile}" ] &&
[ -r "${datafile}" ] &&
awk \
-i "${PANDORA_BASEDIR}/lib/pandora.awk" \
-i "${KARTEL_BASEDIR}/lib/karteldb.awk" \
-v pd_progname="$0" \
-v datafile="${datafile}" \
-f install/backup/restore.awk
