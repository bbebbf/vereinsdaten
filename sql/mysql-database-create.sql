CREATE TABLE IF NOT EXISTS `person` (
  `person_id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `person_vorname` varchar(100) DEFAULT NULL,
  `person_praeposition` varchar(20) DEFAULT NULL,
  `person_nachname` varchar(100) DEFAULT NULL,
  `person_active` bit(1) NOT NULL,
  `person_birthday` date DEFAULT NULL,
  PRIMARY KEY (`person_id`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE IF NOT EXISTS `clubmembership` (
  `clmb_id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `person_id` int(10) unsigned NOT NULL,
  `clmb_number` int(10) unsigned NOT NULL,
  `clmb_active` bit(1) NOT NULL,
  `clmb_startdate` date DEFAULT NULL,
  `clmb_enddate` date DEFAULT NULL,
  `clmb_enddate_str` varchar(50) DEFAULT NULL,
  `clmb_endreason` text DEFAULT NULL,
  PRIMARY KEY (`clmb_id`) USING BTREE,
  UNIQUE KEY `clmb_number` (`clmb_number`) USING BTREE,
  KEY `FK_clubmembership_person` (`person_id`) USING BTREE,
  CONSTRAINT `FK_clubmembership_person` FOREIGN KEY (`person_id`) REFERENCES `person` (`person_id`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE IF NOT EXISTS `address` (
  `adr_id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `adr_street` varchar(100) NOT NULL,
  `adr_postalcode` varchar(5) NOT NULL,
  `adr_city` varchar(50) NOT NULL,
  PRIMARY KEY (`adr_id`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE IF NOT EXISTS `person_address` (
  `person_id` int(10) unsigned NOT NULL,
  `adr_id` int(10) unsigned NOT NULL,
  PRIMARY KEY (`person_id`) USING BTREE,
  KEY `FK_address` (`adr_id`) USING BTREE,
  CONSTRAINT `FK_address` FOREIGN KEY (`adr_id`) REFERENCES `address` (`adr_id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `FK_person` FOREIGN KEY (`person_id`) REFERENCES `person` (`person_id`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE IF NOT EXISTS `unit` (
  `unit_id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `unit_name` varchar(200) NOT NULL,
  `unit_active` bit(1) NOT NULL,
  `unit_active_since` date DEFAULT NULL,
  `unit_active_until` date DEFAULT NULL,
  `unit_data_confirmed_on` date DEFAULT NULL,
  PRIMARY KEY (`unit_id`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE IF NOT EXISTS `role` (
  `role_id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `role_name` varchar(50) NOT NULL,
  `role_sorting` tinyint(3) unsigned NOT NULL DEFAULT 0,
  PRIMARY KEY (`role_id`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE IF NOT EXISTS `member` (
  `mb_id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `person_id` int(10) unsigned NOT NULL,
  `unit_id` int(10) unsigned NOT NULL,
  `role_id` int(10) unsigned DEFAULT NULL,
  `mb_active` bit(1) NOT NULL,
  `mb_active_since` date DEFAULT NULL,
  `mb_active_until` date DEFAULT NULL,
  PRIMARY KEY (`mb_id`) USING BTREE,
  KEY `FK_member_unit` (`unit_id`) USING BTREE,
  KEY `FK_member_role` (`role_id`) USING BTREE,
  KEY `IDX_person_unit` (`person_id`,`unit_id`,`mb_active`) USING BTREE,
  CONSTRAINT `FK_member_person` FOREIGN KEY (`person_id`) REFERENCES `person` (`person_id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `FK_member_role` FOREIGN KEY (`role_id`) REFERENCES `role` (`role_id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `FK_member_unit` FOREIGN KEY (`unit_id`) REFERENCES `unit` (`unit_id`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE IF NOT EXISTS `tenant` (
  `ten_id` tinyint(3) unsigned NOT NULL,
  `ten_title` varchar(150) NOT NULL,
  PRIMARY KEY (`ten_id`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE IF NOT EXISTS `version_info` (
  `versioninfo_id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `versioninfo_entity` tinyint(3) unsigned NOT NULL,
  `versioninfo_number` int(10) unsigned NOT NULL,
  `versioninfo_lastupdated_utc` datetime NOT NULL,
  `person_id` int(10) unsigned DEFAULT NULL,
  `unit_id` int(10) unsigned DEFAULT NULL,
  `adr_id` int(10) unsigned DEFAULT NULL,
  PRIMARY KEY (`versioninfo_id`),
  UNIQUE KEY `UIDX_person_id` (`versioninfo_entity`,`person_id`),
  UNIQUE KEY `UIDX_unit_id` (`versioninfo_entity`,`unit_id`),
  UNIQUE KEY `UIDX_adr_id` (`versioninfo_entity`,`adr_id`),
  KEY `FK_version_info_person` (`person_id`),
  KEY `FK_version_info_unit` (`unit_id`),
  KEY `FK_version_info_address` (`adr_id`),
  CONSTRAINT `FK_version_info_address` FOREIGN KEY (`adr_id`) REFERENCES `address` (`adr_id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `FK_version_info_person` FOREIGN KEY (`person_id`) REFERENCES `person` (`person_id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `FK_version_info_unit` FOREIGN KEY (`unit_id`) REFERENCES `unit` (`unit_id`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;




CREATE ALGORITHM=UNDEFINED SQL SECURITY DEFINER VIEW `vw_person_name` AS select `person`.`person_id` AS `person_id`,concat_ws(', ',`person`.`person_nachname`,concat_ws(' ',`person`.`person_vorname`,`person`.`person_praeposition`)) AS `person_name` from `person`;

CREATE ALGORITHM=UNDEFINED SQL SECURITY DEFINER VIEW `vw_select_address` AS select `a`.`adr_id` AS `adr_id`,concat_ws(', ',`a`.`adr_street`,concat_ws(' ',`a`.`adr_postalcode`,`a`.`adr_city`)) AS `address_title` from `address` `a`;

CREATE ALGORITHM=UNDEFINED SQL SECURITY DEFINER VIEW `vw_active_person` AS select `pn`.`person_id` AS `person_id`,`pn`.`person_name` AS `person_name` from (`vw_person_name` `pn` join `person` `p` on(`p`.`person_id` = `pn`.`person_id`)) where `p`.`person_active` = 1;

CREATE ALGORITHM=UNDEFINED SQL SECURITY DEFINER VIEW `vw_active_unit_member` AS select `u`.`unit_id` AS `unit_id`,`u`.`unit_active_since` AS `unit_active_since`,`m`.`mb_id` AS `mb_id`,`m`.`person_id` AS `person_id`,`m`.`role_id` AS `role_id`,`m`.`mb_active_since` AS `mb_active_since` from (`unit` `u` join `member` `m` on(`m`.`unit_id` = `u`.`unit_id` and `m`.`mb_active` = 1)) where `u`.`unit_active` = 1;

CREATE ALGORITHM=UNDEFINED SQL SECURITY DEFINER VIEW `vw_active_unit_roles` AS select `m`.`mb_id` AS `mb_id`,`u`.`unit_id` AS `unit_id`,`u`.`unit_name` AS `unit_name`,`r`.`role_id` AS `role_id`,`r`.`role_name` AS `role_name`,`r`.`role_sorting` AS `role_sorting`,`p`.`person_id` AS `person_id`,`p`.`person_name` AS `person_name` from (((`unit` `u` join `vw_active_unit_member` `m` on(`m`.`unit_id` = `u`.`unit_id`)) join `role` `r` on(`r`.`role_id` = `m`.`role_id`)) join `vw_person_name` `p` on(`p`.`person_id` = `m`.`person_id`)) where `u`.`unit_active` = 1;
