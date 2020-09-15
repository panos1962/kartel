<?php

// Η ονομασία «πελεκάνος» έλκει την καταγωγή από την επιστημονική ονομασία
// τού πτηνού "pelecanus onocrotalus", το οποίο χρησιμοποιήθηκε από τις
// μυστικές τού Ισραήλ σε επιχειρήσεις κατασκοπείας στη μέση Ανατολή.

require_once "../lib/selida.php";

Pelekanos::init();
Selida::
head()::
stylesheet("pelekanos/selida")::
body()::
toolbar()::
fyi_pano()::
ofelimo_open()::
ofelimo_close()::
fyi_kato()::
ribbon()::
javascript("pelekanos/selida")::
telos();

class Pelekanos {
	public static function init() {
		if (Globals::no_ipalilos()) {
			header("Location: " . Globals::url("welcome/index.php" .
				Globals::$query_string));
			Globals::klise_fige(0);
		}
	}
}

?>
