<?php
require_once "../../lib/standard.php";

Globals::header_json();
Evretirio::init();
Evretirio::check();
Evretirio::evresi();
Globals::klise_fige(0);

class Evretirio {
	private static $eponimo;
	private static $onoma;
	private static $patronimo;
	private static $limit;

	public static function init() {
		self::$eponimo = NULL;
		self::$onoma = NULL;
		self::$patronimo = NULL;
		self::$limit = EVRETIRIO_LIMIT;
	}

	public static function check() {
		if (Globals::perastike("pattern"))
		$pattern = ltrim(urldecode($_POST["pattern"]));

		$pattern = preg_replace(array(
			"/$/",
			"/ {2,}/u",
			"/ /u",
		), array(
			"%",
			"",
			"%",
		), $pattern);

		$parts = explode("", $pattern);
		$nparts = count($parts);

		if ($nparts < 1)
		Globals::klise_fige("Ακαθόριστα κριτήρια επιλογής");

		if ($parts[$nparts - 1] === "%")
		$nparts--;

		if ($nparts < 1)
		Globals::klise_fige("Ελλιπή στοιχεία ονόματος υπαλλήλου");

		if ($nparts > 3)
		$nparts = 3;

		switch ($nparts) {
		case 3:
			$patronimo = $parts[2];
		case 2:
			$onoma = $parts[1];
		case 1:
			$eponimo = $parts[0];
		}

		if ($eponimo === "")
		Globals::klise_fige("Δεν καθορίστηκε επώνυμο υπαλλήλου");

		self::$eponimo = $eponimo;

		if (isset($onoma) && $onoma)
		self::$onoma = $onoma;

		if (isset($patronimo) && $patronimo)
		self::$patronimo = $patronimo;

		self::limit_check();
	}

	private static function limit_check() {
		if (Globals::den_perastike("limit"))
		return;

		$slimit = $_POST["limit"];

		if (!is_numeric($slimit))
		Globals::klise_fige($slimit . ": invalid 'limit' value");

		$nlimit = (int)$slimit;

		if ($nlimit != $slimit)
		Globals::klise_fige($slimit . ": not integer 'limit' value");

		if ($nlimit < 1)
		Globals::klise_fige($slimit . ": negative/zero 'limit' value");

		self::$limit = $nlimit;
	}

	public static function evresi() {
		$query = "SELECT `kodikos`, `eponimo`, `onoma`," .
			" `patronimo`, `afm`" .
			" FROM " . Erpota::erpotadb("ipalilos") .
			" WHERE `eponimo` LIKE " . Globals::asfales_sql(self::$eponimo);

		if (isset(self::$onoma))
		$query .= " AND `onoma` LIKE " . Globals::asfales_sql(self::$onoma);

		if (isset(self::$patronimo))
		$query .= " AND `patronimo` LIKE " . Globals::asfales_sql(self::$patronimo);

		$query .= " ORDER BY `eponimo`, `onoma`, `patronimo`";
		$query .= " LIMIT " . self::$limit;

		Globals::evretirio($query, [ "6R", 20, 16, 14, 10 ],
			[ "Α.Μ.", "Επώνυμο", "Όνομα", "Πατρώνυμο", "ΑΦΜ" ]);
	}
}
?>
