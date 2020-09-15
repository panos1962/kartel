var Welcome = {};

$(window).
ready(function() {
	Welcome.
	toolbarSetup();
});

Welcome.toolbarSetup = function() {
	Selida.
	tabIsodosExodos();

	if (Selida.isIpalilos())
	Selida.
	tabHome();

	return Welcome;
};
