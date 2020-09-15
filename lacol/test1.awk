#!/usr/bin/env awk

@include "pandora"
@include "lib/karteldb"

BEGIN {
	OFS = "\t"
	post = "sort -t'	' -k1,3 -k5"
	minas = "2019-06"

ego = " AND `eponimo` LIKE 'ΠΑΠΑΔΟΠ%'"
ego = ""

	query = "SELECT `kodikos` FROM " kartel_erpotadb("ipalilos") \
		" WHERE ((`apoxorisi` IS NULL) OR" \
		" (`apoxorisi` > " spawk_escape(minas "-01") "))" \
ego \
		" ORDER BY `kodikos`"

	if (spawk_submit(query, 2) != 3)
	exit(2)

	while (spawk_fetchrow(ipalilos))
	proc_ipalilos(ipalilos)
}

function proc_ipalilos(ipalilos,			i) {
	if (kartel_ipalilos_fetch(ipalilos))
	return pd_errmsg(ipalilos["kodikos"] ": fetch ipalilos failed")

	for (mera = 1; mera <= 14; mera++) {
		ipalilos["fetchDate"] = sprintf("%s-%02d", minas, mera)

		if (kartel_ipalilos_metavoli_fetch(ipalilos))
		return pd_errmsg(ipalilos["kodikos"] \
			": fetch ipalilos/metavoli failed")

		if (kartel_ipalilos_adia_fetch(ipalilos))
		return pd_errmsg(ipalilos["kodikos"] \
			": fetch ipalilos/adia failed")

	print \
		ipalilos["fetchDate"], \
		ipalilos["ipidie"], \
		ipalilos["ipitmi"], \
		ipalilos["kodikos"], \
		ipalilos["eponimo"], \
		ipalilos["onoma"], \
		ipalilos["patronimo"], \
		ipalilos["karta"], \
		ipalilos["orario"] | post
	}
}
