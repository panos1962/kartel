///////////////////////////////////////////////////////////////////////////////@

if (!Kalamari)
var Kalamari = {
	'param': {
		'apo': Globals.mera(new Date(),  'd-m-Y'),
		'meres': 14,
	},
};

Kalamari.misc = {
	multiShowTitle: 'Εμφάνιση επιπλέον συμβάντων της ίδιας ημέρας',
	multiHideTitle: 'Απόκρυψη επιπλέον συμβάντων της ίδιας ημέρας',

	filtraShowTitle: 'Εμφάνιση φίλτρων',
	filtraHideTitle: 'Απόκρυψη φίλτρων',

	analitikaTitle: 'Αναλυτική κατάσταση',
	sinoptikaTitle: 'Συνοπτική κατάσταση',

	analitikaLabel: 'Αναλυτικά',
	sinoptikaLabel: 'Συνοπτικά',
};

Selida.init = function() {
	Kalamari.
	filtraSetup().
	toolbarSetup().
	zoomSetup().
	eventsSetup().
	restSetup().
	buttonMoreDOM.trigger('click');

	Selida.windowDOM.trigger('resize');
	return Kalamari;
}

///////////////////////////////////////////////////////////////////////////////@

Kalamari.filtraSetup = function () {
	Kalamari.filtraDOM = $('#filtra').
	dialog({
		'title': 'Κριτήρια επιλογής',
		'autoOpen': false,

		'width': 'auto',
		'height': 'auto',
		'position': {
			'my': 'right-30 top+60',
			'at': 'right top',
		},

		'open': function() {
			Kalamari.filtraTabDOM.data('status', 'visible');
			Kalamari.filtraToggle();
		},

		'show': {
			'effect': 'drop',
			'direction': 'up',
			'duration': 100,
		},

		'close': function() {
			Kalamari.filtraTabDOM.data('status', 'hidden');
			Kalamari.filtraToggle();
		},
		'hide': {
			'effect': 'drop',
			'direction': 'up',
			'duration': 100,
		},
	});

	$('#filtraClose').
	on('click', function(e) {
		e.stopPropagation();
		Kalamari.filtraDOM.dialog('close');
	});

	Kalamari.filtraTabDOM = Selida.
	tab('Φίλτρα').
	data('status', 'hidden').
	attr('title', Kalamari.misc.filtraShowTitle).
	on('click', function(e) {
		e.stopPropagation();
		Kalamari.filtraToggle(true);
	});

	Kalamari.clearPinakas = false;

	Kalamari.filtroApoDOM = $('#filtroApo').
	val(Kalamari.param.apo).
	datepicker().
	on('change', function() {
		Kalamari.elist = [];
		Kalamari.clearPinakas = true;
		Kalamari.apo = $(this).val();
		Kalamari.buttonMoreDOM.
		trigger('click');
	});

	Kalamari.filtroArgiesDOM = $('#filtroArgies').
	on('change', function() {
		$('.argia').css('display',
			$(this).prop('checked') ? 'table-row' : 'none');
	});

	Kalamari.filtroMeresDOM = $('#filtroMeres').
	val(Kalamari.param.meres).
	on('change', function() {
		if ($(this).val() < 1)
		$(this).val(1);

		Kalamari.meraMeresRefresh();
	});

	Kalamari.meraMeresDOM = $('#meraMeres');

	Kalamari.buttonTopDOM = $('#buttonTop').
	on('click', function(e) {
		e.stopPropagation();
		Selida.ofelimoDOM.scrollPano();
		$(this).addClass('anenergo')
		Kalamari.buttonEndDOM.removeClass('anenergo');
	});

	Kalamari.buttonEndDOM = $('#buttonEnd').
	addClass('anenergo').
	on('click', function(e) {
		e.stopPropagation();
		Selida.ofelimoDOM.scrollKato();
		$(this).addClass('anenergo')
		Kalamari.buttonTopDOM.removeClass('anenergo');
	});

	Kalamari.apo = Kalamari.filtroApoDOM.val();

	Kalamari.buttonMoreDOM = $('#buttonMore').
	on('click', function(e) {
		var meres;

		e.stopPropagation();

		meres = parseInt(Kalamari.filtroMeresDOM.val());

		if (!meres) {
			Kalamari.filtroMeresDOM.val(7);
			Kalamari.meraMeresRefresh();
			meres = 14;
		}
	
		Selida.ajax(Selida.server + 'kalamari/select', {
			'apo': Kalamari.apo,
			'meres': meres,
		}).
		done(function(rsp) {
			var dmy;
			var apo;
			try {
				Kalamari.eventsPush(eval(rsp));
				dmy = Kalamari.apo.split(new RegExp(/[^0-9]/));
				apo = new Date(parseInt(dmy[2]), parseInt(dmy[1]) - 1, parseInt(dmy[0]));
				apo.setDate(apo.getDate() - meres);
				Kalamari.apo = Globals.mera(apo, 'd-m-Y');
			} catch (e) {
				console.error(e);
			}
		}).
		fail(function(err) {
			Selida.ajaxFail(err);
		});
	});

	return Kalamari;
};

Kalamari.filtraDisabled = function() {
	return (Kalamari.filtraTabDOM.data('status') === 'hidden');
};

Kalamari.filtraToggle = function(act) {
	if (Kalamari.filtraDisabled())
	Kalamari.filtraEnable(act);

	else
	Kalamari.filtraDisable(act);

	return Kalamari;
};

Kalamari.filtraEnable = function(act) {
	Kalamari.filtraTabDOM.
	removeClass('filtraTabOff').
	attr('title', Kalamari.misc.filrtaHideTitle);

	if (!act)
	return Kalamari;

	Kalamari.filtraDOM.dialog('open');
	Kalamari.buttonMoreDOM.focus();
	return Kalamari;
};

Kalamari.filtraDisable = function(act) {
	Kalamari.filtraTabDOM.
	addClass('filtraTabOff').
	attr('title', Kalamari.misc.filrtaHideTitle);

	if (act)
	Kalamari.filtraDOM.dialog('close');

	return Kalamari;
};

Kalamari.meraMeresRefresh = function(meres) {
	if (meres === undefined)
	meres = Kalamari.filtroMeresDOM.val();

	Kalamari.meraMeresDOM.text(meres > 1 ? 'ημέρες' : 'ημέρα');
};

///////////////////////////////////////////////////////////////////////////////@

Kalamari.toolbarSetup = function() {
	Kalamari.filtraTabDOM.
	appendTo(Selida.toolbarLeftDOM);

	Kalamari.sort.tabDOM = Selida.
	tab().
	attr('title', 'Εναλλαγή ταξινόμησης').
	on('click', function(e) {
		e.stopPropagation();

		Kalamari.
		sort.orderReverse().
		eventsPush();
	}).
	appendTo(Selida.toolbarLeftDOM);
	Kalamari.sort.tabRefresh();

	Kalamari.palioteraTabDOM = Selida.
	tab('Παλαιότερα').
	attr('title', 'Παλαιότερα συμβάντα').
	on('click', function(e) {
		e.stopPropagation();
		Kalamari.buttonMoreDOM.
		trigger('click');
	}).
	appendTo(Selida.toolbarLeftDOM);

	Kalamari.secondaryTabDOM = Selida.
	tab(Kalamari.misc.analitikaLabel).
	attr('title', Kalamari.misc.analitikaTitle).
	on('click', function(e) {
		e.stopPropagation();

		if ($(this).data('analitika')) {
			$('.secondaryColumn').
			css('display', 'none');
			$(this).
			removeData('analitika').
			attr('title', Kalamari.misc.analitikaTitle).
			text(Kalamari.misc.analitikaLabel);
		}

		else {
			$('.secondaryColumn').
			css('display', 'table-cell');
			$(this).
			data('analitika', true).
			attr('title', Kalamari.misc.sinoptikaTitle).
			text(Kalamari.misc.sinoptikaLabel);
		}
	}).
	appendTo(Selida.toolbarLeftDOM);

	Selida.tabIsodosExodos();

	return Kalamari;
};

///////////////////////////////////////////////////////////////////////////////@

Kalamari.zoomSetup = function () {
	Kartel.eventZoom.create({
		'position': {
			'my': 'right-30 bottom-20',
			'at': 'right bottom',
		},
	});
	Kartel.eventZoom.excuse.insertSuccess = Kalamari.excuseInsertSuccess;
	return Kalamari;
}

Kalamari.excuseInsertSuccess = function(excuse) {
	Kartel.eventZoom.excuseRefresh(excuse);
	return Kalamari;
};

///////////////////////////////////////////////////////////////////////////////@

Kalamari.eventsSetup = function () {
	Kartel.eventZoom.
	formDOM.dialog('option', {
		'close': function() {
			$('.rowidZoomed').removeClass('rowidZoomed');
		},
	});

	Kalamari.eventsDOM = $('#events').
	on('mouseenter', '.argia', function(e) {
		e.stopPropagation();
		Selida.fyi.pano($(this).data('argia'), 'left', true);
	}).
	on('mouseleave', '.argia', function(e) {
		e.stopPropagation();
		Selida.fyi.pano();
	}).
	on('click', '.rowid', function(e) {
		var zoomed;

		e.stopPropagation();

		zoomed = $(this).hasClass('rowidZoomed');
		$('.rowidZoomed').removeClass('rowidZoomed');

		if (zoomed)
		return Kartel.eventZoom.close();

		$(this).addClass('rowidZoomed');
		Kartel.eventZoom.open({
			'imerominia': $(this).parent().data('mera'),
			'eventId': $(this).text(),
			'proapo': $(this).data('proapo'),
			'ipalilos': Selida.ipalilosGet(),
		});
	});

	return Kalamari;
};

Kalamari.restSetup = function () {
	Kalamari.eventsDOM.
	on('click', '.multiIndicator', function(e) {
		var rowid;
		var open;

		e.stopPropagation();
		rowid = $(this).data('rowid');
		open = $(this).data('open');

		$('.rest.' + rowid).
		css('display', (open ? 'none' : 'table-row'));

		if (open)
		$(this).
		attr('title', Kalamari.misc.multiShowTitle).
		removeClass('multiClose');

		else
		$(this).
		attr('title', Kalamari.misc.multiHideTitle).
		addClass('multiClose');

		$(this).
		data('open', !open);
	});

	Kalamari.restEnalagiDOM = $('#restShowHide').
	attr('title', Kalamari.misc.multiShowTitle).
	on('click', function(e) {
		e.stopPropagation();

		if ($(this).data('open')) {
			Kalamari.restHideAll();
			$(this).
			attr('title', Kalamari.misc.multiShowTitle).
			removeData('open').
			removeClass('multiClose');
		}

		else {
			Kalamari.restShowAll();
			$(this).
			attr('title', Kalamari.misc.multiHideTitle).
			data('open', true).
			addClass('multiClose');
		}
	});

	return Kalamari;
};

Kalamari.restShowAll = function() {
	Kalamari.eventsDOM.
	find('.rest').
	css('display', 'table-row');

	Kalamari.eventsDOM.
	find('.multiIndicator').
	each(function() {
		$(this).
		data('open', true).
		attr('title', Kalamari.misc.multiHideTitle).
		addClass('multiClose');
	});

	return Kalamari;
};

Kalamari.restHideAll = function() {
	Kalamari.eventsDOM.
	find('.rest').
	css('display', 'none');

	Kalamari.eventsDOM.
	find('.multiIndicator').
	each(function() {
		$(this).
		data('open', false).
		attr('title', Kalamari.misc.multiShowTitle).
		removeClass('multiClose');
	});

	return Kalamari;
};

///////////////////////////////////////////////////////////////////////////////@

Kalamari.elist = [];
Kalamari.partida = 0;

Kalamari.eventsPush = function(elist) {
	var l;

	if (elist === undefined) {
		l = Kalamari.elist;
		Kalamari.clearPinakas = true;
	}

	else {
		l = elist;
		Globals.apush(Kalamari.elist, elist);
	}

	if (Kalamari.clearPinakas) {
		Kalamari.eventsDOM.empty();
		Kalamari.restEnalagiDOM.
		data('open', true).
		trigger('click');
	}

	Kalamari.clearPinakas = false;

	Globals.awalk(l, function(i, e) {
		Kalamari.meraPush(e);
	});

	if (!Kalamari.partida++)
	return Kalamari;

	if (elist === undefined)
	Selida.ofelimoDOM.scrollPano();

	else if (Kalamari.sort.order === 'protaNew')
	Selida.ofelimoDOM.scrollKato();

	else
	Selida.ofelimoDOM.scrollPano();

	return Kalamari;
};

Kalamari.meraPush = function(e) {
	var mera = e['d'];
	var argia = e['a'];
	var karta = e['k'];
	var orario = e['o'];
	var elist = e['e'];
	var ecnt;
	var enull = {'k':'','o':'','t':'','s':''};
	var pro = enull;
	var apo = enull;
	var rowDOM;
	var mltDOM;
	var smera;

	if (elist === undefined)
	elist = [];

	ecnt = elist.length;

	switch (elist.length) {
	case 0:
		break;
	case 1:
		pro = elist[0];
		break;
	default:
		pro = elist[0];
		apo = elist[ecnt - 1];
		break;
	}

	mera = new Date(mera);
	smera = Globals.mera(mera);

	rowDOM = $('<tr>').
	data('mera', smera).
	addClass('mera').
	zebraClass().

	append(mltDOM = $('<td>').
	addClass('multiIndicator')).

	append($('<td>').
	addClass('dow').
	text(mera.toLocaleString('el-GR', {weekday: 'long'}))).

	append($('<td>').
	addClass('date').
	text(smera)).

	append($('<td>').
	addClass('secondaryColumn karta').
	text(karta)).

	append($('<td>').
	addClass('secondaryColumn orario').
	text(orario));

	Kalamari.
	displayProapo(pro, 'ΠΡΟΣΕΛΕΥΣΗ', 'proselefsi', rowDOM).
	displayProapo(apo, 'ΑΠΟΧΩΡΗΣΗ', 'apoxorisi', rowDOM);

	rowDOM.
	append($('<td>').
	addClass('gemisma'));

	if (argia)
	rowDOM.
	data('argia', argia).
	addClass('argia').
	css('display', Kalamari.filtroArgiesDOM.prop('checked') ?
		'table-row' : 'none');

	if (Kalamari.sort.order === 'protaNew')
	rowDOM.appendTo(Kalamari.eventsDOM);

	else
	rowDOM.prependTo(Kalamari.eventsDOM);

	if (ecnt < 3)
	return Kalamari;

	// Υπάρχουν περισσότερα από δύο (2) events στη συγκεκριμένη ημερομηνία.
	// Το πρώτο event θεωρείται «προσέλευση», ενώ το τελευταίο θεωρείται
	// «αποχώρηση». Τα ενδιάμεσα events αφορούν χτυπήματα κάρτας που έγιναν
	// στο ενδιάμεσο διάστημα. Αυτά τα events δεν εμφανίζονται στη σελίδα,
	// αλλά μπορούμε να τα δούμε κάνοντας κλικ στο σχετικό σημαδάκι στην
	// άκρη αριστερά της συγκεκριμένης ημερομηνίας.

	// Πρώτα αποθηκεύουμε το [RecordID] του event ποσέλευσης στο βασικό dom
	// element της συγκεκριμένης ημερομηνίας, και εμφανίζουμε το σχετικό
	// σηματάκι στο αριστερό μέρος της γραμμής.

	mltDOM.
	attr('title', Kalamari.misc.multiShowTitle).
	data('rowid', pro.k).
	addClass('multiOpen').
	html('&#9660');

	// Κατόπιν διατρέχουμε τα ενδιάμεσα events της συγκεκριμένης ημερομηνίας
	// και προσθέτουμε αντίστοιχες γραμμές στον πίνακα συμβάντων. Οι εν λόγω
	// γραμμές αρχικά δεν εμφανίζονται καθώς έτσι επιτάσσει η CSS class
	// "rest" που χαρακτηρίζει τα ενδιάμεσα events.

	Globals.awalk(elist, function(i, e) {
		Kalamari.multiPush(e, pro.k, rowDOM);
	}, {
		from: 1,	// στη πρώτη θέση βρίσκεται η «προσέλευση»
		to: -1,		// στην τελευταία θέση βρίσκεται η «αποχώρηση»
		order: -1,	// αντίστροφη σειρά λόγω insert αντί append
	});

	return Kalamari;
};

Kalamari.displayProapo = function(e, padesc, paclass, rowDOM) {
	var rclass = 'rowid';
	var tclass = 'ora ' + paclass;
	var sclass = 'site';
	var excuse = (e.k && (e.k != parseInt(e.k)));
	var apousia = (e.k === null);
	var rid = e.k;
	var ora = e.t;

	if (apousia) {
		rid = 'ΑΠΟΥΣΙΑ';
		rclass += ' rowidProapo rowidApousia';
		tclass += ' apousia';
		sclass += ' siteProapo';
	}

	else if (excuse) {
		rclass += ' rowidProapo excuse';
		tclass += ' excuse';
		sclass += ' siteProapo';

		if (!ora)
		ora = '&#x2714';
	}
		

	rowDOM.
	append($('<td>').
	addClass(rclass).
	data('proapo', padesc).
	text(rid)).

	append($('<td>').
	addClass(tclass).
	html(ora)).

	append($('<td>').
	addClass(sclass).
	text(e.s));

	return Kalamari;
};

Kalamari.multiPush = function(e, rid, meraDOM) {
	var rowDOM;
	var bc;

	rowDOM = $('<tr>').
	addClass('rest' + ' ' + rid).
	insertAfter(meraDOM);

	bc = rowDOM.css('background-color');

	rowDOM.

	append($('<td>').
	css({
		'border-left-color': bc,
		'border-right-color': bc,
	}).
	attr('colspan', 3)).

	append($('<td>').
	css({
		'border-left-color': bc,
		'border-right-color': bc,
	}).
	prop('colspan', 2).
	addClass('secondaryColumn')).

	append($('<td>').
	addClass('rowid').
	text(e.k)).

	append($('<td>').
	addClass('ora').
	text(e.t)).

	append($('<td>').
	prop('colspan', 5).
	addClass('site').
	text(e.s));

	return Kalamari;
};

///////////////////////////////////////////////////////////////////////////////@

// Ακολουθούν μεταβλητές και functions που αφορούν στη σειρά εμφάνισης των
// events. By default η σειρά εμφάνισης είναι από τα πρόσφατα προς τα παλαιότερα
// γεγονότα. Ωστόσο, η σειρά εμφάνισης μπορεί να αλλάξει με κλικ στο toolbar tab
// «Ταξινόμηση».

Kalamari.sort = {
	'order': 'protaNew',
	'reverse': {
		'protaNew': 'protaOld',
		'protaOld': 'protaNew',
	},
};

Kalamari.sort.orderReverse = function() {
	Kalamari.sort.order = Kalamari.sort.reverse[Kalamari.sort.order];
	Kalamari.sort.tabRefresh();

	return Kalamari;
};

Kalamari.sort.tabRefresh = function() {
	Kalamari.sort.tabDOM.html('Ταξινόμηση&nbsp;' +
	(Kalamari.sort.order === 'protaOld' ? '&#9652;' : '&#9662;'));

	return Kalamari;
};
