================================================================================
kartel - Σύστημα ηλεκτρονικής καταγραφής και ελέγχου εισόδου/εξόδου
================================================================================

Πρόκειται για προγράμματα που αφορούν στις κάρτες ελέγχου πρόσβασης στο Δήμο
Θεσσαλονίκης. Το πρόγραμμα εκπονήθηκε από προγραμματιστές του Τμήματος
Μηχανογραφικής Υποστήριξης (ΤΜΥ) της Διεύθυνσης Επιχειρησιακού Προγραμματισμού
και Συστημάτων ΤΠΕ (ΔΕΠΣΤΠΕ). Πιο συγκεκριμένα, με το θέμα ασχολήθηκαν οι:

-Ηλίας Στραβάκος
-Δώρα Καργάκη
-Ανδρέας Κορδονούρης
-Πάνος Παπαδόπουλος

Στο πρόγραμμα συμμετέχει, επίσης, ο Θέμης Παπαδόπουλος του Τμήματος Επιθεώρησης
Εργασίας της Διεύθυνσης Ανθρώπινων Πόρων.

Από την πλευρά της εταιρείας (ΖΑΡΙΦΟΠΟΥΛΟΣ) συμμετείχαν οι Νίκος Ζώκας, Γιάννης
Μελετιάδης, Νίκος Ιωαννίδης και Λευτέρης Χριστοδούλου.
________________________________________________________________________________

Την Πέμπτη, 21 Φεβρουαρίου 2019, ο Πάνος και η Δώρα δημιούργησαν repository
στο bitbucket:

https://panos1962@bitbucket.org/panos1962/kartel

--------------------------------------------------------------------------------
Εισαγωγή
--------------------------------------------------------------------------------
Η διοίκηση του Δήμου Θεσσαλονίκης αποφάσισε κατά το έτος 2019 να εφαρμόσει
σύστημα ελέγχου εισόδου/εξόδου των υπαλλήλων του ΔΘ. Το σύστημα θα εφαρμοστεί
αρχικά στο κτίριο του Νέου Δημαρχιακού Μεγάρου (ΝΔΜ), στο κτίριο της Κεντρικής
Βιβλιοθήκης (ΚΔΒ) και στο Κέντρο Ιστορίας Θεσσαλονίκης (ΚΙΘ). Το σύστημα θα
υλοποιηθεί από το υπάρχον δίκτυο καρταναγνωστών του ΝΔΜ, το οποίο θα επεκταθεί
μελλοντικά στα κτίρια ΚΔΒ και ΚΙΘ. Για το σκοπό αυτό, μετά από τρείς άγονους
διαγωνισμούς, ανατέθηκε στην εταιρεία "ΖΑΡΙΦΟΠΟΥΛΟΣ" το έργο της αναβάθμισης
και επέκτασης του σχετικού δικτύου.

*** Σημαντικές παρατηρήσεις ***

Το σύστημα ελέγχει και καταγράφει συμβάντα που αφορούν τόσο την είσοδο/έξοδο
των υπαλλήλων, όσο και τον έλεγχο της πρόσβασης σε διάφορους χώρους του ΝΔΜ που
διαθέτουν ηλεκτρονικές κλειδαριές (αποθήκες, κατανεμητές, χώροι Η/Μ κλπ).

Οι κάρτες που θα χρησιμοποιηθούν για είσοδο/έξοδο των υπαλλήλων, αν και μπορούν
να χρησιμοποιηθούν και για πρόσβαση σε χώρους που διαθέτουν ηλεκτρονικές
κλειδαριές, θα χρησιμοποιηθούν μόνο για την καταγραφή της ώρα εισόδου/εξόδου
των υπαλλήλων. Οι κάρτες που χρησιμοποιούνται για την ελεγχόμενη πρόσβαση θα
είναι ξεχωριστές και θα έχουν τις προσήκουσες προσβάσεις και είτε θα είναι
προσωπικές (συντηρητές, ηλεκτρολόγοι κλπ), είτε φυλάσσονται από αρμόδιους
υπαλλήλους διαφόρων υπηρεσιών (αρχεία, αποθήκες κλπ). Αυτό κρίθηκε αναγκαίο
για λόγους ασφαλείας αλλά και για λόγους απλότητας. Πράγματι, οι κάρτες
ελέγχου εισόδου/εξόδου των υπαλλήλων μπορούν να εντάσσονται σε συγκεκριμένο
access level και με τον τρόπο αυτό μπορούν να ξαναχρησιμοποιηθούν, ενώ σε
περίπτωση απώλειας ή κλοπής δεν μπορούν να χρησιμοποηθούν για πρόσβαση σε
φυλασσόμενους χώρους.

--------------------------------------------------------------------------------
Περιγραφή λειτουργίας του συστήματος
--------------------------------------------------------------------------------
Οι εργαζόμενοι θα χτυπάνε κάρτα κατά την προσέλευση και κατά την αποχώρησή τους
από την εργασία. Τα χτυπήματα αυτά θα καταγράφονται σε server που βρίσκεται στο
ΚΥΣ· ο εν λόγω server θα ονομάζεται WP και τρέχει το πρόγραμμα WIN-PAK SE 4.6
της Honeywell με πέντε (5) άδειες λειτουργίας. Ο εν λόγω server διαθέτει
λειτουργικό Windows 10 και το πρόγραμμα WIN-PAK χρησιμοποιεί τον Microsoft SQL
server ως DBMS.

Τα στοιχεία που μας ενδιαφουν είναι το νούμερο της κάρτας, ο καρταναγνώστης και
το timestamp. Παρέχεται, επίσης, η δυνατότητα παραλαβής αυτών των στοιχείων
μέσω δικτύου είτε online είτε on demand για οποιοδήποτε χρονικό διάστημα.
Ωστόσο, στο μέλλον, και μετά την εξασφάλιση των ιστορικών στοιχείων που μας
ενδιαφέρουν, πιθανόν να διαγράφονται τα παλαιά ιστορικά στοιχεία από τον WP
server.

Για τις ανάγκες του συστήματος χρησιμοποιείται και δεύτερος server στο ΚΥΣ, που
ονομάζεται AS (application server) και τρέχει λειτουργικό Linux Ubuntu 16.04.
Στον εν λόγω server έχει εγκατασταθεί ο SQL client της Microsoft "sqlcmd" ο
οποίος παρέχεται από την Microsoft δωρεάν, και μέσω του οποίου δίδεται πρόσβαση
στον server WP προκειμένου να παραλάβουμε τα συμβάντα που αφορούν στη χρήση των
καρτών είτε για είσοδο/έξοδο, είτε για πρόσβαση σε φυλασσόμενους χώρους.

Στον ίδιο server έχει εγκατασταθεί DBMS "MySQL" ή "MariaDB" και βάση δεδομένων
"kartel" στην οποία φυλάσσονται τα συμβάντα που παραλαμβάνονται από τον server
WP μέσω του προγράμματος "kartel" που βασίζεται στον "sqlcmd". Παράλληλα έχει
εγκατασταθεί ο SPAWK που επιτρέπει την πρόσβαση σε MySQL/MariaDB databases
μέσω του awk.

Επίσης, στον ίδιο server έχει εγκατασταθεί ORACLE client προκειμένου να δοθεί
πρόσβαση στην database του ΟΠΣΟΥ και πιο συγκεκριμένα σε χρήσιμους πίνακες του
υποσυστήματος Προσωπικού/Μισθοδοσίας. Συνεπώς, στην database "kartel" εκτός από
τα συμβάντα που παραλαμβάνουμε από τον WP server, θα φυλάσσονται και κάποια
στοιχεία προσωπικού από το ΟΠΣΟΥ, π.χ. στοιχεία ταυτότητας εργαζομένων, άδειες,
αριθμοί καρτών πρόσβασης, ωράριο, οργανικές μονάδες κλπ. Με τα εν λόγω στοιχεία
θα μπορούν να δημιουργούνται πάσης φύσεως είδους reports για οποιαδήποτε
χρονική περίοδο, για οποιονδήποτε εργαζόμενο ή ομάδα εργαζομένων κλπ.

--------------------------------------------------------------------------------
Θέματα πρόσβασης στον WS και στην database [WIN-PAK PRO]
--------------------------------------------------------------------------------
aksjhdgkjashdjkasd

--------------------------------------------------------------------------------
Τεχνικά θέματα που αφορούν στο λογισμικό εφαρμογών
--------------------------------------------------------------------------------
Τα προγράμματα εφαρμογών εγκαθίστανται σε Linux server, κατά προτίμηση Ubuntu
16.04, με ειδικά προγράμματα εγκατάστασης.

--------------------------------------------------------------------------------
Θέματα που αφορούν στην αποστολή μηνυμάτων ηλεκτρονικού ταχυδρομείου
--------------------------------------------------------------------------------
Εφόσον στο δίκτυό μας διαθέτουμε mail server, μπορούμε να στέλνουμε μηνύματα
στους κατόχους καρτών για κάθε καρτανάγνωση που τους αφορά. Για να συμβεί αυτό
θα πρέπει να καθορίσουμε στο command line του "kartel" τις παραμέτρους της
επικοινωνίας μας με τον mail server. Αυτό γίνεται μέσω της option "-M" με
όρισμα της μορφής "[user@]host[,port]", π.χ. -M mail.tessaloniki.gr που
σημαίνει ότι ο maile server είναι ο "mail.thessaloniki.gr" και ο χρήστης
είναι ο default χρήστης "kartel", ενώ το port είναι η default ssh port του
mail server. Αν δώσουμε -M "panos@10.78.2.3,2222" σημαίνει ότι ο mail server
είναι η μηχανή με IP "10.78.2.3", ότι υπάρχει εκεί χρήστης με login name "panos"
με δικαιώματα εκτέλεσης των προγραμμάτων της remote ομάδας "kartel", και ότι η
ssh port του mail server είναι η "2222".

Όσα αρχεία έχουν όνομα που καταλήγει σε ".sh" θεωρούνται -και πρέπει να είναι-
bash shell scripts. Αυτά τα αρχεία κατά την εγκατάσταση περνούν από φίλτρο
αποκοπής σχολίων, κενών γραμμών και άλλων «λευκών» χαρακτήρων προκειμένου από
τη μια μεριά να γίνουν μικρότερα, αλλά και από την άλλη να καταστούν αρκετά
δυσανάγνωστα για επίδοξους λογισμοκάπηλους.
