USE `erpota`
;

ALTER TABLE `prosvasi`
ADD COLUMN `tilefono` VARCHAR(30) NOT NULL DEFAULT '' COMMENT 'Τηλέφωνο επικοινωνίας'
;
