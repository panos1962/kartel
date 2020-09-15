<?php
// Για να αποκτήσουμε πρόσβαση στα δεδομένα και να κάνουμε χρήση της εφαρμογής,
// θα πρέπει:
//
//   1. Να υπάρχει στο session cookie παράμετρος "pubkey" με τιμή που να
//	υπάρχει στο πεδίο `pubkey` ενός record του πίνακα προσβάσεων, τουτέστιν
//	του πίνακα `erpota`.`prosvasi`. Η τιμή αυτή δεν είναι κάτι κρυφό, ωστόσο
//	δεν είναι καλό να διασπείρεται ή να βρίσκεται σε κοινή θέα· ουσιαστικά
//	πρόκειται για ένα είδος δημόσιου κλειδιού που αναφέρεται ακριβώς σε έναν
//	υπάλληλο και ως εκ τούτου θα χρησιμοποιηθεί για τον εντοπισμό των
//	διαπιστευτηρίων του υπαλλήλου στον πίνακα των προσβάσεων. Στα εν λόγω
//	διαπιστευτήρια συμπεριλαμβάνεται ο μυστικός κωδικός του υπαλλήλου, SHA1
//	encrypted, τον οποίο γνωρίζει, η θα πρέπει να γνωρίζει μόνο ο εν λόγω
//	υπάλληλος και κανείς άλλος.
//
//   2. Θα πρέπει να δοθεί ο σωστός μυστικός κωδικός του υπαλλήλου. Εφόσον αυτά
//	τα δύο στοιχεία είναι σωστά, θεωρούμε ότι ο χρήστης της εφαρμογής είναι
//	ο υπάλληλος με τα συγκεκριμένα διαπιστευτήρια και ως εκ τούτου θα έχει
//	τις σχετικές προσβάσεις στα δεδομένα και στα διάφορα προγράμματα της
//	εφαρμογής.

if (!class_exists("Globals"))
require_once "../lib/standard.php";

Globals::www_require("lib/selida.php");

Selida::head();
Selida::stylesheet("isodos/selida");
Selida::javascript("isodos/selida");
Selida::body();
Selida::toolbar();
Selida::fyi_pano();
Selida::ofelimo_open();
?>
<form class="formRight">
<?php Selida::forma_titlos("Φόρμα εισόδου"); ?>

<p>
<label for="ipalilos" class="vprompt">
Α.Μ. υπαλλήλου
</label>
<br>
<input id="ipalilos" class="ipalilosKodikosInput" type="text"
	disabled="yes" value="<?php Isodos::ipalilos_seek(); ?>">
<br>
</p>

<p class="krifo">
<label for="password" class="vprompt">
Μυστικός κωδικός
</label>
<br>
<input id="password" class="ipalilosPasswordInput" type="password">
<br>
</p>

<div class="formPanel">
<input id="submitButton" class="krifo" type="submit" value="Σύνδεση">
<input id="cancelButton" type="button" value="Άκυρο">
<input id="forgotButton" class="krifo" type="button" value="Νέος κωδικός"
	title="Αποστολή νέου μυστικού κωδικού μέσω email">
</div>

</form>
<?php
Selida::ofelimo_close();
Selida::fyi_kato();
Selida::ribbon();
Selida::telos();

class Isodos {
	// Η function "ipalilos_seek" εκτυπώνει τον αρ. μητρώου υπαλλήλου από
	// τον πίνακα `erpota`.`prosvasi` με βάση την παράμετρο "pubkey" από το
	// session cookie. Σε περίπτωση που δεν βρεθεί η συγκεκριμένη παράμετρος
	// στο session cookie, ή δεν βρεθεί η αντίστοιχη εγγραφή στον πίνακα
	// `erpota`.`prosvasi`, η function δεν εκτυπώνει απολύτως τίποτα.

	public static function ipalilos_seek() {
		// Αν δεν υπάρχει παράμετρος "pubkey" στο session cookie,
		// δεν προτείνεται από το πρόγραμμα κωδικός υπαλλήλου.

		if (Globals::no_session(PUBKEY))
		return;

		// Επιχειρούμε να προσπελάσουμε το record `erpota`.`prosvasi`
		// με τιμή πεδίου `pubkey` την τιμή της παραμέτρου "pubkey"
		// από το session cookie.

		$pubkey = Globals::session_get(PUBKEY);
		$prosvasi = (new Prosvasi())->
		pubkey_set($pubkey)->
		prosvasi_fetch();

		// Αν δεν εντοπίστηκε τέτοιο record, το πρόγραμμα δεν προτείνει
		// κωδικό υπαλλήλου.

		if (!isset($prosvasi->ipalilos))
		return;

		// Εντοπίστηκε `erpota`.`prosvasi` record με το συγκεκριμένο
		// public key, οπότε το πρόγραμμα προτείνει τον κωδικό του
		// υπαλλήλου στο πεδίο "Α.Μ. υπαλλήλου".

		print $prosvasi->ipalilos;
	}
}
?>
