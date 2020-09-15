///////////////////////////////////////////////////////////////////////////////@

if (!Pelekanos)
var Pelekanos = {};

Pelekanos.misc = {};
Pelekanos.misc.filtraShowTitle = 'Εμφάνιση φίλτρων επιλογής';
Pelekanos.misc.filtraHideTitle = 'Απόκρυψη φίλτρων επιλογής';

Selida.init = function() {
	Pelekanos.
	filtraSetup().
	toolbarSetup();
Pelekanos.filtraTabDOM.trigger('click');

	return Pelekanos;
}

///////////////////////////////////////////////////////////////////////////////@

Pelekanos.filtraSetup = function () {
	Pelekanos.filtraDOM = $('<table>').
	dialog({
		'title': 'Κριτήρια επιλογής',
		'autoOpen': false,

		'width': 'auto',
		'height': 'auto',
		'position': {
			'my': 'left+50 top+60',
			'at': 'left top',
		},

		'open': function() {
			Pelekanos.filtraTabDOM.data('status', 'visible');
			Pelekanos.filtraToggle();
		},

		'show': {
			'effect': 'drop',
			'direction': 'up',
			'duration': 100,
		},

		'close': function() {
			Pelekanos.filtraTabDOM.data('status', 'hidden');
			Pelekanos.filtraToggle();
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
		Pelekanos.filtraDOM.dialog('close');
	});

	Pelekanos.filtraTabDOM = Selida.
	tab('Φίλτρα').
	data('status', 'hidden').
	attr('title', Pelekanos.misc.filtraShowTitle).
	on('click', function(e) {
		e.stopPropagation();
		Pelekanos.filtraToggle(true);
	});

	Pelekanos.
	filtroMonadaSetup().
	filtroIpalilosSetup();

	return Pelekanos;
};

Pelekanos.filtroMonadaSetup = () => {
	var dom;

	dom = $('<tr>').

	append($('<td>').
	attr('colspan', 10).
	addClass('filtroLabel').
	text('Υπηρεσία')).

	append($('<td>').
	append($('<input>').
	attr('id', 'filtroMonada')
	));

	dom.appendTo(Pelekanos.filtraDOM);

	dom = $('<tr>').

	append($('<td>').
	addClass('filtroLabel').
	text('Διεύθυνση')).

	append($('<td>').
	append($('<div>').
	addClass('filtroIpiresiaKodikos'))).

	append($('<td>').
	append($('<div>').
	addClass('filtroIpiresiaPerigrafi')));

	dom.appendTo(Pelekanos.filtraDOM);

	dom = $('<tr>').

	append($('<td>').
	addClass('filtroLabel').
	text('Τμήμα')).

	append($('<td>').
	append($('<div>').
	addClass('filtroIpiresiaKodikos'))).

	append($('<td>').
	append($('<div>').
	addClass('filtroIpiresiaPerigrafi')));

	dom.appendTo(Pelekanos.filtraDOM);

	dom = $('<tr>').

	append($('<td>').
	addClass('filtroLabel').
	text('Γραφείο')).

	append($('<td>').
	append($('<div>').
	addClass('filtroIpiresiaKodikos'))).

	append($('<td>').
	append($('<div>').
	addClass('filtroIpiresiaPerigrafi')));

	dom.appendTo(Pelekanos.filtraDOM);

	return Pelekanos;
};

Pelekanos.filtroIpalilosSetup = () => {
	var dom;

	dom = $('<div>').
	addClass('filtroLine').
	append($('<div>').
	addClass('filtroLabel').
	text('Υπάλληλος'));

	dom.appendTo(Pelekanos.filtraDOM);
	return Pelekanos;
};

Pelekanos.filtraToggle = function(act) {
	if (Pelekanos.filtraDisabled())
	Pelekanos.filtraEnable(act);

	else
	Pelekanos.filtraDisable(act);

	return Pelekanos;
};

Pelekanos.filtraEnable = function(act) {
	Pelekanos.filtraTabDOM.
	removeClass('filtraTabOff').
	attr('title', Pelekanos.misc.filrtaHideTitle);

	if (!act)
	return Pelekanos;

	Pelekanos.filtraDOM.dialog('open');
	return Pelekanos;
};

Pelekanos.filtraDisable = function(act) {
	Pelekanos.filtraTabDOM.
	addClass('filtraTabOff').
	attr('title', Pelekanos.misc.filrtaHideTitle);

	if (!act)
	return Pelekanos;

	Pelekanos.filtraDOM.dialog('close');
	return Pelekanos;
};

Pelekanos.filtraDisabled = function() {
	return (Pelekanos.filtraTabDOM.data('status') === 'hidden');
};

///////////////////////////////////////////////////////////////////////////////@

Pelekanos.toolbarSetup = function() {
	Pelekanos.
	filtraTabDOM.
	appendTo(Selida.toolbarLeftDOM);

	Selida.tabIsodosExodos();

	return Pelekanos;
};

///////////////////////////////////////////////////////////////////////////////@
