--Объявление всех таблиц БД

--Кварталы
CREATE TABLE Квартал
(
    ID       SERIAL PRIMARY KEY,
    Название TEXT NOT NULL
);

--Соседние кварталы
CREATE TABLE Квартал_Квартал
(
    ID          SERIAL PRIMARY KEY,
    Квартал1_ID INTEGER REFERENCES Квартал ON DELETE CASCADE ON UPDATE CASCADE NOT NULL,
    Квартал2_ID INTEGER REFERENCES Квартал ON DELETE CASCADE ON UPDATE CASCADE NOT NULL check (Квартал2_ID != Квартал1_ID)
);

--Улицы
CREATE TABLE Улица
(
    ID         SERIAL PRIMARY KEY,
    Имя        TEXT                                                           NOT NULL,
    Квартал_ID INTEGER REFERENCES Квартал ON DELETE CASCADE ON UPDATE CASCADE NOT NULL
);

--Пересекающиеся улицы
CREATE TABLE Улица_Улица
(
    ID        SERIAL PRIMARY KEY,
    Улица1_ID INTEGER REFERENCES Улица ON DELETE CASCADE ON UPDATE CASCADE NOT NULL,
    Улица2_ID INTEGER REFERENCES Улица ON DELETE CASCADE ON UPDATE CASCADE NOT NULL check (Улица1_ID != Улица2_ID)
);

--Комитет, который принимает здания (после 90% готовности)
CREATE TABLE Комитет_сдачи_объектов
(
    ID        SERIAL PRIMARY KEY,
    Строгость INTEGER CHECK (0 <= Строгость AND Строгость <= 9) NOT NULL
);

--Бригада, которая строит здания
CREATE TABLE Строй_бригада
(
    ID     SERIAL PRIMARY KEY,
    Размер INTEGER NOT NULL CHECK ( Размер > 0 )
);

--Все стройматериалы, их количество на складе
CREATE TABLE Стройматериал
(
    ID         SERIAL PRIMARY KEY,
    Тип        TEXT                                      NOT NULL,
    Количество INTEGER DEFAULT 1 CHECK (Количество >= 1) NOT NULL,
    Цена       REAL CHECK ( Цена > 0)                    NOT NULL
);

--Доставка стройматериалов
CREATE TABLE Служба_доставки
(
    ID               SERIAL PRIMARY KEY,
    Название         TEXT NOT NULL,
    Тариф            REAL NOT NULL CHECK ( Тариф > 0),
    Стройматериал_ID INTEGER REFERENCES Стройматериал ON DELETE CASCADE ON UPDATE CASCADE
);

--Many To Many
CREATE TABLE Служба_доставки_Строй_бригада
(
    Служба_доставки_ID INTEGER REFERENCES Служба_доставки ON DELETE CASCADE ON UPDATE CASCADE,
    Строй_бригада_ID   INTEGER REFERENCES Строй_бригада ON DELETE CASCADE ON UPDATE CASCADE,
    PRIMARY KEY (Служба_доставки_ID, Строй_бригада_ID)
);

--Служба (газ, вода и т.д.)
CREATE TABLE Городская_служба
(
    ID   SERIAL PRIMARY KEY,
    Тип  TEXT NOT NULL,
    Цена REAL NOT NULL CHECK (Цена > 0)
);

--Команда, подключающая службу
CREATE TABLE Обслуживающая_команда
(
    ID         SERIAL PRIMARY KEY,
    Тариф      REAL CHECK (Тариф > 0)                                                  NOT NULL,
    Квартал_ID INTEGER REFERENCES Квартал ON DELETE CASCADE ON UPDATE CASCADE          NOT NULL,
    Служба_ID  INTEGER REFERENCES Городская_служба ON DELETE CASCADE ON UPDATE CASCADE NOT NULL
);

--Маршрут транспорта
CREATE TABLE Маршрут
(
    ID  SERIAL PRIMARY KEY,
    Тип TEXT NOT NULL
);

--Many To Many + начальный и конечный квартал
CREATE TABLE Маршрут_Кварталы
(
    Маршрут_ID         INTEGER REFERENCES Маршрут ON DELETE CASCADE ON UPDATE CASCADE,
    Квартал_Отправки   INTEGER REFERENCES Квартал ON DELETE CASCADE ON UPDATE CASCADE,
    Квартал_Назначения INTEGER REFERENCES Квартал ON DELETE CASCADE ON UPDATE CASCADE,
    PRIMARY KEY (Маршрут_ID, Квартал_Отправки, Квартал_Назначения)
);

--Many To Many
CREATE TABLE Маршрут_Улица
(
    Маршрут_ID INTEGER REFERENCES Маршрут ON DELETE CASCADE ON UPDATE CASCADE,
    Улица_ID   INTEGER REFERENCES Улица ON DELETE CASCADE ON UPDATE CASCADE,
    PRIMARY KEY (Маршрут_ID, Улица_ID)
);

--Здание, основной объект БД
CREATE TABLE Здание
(
    ID                     SERIAL PRIMARY KEY,
    Тип                    TEXT                                                                                      NOT NULL,
    Назание                TEXT,
    Этажность              INTEGER CHECK ( Этажность >= 1)                                                           NOT NULL,
    Коэффициент_готовности INTEGER DEFAULT 0 CHECK ( Коэффициент_готовности >= 0 AND Коэффициент_готовности <= 100 ) NOT NULL,
    Улица_ID               INTEGER REFERENCES Улица ON DELETE CASCADE ON UPDATE CASCADE                              NOT NULL,
    Комитет_ID             INTEGER REFERENCES Комитет_сдачи_объектов ON DELETE CASCADE ON UPDATE CASCADE             NOT NULL,
    Бригада_ID             INTEGER REFERENCES Строй_бригада ON DELETE CASCADE ON UPDATE CASCADE                      NOT NULL
);

--Many To Many
CREATE TABLE Городская_служба_Здание
(
    Служба_ID INTEGER REFERENCES Городская_служба ON DELETE CASCADE ON UPDATE CASCADE,
    Здание_ID INTEGER REFERENCES Здание ON DELETE CASCADE ON UPDATE CASCADE,
    PRIMARY KEY (Служба_ID, Здание_ID)
);

--Many To Many + необходимое количество материалов для постройки здания
CREATE TABLE Стройматериал_Здание
(
    Стройматериал_ID INTEGER REFERENCES Стройматериал ON DELETE CASCADE ON UPDATE CASCADE,
    Здание_ID        INTEGER REFERENCES Здание ON DELETE CASCADE ON UPDATE CASCADE,
    PRIMARY KEY (Стройматериал_ID, Здание_ID),
    Количество       INTEGER NOT NULL CHECK (Количество > 0)
);