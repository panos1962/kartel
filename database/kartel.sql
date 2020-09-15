-- Data Dictionary

-- Στο παρόν script υπάρχουν παράμετροι που καθιστούν ευέλικτη την κατασκευή
-- της database. Πιο συγκεκριμένα:
--
--	[[KARTELDB]]		Είναι το όνομα της database, π.χ. "kartel".
--
--	[[USERNAME]]		Είναι το όνομα του χρήστη που θα έχει πρόσβαση
--				SELECT, INSERT, UPDATE, DELETE σε όλους τους
--				πίνακες της database, π.χ. "kartel".
--
--	[[USERPASS]]		Είναι το password του παραπάνω χρήστη.

-------------------------------------------------------------------------------@

\! [ -w /dev/tty ] && echo "\nDatabase '[[KARTELDB]]'" >/dev/tty >/dev/tty

-------------------------------------------------------------------------------@

\! [ -w /dev/tty ] && echo "Creating database…" >/dev/tty

-- Πρώτο βήμα είναι η διαγραφή της database εφόσον αυτή υπάρχει ήδη.

DROP DATABASE IF EXISTS `[[KARTELDB]]`
;

-- Με το παρόν κατασκευάζουμε την database.

CREATE DATABASE `[[KARTELDB]]`
DEFAULT CHARSET = utf8
DEFAULT COLLATE = utf8_general_ci
;

-- Καθιστούμε τρέχουσα την database που μόλις κατασκευάσαμε.

USE `[[KARTELDB]]`
;

-- Καθορίζουμε την default storage engine για τους πίνακες που θα δημιουργηθούν.

SET default_storage_engine = INNODB
;

-------------------------------------------------------------------------------@

-- Ο πίνακας "site" περιλαμβάνει κτίρια και τοποθεσίες με καρταναγνώστες.
-- Οι κωδικοί των καρταναγνωστών αποτελούνται από επιμέρους κωδικούς που
-- αναφέρονται στον πίνακα "site".

CREATE TABLE `site` (
	`kodikos`	CHARACTER(128) NOT NULL COMMENT 'Κωδικός site',
	`perigrafi`	VARCHAR(128) NOT NULL COMMENT 'Περιγραφή site',

	PRIMARY KEY (
		`kodikos`
	) USING BTREE
)

COMMENT = 'Πίνακας κτιρίων και θέσεων καρταναγνωστών'
;

CREATE TABLE `reader` (
	`kodikos`	VARCHAR(128) NOT NULL COMMENT 'Κωδικός καρταναγνώστη',
	`idos`		ENUM (
		'ACCESS',
		'IN',
		'OUT'
	) NOT NULL COMMENT 'Είδος καρταναγνώστη',
	`perigrafi`	VARCHAR(512) NOT NULL DEFAULT ''
		COMMENT 'Περιγραφή καρταναγνώστη',

	PRIMARY KEY (
		`kodikos`
	) USING BTREE
)

COMMENT = 'Πίνακας καρταναγνωστών'
;

CREATE TABLE `event` (
	`kodikos`	INT UNSIGNED NOT NULL COMMENT '[History].[RecordID]',
	`meraora`	DATETIME NOT NULL COMMENT '[History].[GenTime]',
	`tipos`		TINYINT NOT NULL COMMENT 'Τύπος συμβάντος (30, 79 κλπ)',
	`karta`		MEDIUMINT UNSIGNED NOT NULL COMMENT 'Αριθμός κάρτας',
	`reader`	VARCHAR(128) NOT NULL COMMENT 'Κωδικός καρταναγνώστη',

	PRIMARY KEY (
		`kodikos`
	) USING BTREE,

	INDEX (
		`meraora`,
		`kodikos`
	) USING BTREE,

	INDEX (
		`karta`
	) USING BTREE
)

COMMENT = 'Πίνακας συμβάντων από το [WIN-PAK PRO].[dbo].[History]'
;

-- Ο πίνακας "mailbook" περιλαμβάνει ειδικές κάρτες, κυρίως κάρτες ελέγχου
-- πρόσβασης, και περιέχει ένα email ενημέρωσης, και πληροφορίες σχετικές με
-- την κάρτα, π.χ. πού βρίσκεται, για ποιο σκοπό δόθηκε κλπ.

CREATE TABLE `mailbook` (
	`karta`		MEDIUMINT UNSIGNED NOT NULL COMMENT 'Αριθμός κάρτας',
	`email`		VARCHAR(100) NULL DEFAULT NULL COMMENT 'Ιδιαίτερο email κάρτας',
	`info`		VARCHAR(4096) NOT NULL COMMENT 'Πληροφορίες σχετικές με την κάρτα',

	PRIMARY KEY (
		`karta`
	) USING BTREE
)

COMMENT = 'Πίνακας συμβάντων από το [WIN-PAK PRO].[dbo].[History]'
;

-- Ο πίνακας "parametros" περιλαμβάνει διάφορες γενικές παραμέτρους που αφορούν
-- στην εφαρμογή, π.χ. την ημερομηνία εκκίνησης της εφαρμογής (δεν αλλάζει), την
-- τρέχουσα version της database `erpota` (εναλλάσσονται οι τιμές 1 και 2) κλπ.

CREATE TABLE `parametros` (
	`kodikos`	VARCHAR(100) NOT NULL COMMENT 'Κωδική ονομασία παραμέτρου',
	`perigrafi`	VARCHAR(128) NOT NULL COMMENT 'Περιγραφή παραμέτρου',
	`info`		VARCHAR(4096) NULL DEFAULT NULL COMMENT 'Εκτενής τεκμηρίωση παραμέτρου',
	`timi`		VARCHAR(4096) NOT NULL COMMENT 'Τιμή παραμέτρου',

	PRIMARY KEY (
		`kodikos`
	) USING HASH
)

COMMENT = 'Πίνακας γενικών παραμέτρων εφαρμογής'
;

COMMIT WORK
;

-------------------------------------------------------------------------------@
 
\! [ -w /dev/tty ] && echo "Creating views…" >/dev/tty

-- Η view "istoriko" αναφέρεται σε επέκταση του πίνακα "event" όπου κάθε
-- συμβάν (πέρασμα κάρτας) εμπλουτίζεται με το είδος του καρταναγνώστη και
-- και την περιγραφή, η οποία συνήθως αφορά την τοποθεσία του καρταναγνώστη.

CREATE VIEW `istoriko` AS

SELECT
`event`.`kodikos`,
`event`.`meraora`,
`event`.`tipos`,
`event`.`karta`,
`event`.`reader`,
`reader`.`idos`,
`reader`.`perigrafi`

FROM `event`LEFT OUTER JOIN `reader`

ON `reader`.`kodikos` = `event`.`reader`

ORDER BY
`event`.`kodikos`
;

COMMIT WORK
;

-------------------------------------------------------------------------------@

\! [ -w /dev/tty ] && echo "Inserting data…" >/dev/tty

\! [ -w /dev/tty ] && echo '\tTable `site`…' >/dev/tty

LOAD DATA LOCAL INFILE 'local/data/kartel/site.tsv'
INTO TABLE `site` (
	`kodikos`,
	`perigrafi`
);

\! [ -w /dev/tty ] && echo '\tTable `reader`…' >/dev/tty

LOAD DATA LOCAL INFILE 'local/data/kartel/reader.tsv'
INTO TABLE `reader` (
	`kodikos`,
	`idos`,
	`perigrafi`
);

\! [ -w /dev/tty ] && echo '\tTable `mailbook`…' >/dev/tty

LOAD DATA LOCAL INFILE 'local/data/kartel/mailbook.tsv'
INTO TABLE `mailbook` (
	`karta`,
	`email`,
	`info`
);

COMMIT WORK
;

-------------------------------------------------------------------------------@

\! [ -w /dev/tty ] && echo "Inserting data…" >/dev/tty

-------------------------------------------------------------------------------@

\! [ -w /dev/tty ] && echo '\tTable `parametros`…' >/dev/tty

INSERT INTO `kartel`.`parametros` (
	`kodikos`,
	`perigrafi`,
	`timi`
) VALUES
( 'ekinisi', 'Ημερομηνία εκκίνησης της εφαρμογής (YYYY-MM-DD)', '[[EKINISI]]'),
( 'erpota12', 'Τρέχουσα έκδοση database `erpota` (1 ή 2)', '2')
;

-------------------------------------------------------------------------------@

\! [ -w /dev/tty ] && echo "Creating users…" >/dev/tty

DROP USER IF EXISTS '[[USERNAME]]'@'localhost'
;

CREATE USER '[[USERNAME]]'@'localhost' IDENTIFIED BY '[[USERPASS]]'
;

-------------------------------------------------------------------------------@

\! [ -w /dev/tty ] && echo "Granting permissions…" >/dev/tty

GRANT SELECT, INSERT, UPDATE, DELETE
ON `[[KARTELDB]]`.* TO '[[USERNAME]]'@'localhost'
;

GRANT SELECT, INSERT, UPDATE, DELETE, CREATE, DROP, ALTER
ON `[[ERPOTADB]]`.* TO '[[USERNAME]]'@'localhost'
;

GRANT SELECT, INSERT, UPDATE, DELETE, CREATE, DROP, ALTER, REFERENCES
ON `[[ERPOTADB]]1`.* TO '[[USERNAME]]'@'localhost'
;

GRANT SELECT, INSERT, UPDATE, DELETE, CREATE, DROP, ALTER, REFERENCES
ON `[[ERPOTADB]]2`.* TO '[[USERNAME]]'@'localhost'
;

COMMIT WORK
;

-------------------------------------------------------------------------------@
