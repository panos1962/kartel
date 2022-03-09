ALTER VIEW `karta` AS

SELECT
`ipalilos`.`kodikos` AS `ipalilos`,
`ipalilos`.`eponimo`,
`ipalilos`.`onoma`,
`ipalilos`.`patronimo`,
`ipalilos`.`genisi`,
`ipalilos`.`premail`,
`ipalilos`.`ipemail`,
`metavoli`.`efarmogi`,
`metavoli`.`idos`,
`metavoli`.`lixi`,
`metavoli`.`timi` AS `karta`

FROM `ipalilos`
LEFT JOIN `metavoli`

ON
`metavoli`.`ipalilos` = `ipalilos`.`kodikos`

WHERE
(`idos` = 'ΚΑΡΤΑ')

ORDER BY
`ipalilos`.`kodikos`,
`metavoli`.`efarmogi`,
`metavoli`.`lixi`
;
