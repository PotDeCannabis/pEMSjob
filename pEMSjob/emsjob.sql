INSERT INTO `addon_account` (name, label, shared) VALUES
	('society_ems', 'EMS', 1)
;

INSERT INTO `addon_inventory` (name, label, shared) VALUES
	('society_ems', 'EMS', 1)
;

INSERT INTO `datastore` (name, label, shared) VALUES
	('society_ems', 'EMS', 1)
;

INSERT INTO `job_grades` (`job_name`, `grade`, `name`, `label`, `salary`, `skin_male`, `skin_female`) VALUES
('ems', 0, 'ambulancier', 'Ambulancier', 20, '', ''),
('ems', 1, 'ambulancier_chef', 'Ambulancier-Chef', 20, '', ''),
('ems', 2, 'medecin', 'Medecin', 40, '', ''),
('ems', 3, 'medecin_chef', "Medecin-chef", 60, '', ''),
('ems', 4, 'chef_service', "Chef de service", 60, '', ''),
('ems', 5, 'boss', 'Directeur', 80, '', '');

INSERT INTO `jobs` (name, label) VALUES
	('ems','EMS')
;

INSERT INTO `items` (name, label) VALUES
	('bandage','Bandage'),
	('medikit','Medikit')
;

ALTER TABLE `users`
	ADD `is_dead` TINYINT(1) NULL DEFAULT '0'
;