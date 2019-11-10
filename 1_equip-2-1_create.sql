-- версия структуры 2-1

drop database if exists equip2;
create DATABASE equip2;
use equip2;

-- наименование трубопроводов
CREATE TABLE pipelines  (
	id TINYINT UNSIGNED NOT NULL UNIQUE PRIMARY KEY,
	full_name VARCHAR(100) NOT NULL UNIQUE,
	short_name VARCHAR(7) NOT NULL UNIQUE,
	`length` SMALLINT NOT NULL COMMENT 'Общая длина трубопровода'
) DEFAULT CHARSET=utf8;


-- километры, на которых расположены технологические площадки на трубопроводах
CREATE TABLE technology_sites (
	id SMALLINT UNSIGNED NOT NULL UNIQUE PRIMARY KEY,
	pipeline_id TINYINT UNSIGNED NOT NULL,
	pipeline_km SMALLINT UNSIGNED,
	FOREIGN KEY (pipeline_id) REFERENCES pipelines(id)
) DEFAULT CHARSET=utf8;
/* ПОКА НЕ ИСПОЛЬЗУЕТСЯ - для организационно-управленческой структуры
-- названия ЛПДС
CREATE TABLE lpdses (
	id SMALLINT UNSIGNED NOT NULL UNIQUE PRIMARY KEY,
	name VARCHAR(50) NOT NULL UNIQUE
) DEFAULT CHARSET=utf8;
-- площадки, входящие в состав ЛПДС
CREATE TABLE lpdses_composition(
	lpds_id SMALLINT UNSIGNED NOT NULL,
	tech_site_id SMALLINT UNSIGNED NOT NULL,
	PRIMARY KEY (lpds_id, tech_site_id),
	FOREIGN KEY (lpds_id) REFERENCES lpdses(id) 
		ON UPDATE CASCADE ON DELETE RESTRICT,
	FOREIGN KEY (tech_site_id) REFERENCES technology_sites(id) 
		ON UPDATE CASCADE ON DELETE RESTRICT
) DEFAULT CHARSET=utf8;
*/

-- системы АСУ ТП
CREATE TABLE asu_systems (
	id SMALLINT UNSIGNED NOT NULL UNIQUE PRIMARY KEY,
	name VARCHAR(50) NOT NULL COMMENT 'Названия систем АСУ ТП',
	full_name VARCHAR(150)
) DEFAULT CHARSET=utf8;
-- обознаяения контрольных точек систем АСУ
CREATE TABLE asu_points (
	id SERIAL PRIMARY KEY,
	asu_id SMALLINT UNSIGNED NOT NULL,
	point_index VARCHAR (15) COMMENT 'Позиционное обозначение прибора',
	name VARCHAR(150),
	INDEX (asu_id, point_index),
	FOREIGN KEY (asu_id) REFERENCES asu_systems(id)
) DEFAULT CHARSET=utf8;

-- связь между площадками и системами АСУТП, которые их контролируют
CREATE TABLE sites_controlling_systems (
	asu_id SMALLINT UNSIGNED NOT NULL,
	tech_site_id SMALLINT UNSIGNED NOT NULL,
	PRIMARY KEY (asu_id, tech_site_id),
	FOREIGN KEY (tech_site_id) REFERENCES technology_sites(id),
	FOREIGN KEY (asu_id) REFERENCES asu_systems(id) 
)DEFAULT CHARSET=utf8;

-- виды технологических сооружений на площадках
CREATE TABLE facilities (
	id SMALLINT UNSIGNED NOT NULL UNIQUE PRIMARY KEY,
	name VARCHAR(50) NOT NULL COMMENT 'Названия объектов на площадках - УЗА. ОУ, 
		площадка ФГУ. маслоблок. помещение вспомсистем. СИКН, блок-бокс ПКУ,',
	full_name VARCHAR(150) COMMENT 'Если необходимо, то указывается расшифровка аббревиатуры'
) DEFAULT CHARSET=utf8;
-- технологические сооружения на имеющихся площадках
CREATE TABLE technology_facilities (
	id MEDIUMINT UNSIGNED NOT NULL UNIQUE PRIMARY KEY,
	tech_site_id SMALLINT UNSIGNED NOT NULL,
	facility_id SMALLINT UNSIGNED NOT NULL,
	FOREIGN KEY (tech_site_id) REFERENCES technology_sites(id),
	FOREIGN KEY (facility_id) REFERENCES facilities(id)
) DEFAULT CHARSET=utf8;

-- виды технологических объектов
CREATE TABLE objects (
	id SMALLINT UNSIGNED NOT NULL UNIQUE PRIMARY KEY,
	name VARCHAR(50) NOT NULL COMMENT 'Названия объектов - МНА, задвижка, колодец, фильтр..',
	full_name VARCHAR(150)
) DEFAULT CHARSET=utf8;
-- технологические объекты на конткретной площадке
CREATE TABLE technology_objects (
	id INT UNSIGNED NOT NULL UNIQUE PRIMARY KEY,
	tech_facility_id MEDIUMINT UNSIGNED NOT NULL,
	object_id SMALLINT UNSIGNED NOT NULL,
	tech_object_index VARCHAR(20) NOT NULL COMMENT 'Номера/индексы объектов на конкретной площадке - 
		задвижка №143,	МНА №1, колодец до задвижки',	
	FOREIGN KEY (tech_facility_id) REFERENCES technology_facilities(id),
	FOREIGN KEY (object_id) REFERENCES objects(id)
) DEFAULT CHARSET=utf8;

-- список параметров, которые необходимо контролировать
CREATE TABLE controlled_parameters (
	id SMALLINT UNSIGNED NOT NULL UNIQUE PRIMARY KEY,
	name VARCHAR(50) CHARACTER SET utf8 NOT NULL COMMENT 'Названия параметров, контролируемых АСУ ТП - 
		вибрация, температура, положение, затопление, открытие, смещение, давление...'
) DEFAULT CHARSET=utf8;
-- точки контроля параметров на технологических объектах
CREATE TABLE objects_control_points (
	id BIGINT UNSIGNED NOT NULL UNIQUE PRIMARY KEY,
	tech_object_id INT UNSIGNED NOT NULL,
	ctrl_param_id SMALLINT UNSIGNED NOT NULL,
	asu_point_id BIGINT UNSIGNED NOT NULL,
	FOREIGN KEY (tech_object_id) REFERENCES technology_objects(id),
	FOREIGN KEY (ctrl_param_id) REFERENCES controlled_parameters(id),
	FOREIGN KEY (asu_point_id) REFERENCES asu_points(id)
) DEFAULT CHARSET=utf8;
-- точки контроля параметров сооружений (затопление, загазованность и т.п.)
CREATE TABLE facilities_control_points (
	id INT UNSIGNED NOT NULL UNIQUE PRIMARY KEY,
	tech_facility_id MEDIUMINT UNSIGNED NOT NULL,
	ctrl_param_id SMALLINT UNSIGNED NOT NULL,
	asu_point_id BIGINT UNSIGNED NOT NULL,
	FOREIGN KEY (tech_facility_id) REFERENCES technology_facilities(id),
	FOREIGN KEY (ctrl_param_id) REFERENCES controlled_parameters(id),
	FOREIGN KEY (asu_point_id) REFERENCES asu_points(id) 
) DEFAULT CHARSET=utf8;


-- приборы КИП - таблица-зашлушка, для учета приборов д/б свой набор таблиц,
-- который сводится к данной таблице
CREATE TABLE units (
	id SERIAL PRIMARY KEY,
	name VARCHAR(50) NOT NULL COMMENT 'Назначение прибора - сигнализатор уровня, выключатель
		концевой, манометр, преобразователь давления...'
) DEFAULT CHARSET=utf8;

CREATE TABLE installed_units (
	unit_id BIGINT UNSIGNED NOT NULL,
	asu_point_id BIGINT UNSIGNED NOT NULL,
	install_date DATE NOT NULL,
	PRIMARY KEY (unit_id, asu_point_id, install_date),
	FOREIGN KEY (unit_id) REFERENCES units(id) ,
	FOREIGN KEY (asu_point_id) REFERENCES asu_points(id) 
) DEFAULT CHARSET=utf8;

CREATE TABLE install_units_history (
	unit_id BIGINT UNSIGNED NOT NULL,
	asu_point_id BIGINT UNSIGNED NOT NULL,
	install_date DATE NOT NULL,
	deinstall_date DATE NOT NULL,
	INDEX (unit_id),
	INDEX (asu_point_id)
);

