<?php
if (!class_exists("Globals"))
require_once "../lib/standard.php";

Profile::init();
Globals::www_require("lib/selida.php");

Selida::head();
Selida::stylesheet("profile/selida");
Selida::javascript("profile/selida");
Selida::body();
Selida::toolbar();
Selida::fyi_pano();
Selida::ofelimo_open();
?>
<form>
<?php Selida::forma_titlos("Ρυθμίσεις λογαριασμού"); ?>

<p>
<label for="ipalilos">
Α.Μ. υπαλλήλου
</label>
<br>
<input id="ipalilos" class="ipalilosKodikosInput" type="text" disabled="yes"
	value="<?php print Globals::$ipalilos->kodikos; ?>">
</p>

<p>
<label for="onoma">
Ονοματεπώνυμο υπαλλήλου
</label>
<br>
<input id="onoma" class="ipalilosOnomateponimoInput" type="text" disabled="yes"
	value="<?php print Globals::$ipalilos->onomateponimo(); ?>">
</p>

<p>
<label for="password">
Μυστικός κωδικός
</label>
<br>
<input id="password" class="ipalilosPasswordInput" type="password">
</p>

<p>
<label for="password1">
Νέος κωδικός
</label>
<br>
<input id="password1" class="ipalilosPasswordInput" type="password">
</p>

<p>
<label for="password2">
Επανάληψη
</label>
<br>
<input id="password2" class="ipalilosPasswordInput" type="password">
</p>

<div class="formPanel">
<input id="submitButton" type="submit" value="Ενημέρωση">
<input id="cancelButton" type="button" value="Άκυρο">
</div>

</form>
<?php
Selida::ofelimo_close();
Selida::fyi_kato();
Selida::ribbon();
Selida::telos();

class Profile {
	public static function init() {
		if (Globals::no_ipalilos()) {
			Globals::www_require("index.php");
			Globals::klise_fige(0);
		}
	}
}
?>
