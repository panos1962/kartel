///////////////////////////////////////////////////////////////////////////////@

var Kartel = {};

///////////////////////////////////////////////////////////////////////////////@

var Erpota = {};

Erpota.erpotadb = function(s) {
	if (s === undefined)
	return Erpota.erpota12;

	return '`' + Erpota.erpota12 + '`.`' + s + '`';
};

Erpota.isArgia = function(d) {
	if (d === undefined)
	d = new Date;

	return false;
};

///////////////////////////////////////////////////////////////////////////////@

Ipalilos = function(props) {
	Globals.initObject(this, props);
};

Ipalilos.prototype.ipalilosKodikosSet = function(kodikos) {
	this.kodikos = kodikos;

	return this;
};

///////////////////////////////////////////////////////////////////////////////@

var Metavoli = function(props) {
	Globals.initObject(this, props);
};

Metavoli.prototype.metavoliIpalilosSet = function(ipalilos) {
	this.ipalilos = ipalilos;

	return this;
};

///////////////////////////////////////////////////////////////////////////////@

var Prosvasi = function(props) {
	Globals.initObject(this, props);
};

Prosvasi.prototype.prosvasiIpalilosSet = function(ipalilos) {
	this.ipalilos = ipalilos;

	return this;
};

///////////////////////////////////////////////////////////////////////////////@

Istoriko = function(props) {
	Globals.initObject(this, props);
};

Istoriko.prototype.istorikoKodikosSet = function(kodikos) {
	this.kodikos = kodikos;

	return this;
};

Istoriko.idosMetafrasi = {
	'IN': 'ΕΙΣΟΔΟΣ',
	'OUT': 'ΕΞΟΔΟΣ',
	'ACCESS': 'ΠΡΟΣΒΑΣΗ',
};

Istoriko.prototype.istorikoIdosMetafrasi = function() {
	return Istoriko.idosMetafrasi[this.idos];
};

///////////////////////////////////////////////////////////////////////////////@

var Adia = function(props) {
	Globals.initObject(this, props);
};

Adia.prototype.idosToString = function() {
	return (this.idos ? this.idos : '');
};

Adia.prototype.infoToString = function() {
	return this.info;
};

///////////////////////////////////////////////////////////////////////////////@

var Excuse = function(props) {
	Globals.initObject(this, props);
};

Excuse.prototype.logosToString = function() {
	return (this.logos ? this.logos : '');
};

Excuse.prototype.infoToString = function() {
	return this.info;
};

///////////////////////////////////////////////////////////////////////////////@

Kartel.eventZoom = {};

Kartel.eventZoom.create = function(opts) {
	Kartel.eventZoom.formDOM = $('<div>').
	attr('id', 'eventZoom').
	appendTo(Selida.bodyDOM);

	Kartel.eventZoom.
	ipalilos.create().
	adia.create().
	excuse.create().
	istoriko.create().
	dialogos(opts);

	return Selida;
};

///////////////////////////////////////////////////////////////////////////////@

Kartel.eventZoom.ipalilos = {};

Kartel.eventZoom.ipalilos.create = function() {
	Kartel.eventZoom.formDOM.
	append(Kartel.eventZoom.ipalilos.panelDOM = $('<div>').
	addClass('subPanel').

	// Υπάλληλος

	append($('<div>').
	addClass('eventZoomInput').

	append($('<div>').
	addClass('hprompt ezp1').
	text('Υπάλληλος')).
	append($('<div>').
	addClass('ezf1').
	append(Kartel.eventZoom.ipalilos.kodikosDOM = $('<input>').
	css('width', '90px')).
	append(Kartel.eventZoom.ipalilos.onomateponimoDOM = $('<input>').
	css('width', '367px')).
	append($('<div>').
	addClass('hprompt').
	text('ΑΦΜ')).
	append(Kartel.eventZoom.ipalilos.afmDOM = $('<input>').
	css('width', '90px')))).

	// Διεύθυνση

	append($('<div>').
	addClass('eventZoomInput').

	append($('<div>').
	addClass('hprompt ezp1').
	text('Διεύθυνση')).
	append($('<div>').
	addClass('ezf1').
	append(Kartel.eventZoom.ipalilos.diefDOM = $('<input>').
	css('width', '90px')).
	append(Kartel.eventZoom.ipalilos.diefDescDOM = $('<input>').
	css('width', '516px')))).

	// Τμήμα

	append($('<div>').
	addClass('eventZoomInput').

	append($('<div>').
	addClass('hprompt ezp1').
	text('Τμήμα')).
	append($('<div>').
	addClass('ezf1').
	append(Kartel.eventZoom.ipalilos.tmimaDOM = $('<input>').
	css('width', '90px')).
	append(Kartel.eventZoom.ipalilos.tmimaDescDOM = $('<input>').
	css('width', '516px')))).

	// Κάρτα και ωράριο

	append($('<div>').
	addClass('eventZoomInput').

	append($('<div>').
	addClass('hprompt ezp1').
	text('Αρ. Κάρτας')).
	append($('<div>').
	addClass('ezf1').
	append(Kartel.eventZoom.ipalilos.kartaDOM = $('<input>').
	css('width', '90px')).
	append($('<div>').
	addClass('hprompt').
	text('Ωράριο')).
	append(Kartel.eventZoom.ipalilos.orarioDOM = $('<input>').
	css('width', '40ch')))));

	return Kartel.eventZoom;
};

///////////////////////////////////////////////////////////////////////////////@

Kartel.eventZoom.adia = {};

Kartel.eventZoom.adia.create = function() {
	Kartel.eventZoom.formDOM.
	append(Kartel.eventZoom.adia.panelDOM = $('<div>').
	addClass('subPanel ezAdia').

	append($('<div>').
	addClass('eventZoomInput').

	// Είδος αδείας

	append($('<div>').
	addClass('hprompt').
	css('margin-left', '58px').
	text('Άδεια')).
	append(Kartel.eventZoom.adia.idosDOM = $('<select>').
	append($('<option selected>').attr('value', '').text('')).
	append($('<option>').attr('value', 'ΚΑΝΟΝΙΚΗ').text('ΚΑΝΟΝΙΚΗ')).
	append($('<option>').attr('value', 'ΓΟΝΙΚΗ').text('ΓΟΝΙΚΗ')).
	append($('<option>').attr('value', 'ΑΝΑΡΡΩΤΙΚΗ Υ/Δ').text('ΑΝΑΡΡΩΤΙΚΗ Υ/Δ')).
	append($('<option>').attr('value', 'ΑΣΘΕΝΕΙΑ').text('ΑΣΘΕΝΕΙΑ')).
	append($('<option>').attr('value', 'ΑΣΘΕΝΕΙΑ ΤΕΚΝΟΥ').text('ΑΣΘΕΝΕΙΑ ΤΕΚΝΟΥ')).
	append($('<option>').attr('value', 'ΑΙΜΟΔΟΣΙΑ').text('ΑΙΜΟΔΟΣΙΑ')).
	append($('<option>').attr('value', 'ΡΕΠΟ ΑΙΜΟΔΟΣΙΑΣ').text('ΡΕΠΟ ΑΙΜΟΔΟΣΙΑΣ')).
	append($('<option>').attr('value', 'ΡΕΠΟ ΥΠΕΡΩΡΙΑΣ').text('ΡΕΠΟ ΥΠΕΡΩΡΙΑΣ')).
	append($('<option>').attr('value', 'ΣΥΝΔΙΚΑΛΙΣΤΙΚΗ').text('ΣΥΝΔΙΚΑΛΙΣΤΙΚΗ')).
	append($('<option>').attr('value', 'ΕΚΠΑΙΔΕΥΤΙΚΗ').text('ΕΚΠΑΙΔΕΥΤΙΚΗ')).
	append($('<option>').attr('value', 'ΔΙΚΑΣΤΗΡΙΟ').text('ΔΙΚΑΣΤΗΡΙΟ')).
	append($('<option>').attr('value', 'ΑΝΕΥ ΑΠΟΔΟΧΩΝ').text('ΑΝΕΥ ΑΠΟΔΟΧΩΝ')).
	append($('<option>').attr('value', 'ΑΠΟΣΠΑΣΗ').text('ΑΠΟΣΠΑΣΗ')).
	append($('<option>').attr('value', 'ΠΑΡΑΙΤΗΣΗ').text('ΠΑΡΑΙΤΗΣΗ')).
	append($('<option>').attr('value', 'ΑΠΟΛΥΣΗ').text('ΑΠΟΛΥΣΗ')).
	append($('<option>').attr('value', 'ΣΥΝΤΑΞΙΟΔΟΤΗΣΗ').text('ΣΥΝΤΑΞΙΟΔΟΤΗΣΗ')).
	append($('<option>').attr('value', 'ΛΥΣΗ ΣΧ. ΕΡΓΑΣΙΑΣ').text('ΛΥΣΗ ΣΧ. ΕΡΓΑΣΙΑΣ')).
	append($('<option>').attr('value', 'ΠΕΝΘΟΣ').text('ΠΕΝΘΟΣ')).
	append($('<option>').attr('value', 'ΕΙΔΙΚΗ ΑΔΕΙΑ').text('ΕΙΔΙΚΗ ΑΔΕΙΑ')).
	css('width', '200px')).

	// Από

	append($('<div>').
	addClass('hprompt').
	css('margin-left', '115px').
	text('Από')).
	append(Kartel.eventZoom.adia.apoDOM = $('<input>').
	css('width', '100px').
	datepicker()).

	// Έως

	append($('<div>').
	addClass('hprompt').
	css('margin-left', '6px').
	text('Έως')).
	append(Kartel.eventZoom.adia.eosDOM = $('<input>').
	css('width', '100px').
	datepicker())).

	append($('<div>').
	addClass('eventZoomInput').

	append($('<div>').
	addClass('hprompt ezp1').
	text('Σχόλια')).
	append(Kartel.eventZoom.adia.infoDOM = $('<textarea>').
	css('width', '622px'))));

	return Kartel.eventZoom;
};

///////////////////////////////////////////////////////////////////////////////@

Kartel.eventZoom.excuse = {};

Kartel.eventZoom.excuse.create = function() {
	Kartel.eventZoom.formDOM.
	append(Kartel.eventZoom.excuse.panelDOM = $('<div>').
	addClass('subPanel ezExcuse').

	append($('<div>').
	addClass('eventZoomInput').

	// Λόγος

	append($('<div>').
	addClass('hprompt').
	css('margin-left', '22px').
	text('Αιτιολογία')).
	append(Kartel.eventZoom.excuse.logosDOM = $('<select>').
	append($('<option selected>').attr('value', '').text('')).
	append($('<option>').attr('value', 'ΕΚΤΟΣ').text('ΕΚΤΟΣ')).
	append($('<option>').attr('value', 'ΚΑΡΤΑ').text('ΚΑΡΤΑ')).
	append($('<option>').attr('value', 'ΑΙΜΟΔΟΣΙΑ').text('ΑΙΜΟΔΟΣΙΑ')).
	append($('<option>').attr('value', 'ΓΟΝΙΚΗ').text('ΓΟΝΙΚΗ')).
	append($('<option>').attr('value', 'ΕΚΠΑΙΔΕΥΣΗ').text('ΕΚΠΑΙΔΕΥΣΗ')).
	append($('<option>').attr('value', 'ΔΙΚΑΣΤΗΡΙΟ').text('ΔΙΚΑΣΤΗΡΙΟ')).
	append($('<option>').attr('value', 'ΥΓΕΙΑ').text('ΥΓΕΙΑ')).
	append($('<option>').attr('value', 'ΠΕΝΘΟΣ').text('ΠΕΝΘΟΣ')).
	append($('<option>').attr('value', 'ΑΛΛΗ ΑΙΤΙΑ').text('ΑΛΛΗ ΑΙΤΙΑ')).
	css('width', '200px')).

	// Ώρα

	append($('<div>').
	addClass('hprompt').
	css('margin-left', '273px').
	text('Ώρα')).
	append(Kartel.eventZoom.excuse.oraDOM = $('<input>').
	css('width', '100px'))).

	append($('<div>').
	addClass('eventZoomInput').

	append($('<div>').
	addClass('hprompt ezp1').
	text('Σχόλια')).
	append(Kartel.eventZoom.excuse.infoDOM = $('<textarea>').
	css('width', '622px'))));

	return Kartel.eventZoom;
};

///////////////////////////////////////////////////////////////////////////////@

Kartel.eventZoom.istoriko = {};

Kartel.eventZoom.istoriko.create = function() {
	Kartel.eventZoom.formDOM.
	append(Kartel.eventZoom.istoriko.panelDOM = $('<div>').
	addClass('subPanel ezIstoriko').

	// Rowid

	append($('<div>').
	addClass('eventZoomInput').

	append($('<div>').
	addClass('hprompt ezp1').
	text('Event-ID')).
	append($('<div>').
	addClass('ezf1').
	append(Kartel.eventZoom.istoriko.rowidDOM = $('<input>').
	css('width', '90px')).

	// Ημερομηνία και ώρα

	append($('<div>').
	addClass('hprompt').
	css('margin-left', '385px').
	text('Ώρα')).
	append(Kartel.eventZoom.istoriko.oraDOM = $('<input>').
	css('width', '90px')))).

	// Καρταναγνώστης

	append($('<div>').
	addClass('eventZoomInput').

	append($('<div>').
	addClass('hprompt ezp1').
	text('Αισθητήρας')).
	append($('<div>').
	addClass('ezf1').
	append(Kartel.eventZoom.istoriko.readerKodikosDOM = $('<input>').
	css('width', '462px')).

	append($('<div>').
	addClass('hprompt').
	text('Τύπος')).
	append(Kartel.eventZoom.istoriko.readerIdosDOM = $('<input>').
	css('width', '90px')))).

	append($('<div>').
	addClass('eventZoomInput').

	append($('<div>').
	addClass('hprompt ezp1').
	text('Τοποθεσία')).
	append(Kartel.eventZoom.istoriko.readerInfoDOM = $('<input>').
	css('width', '622px'))));

	return Kartel.eventZoom;
};

///////////////////////////////////////////////////////////////////////////////@

Kartel.eventZoom.dialogos = function(opts) {
	var settings;

	settings = {
		'title': 'Στοιχεία συμβάντος',
		'autoOpen': false,
		'modal': false,

		'width': 'auto',
		'height': 'auto',
		'resizable': false,
		'position': {
			'my': 'center',
			'at': 'center',
		},

/*
		'buttons': {
			'Άδεια': Kartel.eventZoom.adia.insert,
			'Αιτιολογία': Kartel.eventZoom.excuse.insert,
			'Υποβολή': Kartel.eventZoom.ipovoli,
			'Άκυρο': Kartel.eventZoom.close,
		},
*/

		'show': {
			'effect': 'clip',
			'duration': 100,
		},
		'hide': {
			'effect': 'clip',
			'duration': 150,
		},
	};

	if (opts)
	Globals.walk(opts, function(i, v) {
		settings[i] = v;
	});

	if (!settings.hasOwnProperty('position'))
	settings.position = {};

	if (!settings.position.hasOwnProperty('of'))
	settings.position.of = Selida.ofelimoDOM;

	Kartel.eventZoom.formDOM.dialog(settings);

	return Selida;
};

Kartel.eventZoom.open = function(data) {
	if (data === undefined)
	data = {};

	Selida.fyi.pano('Παρακαλώ περιμένετε…', 'left', true);

	Selida.ajax(Selida.server + 'lib/ezoom', data).
	done(function(rsp) {
		Selida.fyi.pano();
		Kartel.eventZoom.display(Kartel.eventZoom.fixData(rsp));
	}).
	fail(function(err) {
		Selida.fyi.epano('Παρουσιάστηκε σφάλμα!');
	});

	return Selida;
};

Kartel.eventZoom.fixData = function(data) {
	if (data.hasOwnProperty('istoriko'))
	data['istoriko'] = new Istoriko(data['istoriko']);

	if (data.hasOwnProperty('ipalilos'))
	data['ipalilos'] = new Ipalilos(data['ipalilos']);

	Kartel.eventZoom.fixImerominia(data);
	return data;
};

Kartel.eventZoom.fixImerominia = function(data) {
	if (data.imerominia) {
		data.imerominia = new Date(data.imerominia);
		return Kartel.eventZoom;
	}

	if (data.hasOwnProperty('istoriko') && data.istoriko.mera) {
		data.imerominia = new Date(data.istoriko.mera);
		return Kartel.eventZoom;
	}

	delete data.imerominia;
	return Kartel.eventZoom;
};

Kartel.eventZoom.close = function() {
	if (Kartel.eventZoom.formDOM.dialog('isOpen') == true)
	Kartel.eventZoom.formDOM.
	removeData('data').
	dialog('close');

	return Selida;
};

Kartel.eventZoom.ipovoli = function() {
	return Selida;
};

///////////////////////////////////////////////////////////////////////////////@

Kartel.eventZoom.display = function(data) {
	if (Kartel.eventZoom.formDOM.dialog('isOpen') != true)
	Kartel.eventZoom.formDOM.dialog('open');

	Kartel.eventZoom.
	dataSet(data).
	fieldsClear().
	titleSet(data).
	ipalilos.displayData(data.ipalilos).
	displayIstoriko(data.istoriko);

	return Selida;
};

Kartel.eventZoom.dataSet = function(data) {
	Kartel.eventZoom.formDOM.
	removeData('data');

	if (data === undefined)
	return Kartel.eventZoom;

	Kartel.eventZoom.formDOM.
	data('data', data);

	return Kartel.eventZoom;
};

Kartel.eventZoom.dataGet = function() {
	return Kartel.eventZoom.formDOM.data('data');
};

Kartel.eventZoom.fieldsClear = function() {
	return Kartel.eventZoom;

	Kartel.eventZoom.
	formDOM.find('input,textarea,select').
	prop('disabled', true).
prop('disabled', false).
	val('');

	return Kartel.eventZoom;
};

Kartel.eventZoom.titleSet = function(data) {
	var title = '';
	var sep = '';
	var proapo = {
		'ΠΡΟΣΕΛΕΥΣΗ': {
			'class': 'proselefsi',
			'left': '&#9656;',
			'right': '&#9666;',
		},

		'ΑΠΟΧΩΡΗΣΗ': {
			'class': 'apoxorisi',
			'left': '&#9666;',
			'right': '&#9656;',
		},
	};

	if (data.hasOwnProperty('imerominia') &&
		(data.imerominia instanceof Date)) {
		title += sep + data.imerominia.
		toLocaleDateString('el-GR', {
			weekday: 'long',
			year: 'numeric',
			month: 'long',
			day: 'numeric',
		});

		sep = '&nbsp;';
	}

	if (data.proapo) {
		title += sep + '<span class="' + proapo[data.proapo].class +
			'">' + proapo[data.proapo].left + '&nbsp;' +
			 data.proapo + '&nbsp;' + proapo[data.proapo].right +
			'</span>';
		sep = '';
	}

	if (!title)
	title = '???';

	Kartel.eventZoom.
	formDOM.dialog('option', 'title', '').
	parent().find('.ui-dialog-title').
	css('font-weight', 'normal').
	html(title);

	return Kartel.eventZoom;
};

Kartel.eventZoom.ipalilos.displayData = function(ipalilos) {
	Kartel.eventZoom.ipalilos.kodikosDOM.val('');
	Kartel.eventZoom.ipalilos.onomateponimoDOM.val('');
	Kartel.eventZoom.ipalilos.afmDOM.val('');

	if (!ipalilos)
	return Kartel.eventZoom;

	if (!ipalilos.hasOwnProperty('kodikos'))
	return Kartel.eventZoom;

	Kartel.eventZoom.ipalilos.kodikosDOM.
	val(ipalilos.kodikos);

	Kartel.eventZoom.ipalilos.onomateponimoDOM.
	val(ipalilos.eponimo + ' ' + ipalilos.onoma + ' ' +
		ipalilos.patronimo.substr(0, 3));

	Kartel.eventZoom.ipalilos.afmDOM.
	val(ipalilos.afm);

	Kartel.eventZoom.ipalilos.
	displayMetavoli(ipalilos);

	return Kartel.eventZoom;
}

Kartel.eventZoom.ipalilos.displayMetavoli = function(ipalilos) {
	Kartel.eventZoom.ipalilos.diefDOM.val('');
	Kartel.eventZoom.ipalilos.diefDescDOM.val('');
	Kartel.eventZoom.ipalilos.tmimaDOM.val('');
	Kartel.eventZoom.ipalilos.tmimaDescDOM.val('');
	Kartel.eventZoom.ipalilos.kartaDOM.val('');
	Kartel.eventZoom.ipalilos.orarioDOM.val('');

	if (!ipalilos)
	return Kartel.eventZoom;

	if (!ipalilos.metavoli)
	return Kartel.eventZoom;

	if (ipalilos.metavoli.hasOwnProperty('ΔΙΕΥΘΥΝΣΗ')) {
		Kartel.eventZoom.ipalilos.diefDOM.
		val(ipalilos.metavoli['ΔΙΕΥΘΥΝΣΗ'].timi);

		Kartel.eventZoom.ipalilos.diefDescDOM.
		val(ipalilos.metavoli['ΔΙΕΥΘΥΝΣΗ'].decode).
		attr('title', ipalilos.metavoli['ΔΙΕΥΘΥΝΣΗ'].decode);
	}

	if (ipalilos.metavoli.hasOwnProperty('ΤΜΗΜΑ')) {
		Kartel.eventZoom.ipalilos.tmimaDOM.
		val(ipalilos.metavoli['ΤΜΗΜΑ'].timi);

		Kartel.eventZoom.ipalilos.tmimaDescDOM.
		val(ipalilos.metavoli['ΤΜΗΜΑ'].decode).
		attr('title', ipalilos.metavoli['ΤΜΗΜΑ'].decode);
	}

	if (ipalilos.metavoli.hasOwnProperty('ΚΑΡΤΑ'))
	Kartel.eventZoom.ipalilos.kartaDOM.
	val(ipalilos.metavoli['ΚΑΡΤΑ'].timi);

	if (ipalilos.metavoli.hasOwnProperty('ΩΡΑΡΙΟ'))
	Kartel.eventZoom.ipalilos.orarioDOM.
	val(ipalilos.metavoli['ΩΡΑΡΙΟ'].timi);

	return Kartel.eventZoom;
};

Kartel.eventZoom.displayIstoriko = function(istoriko) {
	Kartel.eventZoom.istoriko.rowidDOM.val('');
	Kartel.eventZoom.istoriko.oraDOM.val('');
	Kartel.eventZoom.istoriko.readerKodikosDOM.val('');
	Kartel.eventZoom.istoriko.readerIdosDOM.val('');
	Kartel.eventZoom.istoriko.readerInfoDOM.val('');

	if (!istoriko)
	return Kartel.eventZoom;

	Kartel.eventZoom.istoriko.rowidDOM.
	val(istoriko.kodikos).
	prop('disabled', true);

	Kartel.eventZoom.istoriko.oraDOM.
	val(istoriko.ora).
	prop('disabled', true);

	Kartel.eventZoom.istoriko.readerKodikosDOM.
	val(istoriko.reader).
	prop('disabled', true);

	Kartel.eventZoom.istoriko.readerIdosDOM.
	val(istoriko.istorikoIdosMetafrasi()).
	prop('disabled', true);

	Kartel.eventZoom.istoriko.readerInfoDOM.
	val(istoriko.perigrafi).
	prop('disabled', true);

	return Kartel.eventZoom;
};

///////////////////////////////////////////////////////////////////////////////@

Kartel.eventZoom.excuse.insertSuccess = function(rsp) {
	console.log('Insert "excuse"', rsp);
};

Kartel.eventZoom.excuse.insert = function() {
	var data1;
	var data2;

	data1 = Kartel.eventZoom.dataGet();

	if (!data1)
	return Selida.fyi.epano('Δεν υπάρχουν δεδομένα για άνοιγμα αιτιολογίας', 'right');

	data2 = {};

	if (!data1.hasOwnProperty('ipalilos'))
	return Selida.fyi.epano('Ακαθόριστος υπάλληλος', 'right');

	data2.ipalilos = data1.ipalilos.kodikos;

	if (!data2.ipalilos)
	return Selida.fyi.epano('Ακαθόριστος κωδικός υπαλλήλου', 'right');

	if (!data1.hasOwnProperty('imerominia'))
	return Selida.fyi.epano('Ακαθόριστη ημερομηνία', 'right');

	data2.mera = Globals.mera(data1.imerominia, 'Y-m-d');

	if (!data2.mera)
	return Selida.fyi.epano('Λανθασμένη ημερομηνία', 'right');

	if (!data1.hasOwnProperty('proapo'))
	return Selida.fyi.epano('Ακαθόριστη προσέλευση/αποχώρηση', 'right');

	data2.proapo = data1.proapo;

	data2.logos = Kartel.eventZoom.excuse.logosDOM.val();
	data2.ora = Kartel.eventZoom.excuse.oraDOM.val();
	data2.info = Kartel.eventZoom.excuse.infoDOM.val();

	data2.action = 'insert';
	Selida.ajax(Selida.server + 'lib/xcuse', data2).
	done(function(rsp) {
		Kartel.eventZoom.excuse.insertSuccess(new Excuse(rsp));
	}).
	fail(function(err) {
		Selida.ajaxFail(err, 'right');
	});
};

Kartel.eventZoom.excuse.refresh = function(e) {
	Kartel.eventZoom.excuse.logosDOM.val(e.logosToString());
	Kartel.eventZoom.excuse.infoDOM.val(e.infoToString);

	return Kartel.eventZoom;
};

///////////////////////////////////////////////////////////////////////////////@

Kartel.eventZoom.adia.insertSuccess = function(rsp) {
	console.log(rsp);
};

Kartel.eventZoom.adia.insert = function() {
	var data1;
	var data2;

	data1 = Kartel.eventZoom.dataGet();

	if (!data1)
	return Selida.fyi.epano('Δεν υπάρχουν δεδομένα για άνοιγμα αιτιολογίας', 'right');

	data2 = {};

	if (!data1.hasOwnProperty('ipalilos'))
	return Selida.fyi.epano('Ακαθόριστος υπάλληλος', 'right');

	data2.ipalilos = data1.ipalilos.kodikos;

	if (!data2.ipalilos)
	return Selida.fyi.epano('Ακαθόριστος κωδικός υπαλλήλου', 'right');

	if (!data1.hasOwnProperty('imerominia'))
	return Selida.fyi.epano('Ακαθόριστη ημερομηνία', 'right');

	data2.mera = Globals.mera(data1.imerominia, 'Y-m-d');

	if (!data2.mera)
	return Selida.fyi.epano('Λανθασμένη ημερομηνία', 'right');

	if (!data1.hasOwnProperty('proapo'))
	return Selida.fyi.epano('Ακαθόριστη προσέλευση/αποχώρηση', 'right');

	data2.proapo = data1.proapo;

	data2.logos = Kartel.eventZoom.adia.idosDOM.val();
	data2.ora = Kartel.eventZoom.adia.apoDOM.val();
	data2.ora = Kartel.eventZoom.adia.eos.val();
	data2.info = Kartel.eventZoom.adia.infoDOM.val();

	data2.action = 'insert';
	Selida.ajax(Selida.server + 'lib/adia', data2).
	done(function(rsp) {
		Kartel.eventZoom.adia.insertSuccess(new Adia(rsp));
	}).
	fail(function(err) {
		Selida.ajaxFail(err, 'right');
	});
};

Kartel.eventZoom.adia.refresh = function(a) {
	Kartel.eventZoom.adia.idosDOM.val(a.idosToString());
	Kartel.eventZoom.adia.infoDOM.val(a.infoToString);

	return Kartel.eventZoom;
};

///////////////////////////////////////////////////////////////////////////////@
