-- ������ ��������� 2-1

drop database if exists equip2;
create DATABASE equip2;
use equip2;

-- ������������ �������������
CREATE TABLE pipelines  (
	id TINYINT UNSIGNED NOT NULL UNIQUE PRIMARY KEY,
	full_name VARCHAR(100) NOT NULL UNIQUE,
	short_name VARCHAR(7) NOT NULL UNIQUE,
	`length` SMALLINT NOT NULL COMMENT '����� ����� ������������'
) DEFAULT CHARSET=utf8;


-- ���������, �� ������� ����������� ��������������� �������� �� �������������
CREATE TABLE technology_sites (
	id SMALLINT UNSIGNED NOT NULL UNIQUE PRIMARY KEY,
	pipeline_id TINYINT UNSIGNED NOT NULL,
	pipeline_km SMALLINT UNSIGNED,
	FOREIGN KEY (pipeline_id) REFERENCES pipelines(id)
) DEFAULT CHARSET=utf8;
/* ���� �� ������������ - ��� ��������������-�������������� ���������
-- �������� ����
CREATE TABLE lpdses (
	id SMALLINT UNSIGNED NOT NULL UNIQUE PRIMARY KEY,
	name VARCHAR(50) NOT NULL UNIQUE
) DEFAULT CHARSET=utf8;
-- ��������, �������� � ������ ����
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

-- ������� ��� ��
CREATE TABLE asu_systems (
	id SMALLINT UNSIGNED NOT NULL UNIQUE PRIMARY KEY,
	name VARCHAR(50) NOT NULL COMMENT '�������� ������ ��� ��',
	full_name VARCHAR(150)
) DEFAULT CHARSET=utf8;
-- ����������� ����������� ����� ������ ���
CREATE TABLE asu_points (
	id SERIAL PRIMARY KEY,
	asu_id SMALLINT UNSIGNED NOT NULL,
	point_index VARCHAR (15) COMMENT '����������� ����������� �������',
	name VARCHAR(150),
	INDEX (asu_id, point_index),
	FOREIGN KEY (asu_id) REFERENCES asu_systems(id)
) DEFAULT CHARSET=utf8;

-- ����� ����� ���������� � ��������� �����, ������� �� ������������
CREATE TABLE sites_controlling_systems (
	asu_id SMALLINT UNSIGNED NOT NULL,
	tech_site_id SMALLINT UNSIGNED NOT NULL,
	PRIMARY KEY (asu_id, tech_site_id),
	FOREIGN KEY (tech_site_id) REFERENCES technology_sites(id),
	FOREIGN KEY (asu_id) REFERENCES asu_systems(id) 
)DEFAULT CHARSET=utf8;

-- ���� ��������������� ���������� �� ���������
CREATE TABLE facilities (
	id SMALLINT UNSIGNED NOT NULL UNIQUE PRIMARY KEY,
	name VARCHAR(50) NOT NULL COMMENT '�������� �������� �� ��������� - ���. ��, 
		�������� ���. ���������. ��������� �����������. ����, ����-���� ���,',
	full_name VARCHAR(150) COMMENT '���� ����������, �� ����������� ����������� ������������'
) DEFAULT CHARSET=utf8;
-- ��������������� ���������� �� ��������� ���������
CREATE TABLE technology_facilities (
	id MEDIUMINT UNSIGNED NOT NULL UNIQUE PRIMARY KEY,
	tech_site_id SMALLINT UNSIGNED NOT NULL,
	facility_id SMALLINT UNSIGNED NOT NULL,
	FOREIGN KEY (tech_site_id) REFERENCES technology_sites(id),
	FOREIGN KEY (facility_id) REFERENCES facilities(id)
) DEFAULT CHARSET=utf8;

-- ���� ��������������� ��������
CREATE TABLE objects (
	id SMALLINT UNSIGNED NOT NULL UNIQUE PRIMARY KEY,
	name VARCHAR(50) NOT NULL COMMENT '�������� �������� - ���, ��������, �������, ������..',
	full_name VARCHAR(150)
) DEFAULT CHARSET=utf8;
-- ��������������� ������� �� ����������� ��������
CREATE TABLE technology_objects (
	id INT UNSIGNED NOT NULL UNIQUE PRIMARY KEY,
	tech_facility_id MEDIUMINT UNSIGNED NOT NULL,
	object_id SMALLINT UNSIGNED NOT NULL,
	tech_object_index VARCHAR(20) NOT NULL COMMENT '������/������� �������� �� ���������� �������� - 
		�������� �143,	��� �1, ������� �� ��������',	
	FOREIGN KEY (tech_facility_id) REFERENCES technology_facilities(id),
	FOREIGN KEY (object_id) REFERENCES objects(id)
) DEFAULT CHARSET=utf8;

-- ������ ����������, ������� ���������� ��������������
CREATE TABLE controlled_parameters (
	id SMALLINT UNSIGNED NOT NULL UNIQUE PRIMARY KEY,
	name VARCHAR(50) CHARACTER SET utf8 NOT NULL COMMENT '�������� ����������, �������������� ��� �� - 
		��������, �����������, ���������, ����������, ��������, ��������, ��������...'
) DEFAULT CHARSET=utf8;
-- ����� �������� ���������� �� ��������������� ��������
CREATE TABLE objects_control_points (
	id BIGINT UNSIGNED NOT NULL UNIQUE PRIMARY KEY,
	tech_object_id INT UNSIGNED NOT NULL,
	ctrl_param_id SMALLINT UNSIGNED NOT NULL,
	asu_point_id BIGINT UNSIGNED NOT NULL,
	FOREIGN KEY (tech_object_id) REFERENCES technology_objects(id),
	FOREIGN KEY (ctrl_param_id) REFERENCES controlled_parameters(id),
	FOREIGN KEY (asu_point_id) REFERENCES asu_points(id)
) DEFAULT CHARSET=utf8;
-- ����� �������� ���������� ���������� (����������, �������������� � �.�.)
CREATE TABLE facilities_control_points (
	id INT UNSIGNED NOT NULL UNIQUE PRIMARY KEY,
	tech_facility_id MEDIUMINT UNSIGNED NOT NULL,
	ctrl_param_id SMALLINT UNSIGNED NOT NULL,
	asu_point_id BIGINT UNSIGNED NOT NULL,
	FOREIGN KEY (tech_facility_id) REFERENCES technology_facilities(id),
	FOREIGN KEY (ctrl_param_id) REFERENCES controlled_parameters(id),
	FOREIGN KEY (asu_point_id) REFERENCES asu_points(id) 
) DEFAULT CHARSET=utf8;


-- ������� ��� - �������-��������, ��� ����� �������� �/� ���� ����� ������,
-- ������� �������� � ������ �������
CREATE TABLE units (
	id SERIAL PRIMARY KEY,
	name VARCHAR(50) NOT NULL COMMENT '���������� ������� - ������������ ������, �����������
		��������, ��������, ��������������� ��������...'
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

