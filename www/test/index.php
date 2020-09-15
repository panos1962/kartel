<?php
require_once "../lib/selida.php";

Selida::head();
Selida::javascript("test/selida");
Selida::stylesheet("test/selida");
Selida::body();
Selida::toolbar();
Selida::fyi_pano();
Selida::ofelimo_open();
Test::forma();
Selida::ofelimo_close();
Selida::fyi_kato();
Selida::ribbon();
Selida::telos();

class Test {
	public static function forma() {
		?>
		<form autocomplete="off">
		<?php Selida::forma_titlos("Ευρετήριο συμβάντων"); ?>

		<div class="subPanel">
		<p>
		<label for="formaIpalilos">
		Α.Μ. υπαλλήλου
		</label>
		<br>
		<input id="formaIpalilos" type="text" value="">
		</p>

		<p>
		<label for="formaOnoma">
		Ονοματεπώνυμο υπαλλήλου
		</label>
		<br>
		<input id="formaOnoma" type="text" value="">
		</p>
		</div>

		<div class="subPanel">
		<p>
		<label for="formaMera">
		Ημερομηνία συμβάντος
		</label>
		<br>
		<input id="formaMera" type="text">
		</p>
		</div>

		<div class="subPanel">
		<p>
		Τύπος συμβάντος<br>
		<div class="formaTrexon formaRadio">
		<input type="radio" name="proapo" id="formaProselefsi">
		ΠΡΟΣΕΛΕΥΣΗ
		</div><br>
		<div class="formaTrexon formaRadio">
		<input type="radio" name="proapo" id="formaApoxorisi">
		ΑΠΟΧΩΡΗΣΗ</div><br>
		<div class="formaTrexon formaRadio">
		<input type="radio" name="proapo" id="formaAdia" checked>
		ΑΔΕΙΑ κλπ</div>
		</p>
		</div>

		<div class="subPanel">
		<p>
		<label for="formaRowid">
		Event-ID
		</label>
		<br>
		<input id="formaRowid" type="text" value="">
		</p>
		</div>

		</form>
		<?php
	}
}
?>
