#!/usr/bin/env bash

[ -z "${KARTEL_BASEDIR}" ] &&
KARTEL_BASEDIR="/var/opt/kartel"

pd_tmpdir="${KARTEL_BASEDIR}/tmp"
pd_tmpmax=3

. "${KARTEL_BASEDIR}/lib/kartel.sh" ||
exit 2

pd_seterrcode \
	"noperm" \
	"procerr" \
	"wperr" \
	"sqlcmderr" \
	"rowiderr" \
	"apoeoserr" \
	"dberr" \
	"dmnerr" \
	""

# Μας χρειάζονται τρία προσωρινά αρχεία τα οποία χρησιμοποιούνται
# εκ περιτροπής για διάφορες χρήσεις, όπως για την κατασκευή τού
# SQL query, για την αποθήκευση των αποτελεσμάτων κλπ.

tmp1="${pd_tmpname[1]}"
tmp2="${pd_tmpname[2]}"
tmp3="${pd_tmpname[3]}"

pd_sigtrap

# Η environment variable "KARTEL_BASEDIR" δείχνει το absolute pathname του
# directory στο οποίο έχει εγκατασταθεί το πακέτο "kartel", συλλογής, ελέγχου
# και επεξεργασίας ηλεκτρονικών δεδομένων ημερομηνίας και ώρας εισόδου/εξόδου
# των εργαζομένων που δημιουργούνται από καρταναγνώσεις, τουτέστιν περάσματα
# των καρτών εοσόδου/εξόδου από αισθητήρες που βρίσκονται σε διάφορα σημεία
# διαφόρων κτιρίων και ονομάζονται καρταγνώστες.
#
# Οι καρταναγνώστες ελέγχονται από controllers συνδεδεμένους στο δίκτυο, μέσω
# των οποίων επικοινωνούν με το πρόγραμμα "WIN-PAK SE 4.6" της εταιρείας
# Honeywell. Το συγκεκριμένο πρόγραμμα έχει εγκατασταθεί σε Windows 10 virtual
# server και αποτελεί ένα user friendly interface μιας SQL server database στην
# οποία καταχωρούνται όλα τα δεδομένα καρτών, καρταναγνωστών, χρηστών, επιπέδων
# πρόσβασης και λοιπών στοιχείων που αφορούν σε συγκεκριμένο site, εν προκειμένω
# στον Δήμο Θεσσαλονίκης.
#
# Παράλληλα, καταχωρούνται στην ίδια database όλα τα συμβάντα, π.χ. καταχώρηση,
# ενεργοποίηση και απενεργοποίηση καρτών, δημιουργία, επεξεργασία και διαγραφή
# δικαιωμάτων πρόσβασης σε ηλεκτρονικές κειδαριές κλπ. Τα συμβάντα που αφορούν
# στο παρόν πρόγραμμα είναι συγκεκριμένου τύπου και αφορούν τα περάσματα καρτών
# από καρταναγνώστες. Πράγματι, το παρόν πρόγραμμα επικοινωνεί με την εν λόγω
# database και συλλέγει τα περάσματα των καρτών, τα οποία καταχωρεί σε άλλη
# database η οποία αποτελεί τη βάση για όλα τα προγράμματα ελέγχου και περαιτέρω
# επεξεργασίας των δεδομένων αυτών.

# Για λόγους ευκρίνειας και ευαναγνωσιμότητας του προγράμματος,
# πολλές λειτουργίες έχουν εγκιβωτιστεί σε shell functions και
# έχουν τοποθετηθεί σε άλλο shell script. Το κακό είναι ότι σε
# αυτές τις functions υπάρχουν αναφορές σε global αντικείμενα
# με αποτέλεσμα ο κώδικας να είναι κάπως sloppy και ευεπίφορος
# σε λάθη και αστοχίες.

. "${KARTEL_BASEDIR}/lib/kartel/util.sh" ||
pd_exit "fserr"

# Το process id του προγράμματος θα μας χρειαστεί όχι μόνο για
# τη δημιουργία βολικών ονομάτων των απαιτουμένων προσωρινών
# αρχείων, αλλά και κατά το poll mode προκειμένου να γνωρίζουμε
# αν πρόκειται για την αρχική κλήση του προγράμματος, ή για τις
# μετέπειτα κλήσεις. Αυτός ο έλεγχος γίνεται με τη βοήθεια τής
# environment variable "KARTEL_POLL_PID" η οποία τίθεται μετά
# την αρχική κλήση του προγράμματος και πριν το πρώτο polling.

pid="$$"

test=

# Η μεταβλητή "sqlcmd" είναι το όνομα του SQL client που επικοινωνεί με SQL
# servers της Microsoft. Συνήθως πρόκειται για το πρόγραμμα "sqlcmd" το οποίο
# διατίθεται δωρεάν από την εταιρεία Micorsoft. Αν ο συγκεκριμένος SQL client
# δεν μας ικανοποιεί και προτιμάμε κάποιον άλλον SQL client, τότε μπορούμε να
# καταφύγουμε στην option "-S" με όρισμα τον SQL client που επιθυμούμε. Βεβαίως
# σ' αυτήν την περίπτωση θα πρέπει να προσαρμοστούν ανάλογα τόσο το συντακτικό
# του SQL query, όσο και οι options του "sqlcmd". Επομένως, η πιο πιθανή χρήση
# ενός άλλου SQL client είναι για λόγους ελέγχου και αποσφαλμάτωσης με τη χρήση
# phony SQL clients. Ένας τέτοιος client παρέχεται στο "lib/kartel/phonysql" και
# είτε μπορεί να χρησιμοποιηθεί ως έχει, μέσω των options "T" ή "--test", είτε
# μπορεί να αποτελέσει οδηγό για τη συγγραφή παρόμοιου, ad hoc phony SQL client
# που ενδεχομένως να είναι πιο βολικός για τον προγραμματιστή. Μπορούμε, επίσης,
# να καθορίσουμε τον SQL client μέσω της "KARTEL_SQLCMD" environment variable,
# αλλά ο καθορισμός τού SQL client μέσω της option "-S" υπερτερεί. 

sqlcmd="${PANDORA_BASEDIR}/bin/pd_sqlcmd"

# Η μεταβλητή "rows" δείχνει το πλήθος των συμβάντων που θα πάρουμε από τον
# WIN-PAK server. By default ζητάμε τις δέκα πρώτες γραμμές που θα επιλεγούν από
# το SQL query. Αν καθορίσουμε μηδενικό πλήθος γραμμών, σημαίνει ότι ζητάμε όλες
# τις γραμμές που θα επιστραφούν από το SQL query· εξαίρεση σ' αυτόν τον κανόνα
# αποτελεί η κλήση σε poll mode, όπου το μηδενικό πλήθος εννοείται κυριολεκτικά,
# καθώς σε poll mode το πρόγραμμα εκκινεί τυπώνοντας τις δέκα τελευταίες γραμμές
# των αποτελεσμάτων του SQL query. Επομένως, αν δώσουμε μηδενικό πλήθος γραμμών
# σε poll mode, τότε το πρόγραμμα εκκινεί χωρίς αρχική εκτύπωση γραμμών. Για τον
# καθορισμό τού πλήθους γραμμών που επιθυμούμε χρησιμοποιούμε τις optionς "-n" ή
# "--rows" με όρισμα το επιθυμητό πλήθος γραμμών.

rows=

# Η μεταβλητή "ofs" χρησιμοποιείται ως output field separator, τόσο από τον SQL,
# όσο και κατά το τελικό output που παράγει το πρόγραμμα. By default ως output
# field separator χρησιμοποιείται ο χαρακτήρας tab. Για να ορίσουμε διαφορετικό
# output field separator χρησιμοποιούμε τις options "-s" ή "--separator" με
# όρισμα τον χαρακτήρα που επιθυμούμε. O output field separator δεν μπορεί να
# έχει μήκος μεγαλύτερο από ένα, τουτέστιν πρέπει να είναι ένας μοναδικός
# χαρακτήρας και όχι οποιοδήποτε string μεγαλύτερου μήκους.

ofs=

# Η μεταβλητή cards, εφόσον έχει οριστεί, περιέχει τους αριθμούς των καρτών στις
# οποίες θα περιοριστεί το σχετικό SQL query. Πρόκειται για έναν ή περισσότερους
# αριθμούς καρτών χωρισμένους μεταξύ τους με χαρακτήρες που δεν είναι αριθμητικά
# ψηφία, π.χ. "40601,9182:33015" σημαίνει τις κάρτες με αριθμούς "40601", "9182"
# και "33015". Για τον καθορισμό των επιθυμητών αριθμών καρτών καταφεύγουμε στις
# options "-C" ή "--cards" με όρισμα έναν ή περισσότερους αριθμούς καρτών. Δεκτή
# γίνεται, επίσης, η επανάληψη της option στο command line περισσότερες από μια
# φορές, οπότε η λίστα των επιθυμητών αριθμών καρτών εμπλουτίζεται με τους νέους
# αριθμούς που καθορίζονται κάθε φορά.

cards=

# Η μεταβλητή "rdtype" περιέχει τον «τύπο» των καρταναγνωστών στους οποίους θα
# περιοριστεί το SQL query. Ο τύπος των καρταναγνωστών δεν είναι κάποιο τεχνικό
# χαρακτηριστικό του καρταναγνώστη, αλλά καθορίζεται από την κωδική ονομασία τής
# συσκευής, που περιέχεται στο πεδίο [Name] του πίνακα [HWIndependentDevices].
# Καθορίζουμε τον επιθυμητό τύπο καρταναγνωστών με τις options "-k" ή "--rdtype"
# με όρισμα "IN", "OUT" ή "ACCESS". Ωστόσο γίνονται δεκτά τμήματα των ορισμάτων
# αυτών και μάλιστα χωρίς να λαμβάνεται υπόψη το αν αυτά καθορίζονται με πεζά ή
# κεφαλαία γράμματα. Μπορούμε, ακόμη, να καθορίσουμε περισσότερους από έναν τύπο
# καρταναγνωστών, είτε με επαναλαμβανόμενη χρήση των παραπάνω options, είτε με
# ορίσματα που περιέχουν επιθυμητούς τύπους καρταναγνωστών χωρισμένους μεταξύ
# τους με κόμματα ή άλλους χαρακτήρες, π.χ. "i" σημαίνει καρταναγνώστες τύπου
# "IN", ενώ "o,ACC" σημαίνει καρταναγνώστες τύπου "OUT" και "ACCESS".

rdtype=

# By default τα αποτελέσματα που λαμβάνουμε από τον WIN-PAK server μέσω του SQL
# είναι οι νεότερες εγγραφές τού πίνακα [History] που αφορούν μόνο σε περάσματα
# καρτών, δηλαδή λαμβάνουμε συμβάντα από τα πιο πρόσφατα προς τα παλαιότερα. Για
# να αλλάξουμε τη σειρά από τα παλαιότερα προς τα πιο πρόσφατα, χρησιμοποιούμε
# την option "-r".

sqlorder="DESC"

# Η τελική εκτύπωση των αποτελεσμάτων που λαμβάνουμε από τον WIN-PAK server μέσω
# του SQL γίνεται με αύξουσα σειρά ως προς το [RecordID], δηλαδή, ασχέτως με τη
# σειρά με την οποία επελέγησαν τα συμβάντα, αυτά εκτυπώνονται με σειρά από τα
# παλαιότερα προς τα πιο πρόσφατα. Για να αλλάξουμε τη σειρά τής εκτύπωσης, από
# τα πιο πρόσφατα προς τα παλαιότερα, χρησιμοποιούμε την option "-R".

srtorder=

# Ακολουθούν μεταβλητές που αφορούν στα όρια που μπορούμε να θέσουμε προκειμένου
# να περιορίσουμε τα αποτελέσματα είτε χρονικά με βάση το πεδίο [GenTime], είτε
# ως προς τον αύξοντα αριθμό συμβάντος με βάση το πεδίο [RecordID]. Ο καθορισμός
# των ορίων αυτών γίνεται με τις options "-a", "-A", "-e" και "-E" με ορίσματα
# τα επιθυμητά όρια. Πιο συγκεκριμένα, με την option "-a" θέτουμε κάτω όριο με
# τελεστή ελέγχου ">=", π.χ. "-a '2019-04-30 08:00'" σημαίνει ότι επιθυμούμε
# συμβάντα που συνέβησαν από τη συγκεκριμένη χρονική στιγμή και μετά,
# συμπεριλαμβανομένης και της στιγμής αυτής. Αν ως όρισμα δεν δώσουμε string
# ημερομηνίας ή ώρας, αλλά έναν θετικό ακέραιο αριθμό, τότε το όριο εκλαμβάνεται
# ως [RecordID] και όχι ως [GenTime], πράγμα που σημαίνει ότι το είδος του ορίου
# εξαρτάται από τη μορφή τού ορίσματος, π.χ. αν καθορίσουμε "-a 19835" σημαίνει
# ότι επιθυμούμε συμβάντα με [RecordID] >= 19835, ενώ "-a '2019-04-30'" σημαίνει
# ότι επιθυμούμε συμβάντα με [GenTime] >= 2019-04-30 00:00:00. Αν επιθυμούμε τον
# τελεστή ">" αντί του ">=" μπορούμε να χρησιμοποιήσουμε την option "-A" με τον
# ίδιο ακριβώς τρόπο. Το πρόγραμμα δέχεται και χρονικά όρια στα οποία μπορούμε
# να καθορίσουμε μόνο την ώρα, π.χ. "8:30", "9:10", "12:35:10" κλπ. Σ' αυτήν την
# περίπτωση υποτίθεται η ημερομηνία που καθορίστηκε τελευταία στο command line,
# πριν τον καθορισμό τής εν λόγω χρονικής παραμέτρου· σε περίπτωση που δεν έχει
# καθοριστεί τέτοια ημερομηνία σε προηγούμενο όρισμα, τότε υποτίθεται η τρέχουσα
# ημερομηνία.

apo=
apocol=
apo_op=

# Οι μεταβλητές που ακολουθούν είναι αντίστοιχες με τις μεταβλητές
# που καθορίζουν το κάτω όριο των συμβάντων, αλλά αφορούν τα επάνω
# όρια με μια σημαντική διαφορά: Η option "-e" δέχεται ως όρισμα το
# επάνω όριο, αλλά ο τελεστής αντί του πιθανώς αναμενόμενου "<=",
# είναι "<" ενώ αντίστροφα, με την option "-E" τίθεται ο τελεστής
# "<=" αντί του πιθανώς αναμενόμενου "<". Αυτό συμβαίνει επειδή τα
# συνήθη διαστήματα, κυρίως χρονικών ελέγχων, είναι της μορφής "[)"
# και όχι "[]" ή "()" κλπ. Επομένως οι options "-a 2019-04-30 08:15"
# και "-e 2019-04-30 09:00" θα μας δώσουν γεγονότα που συνέβησαν
# στις 30 Απριλίου 2019, από την ώρα 08:15:00 και μετά, έως και
# την ώρα 08:59:59.

eos=
eoscol=
eos_op=

# Η μεταβλητή "today" τίθεται με την option "-t" και υποδηλώνει
# διάστημα που αφορά στη σημερινή ημερομηνία. Παράλληλα, θέτει
# την default ημερομηνία για τυχόν επόμενα καθαρά ωριαία χρονικά
# όρια, στη σημερινή ημερομηνία.

today=

# Η μεταβλητή "yesterday" τίθεται με την option "-y" και υποδηλώνει
# διάστημα που αφορά τη χθεσινή ημερομηνία. Οι options "-t" και "-y"
# μπορούν να δοθούν και οι δύο, οπότε το διάστημα είναι αφορά από
# τη χθεσινή ημερομηνία έως τη σημερινή. Όπως συμβαίνει και με την
# option "-t", η option "-y" θέτει την default ημερομηνία για τυχόν
# επόμενα καθαρά ωριαία χρονικά όρια, στη χθεσινή ημερομηνία.

yesterday=

# Η μεταβλητή "poll" τίθεται με την option "--poll" και δηλώνει ότι το
# πρόγραμμα θα τρέξει σε poll mode. Αυτό σημαίνει ότι το πρόγραμμα θα
# κάνει κλήσεις στον WIN-PAK server σε τακτά χρονικά διαστήματα και θα
# επιστρέφει τα νέα συμβάντα που ίσως έχουν προκύψει και συμφωνούν με
# τα υπόλοιπα κριτήρια που ενδεχομένως έχουν δοθεί στο command line.
# Το default διάστημα μεταξύ των κλήσεων είναι ένα δευτερόλεπτο, αλλά
# μπορούμε να καθορίσουμε μεγαλύτερο ή μικρότερο διάστημα με χρήση τής
# option "-d" με όρισμα το διάστημα που επιθυμούμε (σε δευτερόλεπτα)·
# το διάστημα μπορεί να είναι και δεκαδικός αριθμός, π.χ. 1.5, 0.5 κλπ,
# αλλά υπάρχει κάποιο όριο στο πόσο μικρό μπορεί να είναι το εν λόγω
# διάστημα. Το συγκεκριμένο όριο είναι της τάξης κάποιων δεκάτων τού
# δευτερολέπτου.

poll=

# Η μεταβλητή "count" τίθεται με την option "-c" με όρισμα έναν
# θετικό ακέραιο αριθμό που υποδηλώνει το πλήθος των κλήσεων που θα
# κάνει το πρόγραμμα, εφόσον τρέχει σε poll mode. Αν το πρόγραμμα
# δεν τρέχει σε poll mode, τότε η εν λόγω παράμετρος δεν θα ληφθεί
# υπόψιν.

count=

# Όταν το πρόγραμμα τρέχει σε poll mode, εκτυπώνει μηνύματα με την
# ώρα και τον αύξοντα αριθμό κλήσης στο standard error πριν από κάθε
# κλήση. Η μεταβλητή "quiet" καθορίζει το αν θα τυπώνονται ή όχι αυτά
# τα μηνύματα. Με την option "-q" χωρίς όρισμα αποφεύγουμε την εκτύπωση
# σχετικών μηνυμάτων.

quiet=

# Η μεταβλητή "mail" αφορά στο αν το πρόγραμμα θα επιχειρεί να
# αποστείλει email στον κάτοχο της κάρτας. By default το πρόγραμμα
# δεν αποστέλλει email στους κατόχους των καρτών, αλλά μπορούμε να
# ενεργοποιήσουμε την αποστολή μηνυμάτων με την option "-M" με όρισμα
# το IP ή το όνομα του mail server.

mail=

dbmode=

print="yes"

verbose="yes"

# Η μεταβλητή "maxrid" προορίζεται να τεθεί στο max [RecordID] των
# υφισταμένων [History] rows, πριν εκτελεστεί το query επιλογής τών
# ζητουμένων rows. Αυτό μπορεί να φανεί χρήσιμο στην επιτάχυνση τών
# διαδικασιών αναζήτησης, είδικά όταν το πρόγραμμα τρέχει σε poll mode.
# Η μεταβλητή τίθεται μέσω της "KARTEL_POLL_MAXRID" environment variable
# η οποία αγνοείται στην αρχική κλήση τού προγράμματος· η μεταβλητή
# τίθεται από το ίδιο το πρόγραμμα στις κλήσεις που κάνει στο εαυτό
# του όταν το πρόγραμμα τρέχει σε poll mode. Αν, ωστόσο, επιθυμούμε
# να ορίσουμε κάτω όριο στο [RecordID], τότε μπορούμε να καταφύγουμε
# στις options "-a" ή "-A" με όρισμα το επιθυμητό rowid.

maxrid=

# Η μεταβλητή "debug" δείχνει αν το πρόγραμμα τρέχει σε debug mode,
# πράγμα που σημαίνει ότι το πρόγραμμα δεν θα τρέξει το SQL query,
# αλλά θα το τυπώσει στο standard output προκειμένου να ελέγξουμε
# την ορθότητά του. Είναι προφανές ότι θα ενεργοποιήσουμε το debug
# mode όταν λαμβάνουμε μηνύματα λάθους από τον SQL. Ενεργοποιούμε
# το debug mode για τον SQL χρησιμοποιώντας την option "-D" με
# όρισμα "Q", οπότε το πρόγραμμα τυπώνει το κατασκευασθέν SQL
# query και σταματά. Αν δεν επιθυμούμε τη διακοπή του προγράμματος,
# χρησιμοποιούμε ως όρισμα το "q". Υπάρχουν και άλλα ορίσματα για
# την option "-D":
#
#	c	Εκτυπώνει το κατασκευασθέν command line σε poll
#		mode.
#
#	r	Εκτυπώνει τους περιορισμούς που έχουν δοθεί στο
#		command line, π.χ. χρονικά όρια, max rowid κλπ.
#
#	d	Εκτυπώνει το ίδιο το debug string.
#
#	a	Ενεργοποιεί όλες τις παραπάνω debug options.
#
# Τα ίδια ορίσματα μπορούν να δοθούν και με κεφαλαία γράμματα, αντί
# με πεζά· γενικά ισχύει ο κανόνας: αν το όρισμα είναι κεφαλαίο,
# τότε αμέσως μετά την εκτύπωση των μηνυμάτων αποσφαλμάτωσης το
# πρόγραμμα τερματίζει, αλλιώς συνεχίζει.

debug=

# Η μεταβλητή "debugwidth" καθορίζει το πλάτος της σελίδας για το
# output των μηνυμάτων αποσφαλμάτωσης. Μπορούμε να χρησιμοποιήσουμε
# την option "-w" για να καθορίσουμε το εν λόγω πλάτος, ωστόσο αν
# το output των μηνυμάτων αποσφαλμάτωσης είναι τερματικό, τότε το
# πλάτος τίθεται αυτόματα στο πλάτος της οθόνης τού τερματικού.

debugwidth=

# Η global μεταβλητή "dfltdate" είναι η default ημερομηνία που θα
# συμπληρωθεί σε περίπτωση που καθορίσουμε χρονικό όριο μόνο με την
# ώρα, χωρίς να καθορίσουμε ημερομηνία. Αυτή η ημερομηνία αλλάζει
# καθώς διατρέχουμε τα arguments τού command line· αν το argument
# είναι χρονικό όριο στο οποίο καθορίζεται ρητά η ημερομηνία, τότε
# τίθεται ως default date η νέα ημερομηνία η οποία θα ισχύει για
# τα επόμενα command line arguments ωριαίων χρονικών ορίων, μέχρι,
# ενδεχομένως, να αλλάξει και πάλι από επόμενο argument καθορισμού
# χρονικού ορίου.

dfltdate="$(date "+%Y-%m-%d")"

opts="$(getopt -n "${pd_progname}" \
--options ":a:A:e:E:tyC:k:rRn:sS:d:c:qmM:bBlvhHTD:w:" \
--long "ge:,gt:,lt:,le:,today,yestreday,cards:,rdtype:,
sqlorder:,sortorder:,rows:,separator:,
poll,delay:,count:,quiet,silent,mail,database:,print:,verbose,sqlcmd:,
test,usage,help,debug:,width:" -- "$@")" ||
pd_usage

eval set -- "${opts}"
unset opts

parseopts "$@" >"${tmp1}" ||
pd_usage

shift "$(cat "${tmp1}")"
[ $# -ne 0 ] &&
pd_usage

# Η μεταβλητή "opts" κατασκευάζεται στην πορεία και ουσιαστικά ετοιμάζει
# τις command line options για τις επόμενες κλήσεις που θα δρομολογήσει
# το πρόγραμμα, εφόσον έχει κληθεί σε poll mode.

opts=

pd_debug="yes"
debugfix
setmaxrid
testfix
mailfix
tydayfix
cardsfix
ofsfix
apoeosfix
pollfix
dbmodefix
databasefix
procrowsfix
sqlcheck

monitor

sqlquery >"${tmp1}"
sqldebug "${tmp1}"
sqlexec "${tmp1}" >"${tmp2}"

# Για λόγους ευκολίας στο debugging δεν τρέχουμε τις εντολές που
# αφορούν στην αποστολή email receipt σε pipeline.

maildata "${tmp2}" >"${tmp1}"
[ -s "${tmp1}" ] &&
mailrecpt "${tmp1}" | bash

# Αν όλα πήγαν καλά, τα αποτελέσματα του SQL query έχουν μαζευτεί στο
# προσωρινό αρχείο "tmp2". Αν δεν έχουμε polling, τότε τα αποτελέσματα
# ταξινομούνται με βάση τη σειρά ταξινόμησης που είναι αύξουσα ως προς
# το [RecordID], εκτός και αν έχει δοθεί η option "-R" οπότε θα είναι
# φθίνουσα.

if [ -z "${poll}" ]; then
	procrows "${tmp2}" &&
	pd_exit
	
	pd_exit "procerr"
fi

# Έχουμε polling, επομένως θα πρέπει πέρα από την ταξινόμηση των
# αποτελεσμάτων, να εντοπίσουμε το maximum [RecordID] όπως αυτό
# εκτυπώθηκε από την πρώτη εντολή του SQL query. Αυτό το rowid
# το αποθηκεύουμε στο προσωρινό αρχείο "tmp1" και εφόσον είναι
# μεγαλύτερο του μηδενός, το δίνουμε στην επόμενη κλήση μέσω της
# environment variable "KARTEL_POLL_MAXRID" η οποία δεν μπορεί να
# τεθεί στην αρχική κλήση του προγράμαατος

procrows "${tmp2}" "${tmp1}" ||
pd_exit "procerr"

# Έχουν εκτυπωθεί τα αποτελέσματα της αναζήτησης νέων συμβάντων,
# οπότε είναι η κατάλληλη στιγμή να ελέγξουμε αν θα κάνουμε νέο
# polling, ή αν έχουμε εξαντλήσει το μέγιστο πλήθος ελέγχων που
# ενδεχομένως καθορίσαμε στο command line μέσω της option "-c".

[ -n "${count}" ] &&
[ "${KARTEL_POLL_PASS}" -ge "${count}" ] &&
pd_exit

# Δημιουργούμε το κατάλληλο environment για την επόμενη κλήση τού
# προγράμματος προκειμένου αφενός να μειώσουμε το πλήθος τών command
# line arguments, και αφετέρου να μπορούμε να ελέγξουμε αν πρόκειται
# για την αρχική κλήση του προγράμματος ή για μετέπειτα κλήση polling.

export KARTEL_POLL_PID="$$"
export KARTEL_POLL_PASS="$(expr ${KARTEL_POLL_PASS} + 1)"
export KARTEL_POLL_MAXRID="$(cat "${tmp1}")"
export KARTEL_SQLCMD="${sqlcmd}"

[ -n "${test}" ] && opts+=" -T"
[ -n "${cards}" ] && opts+=" -C \"${cards}\""
[ -n "${count}" ] && opts+=" -c \"${count}\""
[ -n "${quiet}" ] && opts+=" -q"
[ -n "${silent}" ] && opts+=" -s"
[ -n "${mail}" ] && opts+=" -m"

cmd="${pd_progfull} -d${poll} ${opts}"
pd_tmpcleanup
pollsleep

cmddebug
eval exec "${cmd}"
