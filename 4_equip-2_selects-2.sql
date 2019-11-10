use equip2;

-- выборка всех имеющихся технологических площадок
SELECT short_name, ts.pipeline_km 
FROM pipelines AS pip   
JOIN technology_sites AS ts ON pip.id=ts.pipeline_id
ORDER BY short_name
;
-- выборка имеющихся технологических площадок на конкретном трубопроводе
SET @pipename = 'ХК';
SELECT short_name, ts.pipeline_km 
FROM pipelines AS pip   
JOIN technology_sites AS ts ON pip.id=ts.pipeline_id
WHERE short_name=@pipename
;
-- подсчет количества имеющихся технологических площадок на каждой трубе
SELECT short_name, COUNT(short_name) 
FROM pipelines AS pip   
JOIN technology_sites AS ts ON pip.id=ts.pipeline_id
GROUP BY short_name
ORDER BY short_name
;
-- выборка контролируемых технологических объектов
SELECT pip.short_name AS 'Нефтепровод', ts.pipeline_km AS 'Километр', fac.full_name AS 'Узел', 
				obj.name AS Технологический_объект, tobj.tech_object_index AS 'Номер объекта'
FROM pipelines AS pip, technology_sites AS ts, facilities AS fac, technology_facilities AS tfac,
			objects AS obj, technology_objects AS tobj 
WHERE pip.id=ts.pipeline_id
			AND ts.id=tfac.tech_site_id
			AND fac.id=tfac.facility_id
			AND tfac.id=tobj.tech_facility_id
			AND obj.id=tobj.object_id
ORDER BY pip.short_name, ts.pipeline_km, fac.full_name, tobj.tech_object_index
;
-- выборка всех точек контроля в сооружениях
SELECT pip.full_name, ts.pipeline_km, facilities.name, cp.name     
FROM controlled_parameters AS cp
	JOIN facilities_control_points AS fcp ON fcp.ctrl_param_id=cp.id
 	JOIN technology_facilities AS tf ON tf.id=fcp.tech_facility_id
 	JOIN facilities ON tf.facility_id=facilities.id 
 	JOIN technology_sites AS ts ON tf.tech_site_id=ts.id 
 	JOIN pipelines AS pip ON ts.pipeline_id=pip.id
;
-- выборка точек контроля в конкретном виде сооружений
SELECT pip.full_name, ts.pipeline_km, facilities.name, cp.name     
FROM controlled_parameters AS cp
	JOIN facilities_control_points AS fcp ON fcp.ctrl_param_id=cp.id
 	JOIN technology_facilities AS tf ON tf.id=fcp.tech_facility_id
 	JOIN facilities ON tf.facility_id=facilities.id 
 	JOIN technology_sites AS ts ON tf.tech_site_id=ts.id
 	JOIN pipelines AS pip ON ts.pipeline_id=pip.id
WHERE facilities.name LIKE '%ПКУ%'
;


-- создание представлений точек контроля по разным АСУ с помощью хранимой процедуры
SET @asuname = 'СП 592';
CALL create_asu_view (@asuname);
SELECT * FROM points_asu;

-- подсчет точек контроля каждого вида параметра в конкретной АСУ
SELECT  param_type, COUNT(*) AS Количество FROM points_asu
GROUP BY param_type
ORDER BY Количество DESC;

-- выборка точек контроля заложенных в АСУ, но не реализованных на оборудовании
SELECT asp.point_index, name
FROM asu_points AS asp
WHERE asu_id = (SELECT id FROM asu_systems WHERE name = @asuname)
	AND point_index NOT IN (SELECT points_asu.point_index FROM points_asu);

-- выборка приборов установленных в АСУ
SELECT object_name, object_idx, points_asu.point_index, parameters_name , units.name, inun.install_date
FROM points_asu
JOIN installed_units AS inun ON inun.asu_point_id = points_asu.asp_id
JOIN units ON inun.unit_id=units.id AND inun.deinstall_date IS NULL
-- ORDER BY parameters_name
;
-- выборка ни где не установленных приборов
SELECT name FROM units WHERE id NOT IN (SELECT unit_id FROM installed_units);


-- работа триггера обновления таблицы installed_units
UPDATE installed_units SET unit_id = '24', asu_point_id = '36',install_date = NOW()
WHERE asu_point_id = '36';

SELECT * FROM install_units_history;

-- удаление из таблицы install_units_history записей старше трех лет
DELETE FROM install_units_history WHERE deinstall_date< NOW() - INTERVAL 3 YEAR;;





/* без использования представления с выборкой площадок по АСУ
-- создание представления, хранящее информацию по конкретной АСУ
CREATE OR REPLACE VIEW points_590 AS
(SELECT pip.short_name AS pipeline, ts.pipeline_km, fac.name AS fac_name, objects.name AS object_name,
					tobj.tech_object_index AS object_idx, ctrl_param.name AS param_type,   asp.point_index, asp.name AS parameters_name,
					asp.id AS asp_id
FROM pipelines AS pip, technology_sites AS ts 
JOIN technology_facilities AS tf ON tf.tech_site_id = ts.id
JOIN facilities AS fac ON fac.id = tf.facility_id
JOIN technology_objects AS tobj ON tobj.tech_facility_id = tf.id
JOIN objects ON objects.id = tobj.object_id
JOIN objects_control_points AS ocp ON ocp.tech_object_id = tobj.id
JOIN controlled_parameters AS ctrl_param ON ctrl_param.id = ocp.ctrl_param_id
JOIN asu_points AS asp ON asp.id = ocp.asu_point_id
WHERE ts.id IN (SELECT tech_site_id FROM sites_controlling_systems WHERE asu_id=
										(SELECT id FROM asu_systems WHERE name = 'СП 590'))
			AND pip.id = ts.pipeline_id)
UNION
(SELECT pip.short_name , ts.pipeline_km, fac.name, fac.name, ts.pipeline_km, ctrl_param.name, asp.point_index, asp.name, asp.id
FROM pipelines AS pip, technology_sites AS ts 
JOIN technology_facilities AS tf ON tf.tech_site_id = ts.id
JOIN facilities AS fac ON fac.id = tf.facility_id
JOIN facilities_control_points AS fcp ON fcp.tech_facility_id = tf.id
JOIN controlled_parameters AS ctrl_param ON ctrl_param.id = fcp.ctrl_param_id
JOIN asu_points AS asp ON asp.id = fcp.asu_point_id
WHERE ts.id IN (SELECT tech_site_id FROM sites_controlling_systems WHERE asu_id=
										(SELECT id FROM asu_systems WHERE name = 'СП 590'))
			AND pip.id = ts.pipeline_id)
 ORDER BY pipeline, fac_name
;
*/



