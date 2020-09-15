#!/usr/bin/env awk

function ttymsg(s, nonl) {
	if (!verbose)
	return

	pd_ttymsg(s, nonl)
}
