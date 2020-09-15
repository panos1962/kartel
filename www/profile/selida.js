var Profile = {};

$(window).
ready(function() {
	Profile.ipalilosDOM = $('#ipalilos');
	Profile.passwordDOM = $('#password').focus();
	Profile.password1DOM = $('#password1');
	Profile.password2DOM = $('#password2');
	Profile.submitButtonDOM = $('#submitButton');
	Profile.cancelButtonDOM = $('#cancelButton');

	Profile.
	toolbarSetup().
	formSetup();
});

Profile.toolbarSetup = function() {
	Selida.tabClose();

	return Profile;
};

Profile.formSetup = function() {
	Profile.submitButtonDOM.
	on('click', function(e) {
		var ipalilos;
		var password1;

		ipalilos = parseInt(Profile.ipalilosDOM.val());
		if (!ipalilos) {
			Selida.fyi.epano('Λανθασμένος αρ. μητρώου υπαλλήλου');
			return false;
		}

		password1 = Profile.password1DOM.val();

		if (Profile.password2DOM.val() !== password1) {
			Selida.fyi.epano('Οι δύο κωδικοί διαφέρουν');
			Profile.password1DOM.select();
			return false;
		}

		try {
			Selida.ajax(Selida.server + 'profile/profile', {
				'ipalilos': ipalilos,
				'password': Profile.passwordDOM.val(),
				'password1': password1,
			}).
			done(function(rsp) {
				switch (rsp) {
				case 'OK':
					window.close();
					return;
				case 'AD':
					Selida.fyi.epano('Access denied');
					Profile.passwordDOM.select();
					break;
				case 'NC':
					Selida.fyi.epano('Δεν παρατηρήθηκαν αλλαγές');
					Profile.password1DOM.select();
					break;
				default:
					Selida.fyi.epano(rsp);
					Profile.passwordDOM.select();
					break;
				}
			}).
			fail(function(err) {
				Selida.fyi.epano('Update failed');
				Profile.password1DOM.select();
			});
		} catch(e) {
			Selida.fyi.epano(e.message);
		}

		return false;
	});

	Profile.cancelButtonDOM.
	on('click', function(e) {
		window.close();
	});

	return Profile;
};
