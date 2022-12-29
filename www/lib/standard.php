<?php

if (!class_exists("Erpota"))
require_once "kartel.php";

define("JQCDN", "https://ajax.googleapis.com/ajax/libs/");
define("PUBKEY", "pubkey");
define("IPALILOS", "ipalilos");
define("AUTHDEPT", "authdept");
define("AUTHLEVEL", "authlevel");
define("WEBMAIL", "//webmail.thessaloniki.gr");
define("AJXRSPOK", "_AJXRSPOK_");

define("DTPHP_NUM", "Ymd");
define("DTPHP_YMD", "Y-m-d");
define("DTPHP_DMY", "d-m-Y");
define("TMPHP_NUM", "His");
define("TMPHP_HMS", "H:i:s");
define("TMPHP_HM", "H:i");
define("MISSING_DATE", "1111-11-11");

define("DTSQL_NUM", "%Y%m%d");
define("DTSQL_YMD", "%Y-%m-d");
define("TMSQL_NUM", "%H%i%s");
define("TMSQL_HMS", "%H:%i:%s");

define("ERROR_MAILCONF", 1);
define("ERROR_RCPADDR", 2);
define("ERROR_NULLMSG", 3);
define("ERROR_SENDMAIL", 4);

setlocale(LC_ALL, "el_GR.utf8");

// Εκκινούμε τα PHP προγράμματά μας με τον καθορισμό του character set
// encoding για τα ίδια τα program source files. Αυτός είναι ο λόγος
// που οι εν λόγω functions δεν καλούνται στη φάση του initialization,
// αλλά νωρίτερα.

mb_internal_encoding("UTF-8");
mb_regex_encoding("UTF-8");
mb_http_output("UTF-8");

// Η function "klise_fige" επιτελεί εργασίες ομαλού τερματισμού του PHP
// προγράμματος, π.χ. κλείσιμο της database connection. Είναι καλό όλα
// τα PHP προγράμματά μας να τερματίζονται μέσω της "klise_fige" και όχι
// βάναυσα μέσω των "die", "exit" κλπ. Γι' αυτό φροντίζουμε να κληθεί η
// function "klise_fige" κατά το κλείσιμο, είτε έχει φροντίσει γι' αυτό
// ο προγραμματιστής, είτε όχι. Η ίδια η "klise_fige" γνωρίζει αν έχει
// ήδη κληθεί, οπότε οι εργασίες ομαλού τερματισμού θα εκτελστούν μόνο
// μία φορά.

register_shutdown_function("Globals::klise_fige");

Globals::init();

class Globals {
	// Η property "init_ok" δείχνει αν έτρεξε η μέθοδος "init".
	// Η μέθοδος πρέπει να τρέχει το πολύ μια φορά.

	private static $init_ok = FALSE;

	// Η property "session_ok" δείχνει αν έτρεξε η μέθοδος "session".
	// Η μέθοδος πρέπει να τρέχει το πολύ μια φορά.

	private static $session_ok = FALSE;

	// Η property "klise_fige_ok" δείχνει αν έτρεξε η μέθοδος "klise_fige".
	// Η μέθοδος πρέπει να τρέχει το πολύ μια φορά.

	private static $klise_fige_ok = FALSE;

	// Η property "dbconf" είναι ένα array στο οποίο θα περαστούν τα
	// περιεχόμενα του configuration file της kartel database.

	private static $dbconf = NULL;

	// Η property "mailcf είναι ένα array στο οποίο θα περαστούν τα
	// περιεχόμενα του mail configuration file.

	private static $mailcf = NULL;

	// Η property "server" περιέχει το URI του server μαζί με το root
	// directory της εφαρμογής, και πρέπει να λήγει σε "/", π.χ.
	//
	//	http://www.kartel.thessaloniki.gr/
	//	http://localhost/kartel/
	//	...
	//
	// Η property θα τεθεί αυτόματα κατά το initialization.

	public static $server = NULL;

	// Η property "query_string" περιέχει το τμήμα του URL που
	// αφορά στις παραμέτρους του URL, π.χ. για το URL:
	//
	//	http://www.example.com/list?a=1&b=2
	//
	// η property "query_string" θα έχει την τιμή "?a=1&b=2".
	//
	// Η property θα τεθεί αυτόματα κατά το initialization.

	public static $query_string = "";

	// Η property "home" είναι το πλήρες pathname του directory της
	// εφαρμογής, και πρέπει να λήγει σε "/", π.χ.
	//
	//	/home/panos/Desktop/kartel/
	//	/var/opt/kartel/
	//	...
	//
	// Η property θα τεθεί αυτόματα κατά το initialization.

	public static $home = NULL;

	// Η property "www" είναι το πλήρες pathname του root directory της
	// εφαρμογής που βγαίνει στο δίκτυο, και πρέπει να λήγει σε "/", π.χ.
	//
	//	/home/panos/Desktop/kartel/www/
	//	/var/opt/kartel/www/
	//	...
	//
	// Η property θα τεθεί αυτόματα κατά το initialization.

	public static $www = NULL;

	// Η property "db" είναι ο database handler μέσω του οποίου
	// προσπελαύνουμε την database.

	public static $db = NULL;

	// Η property "pandora_basedir" περιέχει το full pathname του directory
	// βάσης του πακέτου "pandora", το οποίο βρίσκει από την environment
	// variable "PANDORA_BASEDIR".

	public static $pandora_basedir = NULL;

	// Η property "kartel_basedir" περιέχει το full pathname του directory
	// βάσης της εφαρμογής, το οποίο βρίσκει από την environment variable
	// "KARTEL_BASEDIR".

	public static $kartel_basedir = NULL;

	// Η property "titlos" δείχνει τον τίτλο που θα εμφανίζεται στο επάνω μέρος
	// των σελίδων της εφαρμογής.

	public static $titlos = "kartel";

	// Η property "ipalilos" περιέχει τον τρέχοντα υπάλληλο εφόσον έχει
	// καθοριστεί κωδικός υπαλλήλου στο session.

	public static $ipalilos = NULL;

	// Η μέθοδος "init" καλείται άπαξ και θέτει διάφορες properties της
	// ίδιας της κλάσης, π.χ. το login name του τρέχοντος παίκτη, το όνομα
	// του server κλπ.

	public static function init() {
		if (self::$init_ok)
		self::klise_fige("Globals::init: already called");

		self::$init_ok = TRUE;

		// Το array "_SERVER" πρέπει να έχει ήδη στηθεί από τον web
		// server, αλλιώς δεν μπορούμε να προχωρήσουμε. Πρόκειται για
		// associative array, επομένως αντί τού όρου 'array' θα
		// χρησιμοποιείται ενίοτε και ο όρος 'λίστα' ή 'list'.

		if (!isset($_SERVER))
		self::klise_fige("_SERVER: not set");

		if (!is_array($_SERVER))
		self::klise_fige("_SERVER: not an array");

		// Ανιχνεύουμε το URI του server μας μέσω της "HTTP_HOST"
		// property της λίστας "_SERVER" και περιοριζόμαστε σε
		// συγκεκριμένες εγκαταστάσεις μέσω του domain για λόγους
		// ασφάλειας.

		if (array_key_exists("HTTP_HOST", $_SERVER))
		switch ($_SERVER["HTTP_HOST"]) {
		case "kartel.thessaloniki.gr":
			self::$server = "http://" . $_SERVER["HTTP_HOST"] . "/kartel/";
			break;
		default:
			self::$server = "http://" . $_SERVER["HTTP_HOST"] . "/kartel/";
			break;
		}

		if (array_key_exists("QUERY_STRING", $_SERVER) && $_SERVER["QUERY_STRING"])
		self::$query_string = "?" . $_SERVER["QUERY_STRING"];

		// Ανιχνεύουμε την τοποθεσία της εφαρμογής μέσα στον hosting
		// server μέσω του pathname του παρόντος source file.

		self::$home = preg_replace("/\/www\/lib\/standard.php$/", "/", __FILE__);
		self::$www = self::$home . "www/";

		if ((self::$pandora_basedir = getenv("PANDORA_BASEDIR")) === FALSE)
		self::$pandora_basedir = "/var/opt/pandora";

		if ((self::$kartel_basedir = getenv("KARTEL_BASEDIR")) === FALSE)
		self::$kartel_basedir = "/var/opt/kartel";

		self::database();
		self::prosvasi_check();
	}

	private static function prosvasi_check() {
		$session_pubkey = self::session_get(PUBKEY);
		$session_ipalilos = self::session_get(IPALILOS);

		self::session_clear(PUBKEY);
		self::session_clear(IPALILOS);

		///////////////////////////////////////////////////////////////@

		$pubkey = self::pubkey_get();

		if (!isset($pubkey))
		$pubkey = $session_pubkey;

		if (!isset($pubkey))
		return;

		///////////////////////////////////////////////////////////////@

		$ipalilos = self::ipalilos_get();

		if (!isset($ipalilos))
		$ipalilos = $session_ipalilos;

		///////////////////////////////////////////////////////////////@

		$prosvasi = (new Prosvasi())->
		pubkey_set($pubkey)->
		ipalilos_set($ipalilos)->
		prosvasi_fetch();

		if (!isset($prosvasi->ipalilos))
		return;

		$ipalilos = (new Ipalilos())->
		kodikos_set($prosvasi->ipalilos)->
		ipalilos_fetch();

		if (!isset($ipalilos->kodikos))
		return;

		self::session_set(PUBKEY, $pubkey);

		if (!isset($session_ipalilos))
		return;

		self::session_set(IPALILOS, $session_ipalilos);
		self::$ipalilos = $ipalilos;
	}

	private static function pubkey_get() {
		if (!isset($_GET))
		return NULL;

		if (!is_array($_GET))
		return NULL;

		if (!array_key_exists(PUBKEY, $_GET))
		return NULL;

		return urldecode($_GET[PUBKEY]);
	}

	private static function ipalilos_get() {
		if (!isset($_GET))
		return NULL;

		if (!is_array($_GET))
		return NULL;

		if (!array_key_exists(IPALILOS, $_GET))
		return NULL;

		return urldecode($_GET[IPALILOS]);
	}

	///////////////////////////////////////////////////////////////////////@

	// Η μέθοδος "session_init" ενεργοποιεί το session και είναι καλό να
	// καλείται στην αρχή του PHP script, εφόσον χρησιμοποιούμε cookies.

	public static function session_init() {
		if (self::$session_ok)
		return;

		self::$session_ok = TRUE;

		// Καλού κακού ελέγχουμε αν έχει ήδη κληθεί η function
		// "session_start".

		if (session_status() == PHP_SESSION_ACTIVE)
		return;

		// 24 * 7 * 3600 = 604800 (μια εβδομάδα)
/*
		ini_set("session.gc_maxlifetime", "604800");
		session_set_cookie_params(604800);
		session_start();
*/

		if (!session_start())
		self::fatal("session_start: failed");

		if (!setcookie(session_name(), session_id(), time() + (3600 * 12), "/"))
		self::fatal("setcookie: failed");

		if (!isset($_SESSION))
		self::klise_fige("_SESSION: not set");

		if (!is_array($_SESSION))
		self::klise_fige("_SESSION: not an array");
	}

	// Η μέθοδος "session_set" δέχεται ως παράμετρο ένα key/value pair και θέτει
	// το σχετικό cookie.

	public static function session_set($tag, $val) {
		self::session_init();
		$_SESSION[$tag] = $val;
	}

	// Η μέθοδος "session_clear" δέχεται ως παράμετρο ένα string και διαγράφει
	// το σχετικό cookie.

	public static function session_clear($tag) {
		self::session_init();

		if (self::no_session($tag))
		return;

		unset($_SESSION[$tag]);
	}

	// Η μέθοδος "is_session" δέχεται ως παράμετρο ένα string και επιστρέφει
	// TRUE εφόσον υπάρχει το αντίστοιχο session cookie.

	public static function is_session($tag) {
		self::session_init();
		return array_key_exists($tag, $_SESSION);
	}

	// Η μέθοδος "no_session" δέχεται ως παράμετρο ένα string και επιστρέφει
	// TRUE εφόσον ΔΕΝ υπάρχει το αντίστοιχο session cookie.

	public static function no_session($tag) {
		self::session_init();
		return !self::is_session($tag);
	}

	// Η μέθοδος "session" δέχεται ως παράμετρο ένα string και επιστρέφει
	// την τιμή του αντίστοιχου στοιχείου από το session array.

	public static function session_get($tag) {
		self::session_init();

		if (self::no_session($tag))
		return NULL;

		return $_SESSION[$tag];
	}

	// Η μέθοδος "session_fetch" δέχεται ως παράμετρο ένα string και επιστρέφει
	// την τιμή του αντίστοιχου στοιχείου από το session array. Αν δεν υπάρχει
	// σχετική τιμή, τότε το πρόγραμμα σταματά.

	public static function session_fetch($tag) {
		self::session_init();
		if (self::is_session($tag))
		return self::session_get($tag);

		self::klise_fige($tag . ": undefined session value");
	}

	///////////////////////////////////////////////////////////////////////@

	// Η function "is_ipalilos" μας δείχνει αν γίνεται επώνυμη χρήση, αν
	// δηλαδή το πρόγραμμα «τρέχει» μέσω http κλήσης και υπάρχει στοιχείο
	// "ipalilos" στο session cookie.

	public static function is_ipalilos() {
		return self::is_session(IPALILOS);
	}

	// Η function "no_ipalilos" μας δείχνει αν γίνεται ανώνυμη χρήση και
	// έχει νόημα μόνο εφόσον το πρόγραμμα «τρέχει» μέσω http κλήσης και όχι
	// τοπικά όπου έτσι κι αλλιώς δεν υφίσταται το sesssion cookie.

	public static function no_ipalilos() {
		return !self::is_ipalilos();
	}

	///////////////////////////////////////////////////////////////////////@

	public static function is_admin() {
		if (self::no_session(AUTHLEVEL))
		return FALSE;

		return (self::session_get(AUTHLEVEL) == "ADMIN");
	}

	public static function is_editor() {
		if (self::no_session(AUTHLEVEL))
		return FALSE;

		return (self::session_get(AUTHLEVEL) == "UPDATE");
	}

	///////////////////////////////////////////////////////////////////////@

	// Η function "url" δέχεται ένα string και το εμπλουτίζει με το URI του
	// server στον οποίον τρέχει η εφαρμογή, π.χ. για το "images/kartel.png"
	// θα επιστραφεί "http://www.kartel.thessaloniki.gr/images/kartel.png",
	// εφόσον η εφαρμογή τρέχει στο "www.kartel.thessaloniki.gr".

	public static function url($s = "") {
		return self::$server . $s;
	}

	// Η "print_url" είναι παρόμοια με την "url" με μόνη διαφορά ότι αντί να
	// επιστρέφει το επίμαχο URL, το τυπώνει.

	public static function print_url($s = "") {
		print self::url($s);
	}

	///////////////////////////////////////////////////////////////////////@

	// Η function "homename" δέχεται ένα file name με αρχή το home directory
	// της εφαρμογής και το μετασχηματίζει σε full pathname του server στον
	// οποίον τρέχει η εφαρμογή, π.χ. για το "www/images/kartel.png" θα
	// επιστραφεί το string:
	//
	//	/var/opt/kartel/www/images/kartel.png
	//
	// εφόσον η εφαρμογή μας έχει εγκατασταθεί στο "/var/opt/kartel".

	public static function homename($s) {
		return self::$home . $s;
	}

	// Η "print_homename" είναι παρόμοια με την "homename" με μόνη διαφορά
	// ότι αντί να επιστρέφει το επίμαχο pathname, το τυπώνει.

	public static function print_homename($s) {
		print self::homename($s);
	}

	// Η μέθοδος "home_require" είναι ήσσονος σημασίας καθώς υποκαθιστά την
	// "require" και μόνο σκοπό έχει την απλοποίηση των pathnames με βάση
	// το home directory της εφαρμογής.

	public static function home_require($file) {
		require self::homename($file);
	}

	// Ακολουθούν αντίστοιχες μέθοδοι με βάση το root directory της
	// εφαρμογής που παρέχεται στο δίκτυο.

	public static function wwwname($s) {
		return self::$www . $s;
	}

	// Η "print_wwwname" είναι παρόμοια με την "wwwname" με μόνη διαφορά
	// ότι αντί να επιστρέφει το επίμαχο pathname, το τυπώνει.

	public static function print_wwwname($s) {
		print self::wwwname($s);
	}

	// Η μέθοδος "www_require" είναι ήσσονος σημασίας καθώς υποκαθιστά την
	// "require" και μόνο σκοπό έχει την απλοποίηση των pathnames με βάση
	// το root directory της εφαρμογής που παρέχεται στο δίκτυο.

	public static function www_require($file) {
		require self::wwwname($file);
	}

	///////////////////////////////////////////////////////////////////////@

	// Η μέθοδος "database" μας συνδέει με την database και την καλούμε
	// όποτε υπάρχει ανάγκη σύνδεσης με την database. Η function εκτελείται
	// το πολύ μία φορά, ακόμη και αν κληθεί κατ' επανάληψη.

	public static function database() {
		if (self::$db)
		return;

		self::dbconf_read();
		$dbhost = "localhost";
		$dbname = self::$dbconf["karteldb"];
		$dbuser = self::$dbconf["dbuser"];
		$dbpassword = self::$dbconf["dbpassword"];
		self::$db = @new mysqli($dbhost, $dbuser, $dbpassword, $dbname);

		if (self::$db->connect_errno) {
			print "database connection failed (" . self::$db->connect_error . ")";
			self::$db = NULL;
			self::klise_fige(2);
		}

		@self::$db->set_charset("utf8") ||
		self::klise_fige("cannot set character set (database)");
	}

	private static function dbconf_read() {
		$lines = file(self::homename("local/karteldb.cf"),
			FILE_IGNORE_NEW_LINES |
			FILE_SKIP_EMPTY_LINES);

		if ((!isset($lines)) || ($lines === FALSE) ||
			(!is_array($lines)))
		self::klise_fige("cannot read database configuration file");

		$pats = [];
		$pats[] = '/^"/';
		$pats[] = '/"$/';

		self::$dbconf = [];

		foreach ($lines as $i => $line) {
			$parts = explode("=", $line, 2);

			if (count($parts) != 2)
			continue;

			self::$dbconf[$parts[0]] = preg_replace($pats, "", $parts[1]);
		}
	}

	// Η μέθοδος "where_push" δέχεται ένα query (string), μία flag (bool)
	// που ονομάζεται "flag συνεχείας", και ένα SQL condition (string).
	// Σκοπός είναι να εμπλουτιστεί το query με τη δοθείσα condition,
	// παρεμβάλλοντας είτε το keyword "WHERE" εφόσον πρόκειται για την
	// πρώτη condition (flag συνεχείας false), είτε το keyword "AND" εφόσον
	// έχουν προηγηθεί και άλλες conditions (flag συνεχείας true). Η μέθοδος
	// επιστρέφει true και έτσι μπορεί να χρησιμοποιηθεί για να θέσει τη
	// flag συνεχείας σε true, π.χ.
	//
	//	$query = "SELECT * FROM `ipalilos`"
	//	$cond = FALSE;
	//
	//	if (isset($kodikos))
	//	$cond = where_push($query, $cond, "`kodikos` = " . $kodikos);
	//
	//	if (isset($afm))
	//	$cond = where_push($query, $cond, "`afm` = " . $afm);
	//
	//	if (isset($eponimo))
	//	$cond = where_push($query, $cond,
	//		"`eponimo` LIKE '" . $eponimo . "'");
	//
	//	if (isset($onoma))
	//	$cond = where_push($query, $cond,
	//		"`onoma` LIKE '" . $onoma . "'");
	//
	// Αν έχουμε ορίσει ΑΦΜ 032783920 και επώνυμο "ΠΑΠΑΔΟΠΟΥΛΟΣ", τότε το
	// query θα γίνει:
	//
	//	SELECT * FROM `ipalilos` WHERE (`afm` = 32792320)
	//		AND (`eponimo` LIKE 'ΠΑΠΑΔΟΠΟΥΛΟΣ')

	public static function where_push(&$query, $cont, $condition) {
		$query .= " " . ($cont ? "AND" : "WHERE") .
			" (" . $condition . ")";
		return TRUE;
	}
		
	// Η μέθοδος "query" δέχεται ως πρώτη παράμετρο ένα SQL query και το εκτελεί.
	// Αν υπάρξει οποιοδήποτε δομικό πρόβλημα (όχι σχετικό με την επιτυχία ή μη
	// του query), τότε εκτυπώνεται μήνυμα λάθους και το πρόγραμμα σταματά.

	public static function query($query) {
		$result = self::$db->query($query);

		if ($result)
		return $result;

		print "SQL ERROR: " . $query . ": " . self::sql_error();
		self::klise_fige(2);
	}

	public static function sql_errno() {
		return self::$db->errno;
	}

	public static function sql_error() {
		return self::$db->error;
	}

	// Η μέθοδος "first_row" τρέχει ένα query και επιστρέφει την πρώτη γραμμή των
	// αποτελεσμάτων απελευθερώνοντας τυχόν άλλα αποτελέσματα.

	public static function first_row($query, $idx = MYSQLI_NUM) {
		$result = self::query($query);

		while ($row = $result->fetch_array($idx)) {
			$result->free();
			break;
		}

		return $row;
	}

	public static function evretirio($query, $wlist = NULL, $hlist = NULL) {
		$result = Globals::query($query);

		print "[";

		while ($row = $result->fetch_array(MYSQLI_NUM))
		print json_encode($row, JSON_UNESCAPED_UNICODE) . ",";

		$result->free();

		print ((isset($wlist) && is_array($wlist)) ?
			json_encode($wlist) : "[]") . ",";

		print ((isset($hlist) && is_array($hlist)) ?
			json_encode($hlist) : "[]") . "]";
	}

	public static function insert_id() {
		return self::$db->insert_id;
	}

	public static function affected_rows() {
		return self::$db->affected_rows;
	}

	public static function autocommit($on_off) {
		self::$db->autocommit($on_off) ||
		self::klise_fige("autocommit failed");
	}

	public static function commit() {
		self::$db->commit() ||
		self::klise_fige("commit failed");
	}

	public static function rollback() {
		self::$db->rollback() ||
		self::klise_fige("rollback failed");
	}

	// Η μέθοδος "klidoma" επιχειρεί να θέσει κάποιο database lock που
	// καθορίζεται από το tag που περνάμε ως πρώτη παράμετρο. By default η
	// μέθοδος θεωρεί ότι δεν μπορεί να κλειδώσει εφόσον το κλείδωμα
	// αποτύχει για 2 δευτερόλεπτα, αλλά μπορούμε να περάσουμε μεγαλύτερο ή
	// μικρότερο χρονικό διάστημα ως δεύτερη παράμετρο.
	//
	// Η μέθοδος επιστρέφει TRUE εφόσον το κλείδωμα επιτύχει, αλλιώς
	// επιστρέφει FALSE.

	public static function klidoma($tag, $timeout = 2) {
		$query = "SELECT GET_LOCK(" . self::asfales_sql($tag) .
			", " . $timeout . ")";
		$row = self::first_row($query, MYSQLI_NUM);

		if (!$row)
		return FALSE;

		return ($row[0] == 1);
	}

	// Η μέθοδος "xeklidoma" ξεκλειδώνει κάποιο κλείδωμα που θέσαμε με τη
	// μέθοδο "klidoma". Το tag του κλειδώματος που θα ξεκλειδωθεί περνιέται
	// ως πρώτη παράμετρος, ενώ ως δεύτερη παράμετρος μπορούμε να περάσουμε
	// TRUE/FALSE value που δείχνει αν πριν το ξεκλείδωμα θα γίνει commit ή
	// rollback αντίστοιχα· αν δεν περαστεί δεύτερη παράμετρος, τότε δεν
	// επιχειρείται ούτε commit ούτε rollback, οπότε μπορούμε να συνεχίσουμε
	// με άλλες ενέργειες στα πλαίσια της τρέχουσας transaction.

	public static function xeklidoma($tag, $commit = NULL) {
		if (isset($commit)) {
			if ($commit)
			self::$db->commit();

			else
			self::$db->rollback();
		}

		$query = "DO RELEASE_LOCK(" . self::asfales_sql($tag) . ")";
		self::$db->query($query);
	}

	///////////////////////////////////////////////////////////////////////@

	// Η μέθοδος "perastike" δέχεται ως παράμετρο ένα string και επιστρέφει
	// TRUE εφόσον έχει περαστεί αντίστοιχη GET/POST παράμετρος.

	public static function perastike($key) {
		return (
			isset($_REQUEST) &&
			is_array($_REQUEST) &&
			array_key_exists($key, $_REQUEST)
		);
	}

	public static function den_perastike($key) {
		return !self::perastike($key);
	}

	// Η μέθοδος "perastike_must" επιτάσσει να έχει περαστεί η GET/POST
	// παράμετρος που περνάμε ως πρώτη παράμετρο. Αν έχει περαστεί η εν λόγω
	// παράμετρος, τότε επιστρέφεται η τιμή της παραμέτρου, αλλιώς το
	// πρόγραμμα σταματά.

	public static function perastike_must($key, $msg = NULL) {
		if (self::perastike($key))
		return (is_string($_REQUEST[$key]) ?
			urldecode($_REQUEST[$key]) : $_REQUEST[$key]);

		self::header_error(isset($msg) ?
			$msg : $key . ": δεν περάστηκε παράμετρος");
	}

	///////////////////////////////////////////////////////////////////////@

	// Η μέθοδος "asfales_sql" δέχεται ένα string και επιστρέφει το ίδιο
	// string αλλά τροποποιημένο ώστε να μην τίθεται θέμα SQL injection,
	// ενώ παράλληλα γίνεται και διαφυγή των quotes. Το string επιστρέφεται
	// μαζί με τα quotes που το περικλείουν, εκτός και αν περάσουμε δεύτερη
	// (false) παράμετρο.

	public static function asfales_sql($s, $string = TRUE) {
		if (get_magic_quotes_gpc())
		$s = stripslashes($s);

		if (isset(self::$db))
		$s = self::$db->real_escape_string($s);

		return ($string ? "'" . $s . "'" : $s);
	}

	// Η μέθοδος "asfales_json" δέχεται ως παράμετρο ένα string και το
	// επιστρέφει τροποιημένο ώστε να μπορεί με ασφάλεια να ενταχθεί ως
	// rvalue σε json objects μαζί με τα quotes.

	public static function asfales_json($s) {
		$s = str_replace('\\', '\\\\', $s);
		return ("'" . str_replace("'", "\'", $s) . "'");
	}

	///////////////////////////////////////////////////////////////////////@

	public static function header_data() {
		header('Content-type: text/plain; charset=utf-8');
	}

	public static function header_json() {
		header('Content-Type: application/json; charset=utf-8');
	}

	public static function header_html() {
		header('Content-type: text/html; charset=utf-8');
	}

	public static function header_error($msg = "Server error") {
		header("HTTP/1.1 500 " . $msg);
		self::klise_fige($msg);
	}

	///////////////////////////////////////////////////////////////////////@

	// Η function "sendmail" επιχειρεί να αποστείλει email σε συγκεκριμένο
	// παραλήπτη. Ως παραμέτρους δέχεται τη διεύθυνση email του παραλήπτη,
	// το θέμα, και το μήνυμα (ως string).

	public static function sendmail(
		$addr = NULL,
		$subj = "Ενημέρωση",
		$msg = NULL
	) {
		// Για να αποσταλεί το email πρέπει να γνωρίζουμε τον
		// αποστολέα ο οποίος καθορίζεται στο mail configuration
		// file της εφαρμογής ως "mailer". Εάν είναι η πρώτη φορά
		// που καλείται η function "sendmail", διαβάζουμε το mail
		// configuration file και αποθηκεύουμε τις παραμέτρους στο
		// array "mailcf".

		if (!is_array(self::$mailcf))
		self::mailcf_read();

		if ((!array_key_exists("mailer", self::$mailcf)) ||
			(!array_key_exists("domain", self::$mailcf)))
		return ERROR_MAILCONF;

		if (self::email_check($addr) === NULL)
		return ERROR_RCPADDR;

		if ($msg === NULL)
		return ERROR_NULLMSG;

		$cmd = self::$pandora_basedir . '/bin/pd_sendmail';
		$cmd .= ' -F "' . self::$mailcf["mailer"] . '"';
		$cmd .= ' -t "' . $addr . '"';
		$cmd .= ' -s "' . $subj . '"';
		$cmd .= ' -m "' . $msg . '"';

		system($cmd, $ret);
		return ($ret ? ERROR_SENDMAIL : 0);
	}

	private static function mailcf_read() {
		$lines = file(self::homename("local/mail.cf"),
			FILE_IGNORE_NEW_LINES |
			FILE_SKIP_EMPTY_LINES);

		if ((!isset($lines)) || ($lines === FALSE) ||
			(!is_array($lines)))
		self::klise_fige("cannot read mail configuration file");

		$pats = [];
		$pats[] = '/^"/';
		$pats[] = '/"$/';

		self::$mailcf = [];

		foreach ($lines as $i => $line) {
			$parts = explode("=", $line, 2);

			if (count($parts) != 2)
			continue;

			self::$mailcf[$parts[0]] = preg_replace($pats, "", $parts[1]);
		}
	}

	public static function login_check($login) {
		return preg_match("/^[a-zA-Z][a-zA-Z0-9!@#$%-+=:._]*$/",
			$login);
	}

	public static function email_check($email) {
		return (filter_var($email, FILTER_VALIDATE_EMAIL) ?
			$email : NULL);
	}

	///////////////////////////////////////////////////////////////////////@

	public static function is_email($email) {
		return (filter_var($email, FILTER_VALIDATE_EMAIL) ?
			$email : NULL);
	}

	public static function is_integer($x, $min = NULL, $max = NULL) {
		if (!isset($x))
		return NULL;

		$opts = array(
			"options" => array(),
		);

		if (isset($min))
		$opts["options"]["min_range"] = $min;

		if (isset($max))
		$opts["options"]["max_range"] = $max;
		
		$n = filter_var($x, FILTER_VALIDATE_INT, $opts);
		return ($n === FALSE ? NULL : $n);
	}

	public static function no_integer($x, $min = NULL, $max = NULL) {
		return !self::is_integer($x, $min, $max);
	}

	public static function is_positive($x, $max = NULL) {
		return self::is_integer($x, 1, $max);
	}

	public static function is_string($x, $opts = NULL) {
		if (!isset($x))
		return NULL;

		if (!is_string($x))
		return NULL;

		if (!isset($opts))
		$opts = array();

		else if (!is_array($opts))
		return NULL;

		if (!array_key_exists("trim", $opts))
		$opts["trim"] = TRUE;

		if (!array_key_exists("keno", $opts))
		$opts["keno"] = FALSE;

		if ($opts["trim"])
		$x = trim($x);

		if ($opts["keno"])
		return $x;

		if ($x === "")
		return NULL;

		return $x;
	}

	public static function is_date($x, $format = DTPHP_YMD) {
		if (!isset($x))
		return NULL;

		// Ακόμη και αν η παράμετρος είναι τύπου "DateTime",
		// μετατρέπουμε σε string προκειμένου να μηδενιστεί
		// η ώρα.

		if ($x instanceof DateTime)
		$x = $x->format($format);

		elseif (!is_string($x))
		return NULL;

		$x = DateTime::createFromFormat($format, $x);
		return ($x === FALSE ? NULL : $x);
	}

	public static function is_time($x, $format = "TMPHP_HMS") {
		if (!isset($x))
		return NULL;

		if ($x instanceof DateTime)
		$x = $x->format(TMPHP_HMS);

		elseif (!is_string($x))
		return NULL;

		// Αν το input string περιέχει μόνο ώρα και λεπτό, τότε
		// συμπληρώνουμε μηδενικά δευτερόλεπτα.

		if (count(explode(":", $x)) === 2)
		$x .= ":00";

		// Προκειμένου να μην προκύψουν θέματα σε πράξεις μεταξύ
		// ωρών (αφαίρεση, πρόσθεση κλπ), φροντίζουμε να θέσουμε
		// την ίδια ημερομηνία σε DateTime objects που τίθενται
		// μέσω της "is_time".

		$format = DTPHP_YMD . " " . $format;
		$x = MISSING_DATE . " " . $x;

		$x = DateTime::createFromFormat($format, $x);
		return ($x === FALSE ? NULL : $x);
	}

	public static function is_datetime($x,
		$format = DTPHP_YMD . " " . TMPHP_HMS) {
		if (!isset($x))
		return NULL;

		if ($x instanceof DateTime)
		$x = $x->format($format);

		$x = DateTime::createFromFormat($format, $x);
		return ($x === FALSE ? NULL : $x);
	}

	///////////////////////////////////////////////////////////////////////@

	// Η μέθοδος "random_string" επιστρέφει ένα string συγκεκριμένου μήκους,
	// αποτελούμενο από χαρακτήρες που λαμβάνονται από παλέτα.

	public static function random_string($min = 0, $max = 0, $paleta =
		"ABCDEFGHIJKLMNOPQRSTUVWXYZ" .
		"abcdefghijklmnopqrstuvwxyz" .
		"0123456789") {

		if ($min < 0)
		$min = 0;

		if ($max < $min)
		$max = $min;

		$s = "";

		if ($max <= 0)
		return $s;

		$l = strlen($paleta);

		for ($i = mt_rand($min, $max); $i > 0; $i--)
		$s .= $paleta[mt_rand(0, $l)];

		return $s;
	}

	public function errmsg($msg) {
		if(!defined('STDERR'))
		define('STDERR', fopen('php://stderr', 'wb'));

		fwrite(STDERR, $msg);
	}

	public static function klise_fige($stat = 0, $msg = NULL) {
		if (self::$klise_fige_ok)
		return;

		self::$klise_fige_ok = TRUE;

		($stat !== 0) &&
		array_key_exists("HTTP_HOST", $_SERVER) &&
		header("HTTP/1.1 500 Server error");

		if (isset(self::$db)) {
			self::$db->kill(self::$db->thread_id);
			self::$db->close();
		}

		while (@ob_end_flush());

		if (isset($msg) && $msg)
		print $msg;

		exit($stat);
	}
}

?>
