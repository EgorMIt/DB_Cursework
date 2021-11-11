CREATE TABLE Квартал
(
    ID       SERIAL PRIMARY KEY,
    Название TEXT NOT NULL
);

CREATE TABLE Квартал_Квартал
(
    Квартал1_ID INTEGER REFERENCES Квартал ON DELETE CASCADE ON UPDATE CASCADE,
    Квартал2_ID INTEGER REFERENCES Квартал ON DELETE CASCADE ON UPDATE CASCADE,
    PRIMARY KEY (Квартал1_ID, Квартал2_ID)
);

CREATE TABLE Улица
(
    ID         SERIAL PRIMARY KEY,
    Имя        TEXT                                                           NOT NULL,
    Квартал_ID INTEGER REFERENCES Квартал ON DELETE CASCADE ON UPDATE CASCADE NOT NULL
);

CREATE TABLE Улица_Улица
(
    Улица1_ID INTEGER REFERENCES Улица ON DELETE CASCADE ON UPDATE CASCADE,
    Улица2_ID INTEGER REFERENCES Улица ON DELETE CASCADE ON UPDATE CASCADE,
    PRIMARY KEY (Улица1_ID, Улица2_ID)
);

CREATE TABLE Комитет_сдачи_объектов
(
    ID         SERIAL PRIMARY KEY,
    Строгость  INTEGER check (0 <= Строгость AND Строгость <= 9)              NOT NULL
);

CREATE TABLE Строительная_бригада
(
    ID     SERIAL PRIMARY KEY,
    Размер INTEGER NOT NULL CHECK ( Размер > 0 )
);

CREATE TABLE Стройматериал
(
    ID         SERIAL PRIMARY KEY,
    Тип        TEXT                                      NOT NULL,
    Количество INTEGER DEFAULT 1 CHECK (Количество >= 1) NOT NULL,
    Цена       REAL                                      NOT NULL CHECK ( Цена > 0)
);


CREATE TABLE Служба_доставки
(
    ID               SERIAL PRIMARY KEY,
    Название         TEXT NOT NULL,
    Тариф            REAL NOT NULL CHECK ( Тариф > 0),
    Стройматериал_ID INTEGER REFERENCES Стройматериал ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE Служба_доставки_Строительная_бриг
(
    Служба_доставки_ID      INTEGER REFERENCES Служба_доставки ON DELETE CASCADE ON UPDATE CASCADE,
    Строительная_бригада_ID INTEGER REFERENCES Строительная_бригада ON DELETE CASCADE ON UPDATE CASCADE,
    PRIMARY KEY (Служба_доставки_ID, Строительная_бригада_ID)
);

CREATE TABLE Городская_служба
(
    ID   SERIAL PRIMARY KEY,
    Тип  TEXT NOT NULL,
    Цена REAL NOT NULL check (Цена > 0)
);



CREATE TABLE Обслуживающая_команда
(
    ID         SERIAL PRIMARY KEY,
    Тариф      REAL                                                                    NOT NULL check (Тариф > 0),
    Квартал_ID INTEGER REFERENCES Квартал ON DELETE CASCADE ON UPDATE CASCADE          NOT NULL,
    Служба_ID  INTEGER REFERENCES Городская_служба ON DELETE CASCADE ON UPDATE CASCADE NOT NULL
);

CREATE TABLE Маршрут
(
    ID  SERIAL PRIMARY KEY,
    Тип TEXT NOT NULL
);

CREATE TABLE Маршрут_Кварталы
(
    Маршрут_ID INTEGER REFERENCES Маршрут ON DELETE CASCADE ON UPDATE CASCADE,
    Квартал_Отправки INTEGER REFERENCES Квартал ON DELETE CASCADE ON UPDATE CASCADE,
    Квартал_Назначения INTEGER REFERENCES Квартал ON DELETE CASCADE ON UPDATE CASCADE,
    PRIMARY KEY (Маршрут_ID, Квартал_Отправки, Квартал_Назначения)
);

CREATE TABLE Маршрут_Улица
(
    Маршрут_ID INTEGER REFERENCES Маршрут ON DELETE CASCADE ON UPDATE CASCADE,
    Улица_ID   INTEGER REFERENCES Улица ON DELETE CASCADE ON UPDATE CASCADE,
    PRIMARY KEY (Маршрут_ID, Улица_ID)
);

CREATE TABLE Здание
(
    ID                     SERIAL PRIMARY KEY,
    Тип                    TEXT                                                                                      NOT NULL,
    Назание                TEXT,
    Этажность              INTEGER check ( Этажность >= 1)                                                           NOT NULL,
    Коэффициент_готовности INTEGER DEFAULT 0 check ( Коэффициент_готовности >= 0 and Коэффициент_готовности <= 100 ) NOT NULL,
    Улица_ID               INTEGER REFERENCES Улица ON DELETE CASCADE ON UPDATE CASCADE                              NOT NULL,
    Комитет_ID             INTEGER REFERENCES Комитет_сдачи_объектов ON DELETE CASCADE ON UPDATE CASCADE             NOT NULL,
    Бригада_ID             INTEGER REFERENCES Строительная_бригада ON DELETE CASCADE ON UPDATE CASCADE               NOT NULL
);

CREATE TABLE Городская_служба_Здание
(
    Служба_ID INTEGER REFERENCES Городская_служба,
    Здание_ID INTEGER REFERENCES Здание,
    PRIMARY KEY (Служба_ID, Здание_ID)
);

CREATE TABLE Стройматериал_Здание
(
    Стройматериал_ID INTEGER REFERENCES Стройматериал ON DELETE CASCADE ON UPDATE CASCADE,
    Здание_ID        INTEGER REFERENCES Здание ON DELETE CASCADE ON UPDATE CASCADE,
    PRIMARY KEY (Стройматериал_ID, Здание_ID),
    Количество       INTEGER NOT NULL check (Количество > 0)
);