///////////////////////////////////////////////////////////////////////////////@

Test = {};

Test.noop = function() {
	return Test;
};

Selida.init = function() {
	Test.
	toolbarSetup().
	formaSetup().
	zoomSetup().
	noop();

	Kartel.eventZoom.open();
	Selida.windowDOM.trigger('resize');
	Test.test();

	return Test;
}

Test.test = function() {
	var pat = 'ΠΑΠΑΔ';

	Test.formaOnomaDOM.val(pat);
	Selida.evretirio.evresi(Test.ipalilosEvretirioSettings, pat);
	setTimeout(function() {
		Test.formaOnomaDOM.focus();
	}, 100);

	return Test;
};

///////////////////////////////////////////////////////////////////////////////@

Test.toolbarSetup = function() {
	Selida.tabIsodosExodos();
	return Test;
};

///////////////////////////////////////////////////////////////////////////////@

Test.formaSetup = function () {
	Test.formaIpalilosSetup();

	Test.formaMeraDOM = $('#formaMera').datepicker();

	Test.formaProselefsiDOM = $('#formaProselefsi');
	Test.formaApoxorisiDOM = $('#formaApoxorisi');
	Test.formaAdiaDOM = $('#formaAdia');

	Selida.bodyDOM.on('click', '.formaRadio', function(e) {
		e.stopPropagation();
		$(this).children('input').prop('checked', true);
	});

	return Test;
};

Test.formaIpalilosSetup = function () {
	Test.formaIpalilosDOM = $('#formaIpalilos');
	Test.formaOnomaDOM = $('#formaOnoma');

	Test.ipalilosEvretirioSettings = {
		'field': Test.formaOnomaDOM,
		'feeder': Selida.server + 'lib/evretirio/ipalilos',
		'action': Kartel.evretirioIpalilos,
		'limit': 20,
		'rows': 8,
		'page': 4,
		'position': {
			'my': 'left+500 top+50',
		},
		'select': Test.ipalilosSelect,
	};

	Selida.evretirio.fieldSetup(Test.ipalilosEvretirioSettings);

	return Test;
};

Test.ipalilosSelect = function(rowDOM) {
	var kodikosDOM;
	var ipalilos;

	kodikosDOM = rowDOM.children('.evretirioIpalilosKodikos');

	if (kodikosDOM.length !== 1)
	return false;

	ipalilos = kodikosDOM.text();
	Kartel.eventZoom.open({
		'ipalilos': ipalilos,
	});

	return true;
};

///////////////////////////////////////////////////////////////////////////////@

Test.zoomSetup = function () {
	Kartel.eventZoom.create({
		'position': {
			'my': 'right-30 top',
			'at': 'right top',
		},
		'closeOnEscape': false,
	});
	Kartel.eventZoom.excuse.insertSuccess = Test.excuseInsertSuccess;
	return Test;
}

Test.excuseInsertSuccess = function(excuse) {
	Kartel.eventZoom.excuseRefresh(excuse);
	return Test;
};

///////////////////////////////////////////////////////////////////////////////@
