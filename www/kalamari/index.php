<?php
require_once "../lib/standard.php";
Globals::session_init();	// that's ok, do not remove!
Kalamari::init();
Globals::www_require("lib/selida.php");

Selida::head();
Kalamari::setup();
Selida::javascript("kalamari/selida");
Selida::stylesheet("kalamari/selida");

Selida::body();
Selida::toolbar();
Selida::fyi_pano();
Kalamari::filtra_dialog();
Selida::ofelimo_open();
Kalamari::events_setup();
Selida::ofelimo_close();
Selida::fyi_kato();
Selida::ribbon();
Selida::telos();

class Kalamari {
	private static $apo = NULL;
	private static $meres = NULL;

	public static function init() {

		if (Globals::no_ipalilos()) {
			header("Location: " . Globals::url("welcome/index.php" .
				Globals::$query_string));
			Globals::klise_fige(0);
		}

		if (Globals::perastike("apo"))
		self::$apo = Globals::is_date($_REQUEST["apo"]);

		else
		self::$apo = new DateTime();

		if (Globals::perastike("meres"))
		self::$meres = Globals::is_positive($_REQUEST["meres"]);

		else
		self::$meres = 14;
	}

	public static function setup() {
		?>
<script type="text/javascript" charset="UTF-8">
//<![CDATA[
if (Kalamari === undefined)
var Kalamari = {};

Kalamari.param = {
	'apo': '<?php print self::$apo->format(DTPHP_DMY); ?>',
	'meres': <?php print self::$meres; ?>,
};
//]]>
</script>
		<?php
	}

	public static function filtra_dialog() {
		?>
		<div id="filtra">

		<div class="subPanel">
		<label for="filtroApo">Από</label>
		<input type="text" id="filtroApo" value="<?php
			print date(DTPHP_DMY);
		?>">
		<label for="filtroArgies" style="cursor: pointer; margin-left: 10px;">Αργίες</label>
		<input type="checkbox" id="filtroArgies" checked="yes">
		</div>

		<div class="subPanel">
		<input type="button" id="buttonMore" value="Παλαιότερα">
		<input type="number" id="filtroMeres" placeholder="μέρες"
			min="0" max="49" step="7" value="0" style="margin-right: 0;">
			<span id="meraMeres"></span>
		</div>

		<div class="subPanel">
		<input type="button" id="buttonTop" value="Πρώτα">
		<input type="button" id="buttonEnd" value="Τελευταία">
		</div>

		</div>
		<?php
	}

	public static function events_setup() {
		?>
		<table id="pinakas">
		<thead>
		<tr id="epikefalida">
		<td id="restShowHide" class="multiIndicator multiOpen"
			style="border-right-color:transparent;">
		&#9660;
		</td>
		<td colspan="2" style="border-left-color:transparent;">
		ΗΜΕΡΟΜΗΝΙΑ
		</td>
		<td class="secondaryColumn">
		ΚΑΡΤΑ
		</td>
		<td class="secondaryColumn">
		ΩΡΑΡΙΟ
		</td>
		<td colspan="3">
		ΠΡΟΣΕΛΕΥΣΗ
		<?php self::eventIdHeader(); ?>
		</td>
		<td colspan="3">
		ΑΠΟΧΩΡΗΣΗ
		<?php self::eventIdHeader(); ?>
		</td>
		<td class="gemisma">
		</td>
		</tr>
		</thead>
		<tbody id="events">
		</tbody>
		</table>
		<?php
	}

	private static function eventIdHeader() {
		?>
		<div class="rowid eventIdHeader"
			title="Εσωτερικός κωδικός αριθμός συμβάντος">
			event&#8209;ID
		</div>
		<?php
	}
}
?>
