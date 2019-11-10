-- Курсовой проект Селин В.В.
DELIMITER // 
DROP PROCEDURE IF EXISTS create_asu_view //
CREATE  PROCEDURE create_asu_view (IN value VARCHAR(7) CHARSET utf8 )
-- создание представления, с информацией о вхождении площадок в конкретную АСУ
BEGIN
	SET @asuname = value;
	DROP TABLE IF EXISTS tmp_name;
	CREATE TABLE tmp_name (
		id TINYINT UNSIGNED,
		name VARCHAR(7) CHARACTER SET utf8) ;
	INSERT INTO tmp_name VALUES	('1', @asuname);
	CREATE OR REPLACE VIEW sites_asu AS 
	SELECT pip.short_name AS pipe_name, ts.pipeline_km AS pipe_km, ts.id AS site_id
	FROM  asu_systems
	JOIN sites_controlling_systems AS scs ON scs.asu_id = asu_systems.id 
	JOIN technology_sites AS ts ON scs.tech_site_id = ts.id
	JOIN pipelines AS pip ON pip.id = ts.pipeline_id
	WHERE asu_systems.name = (SELECT name FROM tmp_name WHERE id=1);
	

-- создание представления, хранящее информацию по конкретной АСУ
	CREATE OR REPLACE VIEW points_asu AS
	(SELECT sites.pipe_name AS pipe_name, sites.pipe_km, fac.name AS fac_name, objects.name AS object_name,
						tobj.tech_object_index AS object_idx, ctrl_param.name AS param_type,   asp.point_index, asp.name AS parameters_name,
						asp.id AS asp_id
	FROM sites_asu AS sites 
	JOIN technology_facilities AS tf ON tf.tech_site_id = sites.site_id
	JOIN facilities AS fac ON fac.id = tf.facility_id
	JOIN technology_objects AS tobj ON tobj.tech_facility_id = tf.id
	JOIN objects ON objects.id = tobj.object_id
	JOIN objects_control_points AS ocp ON ocp.tech_object_id = tobj.id
	JOIN controlled_parameters AS ctrl_param ON ctrl_param.id = ocp.ctrl_param_id
	JOIN asu_points AS asp ON asp.id = ocp.asu_point_id)
	UNION
	(SELECT sites.pipe_name , sites.pipe_km, fac.name, fac.name, sites.pipe_km, ctrl_param.name, asp.point_index, asp.name, asp.id
	FROM sites_asu AS sites 
	JOIN technology_facilities AS tf ON tf.tech_site_id = sites.site_id
	JOIN facilities AS fac ON fac.id = tf.facility_id
	JOIN facilities_control_points AS fcp ON fcp.tech_facility_id = tf.id
	JOIN controlled_parameters AS ctrl_param ON ctrl_param.id = fcp.ctrl_param_id
	JOIN asu_points AS asp ON asp.id = fcp.asu_point_id)
	 ORDER BY pipe_name, fac_name; 
END //

DROP TRIGGER IF EXISTS insert_history_units//
CREATE TRIGGER insert_history_units BEFORE UPDATE ON installed_units
FOR EACH ROW
BEGIN
	INSERT INTO install_units_history VALUES
		(OLD.unit_id, OLD.asu_point_id, OLD.install_date, NEW.install_date);
END//

DROP TRIGGER IF EXISTS insert_history_units_on_del//
CREATE TRIGGER insert_history_units_on_del BEFORE DELETE ON installed_units
FOR EACH ROW
BEGIN
	INSERT INTO install_units_history VALUES
		(OLD.unit_id, OLD.asu_point_id, OLD.install_date, NOW());
END//

DELIMITER ;



