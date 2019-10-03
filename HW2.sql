-- Селин Владимир
-- Практическое задание по теме "Операторы, фильтрация, сортировка и ограничение"

DROP TABLE IF EXISTS users;
CREATE TABLE users (
  id SERIAL PRIMARY KEY,
  name VARCHAR(255) COMMENT 'Имя покупателя',
  birthday_at DATE COMMENT 'Дата рождения',
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) COMMENT = 'Покупатели';

INSERT INTO users (name, birthday_at,created_at, updated_at) VALUES
  ('Геннадий', '1990-10-05','1990-10-05','1990-10-05'),
  ('Наталья', '1984-11-12','1990-10-05','1990-10-05'),
  ('Александр', '1985-05-20','1990-10-05','1990-10-05'),
  ('Сергей', '1988-02-14','1990-10-05','1990-10-05'),
  ('Иван', '1998-01-12','1990-10-05','1990-10-05'),
  ('Мария', '1992-08-29','1990-10-05','1990-10-05');
 
SELECT created_at AS old_val_created, updated_at AS old_val_upd FROM users;

UPDATE users SET created_at=NOW(), updated_at=NOW(); -- обновление даты и времени

SELECT created_at, updated_at FROM users;
-- --------------------------------------------------------------------------------------------------------
DROP TABLE IF EXISTS userok ;
CREATE TABLE userok (
	name VARCHAR(50),
	created_at VARCHAR(20),
	updated_at VARCHAR(20)
);

INSERT INTO userok (name, created_at, updated_at) VALUES
	('Петя Иванов','06.10.1977 8:50', '06.05.2077 8:50'),
	('Ваня Петров','31.08.2005 18:30', '08.11.2007 8:50'),
	('Сидор Кузнецов','15.01.1987 12:42', '06.10.1997 8:50');
		

SELECT * FROM userok; -- старые данные
ALTER TABLE userok ADD COLUMN 
	(created_at_new DATETIME, updated_at_new DATETIME); -- добавляем новые поля для записи даты в верном формате
UPDATE userok SET 
	created_at_new = STR_TO_DATE(created_at, '%d.%m.%Y %H:%i'), -- преобразуем дату из текстового формата
	updated_at_new = STR_TO_DATE(updated_at, '%d.%m.%Y %H:%i'); -- в DATETIME и сохраняем в новых полях
ALTER TABLE userok DROP COLUMN created_at; -- приводим таблицу к изначальному виду
ALTER TABLE userok DROP COLUMN updated_at;
ALTER TABLE userok CHANGE COLUMN created_at_new created_at DATETIME;
ALTER TABLE userok CHANGE COLUMN updated_at_new updated_at DATETIME;
SELECT * FROM userok; -- данные в новом формате
-- -----------------------------------------------------------------------------------------------------

DROP TABLE IF EXISTS storehouses_products;
CREATE TABLE storehouses_products (
  id SERIAL PRIMARY KEY,
  product VARCHAR(50),
  value INT UNSIGNED COMMENT 'Запас товарной позиции на складе'
) COMMENT = 'Запасы на складе';

INSERT INTO storehouses_products (product, value) VALUES
	('Болт М6','50'),
	('Гайка М12','500'),
	('Задвижка ДУ 50','5'),
	('То без чего не обойтись','0'),
	('Клапан обратный','23'),
	('Прокладка под фланец ДУ100','10'),
	('Насос циркуляционный','1'),
	('Спирт 1 л','150'),
	('Фланец ДУ 50','10'),
	('Фланец ДУ 100','5'),
	('Ключ гаечный 10','0'),
	('То чего не может быть','25');

SELECT product, value FROM storehouses_products ORDER BY value DESC; -- отсортированный вывод
	
	
