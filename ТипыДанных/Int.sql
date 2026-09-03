-- заводим переменную
DECLARE @num TINYINT
-- устанавливаем значение
SET @num = 100
-- выводим переменную в столбец number
SELECT @num AS number
-- одно значение (True/False -> 1/0)
DECLARE @bit bit = 1;
SELECT @bit AS Flag