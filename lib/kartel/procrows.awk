#!/usr/bin/env awk

BEGIN {
	FS = fs
	OFS = fs

	if (verbose)
	spawk_verbose = 1

	errcnt = 0
	rowcnt = 0
	updcnt = 0

	event_table = "`event`"
	event_columns = "`kodikos`, `meraora`, `tipos`, `karta`, `reader`"

	setcols()

	mutli_reader[pd_null]
}

# Το maximum [RecordID] έχει τυπωθεί από τον SQL μόνο του σε
# μια γραμμή, καθώς όταν έχουμε polling, πριν το βασικό query
# τρέχει άλλο query που εκτυπώνει το maximum [RecordID] από τον
# πίνακα [WIN-PAK PRO].[dbo].[History].

NF == 1 {
	print_maxrid($0)
	next
}

NF != 5 {
	pd_errmsg(NF ": invalid [History] data")
	errcnt++
	next
}

{
	procrow()
	rowcnt++
}

END {
	print_stats()

	if (maxridout)
	fatal("missing maximum [RecordID]")

	if (dbmode == "LOAD")
	dbload(datafile)
}

function setcols(			nf) {
	col["kodikos"] = ++nf
	col["meraora"] = ++nf
	col["tipos"] = ++nf
	col["karta"] = ++nf
	col["reader"] = ++nf
}

function print_maxrid(maxrid) {
	if (!maxridout)
	fatal(maxrid ": extra maximum [RecordID]")

	if (maxrid !~ /^[0-9]+$/)
	fatal(maxrid ": invalid maximum [RecordID]")

	print maxrid + 0 >maxridout
	close(maxridout)

	# maxrid has just been saved in a temporary file
	# whose name has been passed to awk via "maxridout"
	# variable. From now on we will use that variable
	# as a flag, just by clearing the file name, in
	# order to state that maxrid has already been saved.

	maxridout = ""
}

function procrow(		reader1, reader2, colrd) {
	colrd = col["reader"]
	reader1 = $(colrd)
	reader2 = reader1
	sub(/:.*/, "", reader2)

	if ((reader2 in multi_reader) && (multi_reader[reader2] != reader1))
	pd_errmsg(reader1 ": multi reader") 

	multi_reader[reader2] = reader1
	$(colrd) = reader2

	if (printrow)
	print

	if (!dbmode)
	return

	dbmode == "LOAD" ?
	dbbulk() : dbrow(dbmode)
}

function dbbulk() {
	gsub(//, "\\N")
	print >datafile
}

function dbrow(dbmode,			event, nf, reader1, reader2, query) {
	event["kodikos"] = $(col["kodikos"])
	event["meraora"] = $(col["meraora"])
	event["tipos"] = $(col["tipos"])
	event["karta"] = $(col["karta"])
	event["reader"] = $(col["reader"])

	query = dbmode " INTO " event_table " (" event_columns ") VALUES (" \
		event["kodikos"] ", " \
		spawk_escape(event["meraora"]) ", " \
		event["tipos"] ", " \
		event["karta"] ", " \
		spawk_escape(event["reader"]) \
	")"

	if (spawk_submit(query) != 2) {
		pd_errmsg($0 ": " dbmode " failed")
		errcnt++
		return
	}

	updcnt++
}

function dbload(datafile,		query) {
	if (!rowcnt)
	return

	close(datafile)
	pd_ttymsg("Loading " rowcnt " 'event' rows…")

	query = "LOAD DATA LOCAL INFILE '" datafile "' " \
		"INTO TABLE " event_table " (" event_columns ")"

	if (spawk_submit(query) != 2)
	fatal("database " dbmode " failed")

	pd_ttymsg(spawk_info)
}

function print_stats(		nonl) {
	nonl = 1

	if (rowcnt)
	pd_ttymsg(rowcnt " rows processed", nonl++)

	if (updcnt)
	pd_ttymsg(", " updcnt " rows updated", nonl++)

	if (nonl > 1)
	pd_ttymsg()
}

function fatal(msg) {
	maxridout = ""
	pd_fatal(msg, 1)
}
