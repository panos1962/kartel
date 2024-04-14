#!/usr/bin/env gawk

BEGIN {
	FS = "\t"
	OFS = "\t"

	errcnt = 0
	extcnt = 0
	ncols = 8

	not_null["ipalilos"]
	not_null["idos"]
	not_null["tipos"]
	not_null["efarmogi"]

	null2val["lixi"] = "\\N"
	null2val["timi"] = ""
	null2val["dcdval"] = ""

	numeric["ipalilos"]
	numeric["idos"]
	numeric["tipos"]

	metavidos["26@2"] = "ΔΙΕΥΘΥΝΣΗ"
	metavidos["26@3"] = "ΤΜΗΜΑ"
	metavidos["26@4"] = "ΓΡΑΦΕΙΟ"
	metavidos["200@342"] = "ΚΑΡΤΑ"

	pinakas["ΔΙΕΥΘΥΝΣΗ"] = "ipiresia"
	pinakas["ΤΜΗΜΑ"] = "ipiresia"
	pinakas["ΓΡΑΦΕΙΟ"] = "ipiresia"

	dcdval[""]
}

parse_metavoli(metavoli) {
	next
}

fix_metavoli(metavoli) {
	next
}

check_dcdval(metavoli) {
	next
}

{
	print \
	metavoli["ipalilos"], \
	metavoli["idos"], \
	metavoli["efarmogi"], \
	metavoli["lixi"], \
	metavoli["timi"]

	extcnt++
}

END {
	ttymsg("metavoli: " NR " rows processed, " \
		extcnt " rows extracted")

	if (errcnt) {
		ttymsg(errcnt " errors encountered")
		exit(1)
	}

	print_ipiresia()
	exit(0)
}

function parse_metavoli(metavoli,			nf) {
	delete metavoli

	if (NF != ncols) {
		errcnt += pd_errmsg($0 ": syntax error " NF " <> " ncols)
		return 1
	}

	metavoli["ipalilos"] = $(++nf)
	metavoli["idos"] = $(++nf)
	metavoli["tipos"] = $(++nf)
	metavoli["perigrafi"] = $(++nf)
	metavoli["efarmogi"] = $(++nf)
	metavoli["lixi"] = $(++nf)
	metavoli["timi"] = $(++nf)
	metavoli["dcdval"] = $(++nf)

	if (metavoli["timi"] == "ΑΝΕΥ")
	return 1

	return 0
}

function fix_metavoli(metavoli,			i, errs) {
	for (i in not_null) {
		if (pd_notnull(metavoli[i]))
		continue

		pd_errmsg($0 ": null '" i "' column value")
		errs++
	}

	if (errs)
	return 1

	for (i in null2val) {
		if (pd_isnull(metavoli[i]))
		metavoli[i] = null2val[i]
	}

	for (i in numeric)
	metavoli[i] += 0

	i = metavoli["idos"] "@" metavoli["tipos"]

	if (!(i in metavidos))
	return 1

	metavoli["idos"] = metavidos[i]
	delete metavoli["tipos"]

	return 0
}

function check_dcdval(metavoli,			idx, errs) {
	if (!(metavoli["idos"] in pinakas))
	return 0

	if (metavoli["dcdval"] == "") {
		pd_errmsg(metavoli["ipalilos"] ": missing 'dcdval' " \
			"for 'idos' " idx)
		errcnt++
		return 1
	}

	idx = sprintf("%s\t%s", pinakas[metavoli["idos"]], metavoli["timi"])

	if (!(idx in dcdval)) {
		dcdval[idx] = metavoli["dcdval"]
		return 0
	}

	if (metavoli["dcdval"] == dcdval[idx])
	return 0

	pd_errmsg(metavoli["ipalilos"] ": " idx ": >>" \
		dcdval[idx] "<< >>" metavoli["dcdval"] "<<")
	dcdval[idx] = metavoli["dcdval"]
	errcnt++
	return 1
}

function print_ipiresia(		cnt, i) {
	cnt = 0

	for (i in dcdval) {
		split(i, a, "\t")

		if (a[1] != "ipiresia")
		continue

		print a[2], dcdval[i] | "sort >" ipiresia
		delete pinakas[i]

		cnt++
	}

	ttymsg("ipiresia: " cnt " rows extracted")
}
