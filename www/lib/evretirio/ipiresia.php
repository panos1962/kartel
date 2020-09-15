<?php
require_once "../../lib/standard.php";

Globals::header_json();
Evretirio::init();
Evretirio::check();
Evretirio::evresi();
Globals::klise_fige(0);

class Evretirio {
	private static $pattern;
	private static $limit;

	public static function init() {
		self::$pattern = NULL;
		self::$limit = EVRETIRIO_LIMIT;
	}

	public static function check() {
		if (Globals::perastike("pattern"))
		$pat = ltrim(urldecode($_POST["pattern"]));

		$tap = rtrim($pat);

		if ($tap === "")
		Globals::klise_fige("Ακαθόριστα κριτήρια επιλογής");

		if ($tap != $pat)
		self::$pattern = $tap;

		else
		self::$pattern = preg_replace(array(
			"/$/",
		), array(
			"%",
		), $tap);

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
		$spat = Globals::asfales_sql(self::$pattern);
		$query = "SELECT `kodikos`, `perigrafi` " .
			" FROM " . Erpota::erpotadb("ipiresia") .
			" WHERE (`kodikos` LIKE " . $spat . ")" .
			" OR (`perigrafi` LIKE " . $spat . ")" .
			" ORDER BY `kodikos`" .
			" LIMIT " . self::$limit;

		Globals::evretirio($query, [ 10, 60 ]);
	}
}
?>
