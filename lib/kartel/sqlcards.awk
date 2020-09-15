#!/usr/bin/env awk

BEGIN {
	FS = ","
	header = "\t\tAND LTRIM([WIN-PAK PRO].[dbo].[Card].[CardNumber]) IN (\n\t\t\t'"
	footer = ""
}

{
	printf header $1
}

{
	for (i = 2; i <= NF; i++)
	printf "',\n\t\t\t'" $i
}

NR == 1 {
	header = "\n\t\t\t\t'"
	footer = "'\n\t\t)"
}

END {
	if (NR)
	print footer
}
