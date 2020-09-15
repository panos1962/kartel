<?php
if (!class_exists("Globals"))
require_once "../lib/standard.php";

Globals::header_json();
Globals::session_init();
Ezoom::init();
Ezoom::close();

class Ezoom {
	private static $checkpoint = NULL;

	public static function init() {
		self::$checkpoint = new Checkpoint();

		if (Globals::perastike("ipalilos"))
		self::$checkpoint->ipalilos_set($_POST["ipalilos"]);

		elseif (Globals::is_ipalilos())
		self::$checkpoint->ipalilos_set(Globals::session_get(IPALILOS));

		if (Globals::perastike("imerominia"))
		self::$checkpoint->imerominia_set($_POST["imerominia"]);

		if (Globals::perastike("proapo"))
		self::$checkpoint->proapo_set(urldecode($_POST["proapo"]));

		if (Globals::perastike("eventId"))
		self::$checkpoint->simvan_set($_POST["eventId"]);
	}

	public static function close() {
		self::fix_simvan_meraora();
		self::fix_imerominia();
		self::$checkpoint->metavoli_refresh();
		self::$checkpoint->excuse_set();
		self::convert_imerominia();
		self::convert_metavoli();

		print json_encode(self::$checkpoint, JSON_UNESCAPED_UNICODE);
		Globals::klise_fige(0);
	}

	private static function fix_simvan_meraora() {
		if (self::$checkpoint->no_simvan())
		return;

		$simvan = self::$checkpoint->simvan;

		if ($simvan->is_meraora())
		return;

		$meraora = self::$checkpoint->simvan->meraora_get();
		$simvan->mera = $meraora->format(DTPHP_YMD);
		$simvan->ora = $meraora->format(TMPHP_HMS);
		$simvan->meraora_clear();
	}

	// Ελέχουμε το πεδίο της ημερομηνίας και διορθώνουμε εφόσον πρέπει να
	// διορθωθεί.

	private static function fix_imerominia() {
		if (self::$checkpoint->no_imerominia())
		return;

		if (self::$checkpoint->no_simvan())
		return;

		$mera = self::$checkpoint->simvan->meraora_get();

		if (isset($mera))
		self::$checkpoint->imerominia_set($mera);
	}

	private static function convert_imerominia() {
		if (self::$checkpoint->is_imerominia())
		self::$checkpoint->imerominia = self::$checkpoint->imerominia->format(DTPHP_YMD);
	}

	private static function convert_metavoli() {
		if (self::$checkpoint->no_ipalilos())
		return;

		if (self::$checkpoint->ipalilos->no_metavoli())
		return;

		foreach (self::$checkpoint->ipalilos->metavoli as $key => $val) {
			if (!isset($val))
			continue;

			if (!($val instanceof Metavoli))
			continue;

			if ($val->is_efarmogi() && ($val->efarmogi instanceof Datetime))
			$val->efarmogi = $val->efarmogi->format(DTPHP_YMD);

			if ($val->is_lixi() && ($val->lixi instanceof Datetime))
			$val->lixi = $val->lixi->format(DTPHP_YMD);

			$val->metavoli_decode();

			// Στο σημείο αυτό διαγράφουμε πεδία που δεν είναι πια
			// απαραίτητα. Η διαγραφή γίνεται για λόγους οικονομίας.

			unset($val->ipalilos);
			unset($val->idos);
		}
	}
}
?>
