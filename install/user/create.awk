#!/usr/bin/env awk

BEGIN {
	FS = ":"
	ret = 1
}

$1 == user {
	ret = 0
	exit(0)
}

END {
	exit(ret)
}
