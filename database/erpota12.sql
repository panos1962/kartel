-- Data Dictionary

-- Ακολουθεί το (κοινό) schema των δίδυμων databases "erpota1" και "erpota2".
-- Ουσιαστικά πρόκειται για τους πίνακες της database "erpota", οι οποίοι
-- ενημερώνονται σε τακτά χρονικά διαστήματα από την απομεμακρυσμένη database
-- "ERPOTA". Παρέχονται δύο εκδόσεις των πινάκων αυτών, οι εκδόσεις 1 και 2,
-- όπου η μία από τις δύο εκδόσεις είναι σε χρήση και η άλλη είναι αυτή που
-- πρόκειται να ενημερωθεί στην επόμενη ενημέρωση.
--
-- Στο script υπάρχουν παράμετροι που καθιστούν ευέλικτη την κατασκευή τής
-- database. Πιο συγκεκριμένα υπάρχουν οι παράμετροι:
--
--	[[ERPOTADB]]		Είναι το κύριο συστατικό τού ονόματος της
--				database, π.χ. "erpota".
--
--	[[ERPOTA12]]		Είναι η version της database (1 ή 2).

-------------------------------------------------------------------------------@

\! [ -w /dev/tty ] && echo "\nDatabase '[[ERPOTADB]][[ERPOTA12]]'" >/dev/tty

-------------------------------------------------------------------------------@

\! [ -w /dev/tty ] && echo "Creating database…" >/dev/tty

DROP DATABASE IF EXISTS `[[ERPOTADB]][[ERPOTA12]]`
;

CREATE DATABASE `[[ERPOTADB]][[ERPOTA12]]`
DEFAULT CHARSET = utf8
DEFAULT COLLATE = utf8_general_ci
;

USE `[[ERPOTADB]][[ERPOTA12]]`
;

SET default_storage_engine = INNODB
;

-------------------------------------------------------------------------------@

\! [ -w /dev/tty ] && echo "Creating tables…" >/dev/tty

CREATE TABLE `ipiresia` (
	`kodikos`	VARCHAR(20) NOT NULL COMMENT 'Κωδικός υπηρεσίας',
	`perigrafi`	VARCHAR(200) NOT NULL COMMENT 'Περιγραφή υπηρεσίας',

	PRIMARY KEY (
		`kodikos`
	) USING BTREE
)

COMMENT = 'Πίνακας υπηρεσιών'
;

CREATE TABLE `ipalilos` (
	`kodikos`	MEDIUMINT UNSIGNED NOT NULL COMMENT 'Κωδικός υπαλλήλου',
	`eponimo`	VARCHAR(100) NOT NULL DEFAULT '' COMMENT 'Επώνυμο υπαλλήλου',
	`onoma`		VARCHAR(100) NOT NULL DEFAULT '' COMMENT 'Όνομα υπαλλήλου',
	`patronimo`	VARCHAR(20) NOT NULL DEFAULT '' COMMENT 'Πατρώνυμο υπαλλήλου',
	`genisi`	DATE NULL DEFAULT NULL COMMENT 'Ημερομηνία γέννησης',
	`afm`		INT UNSIGNED NULL DEFAULT NULL COMMENT 'ΑΦΜ υπαλλήλου',
	`premail`	VARCHAR(100) NULL DEFAULT NULL COMMENT 'Προσωπικό email υπαλλήλου',
	`ipemail`	VARCHAR(100) NULL DEFAULT NULL COMMENT 'Υπηρεσιακό email υπαλλήλου',
	`arxiki`	DATE NULL DEFAULT NULL COMMENT 'Αρχική πρόσληψη/διορισμός',
	`proslipsi`	DATE NULL DEFAULT NULL COMMENT 'Ημερομηνία πρόσληψης',
	`diorismos`	DATE NULL DEFAULT NULL COMMENT 'Ημερομηνία διορισμού',
	`apoxorisi`	DATE NULL DEFAULT NULL COMMENT 'Ημερομηνία αποχώρησης',
	`katastasi`	ENUM (
		'ΕΝΕΡΓΟΣ',
		'ΑΝΕΝΕΡΓΟΣ'
	) NOT NULL COMMENT 'Κατάσταση υπαλλήλου',

	PRIMARY KEY (
		`kodikos`
	) USING BTREE,

	INDEX (
		`eponimo`,
		`onoma`,
		`patronimo`,
		`kodikos`
	) USING BTREE,

	INDEX (
		`afm`
	) USING HASH
)

COMMENT = 'Πίνακας υπαλλήλων'
;

CREATE TABLE `metavoli` (
	`ipalilos`	MEDIUMINT UNSIGNED NOT NULL COMMENT 'Κωδικός υπαλλήλου',
	`idos`		ENUM (
		'ΔΙΕΥΘΥΝΣΗ',
		'ΤΜΗΜΑ',
		'ΓΡΑΦΕΙΟ',
		'ΚΑΡΤΑ'
	) NOT NULL COMMENT 'Είδος μεταβολής',
	`efarmogi`	DATE NOT NULL COMMENT 'Ημερομηνία εφαρμογής',
	`lixi`		DATE NULL DEFAULT NULL COMMENT 'Ημερομηνία λήξης',
	`timi`		VARCHAR(100) NOT NULL DEFAULT '' COMMENT 'Τιμή μεταβολής',

	INDEX (
		`ipalilos`,
		`idos`,
		`efarmogi`
	) USING BTREE,

	INDEX (
		`idos`,
		`timi`,
		`efarmogi`
	) USING BTREE
)

COMMENT = 'Πίνακας μεταβολών παραμέτρων υπαλλήλων'
;

COMMIT WORK
;

-------------------------------------------------------------------------------@

\! [ -w /dev/tty ] && echo "Creating relations…" >/dev/tty

--FK-- metavoli fk_metavoli_ipalilos

ALTER TABLE `metavoli`
ADD CONSTRAINT `fk_metavoli_ipalilos`
FOREIGN KEY (
	`ipalilos`
) REFERENCES `ipalilos` (
	`kodikos`
)
ON UPDATE CASCADE
ON DELETE CASCADE
;

--KF--

COMMIT WORK
;

-------------------------------------------------------------------------------@

\! [ -w /dev/tty ] && echo "Creating views…" >/dev/tty

-- Απομονώνουμε τα βασικά προσωπικά στοιχεία των υπαλλήλων σε ένα view
-- προκειμένου να τα χρησιμοποιούμε με ευκολία σε άλλα views, ή άλλου
-- είδους ενέργειες.

CREATE VIEW `basipal` AS

SELECT
	`ipalilos`.`kodikos` AS `ipalilos`,
	`ipalilos`.`eponimo`,
	`ipalilos`.`onoma`,
	`ipalilos`.`patronimo`,
	`ipalilos`.`genisi`,
	`ipalilos`.`afm`

FROM `ipalilos`
;

-- Το view 'istoriko' περιέχει όλες τις μεταβολές εμπλουτισμένες με τα βασικά
-- προσωπικά στοιχεία των υπαλλήλων.

CREATE VIEW `istoriko` AS

SELECT
	`basipal`.*,
	`metavoli`.`idos`,
	`metavoli`.`efarmogi`,
	`metavoli`.`lixi`,
	`metavoli`.`timi`

FROM `basipal` LEFT JOIN `metavoli`

ON `metavoli`.`ipalilos` = `basipal`.`ipalilos`

ORDER BY
	`basipal`.`ipalilos`,
	`metavoli`.`idos`,
	`metavoli`.`efarmogi`,
	`metavoli`.`lixi`
;

-- Το view 'metakinisi' περιέχει μέρος του view 'istoriko' που αφορά σε
-- μεταβολές ορισμένων τύπων που εμπλέκονται σε τοποθετήσεις και μετακινήσεις
-- των υπαλλήλων.

CREATE VIEW `metakinisi` AS

SELECT
	`istoriko`.*,
	`ipiresia`.`perigrafi`

FROM `istoriko` LEFT JOIN `ipiresia`

ON `istoriko`.`timi` = `ipiresia`.`kodikos`

WHERE `idos` IN (
	'ΔΙΕΥΘΥΝΣΗ',
	'ΤΜΗΜΑ',
	'ΓΡΑΦΕΙΟ'
)

ORDER BY
	`istoriko`.`ipalilos`,
	`istoriko`.`efarmogi`
;

-- Το view 'karta' περιέχει μέρος του view 'istoriko' που αφορά σε μεταβολές
-- σχετικές με τις κάρτες προσέλευσης/αποχώρησης των υπαλλήλων.

CREATE VIEW `karta` AS

SELECT
	`ipalilos`.`kodikos` AS `ipalilos`,
	`ipalilos`.`eponimo`,
	`ipalilos`.`onoma`,
	`ipalilos`.`patronimo`,
	`ipalilos`.`genisi`,
	`ipalilos`.`premail`,
	`ipalilos`.`ipemail`,
	`metavoli`.`efarmogi`,
	`metavoli`.`lixi`,
	`metavoli`.`timi` AS `karta`

FROM `ipalilos` LEFT JOIN `metavoli`

ON `metavoli`.`ipalilos` = `ipalilos`.`kodikos`

WHERE `idos` = 'ΚΑΡΤΑ'

ORDER BY
	`ipalilos`.`kodikos`,
	`metavoli`.`efarmogi`,
	`metavoli`.`lixi`
;

-- Το view 'ipaladia' εμπλουτίζει τις άδειες με τα βασικά στοιχεία των
-- υπαλλήλων.

CREATE VIEW `ipaladia` AS

SELECT
	`basipal`.*,
	`[[ERPOTADB]]`.`adia`.`kodikos`,
	`[[ERPOTADB]]`.`adia`.`apo`,
	`[[ERPOTADB]]`.`adia`.`eos`,
	`[[ERPOTADB]]`.`adia`.`idos`,
	`[[ERPOTADB]]`.`adia`.`info`

FROM `basipal` LEFT JOIN `[[ERPOTADB]]`.`adia`

ON `[[ERPOTADB]]`.`adia`.`ipalilos` = `basipal`.`ipalilos`

ORDER BY
	`basipal`.`ipalilos`,
	`[[ERPOTADB]]`.`adia`.`apo`,
	`[[ERPOTADB]]`.`adia`.`idos`
;

-- Το view 'ipalexcuse' εμπλουτίζει τις δικαιολογημένες εξαιρέσεις με τα βασικά
-- στοιχεία των υπαλλήλων.

CREATE VIEW `ipalexcuse` AS

SELECT
	`basipal`.*,
	`[[ERPOTADB]]`.`excuse`.`mera`,
	`[[ERPOTADB]]`.`excuse`.`proapo`,
	`[[ERPOTADB]]`.`excuse`.`info`

FROM `basipal` LEFT JOIN `[[ERPOTADB]]`.`excuse`

ON `[[ERPOTADB]]`.`excuse`.`ipalilos` = `basipal`.`ipalilos`

ORDER BY
	`basipal`.`ipalilos`,
	`[[ERPOTADB]]`.`excuse`.`mera`,
	`[[ERPOTADB]]`.`excuse`.`proapo` DESC
;

-- Το view 'ipalprosvasi' εμπλουτίζει τις προσβάσεις με τα βασικά στοιχεία των
-- υπαλλήλων.

CREATE VIEW `ipalprosvasi` AS

SELECT
	`basipal`.*,
	`[[ERPOTADB]]`.`prosvasi`.`info`,
	`[[ERPOTADB]]`.`prosvasi`.`efarmogi`,
	`[[ERPOTADB]]`.`prosvasi`.`idos`,
	`[[ERPOTADB]]`.`prosvasi`.`ipiresia`,
	`ipiresia`.`perigrafi`

FROM `basipal`

	INNER JOIN `[[ERPOTADB]]`.`prosvasi`
	ON `[[ERPOTADB]]`.`prosvasi`.`ipalilos` = `basipal`.`ipalilos`

	LEFT JOIN `ipiresia`
	ON `[[ERPOTADB]]`.`prosvasi`.`ipiresia` = `ipiresia`.`kodikos`

ORDER BY
	`[[ERPOTADB]]`.`prosvasi`.`ipiresia`,
	`basipal`.`ipalilos`
;

COMMIT WORK
;

-------------------------------------------------------------------------------@
