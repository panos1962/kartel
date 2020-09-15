CONNECT `erpota1`
;

ALTER TABLE `metavoli` CHANGE `idos`
`idos` ENUM(
	'ΔΙΕΥΘΥΝΣΗ',
	'ΤΜΗΜΑ',
	'ΓΡΑΦΕΙΟ',
	'ΚΑΡΤΑ',
	'ΩΡΑΡΙΟ'
) NOT NULL COMMENT 'Είδος μεταβολής';
