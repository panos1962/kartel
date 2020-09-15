<?php
require_once "lib/standard.php";

Kartel::pubkey_check();
Kartel::load_page();

class Kartel {
	public static function pubkey_check() {
		if (Globals::no_session(PUBKEY))
		return;

		if (Globals::is_session(IPALILOS)) {
			$ipalilos = Globals::session_get(IPALILOS);
			Globals::session_clear(IPALILOS);
		}
		else {
			$ipalilos = NULL;
		}

		$prosvasi = new Prosvasi();

		$prosvasi->pubkey = Globals::session_get(PUBKEY);
		$prosvasi->prosvasi_fetch();

		if (!isset($prosvasi->ipalilos))
		return;

		if ($ipalilos != $prosvasi->ipalilos)
		return;

		Globals::session_set(IPALILOS, $prosvasi->ipalilos);
	}

	public static function load_page() {
		header("Location: " .
		(Globals::is_ipalilos() ? "kalamari" : "welcome") . "/index.php" .
		Globals::$query_string);
		Globals::klise_fige(0);
	}
}
?>
