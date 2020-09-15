<?php
require_once "../lib/standard.php";

Globals::header_data();

Profile::
init()::
password_update()::
affected_check();

print "OK";
Globals::klise_fige(0);

class Profile {
	private static $prosvasi;
	private static $affected;

	public static function init() {
		if (Globals::no_session(PUBKEY))
		Globals::klise_fige(0);

		self::
		pubkey_check()::
		prosvasi_fetch()::
		affected_reset();

		return __CLASS__;
	}

	private static function pubkey_check() {
		if (Globals::is_session(PUBKEY))
		return __CLASS__;

		Globals::klise_fige(0);
	}

	private static function prosvasi_fetch() {
		$ipalilos = Globals::perastike_must("ipalilos");
		$password = Globals::perastike_must("password");
		$pubkey = Globals::session_get(PUBKEY);

		self::$prosvasi = (new Prosvasi())->
		pubkey_set($pubkey)->
		ipalilos_set($ipalilos)->
		password_set($password)->
		prosvasi_fetch();

		if (self::$prosvasi->ipalilos == $ipalilos)
		return __CLASS__;

		print "AD";
		Globals::klise_fige(0);
	}

	private static function affected_reset() {
		self::$affected = 0;
		return __CLASS__;
	}

	public static function password_update() {
		$password1 = Globals::perastike_must("password1");

		if (!isset($password1))
		return __CLASS__;

		if ($password1 == "")
		return __CLASS__;

		$query = "UPDATE `erpota`.`prosvasi` " .
			"SET `password` = SHA1(" . Globals::asfales_sql($password1) . ") " .
			"WHERE `ipalilos` = " . self::$prosvasi->ipalilos;

		Globals::query($query);

		self::$affected += Globals::affected_rows();
		return __CLASS__;
	}

	public static function affected_check() {
		if (self::$affected > 0)
		return __CLASS__;

		print "NC";
		Globals::klise_fige(0);
	}
}
?>
