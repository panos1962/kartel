var Isodos = {};

Selida.init = function() {
	Isodos.ipalilosDOM = $('#ipalilos');
	Isodos.passwordDOM = $('#password');
	Isodos.submitButtonDOM = $('#submitButton');
	Isodos.cancelButtonDOM = $('#cancelButton');
	Isodos.forgotButtonDOM = $('#forgotButton');

	Isodos.
	toolbarSetup().
	formSetup().
	dataSetup();
};

Isodos.dataSetup = function() {
	var ipalilos;

	ipalilos = Isodos.ipalilosGet();
	if (!ipalilos)
	return false;

	$('.krifo').
	removeClass('krifo');

	Isodos.passwordDOM.focus();

	return Isodos;
};

Isodos.toolbarSetup = function() {
	Selida.tabHome();

	return Isodos;
};

Isodos.formSetup = function() {
	Isodos.submitButtonDOM.
	on('click', function(e) {
		var ipalilos;

		e.stopPropagation();

		ipalilos = Isodos.ipalilosGet();
		if (!ipalilos)
		return false;

		Selida.ajax(Selida.server + 'isodos/isodos', {
			'ipalilos': ipalilos,
			'password': Isodos.passwordDOM.val(),
		}).
		done(function(rsp) {
			if (Selida.ajxrspok(rsp))
			self.location = Selida.url(Selida.queryString);

			else
			Selida.fyi.epano('Access denied');
		}).
		fail(function(err) {
			Selida.fyi.epano('Access failed');
		});

		return false;
	});

	Isodos.cancelButtonDOM.
	on('click', function(e) {
		e.stopPropagation();
		self.location = Selida.server;
	});

	Isodos.forgotButtonDOM.
	on('click', function(e) {
		var ipalilos;

		e.stopPropagation();

		ipalilos = Isodos.ipalilosGet();

		if (!ipalilos)
		return false;

		Selida.ajax(Selida.server + 'isodos/forgot', {
			'ipalilos': ipalilos,
		}).
		done(function(rsp) {
			if (!Selida.ajxrspok(rsp))
			return Selida.fyi.epano(rsp);

			Selida.fyi.pano('Έχει αποσταλεί <a target="webmail" ' +
				'href="' + Selida.defineTag['WEBMAIL'] +
				'">email</a> με τον νέο σας μυστικό κωδικό');
		}).
		fail(function(err) {
			Selida.fyi.epano('Δεν απεστάλη νέος μυστικός κωδικός');
		});
	});

	return Isodos;
};

Isodos.ipalilosGet = function() {
	var ipalilos;

	ipalilos = Isodos.ipalilosDOM.val();

	if ($.isNumeric(ipalilos))
	return parseInt(ipalilos);

	Selida.fyi.epano('Ακαθόριστος αρ. μητρώου υπαλλήλου', 'right');
	return false;
};
