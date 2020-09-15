<?php

// Το παρόν πρόγραμμα καλείται μέσω κλήσεων ajax από τη βασική σελίδα τής
// εφαρμογής και σκοπός του είναι να επιλέξει και να αποστείλει όλα τα
// στοιχεία που αφορούν σε συγκεκριμένο υπάλληλο για ορισμένο διάστημα.
// Τα στοιχεία αυτά είναι χτυπήματα κάρτας, αιτιολογίες και άδειες που
// αφορούν στον συγκεκριμένο υπάλληλο για το συγκεκριμένο χρονικά διάστημα.

if (!class_exists("Globals"))
require_once "../lib/standard.php";

Globals::header_data();
Globals::session_init();
Select::init();

class Select {
	private static $proselefsi = NULL;
	private static $apoxorisi = NULL;

	public static function init() {
		// Η επιλογή των στοιχείων γίνεται για τον υπάλληλο ο οποίος
		// «τρέχει» την εφαρμογή. Ως εκ τούτου, ο κωδικός υπαλλήλου
		// δεν περνάει υπό μορφήν παραμέτρου, αλλά λαμβάνεται από
		// το session cookie.

		if (Globals::no_ipalilos())
		Globals::klise_fige("Ακαθόριστος υπάλληλος");

		// Το χρονικό διάστημα υπολογίζεται από την ημερομηνία αρχής
		// και το πλήθος των ημερών του διαστήματος.

		$apo = Globals::perastike_must("apo");
		$meres = Globals::perastike_must("meres");

		// Η ημερομηνία αρχής του διαστήματος περνιέται ως string με
		// format "d-m-Y", π.χ. "2019-05-22".

		$apo = DateTime::createFromFormat("d-m-Y", $apo);

		if ($apo === FALSE)
		Globals::klise_fige("Λανθασμένη ημερομηνία αρχής");

		$meres -= 1;

		if ($meres < 0)
		$meres = 0;

		// Η ημερομηνία τέλους του διαστήματος υπολογίζεται αφαιρώντας
		// τις ημέρες του διαστήματος από την ημερομηνία αρχής.

		$eos = (new DateTime($apo->format(DTPHP_YMD)))->
		sub(new DateInterval("P" . $meres . "D"));

		if ($eos === FALSE)
		Globals::klise_fige("Λανθασμένη ημερομηνία τέλους");

		// Τα στοιχεία επιστρέφονται ως text, αλλά είναι σε json
		// format. Ουσιαστικά πρόκειται για ένα 0-base array στο
		// οποίο κάθε στοιχείο αφορά σε μια ημερομηνία. Το array
		// ακολουθεί φθίνουσα ημερολογιακή σειρά.

		print "[";

		while ($apo > $eos) {
			self::mera_print($apo);
			$apo->sub(new DateInterval("P1D"));
		}

		print "]";
	}

	// Η function "mera_print" εκτυπώνει τα στοιχεία που αφορούν σε
	// συγκεκριμένη ημερομηνία την οποία δέχεται ως παράμετρο.

	private static function mera_print($date) {
		Globals::$ipalilos->metavoli_fetch($date);

		$mera = $date->format(DTPHP_YMD);
		self::mera_open($date, $mera);
		self::mera_adies($date, $mera);
		self::mera_excuses($date, $mera);
		self::mera_events($date, $mera);
		self::mera_close();
	}

	private static function mera_open($date, $mera) {
		print '{d:' . Globals::asfales_json($mera);

		$val = Erpota::is_argia($date);
		if ($val)
		print ',a:' . Globals::asfales_json($val);

		$val = Globals::$ipalilos->metavoli_get(ORARIO);
		if (isset($val))
		print ',o:' . Globals::asfales_json($val->timi);
	}

	private static function mera_adies($date, $mera) {
		$smera = Globals::asfales_sql($mera);

		$query = "SELECT * FROM `erpota`.`adia` WHERE " .
			"(`ipalilos` = " . Globals::$ipalilos->kodikos . ") AND " .
			"(`apo` <= " . $smera . ") AND (`eos` >= " . $smera .") " .
			"ORDER BY `apo`, `eos`, `idos` LIMIT 1";
		$row = Globals::first_row($query, MYSQLI_ASSOC);

		if ($row)
		(new Adia($row))->json_economy();
	}

	private static function mera_excuses($date, $mera) {
		self::$proselefsi = NULL;
		self::$apoxorisi = NULL;

		$query = "SELECT `logos`, `proapo`, `info`," .
			" TIME_FORMAT(`ora`, '%H:%i') AS `ora`" .
			" FROM `erpota`.`excuse` WHERE " .
			"(`ipalilos` = " . Globals::$ipalilos->kodikos . ") " .
			"AND (`mera` = " . Globals::asfales_sql($mera) . ")";
		$result = Globals::query($query);

		while ($row = $result->fetch_array(MYSQLI_ASSOC)) {
			switch ($row["proapo"]) {
			case PROSELEFSI:
				self::$proselefsi = self::excuse_to_event($row);
				break;
			case APOXORISI:
				self::$apoxorisi = self::excuse_to_event($row);
				break;
			}
		}

		$result->free();
	}

	private static function excuse_to_event($row) {
		return array(
			"k" => $row["logos"],
			"t" => $row["ora"],
			"s" => $row["info"]
		);
	}

	private static function mera_events($date, $mera) {
		if (!array_key_exists(KARTA, Globals::$ipalilos->metavoli))
		return;

		$karta = Globals::$ipalilos->metavoli[KARTA]->timi;

		if (!isset($karta))
		return;

		print ',k:' . $karta;

		$apo = $date->format(DTPHP_YMD);

		$eos = (new DateTime($apo))->
		add(new DateInterval("P1D"))->
		format(DTPHP_YMD);

		$query = "SELECT `kodikos` AS `k`," .
			" DATE_FORMAT(`meraora`, '%H:%i') AS `t`, `reader`" .
			" FROM `kartel`.`event` WHERE `karta` = " .
			$karta . " AND `meraora` >= '" . $apo .
			"' AND `meraora` < '" . $eos .
			"' ORDER BY `meraora`, `kodikos`";
		$result = Globals::query($query);

		$eopen = ",e:[";
		$eclose = "";
		self::print_event(self::$proselefsi, $eopen, $eclose);

		while ($row = $result->fetch_array(MYSQLI_ASSOC)) {
			$row["k"] = (int)($row["k"]);

			$site = (new Site())->site_reader($row["reader"]);

			if ($site->is_perigrafi())
			$row["s"] = $site->perigrafi_get();

			unset($row["reader"]);
			self::print_event($row, $eopen, $eclose);
		}

		$result->free();

		self::print_event(self::$apoxorisi, $eopen, $eclose);
		print $eclose;
	}

	private static function print_event($event, &$eopen, &$eclose) {
		if (!isset($event))
		return;

		print $eopen . json_encode($event, JSON_UNESCAPED_UNICODE) . ",";
		$eopen = "";
		$eclose = "],";
	}

	private static function mera_close() {
		print "},";
	}
}
