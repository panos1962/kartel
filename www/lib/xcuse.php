<?php
if (!class_exists("Globals"))
require_once "../lib/standard.php";

Globals::header_json();
Globals::session_init();
Xcuse::init();

class Xcuse {
	private static $excuse;

	public static function init() {
		self::$excuse = new Excuse();

		if (Globals::perastike("ipalilos"))
		self::$excuse->ipalilos_set($_POST["ipalilos"]);

		if (Globals::perastike("mera"))
		self::$excuse->mera_set($_POST["mera"]);

		if (Globals::perastike("proapo"))
		self::$excuse->proapo_set(urldecode($_POST["proapo"]));

		if (Globals::perastike("logos"))
		self::$excuse->proapo_set(urldecode($_POST["logos"]));

		if (Globals::perastike("info"))
		self::$excuse->proapo_set(urldecode($_POST["info"]));

		switch (Globals::perastike_must("action")) {
			case 'select':
			return self::inquire_excuse();

			case 'insert':
			return self::insert_excuse();

			case 'update':
			return self::update_excuse();

			case 'delete':
			return self::delete_excuse();

			default:
			Globals::klise_fige("λανθασμένη ενέργεια αιτιολογίας");
		}
	}

	private static function insert_excuse() {
		self::check_excuse();
		$query = "SELECT 1 FROM `erpota`.`excuse` WHERE " .
			self::$excuse->where_clause();

		if (Globals::first_row($query))
		Globals::klise_fige("Υπάρχει ήδη καταχωρημένη αιτιολογία");

		$smera = Globals::asfales_sql(self::$excuse->mera);
		$sproapo = Globals::asfales_sql(self::$excuse->proapo);
		$slogos = (self::$excuse->is_logos() ?
			Globals::asfales_sql(self::$excuse->proapo) : 'NULL');
		$sinfo = (self::$excuse->is_info() ?
			Globals::asfales_sql(self::$excuse->info) : "''");

		$query = "INSERT INTO `erpota`.`excuse` (`ipalilos`, " .
			"`mera`, `proapo`, `logos`, `info`) VALUES (" .
			self::$excuse->ipalilos . ", " . $smera . ", " .
			$sproapo . ", " . $slogos . ", " . $sinfo . ")";
		Globals::query($query);

		if (Globals::affected_rows() != 1)
		Globals::klise_fige("Απέτυχε η εισαγωγή αιτιολογίας");

		return self::inquire_excuse();
	}

	private static function inquire_excuse() {
		self::check_excuse();

		$query = "SELECT * FROM `erpota`.`excuse` WHERE " .
			self::$excuse->where_clause();
		$row = Globals::first_row($query, MYSQLI_ASSOC);

		if (!$row)
		Globals::klise_fige("Δεν εντοπίστηκε αιτιολογία");

		print json_encode($row, JSON_UNESCAPED_UNICODE);
		Globals::klise_fige(0);
	}

	private static function check_excuse() {
		switch (self::$excuse->excuse_check()) {
		case EXCUSE_NO_IPALILOS:
			Globals::klise_fige("Ακαθόριστος υπάλληλος αιτιολογίας");
		case EXCUSE_NO_MERA:
			Globals::klise_fige("Ακαθόριστη ημερομηνία αιτιολογίας");
		case EXCUSE_NO_PROAPO:
			Globals::klise_fige("Ακαθόριστη προσέλευση/αποχώρηση αιτιολογίας");
		case EXCUSE_OK:
			return;
		}

		Globals::klise_fige("Ακαθόριστη αιτιολογία");
	}
}
?>
