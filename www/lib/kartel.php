<?php

if (!class_exists("Globals"))
require_once "standard.php";

define("IPALILOS_MAX", 999999);
define("AFM_MAX", 999999999);
define("ADIA_MAX", 999999999);
define("KARTA_MAX", 99999);
define("EVENTID_MAX", 999999999);
define("EVRETIRIO_LIMIT", 20);

define("KARTA", "ΚΑΡΤΑ");
define("ORARIO", "ΩΡΑΡΙΟ");

define("READER_ACCESS", "ACCESS");
define("READER_IN", "IN");
define("READER_OUT", "OUT");

define("PROSELEFSI", "ΠΡΟΣΕΛΕΥΣΗ");
define("APOXORISI", "ΑΠΟΧΩΡΗΣΗ");

define("ENERGOS", "ΕΝΕΡΓΟΣ");
define("ANENERGOS", "ΑΝΕΝΕΡΓΟΣ");

define("EXCUSE_OK", 0);
define("EXCUSE_NO_IPALILOS", 1);
define("EXCUSE_NO_MERA", 2);
define("EXCUSE_NO_PROAPO", 3);

// Η κλάση "Erpota" χρησιμοποιείται ως name space και ως εκ τούτου δεν θα
// συναντήσουμε instances αντικειμένων της εν λόγω κλάσης.

class Erpota {
	// Η static property "erpota12" περιέχει την τρέχουσα έκδοση της
	// database που αφορά στα στοιχεία των υπαλλήλων που λαμβάνονται
	// αυτόματα (μέσω του cron), σε τακτά χρονικά διαστήματα από την
	// απομεμακρυσμένη database "erpota". Οι εν λόγω τοπικές databases
	// είναι πανομοιότυπες και ονομάζονται "erpota1" και "erpota2. Οι
	// δύο databases διαφέρουν μόνον στα δεδομένα με την μια database
	// να περιέχει κάπως πιο πρόσφατα δεδομένα από την άλλη. Για τις
	// ανάγκες των εφαρμογών χρησιμοποιείται η πιο πρόσφατα ενημερωμένη
	// έκδοση, δηλαδή είτε η "erpota1" είτε η "erpota2".
	//
	// Η property "erpota12" δείχνει ακριβώς αυτό, τουτέστιν έχει τιμές
	// 1 ή 2, ανάλογα με το αν η database "erpota1" είναι πιο πρόσφατα
	// ενημερωμένη από την "erpota2" και αντιστρόφως. Η τιμή αυτή είναι
	// κρατημένη στον πίνακα "parametros" της database "kartel" με κωδικό
	// "erpota12" και ενημερώνεται αυτόματα από το πρόγραμμα ανανέωσης
	// των στοιχείων προσωπικού από την απομεμακρυσμένη database "erpota".

	private static $erpota12 = NULL;

	// Η static μέθοδος "erpotadb" δέχεται ως παράμετρο το όνομα ενός
	// πίνακα και το επιστρέφει ως πλήρες database table name με σκοπό
	// να χρησιμοποιηθεί σε SQL queries, π.χ. για τον πίνακα "ipalilos"
	// θα επιστρέψει το string "`erpota2`.`ipalilos`" εφόσον η τρέχουσα
	// έκδοση της τοπικής database στοιχείων προσωπικού είναι η "erpota2".
	// Αν κληθεί χωρίς παραμέτρους, τότε απλώς επιστρέφει την τρέχουσα
	// έκδοση ως νούμερο (1 ή 2).
	
	public static function erpotadb($s = NULL) {
		if (!isset(self::$erpota12))
		self::erpota_version_get();

		if (!isset($s))
		return self::$erpota12;

		return "`erpota" . Erpota::$erpota12 . "`.`" . $s . "`";
	}

	private static function erpota_version_get() {
		$query = "SELECT `timi` FROM `kartel`.`parametros` " .
			"WHERE `kodikos` = 'erpota12'";
		$row = Globals::first_row($query, MYSQLI_NUM);

		if (!$row)
		Globals::klise_fige("erpota12: system parameter not found");

		switch ($row[0]) {
		case 1:
		case 2:
			self::$erpota12 = (int)($row[0]);
			break;
		default:
			Globals::klise_fige($row[0] . ": invalid erpota database version");
		}
	}

	public static function is_argia($d = NULL) {
		if (!isset($d))
		$d = date(DTPHP_YMD);

		elseif ($d instanceof DateTime)
		$d = $d->format(DTPHP_YMD);

		switch ((new DateTime($d))->format('w')) {
		case 0:
		case 6:
			return "Σαββατοκύριακο";
			break;
		}

		$query = "SELECT `perigrafi` FROM `erpota`.`argia`" .
			" WHERE `imerominia` = " . Globals::asfales_sql($d);
		$argia = Globals::first_row($query, MYSQLI_NUM);

		if (!$argia)
		return FALSE;

		return $argia[0];
	}
}

// Η κλάση "Site" αναφέρεται σε αντικείμενα που αντανακλούν εγγραφές (rows) τού
// πίνακα "site", της database "kartel".

class Site {
	private $kodikos;
	private $perigrafi;

	public function __construct($colval = NULL) {
		$this->site_set($colval);
	}

	public function site_set($colval = array(
		"kodikos" => NULL,
		"perigrafi" => NULL,
	)) {
		return $this->
		kodikos_set($colval["kodikos"])->
		perigrafi_set($colval["perigrafi"]);
	}

	public function site_clear() {
		return $this->site_set();
	}

	///////////////////////////////////////////////////////////////////////@

	public function kodikos_set($kodikos = NULL) {
		$this->kodikos = $kodikos;
		return $this;
	}

	public function kodikos_get() {
		return $this->kodikos = $kodikos;
	}

	public function is_kodikos() {
		return (isset($this->kodikos) && $this->kodikos);
	}

	public function no_kodikos() {
		return !$this->is_kodikos();
	}

	///////////////////////////////////////////////////////////////////////@

	public function perigrafi_set($perigrafi = NULL) {
		$this->perigrafi = $perigrafi;
		return $this;
	}

	public function perigrafi_get() {
		return $this->perigrafi;
	}

	public function is_perigrafi() {
		return (isset($this->perigrafi) && $this->perigrafi);
	}

	public function no_perigrafi() {
		return !$this->is_perigrafi();
	}

	///////////////////////////////////////////////////////////////////////@

	public function site_fetch($kodikos = NULL) {
		if ((!isset($kodikos)) && isset($this->kodikos))
		$kodikos = $this->kodikos;

		if (!isset($kodikos))
		return $this->site_clear();

		$query = "SELECT * FROM `kartel`.`site` WHERE `kodikos` = " .
			Globals::asfales_sql($kodikos);

		$row = Globals::first_row($query, MYSQLI_ASSOC);
		return $this->site_set($row);
	}

	// Η μέθοδος "site_reader" αποσπά από έναν κωδικό καρταναγνώστη το
	// τμήμα πυ αφορά το site στο οποίο βρίσκεται ο καρταναγνώστης.
	// Υπενθυμίζουμε ότι ο κωδικός καρταναγνώστη αποτελείται από τμήματα
	// χωρισμένα μεταξύ τους με "@" και το πρώτο τμήμα είναι ο κωδικός
	// του site στο οποίο είναι εγκατεστημένος ο καρταναγνώστης.

	public function site_reader($reader) {
		$a = explode("@", $reader);

		if (!is_array($a))
		return $this->site_clear();

		return $this->site_fetch($a[0]);
	}
}

class Reader {
	private $kodikos;
	private $idos;
	private $perigrafi;
	private $site;

	public function __construct($colval = NULL) {
		$this->reader_set($colval);
	}

	public function reader_set($colval = array(
		"kodikos" => NULL,
		"idos" => NULL,
		"perigrafi" => NULL,
	)) {
		return $this->
		kodikos_set($colval["kodikos"])->
		idos_set($colval["idos"])->
		perigrafi_set($colval["perigrafi"])->
		site_set();
	}

	public function reader_clear() {
		return $this->reader_set();
	}

	///////////////////////////////////////////////////////////////////////@

	public function kodikos_set($kodikos = NULL) {
		$this->kodikos = $kodikos;
		return $this;
	}

	public function kodikos_get() {
		return $this->kodikos;
	}

	public function is_kodikos() {
		return (isset($this->kodikos) && $this->kodikos);
	}

	public function no_kodikos() {
		return !$this->is_kodikos();
	}

	///////////////////////////////////////////////////////////////////////@

	public function idos_set($idos = NULL) {
		switch ($idos) {
		case READER_ACCESS:
		case READER_IN:
		case READER_OUT:
			$this->idos = $idos;
			break;
		default:
			$this->idos = NULL;
			break;
		}

		return $this;
	}

	public function idos_get() {
		return $this->idos;
	}

	public function is_idos() {
		return (isset($this->idos) && $idos);
	}

	public function no_idos() {
		return !$this->idos();
	}

	///////////////////////////////////////////////////////////////////////@

	public function perigrafi_set($perigrafi = NULL) {
		$this->perigrafi = $perigrafi;
		return $this;
	}

	public function perigrafi_get() {
		return $this->perigrafi;
	}

	public function is_perigrafi() {
		return (isset($this->perigrafi) && $perigrafi);
	}

	public function no_perigrafi() {
		return !$this->perigrafi();
	}

	///////////////////////////////////////////////////////////////////////@

	public function site_set() {
		$this->site = NULL;

		if ($this->no_kodikos())
		return $this->site;

		$a = explode($this->kodikos, "@");

		if (!is_array($a))
		return $this;

		if (isset($a[0]) && $a[0])
		$this->site = $a[0];

		return $this;
	}

	public function site_get() {
		return $this->site;
	}

	public function is_site() {
		if (!isset($this->site))
		return FALSE;

		if ($this->site instanceof Site)
		return $this->site->is_kodikos();

		return $this->site;
	}

	public function no_site() {
		return !$this->site();
	}

	///////////////////////////////////////////////////////////////////////@

	public function reader_fetch($kodikos = NULL) {
		if ((!isset($kodikos)) && isset($this->kodikos))
		$kodikos = $this->kodikos;

		if (!isset($kodikos))
		return $this->reader_clear();

		$query = "SELECT * FROM `kartel`.`reader`" .
			" WHERE `kodikos` = " . Globals::asfales_sql($kodikos);

		$row = Globals::first_row($query, MYSQLI_ASSOC);
		return $this->reader_set($row);
	}
}

class Ipiresia {
	private $kodikos;	// κωδικός υπηρεσίας (not null)
	private $perigrafi;	// περιγραφή υπηρεσίας (not null)

	public function __construct($colval = NULL) {
		$this->ipiresia_set($colval);
	}

	public function ipiresia_set($colval = array(
		"kodikos" => NULL,
		"perigrafi" => NULL,
	)) {

		return $this->
		kodikos_set($colval["kodikos"])->
		perigrafi_set($colval["perigrafi"]);
	}

	public function ipiresia_clear() {
		return $this->ipiresia_set();
	}

	///////////////////////////////////////////////////////////////////////@

	public function kodikos_set($kodikos = NULL) {
		$this->kodikos = $kodikos;
		return $this;
	}

	public function kodikos_get() {
		return $this->kodikos;
	}

	public function is_kodikos() {
		return isset($this->kodikos);
	}

	public function no_kodikos() {
		return !$this->is_Kodikos();
	}

	///////////////////////////////////////////////////////////////////////@

	public function perigrafi_set($perigrafi = NULL) {
		$this->perigrafi = $perigrafi;
		return $this;
	}

	public function perigrafi_get() {
		return $this->perigrafi;
	}

	///////////////////////////////////////////////////////////////////////@

	public function ipiresia_fetch($kodikos = NULL) {
		if ((!isset($kodikos)) && isset($this->kodikos))
		$kodikos = $this->kodikos;

		if (!isset($kodikos))
		return $this->ipiresia_clear();

		$query = "SELECT * FROM " . Erpota::erpotadb("ipiresia") .
			" WHERE `kodikos` = " . Globals::asfales_sql($kodikos);

		$row = Globals::first_row($query, MYSQLI_ASSOC);
		return $this->ipiresia_set($row);
	}
}

class Ipalilos {
	public $kodikos;	// κωδικός υπαλλήλου (not null)
	public $eponimo;	// επώνυμο υπαλλήλου (not null)
	public $onoma;		// όνομα υπαλλήλου (not null)
	public $patronimo;	// πατρώνυμο υπαλλήλου (not null)
	public $genisi;		// ημ. γέννησης υπαλλήλου
	public $afm;		// ΑΦΜ υπαλλήλου (αριθμητικό)
	public $premail;	// διεύθυνση προσωπικού email
	public $ipemail;	// διεύθυνση υπηρεσιακού email
	public $arxiki;		// ημερομηνία αρχικής πρόσληψης/διορισμού
	public $proslipsi;	// ημερομηνία πρόσληψης
	public $diorismos;	// ημερομηνία διορισμού
	public $apoxorisi;	// ημερομηνία αποχώρησης από την υπηρεσία
	public $katastasi;	// ΕΝΕΡΓΟΣ, ΑΝΕΝΕΡΓΟΣ

	// Οι properties που ακολουθούν αφορούν στις παραμέτρους του
	// υπαλλήλου σε δεδομένη χρονική στιγμή. Η property "metavoli"
	// είναι array δεικτοδοτημένο με το είδος της παραμέτρου, ενώ
	// οι properties "metavoli_apo" και "metavoli_eos" αφορούν
	// στην ελάχιστη και στη μέγιστη ημερομηνία για το διάστημα
	// ισχύος των παραμέτρων αυτών.

	public $metavoli;	// λίστα παραμέτρων με δείκτη το είδος
	public $metavoli_apo;	// ελάχιστη ημερομηνία ισχύος τιμών των
				// επιλεγμένων παραμέτρων
	public $metavoli_eos;	// ημερομηνία μέχρι πριν την οποία ισχύουν
				// οι τιμές των επιλεγμένων παραμέτρων

	// Η property "adia" αφορά ενδεχόμενη άδεια τού υπαλλήλου σε δεδομένη
	// χρονική στιγμή. Αν ο υπάλληλος δεν έχει άδεια κατά την εν λόγω
	// χρονική στιγμή, η τιμή τής property παραμένει null, ενώ σε αντίθετη
	// περίπτωση δείχνει την άδεια του υπαλλήλου, δεν υφίσταται ανάγκη για
	// properties ισχύος της εν λόγω άδειας καθώς τα χρονικά όρια της αδείας
	// αποτελούν στοιχεία της άδειας.

	public $adia;

	///////////////////////////////////////////////////////////////////////@

	public static function is_valid_kodikos($x) {
		return Globals::is_positive($x, IPALILOS_MAX);
	}

	public static function no_valid_kodikos($x) {
		return !self::is_valid_kodikos($x);
	}

	///////////////////////////////////////////////////////////////////////@

	public function __construct($colval = NULL) {
		$this->
		ipalilos_set($colval)->
		metavoli_clear()->
		adia_clear();
	}

	private function ipalilos_set($colval = array(
		"kodikos" => NULL,
		"eponimo" => NULL,
		"onoma" => NULL,
		"patronimo" => NULL,
		"genisi" => NULL,
		"afm" => NULL,
		"premail" => NULL,
		"ipemail" => NULL,
		"arxiki" => NULL,
		"proslipsi" => NULL,
		"diorismos" => NULL,
		"apoxorisi" => NULL,
		"katastasi" => NULL,
	)) {
		return $this->
		kodikos_set($colval["kodikos"])->
		eponimo_set($colval["eponimo"])->
		onoma_set($colval["onoma"])->
		patronimo_set($colval["patronimo"])->
		genisi_set($colval["genisi"])->
		afm_set($colval["afm"])->
		premail_set($colval["premail"])->
		ipemail_set($colval["ipemail"])->
		arxiki_set($colval["arxiki"])->
		proslipsi_set($colval["proslipsi"])->
		diorismos_set($colval["diorismos"])->
		apoxorisi_set($colval["apoxorisi"])->
		katastasi_set($colval["katastasi"]);
	}

	private function ipalilos_clear() {
		return $this->
		ipalilos_set()->
		metavoli_clear();
	}

	///////////////////////////////////////////////////////////////////////@

	public function kodikos_set($kodikos = NULL) {
		$this->kodikos = self::is_valid_kodikos($kodikos);
		return $this;
	}

	public function kodikos_get() {
		return $this->kodikos;
	}

	public function is_kodikos() {
		return isset($this->kodikos);
	}

	public function no_kodikos() {
		return !$this->is_kodikos();
	}

	public function is_ipalilos() {
		return $this->is_kodikos();
	}

	public function no_ipalilos() {
		return !$this->is_ipalilos();
	}

	public function eponimo_set($eponimo = NULL) {
		$this->eponimo = Globals::is_string($eponimo);
		return $this;
	}

	public function eponimo_get() {
		return $this->eponimo;
	}

	public function onoma_set($onoma = NULL) {
		$this->onoma = Globals::is_string($onoma);
		return $this;
	}

	public function onoma_get() {
		return $this->onoma;
	}

	public function patronimo_set($patronimo = NULL) {
		$this->patronimo = Globals::is_string($patronimo);
		return $this;
	}

	public function patronimo_get() {
		return $this->patronimo;
	}

	public function onomateponimo($patronimo = TRUE) {
		$x = $this->eponimo_get();
		$s = (isset($x) ? $x : "?????????");

		$x = $this->onoma_get();
		$s .= " " . (isset($x) ? $x : "?????????");

		if (!$patronimo)
		return $s;

		$x = $this->patronimo_get();
		$s .= " " . (isset($x) ? mb_substr($x, 0, 3) : "???");

		return $s;
	}

	public function genisi_set($genisi = NULL) {
		$this->genisi = Globals::is_date($genisi);
		return $this;
	}

	public function afm_set($afm = NULL) {
		$this->afm = Globals::is_positive($afm, AFM_MAX);
		return $this;
	}

	public function premail_set($premail = NULL) {
		$this->premail = Globals::is_email($premail);
		return $this;
	}

	public function ipemail_set($ipemail = NULL) {
		$this->ipemail = Globals::is_email($ipemail);
		return $this;
	}

	public function arxiki_set($arxiki = NULL) {
		$this->arxiki = Globals::is_date($arxiki);
		return $this;
	}

	public function proslipsi_set($proslipsi = NULL) {
		$this->proslipsi = Globals::is_date($proslipsi);
		return $this;
	}

	public function diorismos_set($diorismos = NULL) {
		$this->diorismos = Globals::is_date($diorismos);
		return $this;
	}

	public function apoxorisi_set($apoxorisi = NULL) {
		$this->apoxorisi = Globals::is_date($apoxorisi);
		return $this;
	}

	public function katastasi_set($katastasi = NULL) {
		$katastasi = Globals::is_string($katastasi);

		switch ($katastasi) {
		case ENERGOS:
		case ANENERGOS:
			$this->katastasi = $katastasi;
			break;
		default:
			$this->katastasi = NULL;
			break;
		}

		return $this;
	}

	// Η μέθοδος "ipalilos_fetch" επιχειρεί να προσπελάσει έναν υπάλληλο
	// από τον πίνακα "ipalilos" της database "erpota[12]" και επιστρέφει
	// τον συγκεκριμένο υπάλληλο ως "Ipalilos" object. Η μέθοδος δέχεται
	// ως παράμετρο τον κωδικό υπαλλήλου που επιχειρούμε να προσπελάσουμε,
	// ωστόσο υπάρχει και εναλλακτική μέθοδος: Αν δεν περάσουμε κωδικό
	// υπαλλήλου, τότε η μέθοδος χρησιμοποιεί ως κωδικό την τιμή της
	// property "kodikos". Αν και αυτή η τιμή δεν έχει τεθεί, τότε
	// επιστρέφεται null "Ipalilos" object.

	public function ipalilos_fetch($kodikos = NULL) {
		// Αρχικά ελέγχουμε αν δεν έχει περαστεί κωδικός υπαλλήλου
		// οπότε χρησιμοποιούμε την τιμή της property "kodikos",
		// εφόσον, βεβαίως, έχει τεθεί.

		if ((!isset($kodikos)) && $this->is_kodikos())
		$kodikos = $this->kodikos;

		// Πρώτη δουλειά είναι να καθαρίσουμε τον υπάλληλο, δηλαδή
		// να καταστήσουμε το ανά χείρας "Ipalilos" object σε null
		// υπάλληλο.

		$this->ipalilos_clear();

		// Αν δεν έχει καθοριστεί κωδικός υπαλλήλου με τον έναν ή τον
		// άλλο τρόπο, τότε επιστρέφουμε τον ανά χείρας null υπάλληλο.

		if (!isset($kodikos))
		return $this;

		// Εφόσον έχει καθοριστεί κωδικός υπαλλήλου, επιχειρούμε να
		// προσπελάσουμε τον υπάλληλο στην database.

		$query = "SELECT * FROM " . Erpota::erpotadb("ipalilos") .
			" WHERE `kodikos` = " . $kodikos;

		$row = Globals::first_row($query, MYSQLI_ASSOC);

		// Αν δεν εντοπίσουμε υπάλληλο με τον κωδικό που έχει δοθεί,
		// επιστρέφουμε τον ανά χείρας (null) υπάλληλο.

		if (!$row)
		return $this;

		// Έχει εντοπιστεί ο υπάλληλος, οπότε θέτουμε τις τιμές των
		// properties και επιστρέφουμε τον υπάλληλο.

		return $this->ipalilos_set($row);
	}

	//////////////////////////////////////////////////////////////////////@

	// Η μέθοδος "is_metavoli" ελέγχει αν έχουν επιλεγεί παράμετροι του
	// υπαλλήλου με βάση κάποια ημερομηνία επιλογής. Αυτό φαίνεται κατ'
	// αρχάς από το αν η property "metavoli" παραμένει null ή δείχνει σε
	// κάποιο array παραμέτρων. Μπορούμε, επιπροσθέτως, να περάσουμε ως
	// παράμετρο συγκεκριμένο είδος μεταβολής, οπότε θα επιστραφεί η τιμή
	// τής εν λόγω μεταβολής εφόσον αυτή υπάρχει στη στη λίστα μεταβολών,
	// αλλιώς επιστρέφεται η boolean τιμή false.

	public function is_metavoli($idos = NULL) {
		if (!isset($this->metavoli))
		return FALSE;

		if (!is_array($this->metavoli))
		return FALSE;

		if (!isset($idos))
		return TRUE;

		if (array_key_exists($idos, $this->metavoli))
		return $this->metavoli[$idos];

		return FALSE;
	}

	public function no_metavoli($idos = NULL) {
		return !$this->is_metavoli($idos);
	}

	// Η μέθοδος "metavoli_get" επιστρέφει τη λίστα μεταβολών του υπαλλήλου.
	// Επιπροσθέτως, μπορούμε να περάσουμε ως παράμετρο συγκεκριμένο είδος
	// μεταβολής, οπότε θα επιστραφεί η τιμή της συγκεκριμένης μεταβολής
	// εφόσον αυτή υπάρχει, αλλιώς θα επιστραφεί null.

	public function metavoli_get($idos = NULL) {
		if (!isset($idos))
		return $this->metavoli;

		if ($this->is_metavoli($idos))
		return $this->metavoli[$idos];

		return NULL;
	}

	private function metavoli_set($m, $d = NULL) {
		if (!isset($d)) {
			$this->metavoli[$m->idos] = $m;
			return $this;
		}

		// Αγνοούμε διάφορες «εξωτικές» μεταβολές.

		if (!isset($m))
		return $this;

		if (!($m instanceof Metavoli))
		return $this;

		if ($m->no_idos())
		return $this;

		if ($m->no_efarmogi())
		return $this;

		if ($m->is_lixi() && ($m->lixi <= $m->efarmogi))
		return $this;

		// Η μεταβολή δείχνει να είναι ορθή, επομένως προχωρούμε
		// στην καταχώρησή της στο array μεταβολών του υπαλλήλου.
		// Πρώτα ελέγχουμε τις «εύκολες» περιπτώσεις.

		if ($m->efarmogi > $d)
		return $this->metavoli_eos_set($m->efarmogi);

		if ($m->is_lixi() && ($m->lixi <= $d))
		return ($this->metavoli_apo_set($m->lixi));

		return $this->
		metavoli_set($m)->
		metavoli_apo_set($m->efarmogi)->
		metavoli_eos_set($m->lixi);
	}

	public function metavoli_clear($mlist = NULL) {
		$this->metavoli = $mlist;
		$this->metavoli_apo = NULL;
		$this->metavoli_eos = NULL;
		return $this;
	}

	public function is_metavoli_apo() {
		if (!isset($this->metavoli_apo))
		return FALSE;

		if ($this->metavoli_apo instanceof DateTime)
		return $this->metavoli_apo;

		return FALSE;
	}

	public function no_metavoli_apo() {
		return !$this->is_metavoli_apo();
	}

	// Η μέθοδος "metavoli_apo_set" δέχεται ως παράμετρο μια ημερομηνία
	// αρχής διαστήματος ισχύος επιλεγμένων μεταβολών (ΑΔΙΜ), και εφόσον
	// αυτή η ημερομηνία είναι μεγαλύτερη από την τρέχουσα ΑΔΙΜ, τίθεται
	// ως νέα ΑΔΙΜ «στενεύοντας» το διάστημα ισχύος μεταβολών από κάτω.

	private function metavoli_apo_set($date = NULL) {
		if (!isset($date))
		return $this;

		if ($this->is_metavoli_apo() &&
			($this->metavoli_apo >= $date))
		return $this;

		$this->metavoli_apo = $date;
		return $this;
	}

	public function is_metavoli_eos() {
		if (!isset($this->metavoli_eos))
		return FALSE;

		if ($this->metavoli_eos instanceof DateTime)
		return $this->metavoli_eos;

		return FALSE;
	}

	public function no_metavoli_eos() {
		return !$this->is_metavoli_eos();
	}

	// Η μέθοδος "metavoli_eos_set" δέχεται ως παράμετρο μια ημερομηνία
	// τέλους διαστήματος ισχύος επιλεγμένων μεταβολών (ΤΔΙΜ), και εφόσον
	// αυτή η ημερομηνία είναι μικρότερη από το τρέχον ΤΔΙΜ, τίθεται ως
	// νέο ΤΔΙΜ «στενεύοντας» το διάστημα ισχύος μεταβολών από πάνω.

	private function metavoli_eos_set($date = NULL) {
		if (!isset($date))
		return $this;

		if ($this->is_metavoli_eos() &&
			($this->metavoli_eos < $date))
		return $this;

		$this->metavoli_eos = $date;
		return $this;
	}

	// Η μέθοδος "metavoli_fetch" δέχεται ως παράμετρο μια ημερομηνία και
	// επιλέγχει τις μεταβολές που ισχύουν για τον ανά χείρας υπάλληλο στη
	// συγκεκριμένη ημερομηνία. Οι μεταβολές αυτές τοποθετούνται σε λίστα
	// δεικτοδοτημένη με το είδος της μεταβολής, ενώ παράλληλα τίθενται η
	// αρχή και το τέλος του διαστήματος ισχύος των μεταβολών αυτών.

	public function metavoli_fetch($date = NULL) {
		// Προϋπόθεση για να επιλέξουμε παραμέτρους του υπαλλήλου είναι,
		// βέβαια, ο υπάλληλος να είναι καθορισμένος.

		if ($this->no_kodikos())
		return $this->metavoli_clear();

		// Αν δεν έχουμε περάσει ημερομηνία, τότε λογίζεται η τρέχουσα
		// ημερομηνία.

		if (!isset($date))
		$date = date(DTPHP_YMD);

		$date = Globals::is_date($date);

		if (!isset($date))
		return $this->metavoli_clear();

		// Πριν αρχίσουμε να μαζεύουμε παραμέτρους του υπαλλήλου,
		// ελέγχουμε μήπως οι παράμετροι για την ζητούμενη ημερομηνία
		// είναι ήδη in situ.

		if ($this->metavoli_insitu($date))
		return $this;

		// Οι παράμετροι πρέπει να επιλεγούν από την database και ως
		// εκ τούτου δημιουργώ νέο array μεταβολών και καθαρίζω το
		// χρονικό διάστημα ισχύος των παραμέτρων που θα επιλεγούν.

		$this->metavoli_clear(array());

		// Διατρέχω όλες τις παραμέτρους του υπαλλήλου χωρίς αρχικά
		// να λαμβάνω υπόψη μου τις ημερομηνίες εφαρμογής και λήξης.

		$query = "SELECT * FROM " . Erpota::erpotadb("metavoli") .
			" WHERE `ipalilos` = " . $this->kodikos;
		$result = Globals::query($query);

		while ($row = $result->fetch_array(MYSQLI_ASSOC))
		$this->metavoli_set(new Metavoli($row), $date);

		$result->free();
		return $this;
	}

	private function metavoli_insitu($date) {
		if ($this->no_metavoli())
		return FALSE;

		// Αν το array μεταβολών έχει τεθεί, αλλά δεν έχουν τεθεί
		// χρονικά όρια ισχύος των τιμών του array μεταβολών, τότε
		// θεωρούμε ότι οι συγκεκριμένες τιμές ισχύουν πάντα. Αυτό
		// μπορεί να συμβεί μόνο όταν ο υπάλληλος στερείται μεταβολών.

		if ($this->no_metavoli_apo() && $this->no_metavoli_eos())
		return TRUE;

		if ($this->is_metavoli_apo() && ($date < $this->metavoli_apo))
		return FALSE;

		if ($this->is_metavoli_eos() && ($date >= $this->metavoli_eos))
		return FALSE;

		return TRUE;
	}

	//////////////////////////////////////////////////////////////////////@

	public function adia_set($date = NULL) {
		if ($this->no_ipalilos())
		return $this->adia_clear();

		if (!isset($date))
		return $this->adia_clear();

		if ($date instanceof DateTime)
		$date = $date->format(DTPHP_YMD);

		$date = Globals::is_date($date);

		if (!isset($date))
		return $this->adia_clear();

		$adia = (new Adia())->
		ipalilos_set($this->kodikos_get())->
		adia_fetch($date);

		if ($adia->no_adia())
		return $this->adia_clear();

		$this->adia = $adia;
		return $this;
	}

	public function adia_clear() {
		$this->adia = NULL;
		return $this;
	}

	public function is_adia() {
		return $this->adia;
	}

	public function no_adia() {
		return !$this->is_adia();
	}

	public function adia_fetch($date = NULL) {
		// Προϋπόθεση για να επιλέξουμε οποιαδήποτε άδεια του υπαλλήλου
		// είναι, βέβαια, ο υπάλληλος να είναι καθορισμένος.

		if ($this->no_ipalilos())
		return $this->adia_clear();

		// Αν δεν έχουμε περάσει ημερομηνία, τότε λογίζεται η τρέχουσα
		// ημερομηνία.

		if (!isset($date))
		$date = date(DTPHP_YMD);

		$date = Globals::is_date($date);

		if (!isset($date))
		return $this->adia_clear();

		$date = $date->format(DTPHP_YMD);

		// Πριν επιχειρήσουμε να επιλέξουμε ενδεχόμενη άδεια του
		// υπαλλήλου κατά τη συγκεκριμένη ημερομηνία, ελέγχουμε μήπως
		// η συγκεκριμένη ημερομηνία εμπεριέχεται σε ήδη επιλεγμένη
		// άδεια.

		if ($this->adia_insitu($date))
		return $this;

		$query = "SELECT * FROM `erpota`.`adia`" .
			" WHERE (`ipalilos` = " . $this->kodikos . ")" .
			" AND (`apo` <= " . Globals::asfales_sql($date) . ")" .
			" ORDER BY `apo`, `kodikos` LIMIT 1";
		$row = Globals::first_row($query, MYSQLI_ASSOC);

		if (!isset($row))
		return $this->adia_clear();

		$this->adia = new Adia($row);
	}

	private function adia_insitu($date) {
		if ($this->no_adia())
		return FALSE;

		// Αν το array μεταβολών έχει τεθεί, αλλά δεν έχουν τεθεί
		// χρονικά όρια ισχύος των τιμών του array μεταβολών, τότε
		// θεωρούμε ότι οι συγκεκριμένες τιμές ισχύουν πάντα. Αυτό
		// μπορεί να συμβεί μόνο όταν ο υπάλληλος στερείται μεταβολών.

		if ($this->no_adia_apo() && $this->no_adia_eos())
		return TRUE;

		if ($this->is_adia_apo() && ($date < $this->adia_apo))
		return FALSE;

		if ($this->is_adia_eos() && ($date >= $this->adia_eos))
		return FALSE;

		return TRUE;
	}
}

class Metavoli {
	public $ipalilos;
	public $idos;
	public $efarmogi;
	public $lixi;
	public $timi;
	public $decode;

	public function __construct($colval = NULL) {
		$this->metavoli_set($colval);
	}

	private function metavoli_set($colval = array(
		"ipalilos" => NULL,
		"idos" => NULL,
		"efarmogi" => NULL,
		"lixi" => NULL,
		"timi" => NULL,
		"decode" => NULL,
	)) {
		if (!array_key_exists("decode", $colval))
		$colval["decode"] = NULL;
		
		return $this->
		ipalilos_set($colval["ipalilos"])->
		idos_set($colval["idos"])->
		efarmogi_set($colval["efarmogi"])->
		lixi_set($colval["lixi"])->
		timi_set($colval["timi"])->
		decode_set($colval["decode"]);
	}

	private function metavoli_clear() {
		return $this->metavoli_set();
	}

	///////////////////////////////////////////////////////////////////////@

	private function ipalilos_set($ipalilos = NULL) {
		$this->ipalilos = Ipalilos::is_valid_kodikos($ipalilos);
		return $this;
	}

	private function idos_set($idos = NULL) {
		$this->idos = Globals::is_string($idos);
		return $this;
	}

	private function efarmogi_set($efarmogi = NULL) {
		$this->efarmogi = Globals::is_date($efarmogi);
		return $this;
	}

	private function lixi_set($lixi = NULL) {
		$this->lixi = Globals::is_date($lixi);
		return $this;
	}

	private function timi_set($timi = NULL) {
		$this->timi = Globals::is_string($timi);
		return $this;
	}

	private function decode_set($decode = NULL) {
		$this->decode = Globals::is_string($decode);
		return $this;
	}

	private function decode_clear() {
		return $this->decode_set();
	}

	///////////////////////////////////////////////////////////////////////@

	public function is_idos() {
		return isset($this->idos);
	}

	public function no_idos() {
		return !$this->is_idos();
	}

	public function is_efarmogi() {
		return isset($this->efarmogi);
	}

	public function no_efarmogi() {
		return !$this->is_efarmogi();
	}

	public function is_lixi() {
		return isset($this->lixi);
	}

	public function no_lixi() {
		return !$this->is_lixi();
	}

	public function is_timi() {
		return isset($this->timi);
	}

	public function no_timi() {
		return !$this->is_timi();
	}

	public function is_decode() {
		return isset($this->decode);
	}

	public function no_decode() {
		return !$this->is_decode();
	}

	public function metavoli_decode() {
		if ($this->no_idos())
		return $this->decode_clear();

		if ($this->no_timi())
		return $this->decode_clear();

		switch ($this->idos) {
		case "ΔΙΕΥΘΥΝΣΗ":
		case "ΤΜΗΜΑ":
		case "ΓΡΑΦΕΙΟ":
			return $this->metavoli_decode_ipiresia();
		}

		return $this->decode_clear();
	}

	private function metavoli_decode_ipiresia() {
		if ($this->no_timi())
		return $this->decode_clear();

		$ipiresia = (new Ipiresia())->
		kodikos_set($this->timi)->
		ipiresia_fetch();

		if ($ipiresia->no_kodikos())
		return $this->decode_clear();

		return $this->decode_set($ipiresia->perigrafi_get());
	}
}

class Prosvasi {
	public $ipalilos;
	public $efarmogi;
	public $ipiresia;
	public $level;
	public $info;
	public $pubkey;
	public $password;

	public function __construct($colval = NULL) {
		$this->prosvasi_set($colval);
	}

	public function prosvasi_set($colval = array(
		"ipalilos" => NULL,
		"efarmogi" => NULL,
		"ipiresia" => NULL,
		"level" => NULL,
		"info" => NULL,
		"pubkey" => NULL,
		"password" => NULL,
	)) {
		return $this->
		ipalilos_set($colval["ipalilos"])->
		efarmogi_set($colval["efarmogi"])->
		ipiresia_set($colval["ipiresia"])->
		level_set($colval["level"])->
		info_set($colval["info"])->
		pubkey_set($colval["pubkey"])->
		password_set($colval["password"]);
	}

	private function prosvasi_clear() {
		return $this->prosvasi_set();
	}

	public function ipalilos_set($ipalilos = NULL) {
		$this->ipalilos = Ipalilos::is_valid_kodikos($ipalilos);
		return $this;
	}

	public function efarmogi_set($efarmogi = NULL) {
		$this->efarmogi = Globals::is_date($efarmogi);
		return $this;
	}

	public function ipiresia_set($ipiresia = NULL) {
		$this->ipiresia = Globals::is_string($ipiresia);
		return $this;
	}

	public function level_set($level = NULL) {
		$this->level = Globals::is_string($level);
		return $this;
	}

	public function info_set($info = NULL) {
		$this->info = Globals::is_string($info);
		return $this;
	}

	public function pubkey_set($pubkey = NULL) {
		$this->pubkey = Globals::is_string($pubkey);
		return $this;
	}

	public function password_set($password = NULL) {
		$this->password = Globals::is_string($password, array(
			"trim" => FALSE,
			"keno" => TRUE,
		));
		return $this;
	}

	public function prosvasi_fetch() {
		$query = "SELECT * FROM `erpota`.`prosvasi`";
		$where = FALSE;

		if (isset($this->ipalilos))
		$where = Globals::where_push($query, $where,
			"`ipalilos` = " . $this->ipalilos);

		if (isset($this->pubkey))
		$where = Globals::where_push($query, $where,
			"BINARY `pubkey` = BINARY " .
			Globals::asfales_sql($this->pubkey));

		if (isset($this->password))
		$where = Globals::where_push($query, $where,
			"BINARY `password` = BINARY SHA1(" .
			Globals::asfales_sql($this->password) . ")");

		return $this->prosvasi_set
			(Globals::first_row($query, MYSQLI_ASSOC));
	}

	public function authlevel_get() {
		return $this->level;
	}

	public function authdept_get() {
		return $this->ipiresia;
	}

	public function is_admin() {
		return ($this->level_get() === 'ADMIN');
	}

	public function is_editor() {
		return ($this->level_get() === 'UPDATE');
	}
}

class Simvan {
	private $kodikos;
	private $meraora;
	private $tipos;
	private $karta;
	private $reader;

	///////////////////////////////////////////////////////////////////////@

	public static function is_valid_kodikos($x) {
		return Globals::is_positive($x, EVENTID_MAX);
	}

	public static function no_valid_kodikos($x) {
		return !self::is_valid_kodikos($x);
	}

	///////////////////////////////////////////////////////////////////////@

	public function __construct($colval = NULL) {
		$this->simvan_set($colval);
	}

	public function simvan_set($colval = array(
		"kodikos" => NULL,
		"meraora" => NULL,
		"tipos" => NULL,
		"karta" => NULL,
		"reader" => NULL,
	)) {
		return $this->
		kodikos_set($colval["kodikos"])->
		meraora_set($colval["meraora"])->
		tipos_set($colval["tipos"])->
		reader_set($colval["reader"]);
	}

	public function simvan_clear() {
		return $this->simvan_set();
	}

	///////////////////////////////////////////////////////////////////////@

	public function is_simvan() {
		return $this->is_kodikos();
	}

	public function no_simvan() {
		return !$this->is_simvan();
	}

	///////////////////////////////////////////////////////////////////////@

	public function kodikos_set($kodikos = NULL) {
		$this->kodikos = self::is_valid_kodikos($kodikos);
		return $this;
	}

	public function kodikos_get() {
		return $this->kodikos;
	}

	public function is_kodikos() {
		return self::is_valid_kodikos($this->kodikos);
	}

	public function no_kodikos() {
		return !$this->is_kodikos();
	}

	///////////////////////////////////////////////////////////////////////@

	public function meraora_set($meraora = NULL) {
		$this->meraora = Globals::is_datetime($meraora);
		return $this;
	}

	public function meraora_get() {
		return $this->meraora;
	}

	public function is_meraora() {
		if (!isset($this->meraora))
		return FALSE;

		if ($this->meraora instanceof DateTime)
		return $this->meraora;

		return FALSE;
	}

	public function no_meraora() {
		return !$this->is_meraora();
	}

	///////////////////////////////////////////////////////////////////////@

	public function tipos_set($tipos = NULL) {
		$this->tipos = Globals::is_string($tipos);
		return $this;
	}

	public function tipos_get() {
		return $this->tipos;
	}

	public function is_tipos() {
		return (isset($this->tipos) && $tipos);
	}

	public function no_tipos() {
		return !$this->is_tipos();
	}

	///////////////////////////////////////////////////////////////////////@

	public function karta_set($karta = NULL) {
		$this->karta = Globals::is_positive($karta, KARTA_MAX);
		return $this;
	}

	public function karta_get() {
		return $this->karta;
	}

	public function is_karta() {
		return isset($this->karta);
	}

	public function no_karta() {
		return !$this->is_karta();
	}

	///////////////////////////////////////////////////////////////////////@

	public function reader_set($reader = NULL) {
		if (!isset($reader))
		return $this->reader_clear();

		if ($reader instanceof Reader)
		$reader = $reader->kodikos_get();

		if (isset($reader) && $reader)
		$reader = (new Reader())->reader_fetch($reader);

		if ($reader->no_kodikos())
		return $this->reader_clear();

		$this->reader = $reader;
		return $this;
	}

	public function reader_get() {
		return $this->reader;
	}

	public function is_reader() {
		return (isset($this->reader) && $reader->is_kodikos());
	}

	public function no_reader() {
		return !$this->is_reader();
	}

	public function reader_clear() {
		$this->reader = NULL;
		return $this;
	}

	///////////////////////////////////////////////////////////////////////@

	public function simvan_fetch($simvan = NULL) {
		if (!isset($simvan))
		return $this->simvan_clear();

		if ($simvan instanceof Simvan)
		$simvan = $simvan->kodikos_get();

		$simvan = Simvan::is_valid_kodikos($simvan);

		if (!$simvan)
		return $this->simvan_clear();

		$query = "SELECT * FROM `kartel`.`event`" .
			" WHERE `kodikos` = " . $simvan;

		$row = Globals::first_row($query, MYSQLI_ASSOC);
		return $this->simvan_set($row);
	}
}

// Η κλάση "Excuse" αφορά σε αιτιολογίες προσέλευσης ή αποχώρησης των υπαλλήλων.
// Οι αιτιολογίες αποθηκεύονται στην database στον πίνακα "erpota.excuse" από
// εξουσιοδοτημένους χρήστες, ενώ ως primary key χρησιμοποιούνται τα πεδία του
// κωδικού υπαλλήλου, η ημερομηνία και το αν πρόκειται για την προσέλευση ή την
// αποχώρηση του υπαλλήλου. Τα υπόλοιπα πεδία είναι η ώρα και τυχόν σχόλιο.
//
// Το πεδίο της ώρα έχει κάποια ιδιαιτερότητα, καθώς μπορεί να είναι null πράγμα
// που σημαίνει ότι ο υπάλληλος προσήλθε ή αποχώρησε την προσήκουσα ώρα. Αν η
// ώρα είναι συμπληρωμένη, τότε υπολογίζεται η διαφορά ώρας όπως ακριβώς στις
// καταγεγραμμένες -μέσω κάρτας- προσελεύσεις ή αποχωρήσεις.
//
// Αν ο λόγος είναι null, τότε ο υπάλληλος θεωρείται ότι ο υπάλληλος δεν
// προσήθλε ή δεν αποχώρησε κανονικά.

class Excuse {
	// Τα πεδία "ipalilos", "mera" και "proapo" αποτελούν primary key.

	public $ipalilos;	// κωδικός υπαλλήλου
	public $mera;		// ημερομηνία
	public $proapo;		// προσέλευση ή αποχώρηση
	public $ora;		// ώρα, μπορεί να είναι και null
	public $logos;		// λόγος από συγκεκριμένη λίστα
	public $info;		// ελεύθερο κείμενο περαιτέρω επεξήγησης

	///////////////////////////////////////////////////////////////////////@

	public static function is_valid_proapo($proapo) {
		if (!isset($proapo))
		return NULL;

		if (!is_string($proapo))
		return NULL;

		switch ($proapo) {
		case PROSELEFSI:
		case APOXORISI:
			return $proapo;
		}

		return NULL;
	}

	public static function no_valid_proapo($proapo) {
		return !self::is_valid_proapo($proapo);
	}

	///////////////////////////////////////////////////////////////////////@

	public function __construct($colval = NULL) {
		$this->excuse_set($colval);
	}

	public function excuse_set($colval = array(
		"ipalilos" => NULL,
		"mera" => NULL,
		"proapo" => NULL,
		"ora" => NULL,
		"logos" => NULL,
		"info" => NULL,
	)) {
		return $this->
		ipalilos_set($colval["ipalilos"])->
		mera_set($colval["mera"])->
		proapo_set($colval["proapo"])->
		ora_set($colval["ora"])->
		logos_set($colval["logos"])->
		info_set($colval["info"]);
	}

	public function excuse_clear() {
		return $this->excuse_set();
	}

	public function ipalilos_set($ipalilos = NULL) {
		$this->ipalilos = NULL;

		if (!isset($ipalilos))
		return $this;

		if ($ipalilos instanceof Ipalilos)
		$ipalilos = $ipalilos->kodikos_get();

		$this->ipalilos = Ipalilos::is_valid_kodikos($ipalilos);
		return $this;
	}

	public function mera_set($mera = NULL, $format = DTPHP_YMD) {
		$this->mera = Globals::is_date($mera, $format);
		return $this;
	}

	public function proapo_set($proapo = NULL) {
		$this->proapo = self::is_valid_proapo($proapo);
		return $this;
	}

	public function ora_set($ora = NULL, $format = "TMPHP_HMS") {
		$this->ora = Globals::is_time($ora, $format);
		return $this;
	}

	public function logos_set($logos = NULL) {
		$this->logos = Globals::is_string($logos);
		return $this;
	}

	public function info_set($info = NULL) {
		$this->info = Globals::is_string($info);
		return $this;
	}

	///////////////////////////////////////////////////////////////////////@

	public function is_excuse() {
		if ($this->no_ipalilos())
		return FALSE;

		if ($this->no_mera())
		return FALSE;

		if ($this->no_proapo())
		return FALSE;

		return $this;
	}

	public function no_excuse() {
		return !$this->is_excuse();
	}

	public function is_ipalilos() {
		if (!isset($this->ipalilos))
		return FALSE;

		if ($this->ipalilos instanceof Ipalilos)
		return $this->ipalilos->is_ipalilos();

		return FALSE;
	}

	public function no_ipalilos() {
		return !$this->is_ipalilos();
	}

	public function is_mera() {
		if (!isset($this->mera))
		return FALSE;

		if ($this->mera instanceof DateTime)
		return $this->mera;

		return FALSE;
	}

	public function no_mera() {
		return !$this->is_mera();
	}

	public function is_proapo() {
		if (!isset($this->proapo))
		return FALSE;

		if (self::is_valid_proapo($this->proapo))
		return $this->proapo;

		return FALSE;
	}

	public function no_proapo() {
		return !$this->is_proapo();
	}

	public function is_ora() {
		if (!isset($this->ora))
		return FALSE;

		if ($this->ora instanceof DateTime)
		return $this->ora;

		return FALSE;
	}

	public function no_ora() {
		return !$this->is_ora();
	}

	public function is_logos() {
		return isset($this->logos);
	}

	public function no_logos() {
		return !$this->is_logos();
	}

	public function is_info() {
		return isset($this->info);
	}

	public function no_info() {
		return !$this->is_info();
	}

	///////////////////////////////////////////////////////////////////////@

	public function excuse_check() {
		if ($this->no_ipalilos())
		return EXCUSE_NO_IPALILOS;

		if ($this->no_mera())
		return EXCUSE_NO_MERA;

		if ($this->no_proapo())
		return EXCUSE_NO_PROAPO;

		return EXCUSE_OK;
	}

	public function where_clause() {
		if ($this->excuse_check())
		return "";

		return " WHERE ((`excuse`.`ipalilos` = " .
			$this->ipalilos->kodikos . ") " .
			"AND (`excuse`.`mera` = '" .
			$this->mera->format(DTPHP_YMD) . "') " .
			"AND (`excuse`.`proapo` = '" . $this->proapo . "'))";
	}

	public function excuse_fetch() {
		if ($this->excuse_check())
		return $this->excuse_clear();

		$query = "SELECT * FROM `erpota`.`excuse` WHERE " .
			$this->where_clause();
		$row = Globals::first_row($query, MYSQLI_ASSOC);

		return $this->excuse_set($row);
	}
}

class Adia {
	public $kodikos;	// κωδικός αδείας
	public $ipalilos;	// κωδικός υπαλλήλου
	public $apo;		// ημερομηνία αρχής
	public $eos;		// ημερομηνία τέλους
	public $idos;		// είδος αδείας
	public $info;		// ελεύθερο κείμενο σχετικών σχολίων

	public function __construct($colval = NULL) {
		$this->adia_set($colval);
	}

	public function adia_set($colval = array(
			"kodikos" => NULL,
			"ipalilos" => NULL,
			"apo" => NULL,
			"eos" => NULL,
			"idos" => NULL,
			"info" => NULL,
		)) {

		return $this->
		kodikos_set($colval["kodikos"])->
		ipalilos_set($colval["ipalilos"])->
		apo_set($colval["apo"])->
		eos_set($colval["eos"])->
		idos_set($colval["idos"])->
		info_set($colval["info"]);
	}

	public function adia_clear() {
		return $this->adia_set();
	}

	public function kodikos_set($kodikos = NULL) {
		$this->kodikos = Globals::is_positive($kodikos, ADIA_MAX);
		return $this;
	}

	public function ipalilos_set($ipalilos = NULL) {
		$this->ipalilos = Ipalilos::is_valid_kodikos($ipalilos);
		return $this;
	}

	public function apo_set($apo = NULL) {
		$this->apo = Globals::is_date($apo);
		return $this;
	}

	public function eos_set($eos = NULL) {
		$this->eos = Globals::is_date($eos);
		return $this;
	}

	public function idos_set($idos = NULL) {
		$this->idos = Globals::is_string($idos);
		return $this;
	}

	public function info_set($info = NULL) {
		$this->info = Globals::is_string($info);
		return $this;
	}

	public function is_kodikos() {
		return isset($this->kodikos);
	}

	public function no_kodikos() {
		return !$this->is_kodikos();
	}

	public function is_apo() {
		return isset($this->apo);
	}

	public function no_apo() {
		return !$this->is_apo();
	}

	public function is_eos() {
		return isset($this->eos);
	}

	public function no_eos() {
		return !$this->is_eos();
	}

	public function is_idos() {
		return isset($this->idos);
	}

	public function no_idos() {
		return !$this->is_idos();
	}

	// Η μέθοδος "json_economy" εκτυπώνει την άδεια σε json format
	// κατάλληλο για τη βασική σελίδα εμφάνισης ημερολογίου συμβάντων.

	public function json_economy($ante = ",", $post = "") {
		if ($this->no_kodikos())
		return $this;

		print $ante . "A:{k:" . $this->kodikos;

		if ($this->is_apo())
		print ",a:" . Globals::asfales_json($this->apo->format(DTPHP_YMD));

		if ($this->is_eos())
		print ",e:" . Globals::asfales_json($this->eos->format(DTPHP_YMD));

		if ($this->is_idos())
		print ",i:" . Globals::asfales_json($this->idos);

		print "}" . $post;
		return $this;
	}
}

// Τα αντικείμενα κλάσης "Checkpoint" αφορούν σε προσελεύσεις ή αποχωρήσεις
// συγκεκριμένων υπαλλήλων σε συγκεκριμένες ημερομηνίες. Η σειρά των properties
// δεν έχει ιδιαίτερη σημασία, ωστόσ καταδεικνύει την ορθή οπτική αντικειμένων
// τής κλάσης "Checkpoint". Πράγματι, η κύρια χρήση των αντικειμένων αυτών είναι
// η σύνταξη των παρουσιολογίων τα οποία συντάσσονται σε κάθε οργανική μονάδα,
// τόσο κατά την προσέλευση των υπαλλήλων της συγκεκριμένης οργανικής μονάδας,
// όσο και κατά την αποχώρηση των υπαλλήλων αυτών. Επομένως, πρωτεύοντα ρόλο
// παίζουν, με τη σειρά που παρατίθενται: η ημερομηνία, ο υπάλληλος, και το αν
// πρόκειται για προσέλευση ή για αποχώρηση τού υπαλλήλου.

class Checkpoint {
	public $imerominia;
	public $ipalilos;
	public $proapo;
	public $simvan;
	public $excuse;
	public $adia;

	public function __construct($colval = NULL) {
		$this->checkpoint_set($colval);
	}

	public function checkpoint_set($colval = array(
		"imerominia" => NULL,
		"ipalilos" => NULL,
		"proapo" => NULL,
		"simvan" => NULL,
		"excuse" => NULL,
		"adia" => NULL,
	)) {
		return $this->
		imerominia_set($colval["imerominia"])->
		ipalilos_set($colval["ipalilos"])->
		proapo_set($colval["proapo"])->
		simvan_set($colval["simvan"])->
		excuse_set($colval["excuse"]);
	}

	public function checkpoint_clear() {
		return $this->checkpoint_set();
	}

	///////////////////////////////////////////////////////////////////////@

	public function imerominia_set($date = NULL) {
		$this->imerominia = Globals::is_date($date);
		return $this;
	}

	public function imerominia_clear() {
		$this->imerominia = NULL;
		return $this;
	}

	public function is_imerominia() {
		return isset($this->imerominia);
	}

	public function no_imerominia() {
		return !$this->is_imerominia();
	}

	///////////////////////////////////////////////////////////////////////@

	public function ipalilos_set($ipalilos = NULL) {
		if (!isset($ipalilos))
		return $this->ipalilos_clear();

		if (($ipalilos instanceof Ipalilos) &&
			$ipalilos->is_ipalilos()) {

			$this->ipalilos = $ipalilos;
			return $this;
		}

		if (Ipalilos::no_valid_kodikos($ipalilos))
		return $this->ipalilos_clear();

		$ipalilos = (new Ipalilos())->
		kodikos_set($ipalilos)->
		ipalilos_fetch();

		if ($ipalilos->no_ipalilos())
		return $this->ipalilos_clear();

		$this->ipalilos = $ipalilos;
		return $this;
	}

	public function ipalilos_clear() {
		$this->ipalilos = NULL;
		return $this;
	}

	public function is_ipalilos() {
		return isset($this->ipalilos);
	}

	public function no_ipalilos() {
		return !$this->is_ipalilos();
	}

	public function metavoli_clear() {
		if ($this->is_ipalilos())
		$this->ipalilos->metavoli_clear();

		return $this;
	}

	public function metavoli_refresh() {
		if ($this->no_ipalilos())
		return $this;

		if ($this->no_imerominia()) {
			$this->ipalilos->metavoli_clear();
			return $this;
		}

		$this->ipalilos->metavoli_fetch($this->imerominia);
		return $this;
	}

	public function adia_clear() {
		if ($this->is_ipalilos())
		$this->ipalilos->adia_clear();

		return $this;
	}

	public function adia_refresh() {
		if ($this->no_ipalilos())
		return $this;

		if ($this->no_imerominia()) {
			$this->ipalilos->adia_clear();
			return $this;
		}

		$this->ipalilos->adia_fetch($this->imerominia);
		return $this;
	}

	///////////////////////////////////////////////////////////////////////@

	public function proapo_set($proapo = NULL) {
		if (!isset($proapo))
		return $this->proapo_clear();

		if (Excuse::no_valid_proapo($proapo))
		return $this->proapo_clear();

		$this->proapo = $proapo;
		return $this;
	}

	public function proapo_clear() {
		$this->proapo = NULL;
		return $this;
	}

	public function is_proapo() {
		return isset($this->proapo);
	}

	public function no_proapo() {
		return !$this->is_proapo();
	}

	public function is_proselefsi() {
		return ($this->proapo === PROSELEFSI);
	}

	public function is_apoxorisi() {
		return ($this->proapo === APOXORISI);
	}

	///////////////////////////////////////////////////////////////////////@

	public function simvan_set($simvan = NULL) {
		if (!isset($simvan))
		return $this->simvan_clear();

		if ($simvan instanceof Simvan) {
			if ($simvan->no_simvan())
			return $this->simvan_clear();

			$this->simvan = $simvan;
			return $this;
		}

		if (Simvan::no_valid_kodikos($simvan))
		return $this->simvan_clear();

		$simvan = (new Simvan())->
		simvan_fetch($simvan);

		if ($simvan->no_simvan())
		return $this->simvan_clear();

		$this->simvan = $simvan;
		return $this;
	}

	public function simvan_clear() {
		$this->simvan = NULL;
		return $this;
	}

	public function is_simvan() {
		return isset($this->simvan);
	}

	public function no_simvan() {
		return !$this->is_simvan();
	}

	///////////////////////////////////////////////////////////////////////@

	public function excuse_clear() {
		$this->excuse = NULL;
		return $this;
	}

	public function excuse_set($excuse = NULL) {
		if (!isset($excuse))
		return $this->excuse_clear();

		if ($excuse instanceof Excuse) {
			if ($excuse->no_excuse())
			return $this->excuse_clear();

			$this->excuse = $excuse;
			return $this;
		}

		if (Simvan::no_valid_kodikos($excuse))
		return $this->excuse_clear();

		$excuse = (new Simvan())->
		excuse_fetch($excuse);

		if ($excuse->no_excuse())
		return $this->excuse_clear();

		$this->excuse = $excuse;
		return $this;
		if ($this->no_imerominia())
		return $this->excuse_clear();

		if ($this->no_ipalilos())
		return $this->excuse_clear();

		if ($this->no_proapo())
		return $this->excuse_clear();

		$excuse = (new Excuse())->
		ipalilos_set($this->ipalilos)->
		mera_set($this->imerominia)->
		proapo_set($this->proapo)->
		excuse_fetch();

		if ($excuse->no_excuse())
		return $this->excuse_clear();

		$this->excuse = $excuse;
		return $this;
	}

	public function excuse_refresh() {
		return $this->excuse_set();
	}
}

// Η κλάση "Vardia" απεικονίζει βάρδιες ωραρίου. Η βάρδια καθορίζεται από την
// έναρξη, το πέρας και τη διάρκεια, ωστόσο υπάρχει περίπτωση να καθορίζεται
// μόνο η διάρκεια. Ας δούμε μερικά παραδείγματα:
//
// 07:30-15:30
// -----------
// Σημαίνει βάρδια από τις 7:30 το πρωί μέχρι τις 3:30 το μεσημέρι. Σ' αυτήν
// την περίπτωση δεν καθορίζουμε διάρκεια, οπότε η διάρκεια θα υπολογιστεί
// αυτόματα (8 ώρες).
//
// 6:39
// ----
// Εφόσον δεν υπάρχουν δύο χρονικά όρια χωρισμένα μεταξύ τους με παύλα ("-"),
// πρόκειται για ιδιαίτερο ωράριο όπου καθορίζεται μόνο η διάρκεια σε 6 ώρες
// και 39 λεπτά.
//
// 16-22
// -----
// Η σύνταξη είναι αρκετά ελεύθερη, οπότε το παραπάνω σημαίνει από 16:00 μέχρι
// 22:00, οπότε η διάρκεια θα υπολογιστεί αυτόματα στις 8 ώρες.

class Vardia {
	private $apo;	
	private $eos;
	private $ores;

	public function __construct($s = NULL) {
		$this->vardia_clear();

		if (!isset($s))
		return $this;

		if ($s instanceof DateTime)
		$s = $s->format(TMPHP_HM);

		elseif (is_numeric($s))
		$s = (string)$s;

		else
		$s = Globals::is_string($s);

		if (!isset($s))
		return $this;

		$s = preg_replace(array(
			"/\\s+/",
			"/\\s$/",
			"/^\\s/",
			"/\\s*:\\s*/",
			"/\\s*-\\s*/",
		), array(
			" ",
			"",
			"",
			":",
			"-",
		), $s);

		$a = explode("-", $s);

		if ($a === FALSE)
		return $this;

		switch (count($a)) {

		// Σε περίπτωση που έχει δοθεί μία μόνο ώρα, τότε πρόκειται
		// για τις ώρες ωραρίου του υπαλλήλου, π.χ. 6:39 σημαίνει ότι
		// ο εργαζόμενος πρέπει να εργάζεται 6 ώρες και 39 λεπτά
		// ημερησίως.

		case 1:
			return $this->ores_set(self::hm2time($s));

		// Αν έχουν δοθεί δύο παράμετροι ώρας, τότε πρόκειται για την
		// αρχή και το πέρας του ωραρίου, π.χ. 7:00-15:00 σημαίνει
		// ωράριο οκτώ ωρών ανά ημέρα, από τις 7 το πρωί μέχρι τις 3
		// το μεσημέρι.

		case 2:
			$this->apo = self::hm2time($a[0]);
			$this->eos = self::hm2time($a[1]);
			return $this->ores_set();
		}

		return $this;
	}

	public function vardia_clear() {
		$this->apo = NULL;
		$this->eos = NULL;
		$this->ores = NULL;

		return $this;
	}

	// Σε κάθε περίπτωση η διάρκεια του ωραρίου πρέπει να έχει
	// καθοριστεί είτε ρητά, είτε με υπολογισμό από την έναρξη
	// και το πέρας του ωραρίου. Επομένως η βάρδια θεωρείται
	// ορθή όταν έχει καθορισμένη διάρκεια.

	public function is_vardia() {
		return $this->is_ores();
	}

	public function no_vardia() {
		return !$this->is_vardia();
	}

	///////////////////////////////////////////////////////////////////////@

	public function apo_set($apo = NULL) {
		$this->apo = self::hm2time($apo);

		// Η αλλαγή της αρχής του διαστήματος επανακαθορίζει
		// αυτόματα και τη διάρκεια της βάρδιας.

		return $this->ores_set();
	}

	public function apo_get() {
		return $this->apo;
	}

	public function is_apo() {
		return $this->apo;
	}

	public function no_apo() {
		return !$this->is_apo();
	}

	///////////////////////////////////////////////////////////////////////@

	public function eos_set($eos = NULL) {
		$this->eos = self::hm2time($eos);

		// Η αλλαγή τέλους του διαστήματος επανακαθορίζει
		// αυτόματα και τη διάρκεια της βάρδιας.

		return $this->ores_set();
	}

	public function eos_get() {
		return $this->eos;
	}

	public function is_eos() {
		return $this->eos;
	}

	public function no_eos() {
		return !$this->is_eos();
	}

	///////////////////////////////////////////////////////////////////////@

	public function ores_set($s = NULL) {
		if (!isset($s)) {
			$ores = $this->ores_apo_eos();

			if (!isset($ores))
			return $this->vardia_clear();

			$this->ores = $ores;
			return $this;
		}

		if ($s instanceof DateInterval) {
			$this->ores = $s;
			return $this;
		}

		if ($s instanceof DateTime)
		$s = $s->format(TMPHP_HM);

		if (!is_string($s))
		return $this->ores_clear();

		$s = self::hm2time($s);

		if (!isset($s))
		return $this->ores_clear();

		$this->ores = DateTime::createFromFormat("H", "0")->diff($s);
		return $this;
	}

	public function ores_get($ores = NULL) {
		return $this->ores;
	}

	public function ores_clear() {
		$this->ores = NULL;
		return $this;
	}

	public function is_ores() {
		return $this->ores;
	}

	public function no_ores() {
		return !$this->is_ores();
	}

	///////////////////////////////////////////////////////////////////////@

	public function ores_apo_eos() {
		if ($this->no_apo())
		return NULL;
		
		if ($this->no_eos())
		return NULL;

		$ores = $this->apo->diff($this->eos);

		if ($ores === FALSE)
		return NULL;

		return $ores;
	}

	public function to_string() {
		$apo = $this->apo_get();
		$eos = $this->eos_get();
		$ores = $this->ores_get();

		if (isset($apo) && isset($eos))
		return $apo->format(TMPHP_HM) . "-" . $eos->format(TMPHP_HM);

		if (isset($ores))
		return $ores->format("[%H:%I]");

		return "";
	}

	///////////////////////////////////////////////////////////////////////@

	private function hm2time($s = NULL) {
		if (!isset($s))
		return NULL;

		if ($s instanceof DateTimeInterval)
		$s = $s->format("%H:%I");

		elseif ($s instanceof DateTime)
		$s = $s->format(TMPHP_HM);

		elseif (is_numeric($s))
		$s = self::num2hm($s);

		if (!isset($s))
		return NULL;

		if ($s === FALSE)
		return NULL;

		$s = DateTime::createFromFormat("H:i", $s);

		if ($s === FALSE)
		return NULL;

		return $s;
	}

	// Η μέθοδος "num2hm" δέχεται ώρες και λεπτά ως ένα ενιαίο νούμερο
	// και επιστρέφει το χρονικό αυτό διάστημα ως string με τη μορφή
	// "ΩΩ:ΛΛ". Αν το νούμερο είναι μικρότερο του 24, τότε θεωρούμε
	// ότι πρόκειται για ώρες χωρίς να έχουν καθοριστεί τα λεπτά, π.χ.
	//
	//	630	-> "06:30"
	//	63	-> null
	//	8	-> "08:00"
	//	23	-> "23:00"
	//	24	-> null
	//
	// Σύμφωνα με τα παραπάνω, είναι προφανές ότι διάστημα μικρότερο
	// της μίας ώρας δεν μπορεί να καθοριστεί ως ένα ενιαίο νούμερο.

	private function num2hm($n) {
		if ($n < 0)
		return NULL;

		if ($n >= 2400)
		return NULL;

		if ($n < 100)
		$n *= 100;

		$m = $n % 100;

		if ($m > 59)
		return NULL;

		$h = ($n - $m) / 100;

		if ($h > 23)
		return NULL;

		return sprintf("%02d:%02d", $h, $m);
	}
}

// Ακολουθεί η κλάση ωράριο η οποία χρησιμοποιείται για την αποκωδικοποίηση
// της τιμής μεταβολής (παραμέτρου) "ΠΑΡΟΥΣΙΟΛΟΓΙΟ". Η εν λόγω τιμή δείχνει
// ταυτόχρονα διάφορα πράγματα. Το πιο σημαντικό είναι ότι εφόσον υπάρχει
// τιμή και δεν είναι null, ο υπάλληλος εμφανίζεται στο παρουσιολόγιο τής
// υπηρεσίας στην οποία ανήκει. Ωφέλιμη παρενέργεια είναι η παρακολούθηση
// διακοπής σχέσης εργασίας του υπαλλήλου, π.χ. αν κάποιος υπάλληλος βγει
// στη σύνταξη στις 29-10-2019, τότε θα πρέπει να τεθεί ημερομηνία λήξης
// στην εν λόγω μεταβολή· αν ο ίδιος υπάλληλος επανέλθει στις 10-03-2020
// θα πρέπει να προστεθεί νέα εγγραφή μεταβολής με ημερομηνία εφαρμογής
// 10-03-2020, οπότε από εκείνη την ημερομηνία και μετά ο εν λόγω υπάλληλος
// θα εμφανίζεται στο παρουσιολόγιο.
//
// Παραδείγματα τιμών μεταβολής
// ----------------------------
//
// "09:00-15:00" -> 09:00-15:00
//
// "0900 - 1500" -> 09:00-15:00
//
// "730-1530" -> 07:30-15:30
//
// "600-1400,1830-230 1400-22:00" -> 06:00-14:00, 18:30-02:30, 14:00-22:00
//
// Αν καθορίζεται διάρκεια σε ώρες τότε είτε θα πρέπει να μην καθορίζονται
// χρονικά διαστήματα, είτε αυτά να έχουν προηγηθεί, π.χ.
//
// "800" -> 08:00
// "09:00-17:00 8" -> 09:00-15:00 [08:00]
// "06:00-14:00 8 15:00-23:00" -> null
// "06:00-14:00 15:00-23:00 8" -> 06:00-14:00, 15:00-23:00 [08:00]

class Orario {
	private $script;	// ελεύθερο κείμενο
	private $decode;	// διορθωμένο κείμενο (αυτόματα)
	private $vardia;	// array βαρδιών (αυτόματα)
	private $ores;		// σύνολο ωρών/ημέρα (αυτόματα)

	public function __construct($script = NULL) {
		$this->script_set($script);
	}

	public function orario_clear() {
		return $this->script_set();
	}

	///////////////////////////////////////////////////////////////////////@

	public function script_set($script = NULL) {
		$this->script = Globals::is_string($script);
		return $this->decode_set();
	}

	public function script_get() {
		return $this->script;
	}

	///////////////////////////////////////////////////////////////////////@

	private function decode_set($s = NULL) {
		$this->decode_clear();
		$script = $this->script_get();

		if (!isset($script))
		return $this;

		$script = preg_replace(array(
			"/\\s+/",
			"/\\s*:\\s*/",
			"/\\s*-\\s*/",
			"/[^0-9:-]+/",
		), array(
			" ",
			":",
			"-",
			" ",
		), $script);

		$v = explode(" ", $script);

		if ($v === FALSE)
		return $this;

		$count = count($v) - 1;

		if ($count < 0)
		return $this;

		for ($i = 0; $i <= $count; $i++) {
			$vardia = new Vardia($v[$i]);

			if (!isset($vardia))
			return $this->decode_error($v[$i]);

			if ($vardia->is_apo() && $vardia->is_eos())
			$this->vardia_push($vardia);

			elseif ($vardia->no_ores())
			return $this->decode_error($v[$i]);

			elseif ($i !== $count)
			return $this->decode_error($v[$i]);

			else
			$this->ores_set($vardia->ores_get());

			$this->decode_push($vardia);
		}

		if ($this->is_ores())
		return $this;

		if ($this->no_vardia())
		return $this;

		$ores = $this->vardia[0]->ores_get();

		if (!isset($ores))
		return $this;

		$s = $ores->format("%H%I");

		for ($i = 1; $i < $count; $i++) {
			$o = $this->vardia[$i]->ores_apo_eos();

			if (!isset($o))
			return $this;


			if ($o->format("%H%I") !== $s)
			return $this;
		}

		return $this->ores_set($ores);
	}

	private function decode_push($v) {
		$s = $v->to_string();

		if ($s === "")
		return $this;

		if ($this->is_decode())
		$this->decode .= " " . $s;

		else
		$this->decode = $s;

		return $this;
	}

	private function decode_clear() {
		$this->decode = NULL;
		$this->vardia = NULL;
		$this->ores = NULL;

		return $this;
	}

	private function decode_error() {
		$this->vardia = NULL;
		$this->ores = NULL;

		if ($this->no_decode())
		$this->decode = "";

		$this->decode .= "?";
		return $this;
	}

	public function decode_get() {
		return $this->decode;
	}

	public function is_decode() {
		return $this->decode;
	}

	public function no_decode() {
		return !$this->is_decode();
	}

	///////////////////////////////////////////////////////////////////////@

	private function vardia_push($v) {
		if ($this->no_vardia())
		$this->vardia = [];

		array_push($this->vardia, $v);
		return $this;
	}

	private function vardia_clear() {
		$this->vardia = NULL;
		return $this;
	}

	public function vardia_get() {
		return $this->vardia;
	}

	public function is_vardia() {
		return $this->vardia_get();
	}

	public function no_vardia() {
		return !$this->is_vardia();
	}

	public function vardia_to_string() {
		$s = "";

		if ($this->no_vardia())
		return $s;

		$n = count($this->vardia);

		if ($n <= 0)
		return $s;

		$s = $this->vardia[0]->to_string();

		for ($i = 1; $i < $n; $i++)
		$s .= ", " . $this->vardia[$i]->to_string();

		return $s;
	}

	///////////////////////////////////////////////////////////////////////@

	private function ores_set($o = NULL) {
		$this->ores = $o;
		return $this;
	}

	private function ores_clear() {
		return $this->ores_set();
	}

	public function ores_get() {
		return $this->ores;
	}

	public function is_ores() {
		return $this->ores_get();
	}

	public function no_ores() {
		return !$this->is_ores();
	}

	public function ores_to_string() {
		$s = "";

		$o = $this->ores_get();

		if (!isset($o))
		return $s;

		$o = $o->format("%H:%I");

		if ($o === FALSE)
		return $s;

		return $o;
	}
}

?>
