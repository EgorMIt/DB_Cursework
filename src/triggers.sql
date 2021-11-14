--Триггеры для проверки данных при их добавлении

--Достаточно ли материала на складе для постройки здания
DROP TRIGGER IF EXISTS "ПроверкаМатериала" ON "Стройматериал_Здание";
CREATE TRIGGER ПроверкаМатериала
    AFTER INSERT
    ON "Стройматериал_Здание"
    FOR EACH ROW
EXECUTE PROCEDURE "СравнитьКоличество"();

--Добавление обратной связи при указании факта пересечения улиц
DROP TRIGGER IF EXISTS "ДублироватьУлицу" ON "Улица_Улица";
CREATE TRIGGER ДублироватьУлицу
    AFTER INSERT
    ON "Улица_Улица"
    FOR EACH ROW
EXECUTE PROCEDURE "ДублироватьРеверсУлицу"();

--Добавление обратной связи при указании факта соседства кварталов
DROP TRIGGER IF EXISTS "ДублироватьКвартал" ON "Квартал_Квартал";
CREATE TRIGGER ДублироватьКвартал
    AFTER INSERT
    ON "Квартал_Квартал"
    FOR EACH ROW
EXECUTE PROCEDURE "ДублироватьРеверсКвартал"();

--Проверка на доступность городской службы в районе постройки здания
DROP TRIGGER IF EXISTS "ПроверитьСлужбу" ON "Городская_служба_Здание";
CREATE TRIGGER ПроверитьСлужбу
    AFTER INSERT
    ON "Городская_служба_Здание"
    FOR EACH ROW
EXECUTE PROCEDURE "ПроверитьНаличиеСлужбыВКвартале"();