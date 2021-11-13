--Функции для проверки триггеров и вычисления

-- <<ТРИГГЕР>> Сравнивает количество нужного для здания стройматериала с количеством на складе
CREATE OR REPLACE FUNCTION СравнитьКоличество() RETURNS TRIGGER AS
$$
begin
    IF (select NEW.Количество) > (select "Количество" from "Стройматериал" where id = NEW.Стройматериал_id)
    then
        delete
        from "Стройматериал_Здание"
        where "Стройматериал_id" = NEW.Стройматериал_id
          and "Здание_id" = NEW.Здание_id;
        raise exception 'На складе не хватает материала: %!', NEW.Стройматериал_id;
    end if;
    return NEW;
end;
$$ LANGUAGE plpgsql;

-- <<ТРИГГЕР>> Добавляет обратную связь для квартала
CREATE OR REPLACE FUNCTION ДублироватьРеверсКвартал() RETURNS TRIGGER AS
$$
begin
    if (select count(*)
        from "Квартал_Квартал"
        where "Квартал2_id" = new.Квартал1_id
          and "Квартал1_id" = new.Квартал2_id) = 0
    then
        insert into "Квартал_Квартал" ("Квартал1_id", "Квартал2_id") values (new.Квартал2_id, new.Квартал1_id);
    end if;
    return NEW;
end;
$$ LANGUAGE plpgsql;

-- <<ТРИГГЕР>> Добавляет обратную связь для улицы
CREATE OR REPLACE FUNCTION ДублироватьРеверсУлицу() RETURNS TRIGGER AS
$$
begin
    if (select count(*) from "Улица_Улица" where "Улица2_id" = new.Улица1_id and "Улица1_id" = new.Улица2_id) = 0
    then
        insert into "Улица_Улица" ("Улица1_id", "Улица2_id") values (new.Улица2_id, new.Улица1_id);
    end if;
    return NEW;
end;
$$ LANGUAGE plpgsql;

--Возвращает квартал, в котором находится нужное здание
CREATE OR REPLACE FUNCTION ПолучитьКварталИзЗдания(build int) RETURNS INTEGER AS
$$
declare
    street  integer;
    quarter integer;
begin
    select "Улица_id" into street from "Здание" where "Здание".id = build;
    select "Квартал_id" into quarter from "Улица" where "Улица".id = street;
    return quarter;
end;
$$ LANGUAGE plpgsql;

-- <<ТРИГГЕР>> Проверяет, есть ли служба в квартале здания
CREATE OR REPLACE FUNCTION ПроверитьНаличиеСлужбыВКварталеЗдания() RETURNS TRIGGER AS
$$
declare
    quarter record;
    flag    bool := true;
begin
    for quarter in select "Квартал_id" from "Обслуживающая_команда" where "Служба_id" = NEW.Служба_id
        loop
            if quarter."Квартал_id" = ПолучитьКварталИзЗдания(NEW.Здание_id)
            then
                flag := false;
                exit;
            end if;
        end loop;
    if flag then
        delete from "Городская_служба_Здание" WHERE "Служба_id" = NEW.Служба_id AND "Здание_id" = NEW.Здание_id;
        RAISE EXCEPTION 'Служба: % недоступна в квартале номер: %!', NEW.Служба_id, ПолучитьКварталИзЗдания(new.Здание_id);
    end if;
    return NEW;
end;
$$ LANGUAGE plpgsql;

--Считает стоимость материалов для здания и подключения служб
CREATE OR REPLACE FUNCTION ПодсчитатьСтоимостьЗдания(building integer) RETURNS REAL AS
$$
declare
    sum          real := 0;
    rec_material record;
    service_cost real;
begin
    for rec_material in select "Стройматериал_Здание"."Количество", С."Цена"
                        from "Стройматериал_Здание"
                                 join "Стройматериал" С on С.id = "Стройматериал_Здание"."Стройматериал_id"
                        where "Здание_id" = building
        loop
            sum := sum + rec_material."Количество" * rec_material."Цена";
        end loop;
    for service_cost in select "Цена"
                        from "Городская_служба_Здание"
                                 join "Городская_служба" Гс on Гс.id = "Городская_служба_Здание"."Служба_id"
                        where "Здание_id" = building
        loop
            sum := sum + service_cost;
        end loop;
    return sum;
end;
$$ LANGUAGE plpgsql;

--Выбранный комитет принимает все свои готовые здания
CREATE OR REPLACE FUNCTION ПринятьГотовыеЗданияДляКомитета(Комитет integer) RETURNS INTEGER AS
$$
declare
    count       integer := 0;
    building    record;
    coefficient integer;
BEGIN
    select "Строгость" into coefficient from "Комитет_сдачи_объектов" WHERE id = Комитет;

    for building in select "Коэффициент_готовности", id from "Здание" where "Комитет_id" = Комитет
        loop
            if (building."Коэффициент_готовности" - 90) >= coefficient
            then
                update "Здание" SET "Коэффициент_готовности" = 100 where id = building.id;
                count := count + 1;
            end if;
        end loop;
    return count;
end;
$$ LANGUAGE plpgsql;

--Считает, на сколько % готова улица
CREATE OR REPLACE FUNCTION ПодсчитатьДолюГотовностиУлицы(Улица integer) RETURNS REAL AS
$$
declare
    res real;
begin
    select avg("Коэффициент_готовности") into res from "Здание" where "Улица_id" = Улица;
    return res;
end;
$$ LANGUAGE plpgsql;

--Считает, на сколько % готов квартал
CREATE OR REPLACE FUNCTION ПодсчитатьДолюГотовностиКвартала(Квартал integer) RETURNS REAL AS
$$
declare
    sum   real    := 0;
    count integer := 0;
    i     integer;
BEGIN
    for i in select "id" from "Улица" where "Квартал_id" = Квартал
        loop
            sum := sum + ПодсчитатьДолюГотовностиУлицы(i);
            count := count + 1;
        end loop;
    if count > 0 then
        return sum / count;
    else
        return 0;
    end if;
end;
$$ LANGUAGE plpgsql;

--Считает, на сколько % готов весь город
CREATE OR REPLACE FUNCTION ПодсчитатьДолюГотовностиГорода() RETURNS REAL AS
$$
declare
    res real;
begin
    select avg("Коэффициент_готовности") into res from "Здание";
    return res;
end;
$$ LANGUAGE plpgsql;