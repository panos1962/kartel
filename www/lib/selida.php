<?php
if (!class_exists("Globals"))
require_once "standard.php";

Selida::init();

// Η κλάση "Selida" χρησιμοποιείται ως namespace για δομές και funtions που
// αφορούν στη μορφοποίηση των σελίδων της εφαρμογής.

class Selida {
	// Η property "init_ok" δείχνει αν έχει τρέξει ήδη η μέθοδος "init".
	// Η μέθοδος πρέπει να τρέχει το πολύ μια φορά.

	private static $init_ok = FALSE;
	private static $titlos = NULL;
	private static $zebra01 = 0;

	public static function init() {
		if (self::$init_ok)
		Globals::klise_fige("Selida::init: already called");

		Globals::session_init();
		self::$init_ok = TRUE;
		self::$titlos = "kartel";
		self::zebra_reset();

		return __CLASS__;
	}

	public static function head($titlos = NULL) {
		if ($titlos === NULL)
		$titlos = Globals::$titlos;

		self::$titlos = $titlos;
		?>
		<!DOCTYPE html>
		<html>
		<head>

		<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
		<meta name="description" content="Έλεγχος προσέλευσης/αποχώρησης" />
		<link rel="shortcut icon" href="<?php Globals::print_url("favicon.ico"); ?>" />

		<title><?php print self::$titlos; ?></title>

		<script src="<?php print JQCDN; ?>jquery/3.3.1/jquery.min.js"></script>
		<link rel="stylesheet" href="<?php print JQCDN; ?>jqueryui/1.12.1/themes/smoothness/jquery-ui.css">
		<script src="<?php print JQCDN; ?>jqueryui/1.12.1/jquery-ui.min.js"></script>

		<?php
		$debug = Globals::perastike("debug");
		self::stylesheet("lib/selida", $debug);
		self::stylesheet("lib/kartel", $debug);

		self::javascript("lib/globals");
		self::javascript("lib/selida");
		self::javascript("lib/kartel");

		self::javascript_begin();
		?>
		Selida.defineTag = {
			'AJXRSPOK': '<?php print AJXRSPOK; ?>',
			'PUBKEY': '<?php print PUBKEY; ?>',
			'IPALILOS': '<?php print IPALILOS; ?>',
			'AUTHDEPT': '<?php print AUTHDEPT; ?>',
			'AUTHLEVEL': '<?php print AUTHLEVEL; ?>',
			'WEBMAIL': '<?php print WEBMAIL; ?>',

			'ERROR_MAILCONF': '<?php print ERROR_MAILCONF; ?>',
			'ERROR_RCPADDR': '<?php print ERROR_RCPADDR; ?>',
			'ERROR_NULLMSG': '<?php print ERROR_NULLMSG; ?>',
			'ERROR_SENDMAIL': '<?php print ERROR_SENDMAIL; ?>',
		};

		Selida.server = <?php print Globals::asfales_json(Globals::$server); ?>;
		Selida.timeDif = <?php print time(); ?> - Globals.tora();
		Selida.queryString = <?php print Globals::asfales_json(Globals::$query_string); ?>;
		Selida.session = {};
		Selida.zebra01 = <?php print Selida::$zebra01 ?>;
		Selida.ipalilosTag = <?php print Globals::asfales_json(self::ipalilos_tag()); ?>;
		Erpota.erpota12 = <?php print Erpota::erpotadb(); ?>;
		<?php
		foreach ($_SESSION as $tag => $val) {
			?>
			Selida.session[<?php
				print Globals::asfales_json($tag); ?>] = <?php
				print Globals::asfales_json($val); ?>;
			<?php
		}
		self::javascript_end();

		return __CLASS__;
	}

	private static function ipalilos_tag() {
		if (Globals::no_ipalilos())
		return "";

		return "<strong>" . Globals::$ipalilos->kodikos . "</strong> " .
			Globals::$ipalilos->eponimo .  " " .
			Globals::$ipalilos->onoma;
	}

	public static function body() {
		?>
		</head>
		<body>
		<?php

		return __CLASS__;
	}

	public static function telos() {
		?>
		</body>
		</html>
		<?php

		return __CLASS__;
	}

	public static function stylesheet($css, $debug = FALSE) {
		$file = Globals::wwwname($css . ".css");

		if (!file_exists($file))
		return __CLASS__;

		$mtime = "?mt=" . filemtime($file);
		$mtime = "";
		?><link rel="stylesheet" type="text/css" href="<?php
			Globals::print_url($css); ?>.css<?php
			print $mtime; ?>" /><?php

		if (!$debug)
		return __CLASS__;

		$file = Globals::wwwname($css . ".debug.css");

		if (!file_exists($file))
		return __CLASS__;

		$mtime = filemtime($file);
		?><link rel="stylesheet" type="text/css" href="<?php
			Globals::print_url($css); ?>.debug.css?mt=<?php
			print $mtime; ?>" /><?php

		return __CLASS__;
	}

	///////////////////////////////////////////////////////////////////////@

	// Η μέθοδος "javascript" δέχεται το όνομα ενός JavaScript source file και
	// παράγει το HTML script tag με το οποίο θα ενσωματώσουμε τον κώδικα στη
	// σελίδα μας. Η function προσθέτει το modification timestamp ως παράμετρο
	// στο URL του αρχείου, ώστε να αποφύγουμε το caching σε περίπτωση μεταβολής
	// του αρχείου. Επίσης, ελέγχει αν υπάρχει νεότερη minified version αυτού
	// του αρχείου και αν ναι, τότε προτιμά την minified version. Ως minified
	// version του αρχείου θεωρούμε το ίδιο αρχείο με κατάληξη ".min.js"

	public static function javascript($script) {
		$file = Globals::wwwname($script . ".js");

		if (!file_exists($file))
		return __CLASS__;

		$mtime = filemtime($file);
		$file1 = Globals::wwwname($script . ".min.js");

		if (file_exists($file1)) {
			$mtime1 = filemtime($file1);
			if ($mtime1 > $mtime) {
				$script .= ".min";
				$mtime = $mtime1;
			}
		}

		$mtime = "?mt=" . $mtime;
		$mtime = "";
		?><script type="text/javascript" src="<?php
			Globals::print_url($script); ?>.js<?php
			print $mtime; ?>" charset="UTF-8"></script><?php

		return __CLASS__;
	}

	public static function javascript_begin() {
		?>
		<script type="text/javascript" charset="UTF-8">
		//<![CDATA[
		<?php

		return __CLASS__;
	}

	public static function javascript_end() {
		?>
		//]]>
		</script>
		<?php

		return __CLASS__;
	}

	///////////////////////////////////////////////////////////////////////@

	public static function fyi_pano() {
		?>
		<div id="fyiPano" class="fyi">
		</div>
		<?php

		return __CLASS__;
	}

	public static function fyi_kato() {
		?>
		<div id="fyiKato" class="fyi">
		</div>
		<?php

		return __CLASS__;
	}

	///////////////////////////////////////////////////////////////////////@

	public static function tab_open($id = NULL) {
		?><div class="tab"<?php
		if (isset($id))
		print ' id="' . $id . '"';
		?>><?php

		return __CLASS__;
	}

	public static function tab_close() {
		?></div><?php

		return __CLASS__;
	}

	///////////////////////////////////////////////////////////////////////@

	public static function toolbar() {
		?><div id="toolbar" class="zelatina perigrama">
			<table>
			<tbody>
			<tr>
			<td id="toolbarLeft"></td>
			<td id="toolbarCenter">
				<a target="_self" href="<?php
					Globals::print_url("welcome");
				?>">
					<div id="toolbarCenterTitlos">
						kartel
					</div>
				</a>
			</td>
			<td id="toolbarRight"></td>
			</tr>
			</tbody>
			</table>
		</div>
		<?php

		return __CLASS__;
	}

	public static function ribbon() {
		?>
		<div id="ribbon" class="zelatina perigrama">
			<table>
			<tbody>
			<tr>

			<td id="ribbonLeft">
				<?php self::tab_open("tabWebmail"); ?>
				<a target="webmail" href="<?php print WEBMAIL; ?>"
					title="Ηλεκτρονικό ταχυδρομείο Δήμου Θεσσαλονίκης">Email</a>
				<?php self::tab_close(); ?>
			</td>

			<td id="ribbonCenter">
				<?php /* self::tab_open("tabOdigies"); ?>
				<a target="odigies" href="<?php
					Globals::print_url("odigies");
				?>">Οδηγίες</a>
				<?php self::tab_close(); */?>
			</td>

			<td id="ribbonRight">
				<?php self::tab_open("tabCopyright"); ?>
				<a target="copyright" title="Copyright statement"
					href="<?php Globals::print_url("copyright");
					?>">&copy;&nbsp;Δήμος Θεσσαλονίκης</a>
				<?php self::tab_close(); ?>
			</td>

			</tr>
			</tbody>
			</table>
		</div>
		<?php

		return __CLASS__;
	}

	///////////////////////////////////////////////////////////////////////@

	public static function ofelimo_open() {
		?>
		<div id="ofelimo">
		<?php

		return __CLASS__;
	}

	public static function forma_titlos($titlos = NULL) {
		if (!isset($titlos))
		return __CLASS__;

		if (!$titlos)
		return __CLASS__;

		?>
		<div class="formTitleArea">
		<div class="formTitle">
		<?php print $titlos; ?>
		</div>
		</div>
		<?php

		return __CLASS__;
	}

	public static function ofelimo_close() {
		?>
		</div>
		<?php

		return __CLASS__;
	}

	///////////////////////////////////////////////////////////////////////@

	private static function zebra_reset() {
		self::$zebra01 = 0;

		return __CLASS__;
	}

	public static function zebra() {
		self::$zebra01 = (self::$zebra01 ? 0 : 1);
		print "zebra" . self::$zebra01;

		return __CLASS__;
	}

	///////////////////////////////////////////////////////////////////////@
}
?>
