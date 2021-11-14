--Индексы для ускорения select-запросов

CREATE INDEX Здание_idx ON "Здание" USING hash("Улица_id");

CREATE UNIQUE INDEX Улица_idx ON "Улица_Улица" USING hash("Улица1_id", "Улица2_id");

CREATE UNIQUE INDEX Квартал_idx ON "Квартал_Квартал" USING hash("Квартал1_id","Квартал2_id");

CREATE INDEX Служба_Команды_idx ON "Обслуживающая_команда" USING hash("Служба_id");

CREATE INDEX Квартал_Команды_idx ON "Обслуживающая_команда" USING hash("Квартал_id");

CREATE INDEX Цена_Материала_idx ON "Стройматериал" ("Цена");