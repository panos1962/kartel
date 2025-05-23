-- Data Dictionary

-- Ακολουθεί το schema της τοπικής database "erpota" που περιέχει τους πίνακες
-- που αφορούν σε παρουσιολόγια, άδειες και εξαιρέσεις. Ως «άδειες» λογίζονται
-- χρονικά διαστήματα κατά τα οποία ο υπάλληλος δεν χτυπά την κάρτα του για
-- συγκεκριμένο λόγο, π.χ. κανονική άδεια, αναρρωτική άδεια, άδεια ανατροφής,
-- ρεπό, διαθεσιμότητα, αργία κλπ, ενώ ως «εξαιρέσεις» λογίζονται συγκεκριμένες
-- αιτιολογίες για τις οποίες ο υπάλληλος δεν χτύπησε κάρτα κατά την προσέλευση
-- ή κατά την αποχώρηση, π.χ. απώλεια κάρτας, εξωτερική εργασία, σεμινάριο κλπ.
--
-- Χρειάζεται ιδιαίτερη προσοχή στην αποφυγή foreign key constraints, π.χ.
-- συσχετισμός άδειας υπαλλήλου με τον υπάλληλο, συσχετισμός πρόσβασης με την
-- οργανική μονάδα κλπ, καθώς οι πίνακες αναφοράς ανήκουν εκ περιτροπής σε δύο
-- δίδυμες βάσεις δεδομένων (erpota1 και erpota2).
--
-- Στο παρόν script υπάρχουν παράμετροι που καθιστούν ευέλικτη την κατασκευή
-- της database. Πιο συγκεκριμένα υπάρχουν οι εξής παράμετροι:
--
--	[[ERPOTADB]]		Είναι το όνομα της database, π.χ. "erpota".

-------------------------------------------------------------------------------@

\! [ -w /dev/tty ] && echo "\nDatabase '[[ERPOTADB]]'" >/dev/tty

-------------------------------------------------------------------------------@

\! [ -w /dev/tty ] && echo "Creating database…" >/dev/tty

DROP DATABASE IF EXISTS `[[ERPOTADB]]`
;

CREATE DATABASE `[[ERPOTADB]]`
DEFAULT CHARSET = utf8
DEFAULT COLLATE = utf8_general_ci
;

USE `[[ERPOTADB]]`
;

SET default_storage_engine = INNODB
;

-------------------------------------------------------------------------------@

\! [ -w /dev/tty ] && echo "Creating tables…" >/dev/tty

CREATE TABLE `argia` (
	`imerominia`	DATE NOT NULL COMMENT 'Από',
	`perigrafi`	VARCHAR(120) NOT NULL DEFAULT '' COMMENT 'Περιγραφή αργίας',

	-- Σε περιπτώσεις ημιαργιών και άλλων ανώμαλων καταστάσεων μπορούμε
	-- να δημιουργήσουμε εγγραφές αργίας στις οποίες να συμπληρώσουμε
	-- τα λεπτά της ώρας που δικαιολογούνται να αφαιρεθούν από το κανονικό
	-- ωράριο. Αν το πεδίο "leptamion" είναι null τότε σημαίνει πλήρη
	-- αργία.

	`leptamion`	TINYINT UNSIGNED NULL DEFAULT NULL COMMENT 'Μειωμένο ωράριο',

	PRIMARY KEY (
		`imerominia`
	) USING BTREE
)

COMMENT = 'Πίνακας αργιών'
;

CREATE TABLE `adia` (
	`kodikos`	MEDIUMINT UNSIGNED NOT NULL AUTO_INCREMENT COMMENT 'Κωδικός αδείας',
	`ipalilos`	MEDIUMINT UNSIGNED NOT NULL COMMENT 'Κωδικός υπαλλήλου',
	`apo`		DATE NOT NULL COMMENT 'Από',
	`eos`		DATE NULL DEFAULT NULL COMMENT 'Έως',
	`idos`		ENUM (
		'ΚΑΝΟΝΙΚΗ',
		'ΓΟΝΙΚΗ ΑΝΑΤΡΟΦΗΣ',
		'ΓΟΝΙΚΗ ΕΠΙΔΟΣΗΣ',

		'ΑΝΑΡΡΩΤΙΚΗ Υ/Δ',
		'ΑΣΘΕΝΕΙΑ',
		'ΑΣΘΕΝΕΙΑ ΤΕΚΝΟΥ',

		'ΑΙΜΟΔΟΣΙΑ',
		'ΡΕΠΟ ΑΙΜΟΔΟΣΙΑΣ',
		'ΡΕΠΟ ΥΠΕΡΩΡΙΑΣ',
		'ΡΕΠΟ',
		'ΣΥΝΔΙΚΑΛΙΣΤΙΚΗ',
		'ΕΚΠΑΙΔΕΥΤΙΚΗ',
		'ΠΕΝΘΟΣ',
		'ΔΙΚΑΣΤΗΡΙΟ',

		'ΑΝΕΥ ΑΠΟΔΟΧΩΝ',
		'ΑΠΟΣΠΑΣΗ',
		'ΔΙΑΘΕΣΙΜΟΤΗΤΑ',
		'ΑΡΓΙΑ',
		'ΠΑΡΑΙΤΗΣΗ',
		'ΑΠΟΛΥΣΗ',
		'ΣΥΝΤΑΞΙΟΔΟΤΗΣΗ',
		'ΛΥΣΗ ΣΧ. ΕΡΓ.',

		'ΕΙΔΙΚΗ ΑΔΕΙΑ'
	) NULL DEFAULT NULL COMMENT 'Είδος αδείας',
	`info`	VARCHAR(1024) NOT NULL DEFAULT '' COMMENT 'Σχόλια',

	PRIMARY KEY (
		`kodikos`
	) USING BTREE,

	INDEX (
		`ipalilos`,
		`apo`
	) USING BTREE
)

COMMENT = 'Πίνακας αδειών'
;

CREATE TABLE `excuse` (
	`ipalilos`	MEDIUMINT UNSIGNED NOT NULL COMMENT 'Κωδικός υπαλλήλου',
	`mera`		DATE NOT NULL COMMENT 'Ημερομηνία αιτιολογίας',
	`proapo`	ENUM (
		'ΠΡΟΣΕΛΕΥΣΗ',
		'ΑΠΟΧΩΡΗΣΗ'
	) NOT NULL COMMENT 'Κατά την προσέλευση ή κατά την αποχώρηση',

	-- Το πεδίο "ora" δείχνει την ώρα προσέλευσης ή αποχώρησης του
	-- υπαλλήλου, εφόσον δεν υπάρχει σχετική καταγραφή μέσω κάρτας.
	-- Σε περίπτωση που αφεθεί null σημαίνει ότι ο υπάλληλος προσήλθε
	-- ή αποχώρησε την προσήκουσα ώρα.

	`ora`		TIME NULL DEFAULT NULL COMMENT 'Ώρα',

	-- Το πεδίο "logos" είναι κωδικοποιημένη επεξήγηση μη καταγραφής
	-- ώρας προσέλευσης ή την αποχώρησης. Περαιτέρω εξηγήσεις μπορούν
	-- να γραφούν εν είδει σχολίων στο πεδίο "info".
	--
	-- Αν το πεδίο έχει null τιμή, τότε σημαίνει ότι ο υπάλληλος
	-- αναιτιολόγητα δεν φρόντισε να καταγραφεί η ώρα προσέλευσης
	-- ή αποχώρησης. Αυτό ισοδυναμεί με την μη εισαγωγή εγγραφής
	-- (record) αιτιολογίας και ο μόνος λόγος που θα προβούμε σε
	-- εισαγωγή record αιτιολογίας είναι η καταγραφή του σχολίου.
	--
	-- Η τιμή "ΕΝΤΑΞΕΙ" σημαίνει ότι ο υπάλληλος θεωρείται εντάξει
	-- με την ώρα προσέλευσης/αποχώρησης, αλλά δεν υπάρχει σχετικό
	-- χτύπημα κάρτας. Σε περίπτωση η υπηρεσιακή μονάδα τού υπαλλήλου
	-- δεν έχει ενταχθεί στο σύστημα καταγραφής, τότε η τιμή "ΕΝΤΑΞΕΙ"
	-- καταχωρείται για όλους τους υπαλλήλους, εφόσον βέβαια προσήλθαν
	-- ή αποχώρησαν κανονικά. Στις περιπτώσεις στις οποίες η υπηρεσιακή
	-- μονάδα τού υπαλλήλου είναι ενταγμένη στο σύστημα καταγραφής,
	-- η τιμή "ΕΝΤΑΞΕΙ" χρησιμοποιείται όποτε ο υπάλληλος επιτελεί
	-- εργασία σε χώρο που δεν διαθέτει καταγραφικά.
	--
	-- Εάν δεν καθοριστεί τιμή για το πεδίο "logos" (null τιμή), τότε
	-- σημαίνει ότι ο υπάλληλος δεν έκανε γνωστή την προσέλευση ή την
	-- αποχώρησή του και ως εκ τούτου ελέγχεται ως απών ή αμελής.

	`logos`		ENUM (
		'ΕΝΤΑΞΕΙ',

		'ΑΣΘΕΝΕΙΑ',
		'ΓΟΝΙΚΗ',
		'ΑΙΜΟΔΟΣΙΑ',

		'ΚΑΡΤΑ/ΑΝΕΥ',
		'ΚΑΡΤΑ/ΑΠΩΛΕΙΑ',
		'ΚΑΡΤΑ/ΒΛΑΒΗ',
		'ΚΑΡΤΑ/ΚΛΟΠΗ',

		'ΟΝΟΜΑΣΤΙΚΗ ΕΟΡΤΗ',
		'ΕΘΝΙΚΗ ΕΟΡΤΗ',
		'ΣΤΑΣΗ',
		'ΑΠΕΡΓΙΑ',
		'ΣΥΝΔΙΚΑΛΙΣΜΟΣ',

		'ΕΚΠΑΙΔΕΥΣΗ',
		'ΔΙΚΑΣΤΗΡΙΟ',
		'ΠΕΝΘΟΣ',
		'ΘΑΝΑΤΟΣ',

		'ΑΛΛΗ ΑΙΤΙΑ'
	) NULL DEFAULT NULL COMMENT 'Αιτιολογία',
	`info`		VARCHAR(1024) NOT NULL DEFAULT '' COMMENT 'Σχόλια',

	PRIMARY KEY (
		`ipalilos`,
		`mera`,
		`proapo` DESC
	) USING BTREE
)

COMMENT = 'Πίνακας αιτιολόγησης μη καταγραφής ώρας προσέλευσης/αποχώρησης'
;

-- Στον πίνακα των προσβάσεων εισάγουμε υπαλλήλους που έχουν πρόσβαση σε
-- συμβάντα άλλων υπαλλήλων. By default ο κάθε υπάλληλος έχει πρόσβαση στα δικά
-- του συμβάντα, δηλαδή σε συμβάντα που αφορούν την κάρτα που είχε σε κάποια
-- χρονική περίοδο.
--
-- Οι προσβάσεις που παρέχονται είναι δύο ειδών: VIEW για έλεγχο, και UPDATE
-- για έλεγχο ΚΑΙ ενημέρωση. Οι προσβάσεις τύπου VIEW δίνουν τη δυνατότητα
-- ελέγχου των συμβάντων, ενώ οι προσβάσεις τύπου UPDATE δίνουν επιπλέον τη
-- δυνατότητα εισαγωγής, τροποποίησης και διαγραφής σε άδειες και εξαιρέσεις.
--
-- Οι προσβάσεις σε συμβάντα άλλων υπαλλήλων δίνονται σε επίπεδο οργανικής
-- μονάδας, τουτέστιν γραφείο, τμήμα, διεύθυνση. Χρειάζεται προσοχή στο πεδίο
-- του κωδικού υπηρεσίας, καθώς ο μη καθορισμός τιμής (null) σημαίνει μόνο
-- ατομικά δικαιώματα, ενώ το κενό σημαίνει πρόσβαση σε όλες τις υπηρεσίες άρα
-- σε όλα τα συμβάντα όλων των υπαλλήλων.
--
-- Σημαντικό ρόλο παίζει επίσης η ημερομηνία εφαρμογής, καθώς η πρόσβαση ισχύει
-- μόνο για συμβάντα που έλαβαν χώρα από την ημερομηνία εφαρμογής και μετά. Αν
-- δεν καθοριστεί ημερομηνία εφαρμογής (null), τότε η πρόσβαση είναι διαχρονική.

CREATE TABLE `prosvasi` (
	`ipalilos`	MEDIUMINT UNSIGNED NOT NULL COMMENT 'Κωδικός υπαλλήλου',
	`efarmogi`	DATE NOT NULL COMMENT 'Ημερομηνία εφαρμογής πρόσβασης',
	`ipiresia`	VARCHAR(20) NULL DEFAULT NULL COMMENT 'Κωδικός υπηρεσίας',
	`level`		ENUM (
		'VIEW',
		'UPDATE',
		'ADMIN'
	) NOT NULL DEFAULT 'VIEW' COMMENT 'Επίπεδο πρόσβασης',
	`info`		VARCHAR(1024) NOT NULL DEFAULT '' COMMENT 'Σχόλια',
	`tilefono`	VARCHAR(30) NOT NULL DEFAULT '' COMMENT 'Τηλέφωνο επικοινωνίας',
	`pubkey`	CHARACTER(40) NULL DEFAULT NULL COMMENT 'Public key',
	`password`	CHARACTER(40) NULL DEFAULT NULL COMMENT 'Password',

	PRIMARY KEY (
		`ipalilos`
	) USING BTREE,

	INDEX (
		ipiresia
	) USING BTREE,

	UNIQUE INDEX (
		pubkey
	) USING HASH
)

COMMENT = 'Πίνακας προσβάσεων'
;

-- Ο πίνακας "omada" περιλαμβάνει τις ομάδες υπαλλήλων που συμμετέχουν σε
-- συγκεκριμένα παρουσιολόγια, π.χ.
--
--	ΤΜΗΜΑ ΜΗΧΑΝΟΓΡΑΦΙΚΗΣ ΥΠΟΣΤΗΡΙΞΗΣ (ΔΕΠΣΤΠΕ), ΤΑΚΤΙΚΟ ΠΡΟΣΩΠΙΚΟ
--	ΤΜΗΜΑ ΜΗΧΑΝΟΓΡΑΦΙΚΗΣ ΥΠΟΣΤΗΡΙΞΗΣ (ΔΕΠΣΤΠΕ), ΠΡΑΚΤΙΚΗ ΑΣΚΗΣΗ
--	ΤΜΗΜΑ ΜΗΧΑΝΟΓΡΑΦΙΚΗΣ ΥΠΟΣΤΗΡΙΞΗΣ (ΔΕΠΣΤΠΕ), ΚΟΙΝΩΦΕΛΗΣ ΕΡΓΑΣΙΑ

CREATE TABLE `omada` (
	`kodikos`	MEDIUMINT UNSIGNED NOT NULL AUTO_INCREMENT COMMENT 'Κωδικός ομάδας',
	`perigrafi`	VARCHAR(100) NOT NULL COMMENT 'Περιγραφή ομάδας',
	`ipiresia`	VARCHAR(20) NULL DEFAULT NULL COMMENT 'Κωδικός υπηρεσίας',
	`anenergi`	DATE NULL DEFAULT NULL COMMENT 'Ημερομηνία απενεργοποίησης',

	PRIMARY KEY (
		`kodikos`
	) USING BTREE,

	INDEX (
		`ipiresia`
	) USING BTREE
)

COMMENT = 'Πίνακας ομάδων παρουσιολογίου'
;

-- Ο πίνακας "melos" επανδρώνει τις ομάδες παρουσιολογίου με συγκεκριμένους
-- υπαλλήλους. Κάθε υπάλληλος μπορεί να ανήκει σε ένα μόνο παρουσιολόγιο ενώ
-- μπορεί να υπάρχουν υπάλληλοι που να μην είναι ενταγμένοι σε κάποια ομάδα.

CREATE TABLE `melos` (
	`omada`		MEDIUMINT UNSIGNED NOT NULL COMMENT 'Κωδικός ομάδας',
	`ipalilos`	MEDIUMINT UNSIGNED NOT NULL COMMENT 'Κωδικός υπαλλήλου',
	`entaxi`	DATE NULL DEFAULT NULL COMMENT 'Ημερομηνία ένταξης',

	INDEX (
		`omada`,
		`ipalilos`
	) USING BTREE,

	UNIQUE INDEX (
		`ipalilos`
	) USING HASH
)

COMMENT = 'Πίνακας συμμετεχόντων σε ομάδες παρουσιολογίου'
;

-- Ο πίνακας "deltio" περιλαμβάνει δύο φύλλα παρουσιολογίου για κάθε ενεργή
-- ομάδα και κάθε ημέρα, ένα για την προσέλευση και ένα για την αποχώρηση
-- των υπαλλήλων τής εν λόγω ομάδας κατά τη συγκεκριμένη ημέρα. Τα δελτία
-- δημιουργούνται καθημερινά από τους αρμόδιους υπαλλήλους κάθε ομάδας και
-- «στελεχώνεται» με τους υπαλλήλους της κάθε ομάδας. Κάθε δελτίο φέρει ως
-- μοναδική ταυτότητα έναν μοναδικό αριθμητικό κωδικό που δίνεται αυτόματα
-- από το σύστημα.

CREATE TABLE `deltio` (
	`kodikos`	MEDIUMINT UNSIGNED NOT NULL AUTO_INCREMENT COMMENT 'Κωδικός δελτίου',
	`imerominia`	DATE NOT NULL COMMENT 'Ημερομηνία',
	`omada`		MEDIUMINT UNSIGNED NOT NULL COMMENT 'Κωδικός ομάδας',
	`proapo`	ENUM (
		'ΠΡΟΣΕΛΕΥΣΗ',
		'ΑΠΟΧΩΡΗΣΗ'
	),

	PRIMARY KEY (
		`kodikos`
	) USING BTREE,

	UNIQUE INDEX (
		`imerominia`,
		`omada`,
		`proapo`
	) USING BTREE
)

COMMENT = 'Πίνακας ημερήσιων δελτίων προσέλευσης και αποχώρησης υπαλλήλων'
;

-- Ο πίνακας "katagrafi" περιλαμβάνει τους υπαλλήλους που συμμετέχουν στα
-- ημερήσια δελτία με τα σχετικά στοιχεία συμβάντων προσέλευσης και αποχώρησης
-- των υπαλλήλων αυτών. Κατά τη δημιουργία του δελτίου δημιουργούνται αυτόματα
-- καταγραφές με βάση την ομάδα του δελτίου και κάποιο χρονικό διάστημα εντός
-- του οποίου θα επιλεγούν συμβάντα από την database "kartel".

CREATE TABLE `katagrafi` (
	`deltio`	MEDIUMINT UNSIGNED NOT NULL COMMENT 'Κωδικός δελτίου',
	`ipalilos`	MEDIUMINT UNSIGNED NOT NULL COMMENT 'Κωδικός υπαλλήλου',

	-- Το πεδίο "meraora" μπορεί να είναι null που σημαίνει ότι δεν υπάρχει
	-- σχετική καταγραφή ημερομηνίας και ώρας προσέλευσης/αποχώρησης του
	-- υπαλλήλου για το συγκεκριμένο δελτίο. Σε αυτή την περίπτωση πρέπει
	-- να υπάρχει σχετική άδεια ή εξαίρεση για τον συγκεκριμένο υπάλληλο
	-- και τη συγκεκριμένη ημερομηνία, αλλιώς θεωρείται αδικαιολητως απών.
	-- ΣΗΜΑΝΤΙΚΟ: Η ημερομηνία του συμβάντος μπορεί να μην συμφωνει με την
	-- ημερομηνία του δελτίου· αυτό μπορεί να συμβεί σε περιπτώσεις όπου
	-- ο υπάλληλος έχει ιδιαίτερο ωράριο όπως φύλακες, αστυνομικοί κοκ.
	-- Επί παραδείγματι ένας υπάλληλος που «πιάνει δουλειά» στις 10 το
	-- βράδυ της Πέμπτης 5 Μαρτίου 2020, και «σχολάει» στις 6 το πρωί της
	-- Παρασκευής 6 Μαρτίου 2020, θα έχει στο δελτίο προσέλευσης της
	-- Πέμπτης (05-03-2020) 2020-03-05 21:52:10, ενώ στο δελτίο αποχώρησης
	-- της ίδιας ημέρας θα έχει αποχώρηση 2020-03-06 06:05:23

	`meraora`	DATETIME NULL DEFAULT NULL COMMENT 'Ημερομηνία και ώρα συμβάντος',

	-- Το πεδίο "event" παρόλο που περιέχει πρωτογενή πληροφορία, θεωρείται
	-- δευτερεύον καθώς περιέχει τον κωδικό συμβάντος που εντόπισε το
	-- πρόγραμμα κατά τη δημιουργία του δελτίου προκειμένου να συμπληρώσει
	-- αρχικά τη χρονική στιγμή προσέλευσης/αποχώρησης του υπαλλήλου στο
	-- πεδίο "meraora" που περιέχει την επίσημη καταγραφή χρόνου συμβάντος.
	-- Άρα το πεδίο "meraora" είναι πρωτεύον ενώ το πεδίο "event" είναι
	-- βοηθητικό.

	`event`		INT UNSIGNED NULL DEFAULT NULL COMMENT 'Κωδικός συμβάντος kartel',

	PRIMARY KEY (
		`deltio`,
		`ipalilos`
	) USING BTREE
)

COMMENT = 'Πίνακας καταγραφών ημερομηνίας και ώρας προσέλευσης/αποχώρησης'
;

COMMIT WORK
;

-------------------------------------------------------------------------------@

\! [ -w /dev/tty ] && echo "Creating views…" >/dev/tty

CREATE VIEW `erpota`.`poupios` AS

SELECT
`erpota1`.`ipalilos`.`kodikos`,
`erpota1`.`ipalilos`.`eponimo`,
`erpota1`.`ipalilos`.`onoma`,
`erpota1`.`ipalilos`.`patronimo`,
`erpota`.`prosvasi`.`tilefono`,
`erpota`.`prosvasi`.`ipiresia`,
`erpota`.`prosvasi`.`level`,
`erpota`.`prosvasi`.`password`

FROM `erpota1`.`ipalilos`, `erpota`.`prosvasi`

WHERE `erpota1`.`ipalilos`.`kodikos` = `erpota`.`prosvasi`.`ipalilos`
;

COMMIT WORK
;

-------------------------------------------------------------------------------@

\! [ -w /dev/tty ] && echo "Inserting data…" >/dev/tty

-------------------------------------------------------------------------------@

\! [ -w /dev/tty ] && echo '\tTable `argia`…' >/dev/tty

INSERT INTO `erpota`.`argia` (
	`imerominia`,
	`perigrafi`,
	`leptamion`
) VALUES
( '2019-06-17', 'Αγίου Πνεύματος', NULL),
( '2019-08-15', 'Δεκαπενταύγουστος', NULL)
;

\! [ -w /dev/tty ] && echo '\tTable `prosvasi`…' >/dev/tty

INSERT INTO `erpota`.`prosvasi` (
	`ipalilos`,
	`efarmogi`,
	`ipiresia`,
	`level`,
	`info`,
	`pubkey`,
	`password`
) VALUES
( 3307, '2019-05-01', '', 'ADMIN', 'Υπεύθυνος προγράμματος', 'xxx', 'b60d121b438a380c343d5ec3c2037564b82ffef3' ),
( 9457, '2019-05-01', '', 'ADMIN', 'Υπεύθυνος προγράμματος', NULL, NULL ),
( 14318, '2019-05-01', '', 'ADMIN', 'Προεξάρχων χειριστής προγράμματος', NULL, NULL ),
( 15955, '2019-05-01', 'Β09', 'UPDATE', 'Προϊστάμενος Διεύθυνσης', NULL, NULL ),
( 5686, '2019-05-01', 'Β09', 'UPDATE', 'Διοικητική Υποστήριξη', NULL, NULL ),
( 4262, '2019-05-01', 'Β09', 'UPDATE', 'Διοικητική Υποστήριξη', NULL, NULL ),
( 16664, '2019-05-01', 'Β090004', 'UPDATE', 'Προϊστάμενος Τμήματος', NULL, NULL ),
( 93411, '2019-05-01', 'Β090001', 'UPDATE', 'Προϊστάμενος Τμήματος', NULL, NULL ),
( 90300, '2019-05-01', 'Β090002', 'UPDATE', 'Προϊσταμένη Τμήματος', NULL, NULL )
;

-- Οι παραπάνω εγγραφές αποτελούν απλά παραδείγματα προσβάσεων, οπότε τις
-- διαγράφουμε.

TRUNCATE TABLE `erpota`.`prosvasi`
;

COMMIT WORK
;

-------------------------------------------------------------------------------@
