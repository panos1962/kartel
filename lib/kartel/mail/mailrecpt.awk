#!/usr/bin/env awk

BEGIN {
	OFS = ": "
	EOD = "+++"

	read_message()
}

{
	if ((NF < 6) || (NF > 8)) {
		pd_errmsg($0 ": syntax error")
		next
	}

	nf = 1

	gsub(/\\/, "\\\\")
	gsub(/"/, "\\\"")

	email = $(nf++)
	rowid = $(nf++)
	card = $(nf++)
	time = $(nf++)
	reader = $(nf++)
	info = $(nf++)

	if (email !~ /^[a-zA-Z][a-zA-Z0-9_.-]*@[a-zA-Z][a-zA-Z0-9_.-]*\.[a-zA-Z]{2,4}$/) {
		pd_errmsg($0 ": invalid email")
		next
	}

	pubkey = (NF > 6 ? $(nf++) : "")
	password = (NF > 7 ? $(nf++) : "")

	gsub(/@/, "#", info)
	gsub(/[&]/, "\\&amp;", info)
	gsub(/[<]/, "\\&lt;", info)
	gsub(/[>]/, "\\&gt;", info)
	gsub(/["]/, "\\&quot;", info)
	gsub(/[']/, "\\&#39;", info)

	mailrecpt(email, rowid, card, time, info, pubkey, password)
	next
}

END {
	print "exit 0"
}

function read_message() {
	if (!messagefile)
	return

	message = pd_readfile(messagefile)
}

function mailrecpt(email, rowid, card, time, info, pubkey, password) {
	print "sendmail -t <<" EOD
	print "To", email
	print "From", mailer
	print "Subject", "Entry/Exit receipt"
	print "MIME-Version", "1.0"
	print "Content-Type", "text/html; charset=UTF-8"
	print "Content-Disposition", "inline"

	print \
	"<html>\n" \
	"<body>"

	if (message)
	print \
	"<p>" \
	message \
	"</p>"

	print \
	"<pre " style_data() ">\n" \
	"RecordID...", "<strong>" rowid "</strong>\n" \
	"Card number", "<strong>" card "</strong>\n" \
	"Date/Time..", "<strong>" time "</strong>\n"

	if (info)
	print \
	"Location...", "<strong>" info "</strong>\n"

	print \
	"</pre>"

	prosvasi_data(pubkey, password, card)

	print \
	"</body>\n" \
	"</html>"

	print EOD
	print "checkerr $? " rowid

	next
}

function prosvasi_data(pubkey, password, card) {
	if (!pubkey)
	return

	print \
	"<hr />" \
	"<p>" \
	"Μπορείτε να δείτε τα συμβάντα που σας αφορούν " \
	kartel_link("εδώ") "." \
	"</p>"

	if (password)
	print \
	"<p>" \
	"Μυστικός κωδικός: <code " style_data() ">" \
	password \
	"</code>" \
	"</p>"

	print \
	"<div " style_notice() ">" \
	"<p " style_simantiko() ">" \
	"Σημαντικό:" \
	"</p>" \
	"<p>" \
	"Μην κοινοποιείτε τη διεύθυνση που σας έχει αποσταλεί!" \
	"</p>"

	if (password)
	print \
	"<p>" \
	"Ο μυστικός κωδικός αποτελεί το κλειδί " \
	"για την πρόσβαση στα συμβάντα που σας αφορούν, επομένως θα πρέπει " \
	"να κρατηθεί μυστικός." \
	"</p>" \
	"<p>" \
	"Για λόγους ασφαλείας είναι καλό να αλλάζετε τον μυστικό κωδικό σας " \
	"σε τακτά χρονικά διαστήματα, π.χ. κάθε δύο μήνες. " \
	"Για να αλλάξετε τον μυστικό κωδικό, " \
	kartel_link("συνδεθείτε") " στην εφαρμογή και κάντε κλικ στo " \
	"ονοματεπώνυμό σας στο επάνω δεξιά μέρος της σελίδας." \
	"</p>"

	print "</div>"
}

function kartel_link(s) {
	return "<a target=\"kartel\" href=\"" kartelurl \
		"/index.php?pubkey=" pubkey "\">" s "</a>"
}

function style_data() {
	return "style=\"font: monospace; font-size: 16px;\"";
}

function style_notice() {
	return "style=\"padding: 0px 4px; max-width: 600px; " \
		"border-style: solid; border-width: 1px; " \
		"border-color: #888888; border-radius: 5px;\""
}

function style_simantiko() {
	return "style=\"font-weight: bold;\""
}
