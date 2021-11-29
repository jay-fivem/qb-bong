CREATE TABLE `bongs` (
	`id` INT(11) NOT NULL AUTO_INCREMENT,
	`citizenid` VARCHAR(50) NOT NULL COLLATE 'latin1_swedish_ci',
	`tolerance` INT(11) NOT NULL,
	`amount` INT(11) NOT NULL,
	`high` TINYINT(11) NOT NULL,
    `time` int(64) NOT NULL,
	PRIMARY KEY (`id`) USING BTREE,
	UNIQUE INDEX `UNIQUE KEY` (`citizenid`) USING BTREE
)
COLLATE='latin1_swedish_ci'
ENGINE=InnoDB
AUTO_INCREMENT=2
;
