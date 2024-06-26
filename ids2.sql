-- IDS Project - Kitty Information System
-- Authors: David Cermak (xcerma45)
--          Dominik Horut (xhorut01)

-- DROPPING EXISTING TABLES --
DROP TABLE "TKockaPredmet";
DROP TABLE "TRasaHostitel";
DROP TABLE "TKockaHostitel";
DROP TABLE "TKockaTeritorium";
DROP TABLE "TPredmet";
DROP TABLE "TZivot";
DROP TABLE "TTeritorium";
DROP TABLE "THostitel";
DROP TABLE "TKocka";
DROP TABLE "TRasa";
DROP SEQUENCE "sekvence_kc";
DROP MATERIALIZED VIEW "kocky_zivoty";

-- CREATING TABLES --
CREATE TABLE "TRasa"(
"nazev_rasy" VARCHAR2(50) NOT NULL PRIMARY KEY,
"barva_oci" VARCHAR2(50) NOT NULL,
"puvod" VARCHAR2(100) NOT NULL,
"prumerna_hmotnost" NUMBER(4,1) NOT NULL,
"prumerny_vek" SMALLINT NOT NULL,
"charakter" VARCHAR2(500) NOT NULL
);

CREATE TABLE "TKocka" (
"kocici_cislo" INT DEFAULT NULL PRIMARY KEY,
"jmeno" VARCHAR2(50) NOT NULL,
"pohlavi" VARCHAR2(10) NOT NULL
            CHECK("pohlavi" IN ('Muž', 'Žena', 'Jiné')) ,
"hmotnost" NUMBER(4,1) NOT NULL ,
"barva_srsti" VARCHAR2(50) NOT NULL ,
"opravneni" VARCHAR2(10) NOT NULL
            CHECK ("opravneni" IN ('Uživatel', 'Admin')),
"rasa" VARCHAR2(50),
CONSTRAINT "rasa_kocka_fk"
        FOREIGN KEY ("rasa") REFERENCES "TRasa" ("nazev_rasy")
        ON DELETE SET NULL
);

CREATE TABLE "THostitel"(
"ID_hostitele" INT GENERATED AS IDENTITY NOT NULL PRIMARY KEY,
"jmeno" VARCHAR2(50) NOT NULL,
"datum_narozeni" DATE NOT NULL,
"pohlavi" VARCHAR2(10) NOT NULL
            CHECK ("pohlavi" IN ('Muž', 'Žena', 'Jiné')),
"ulice" VARCHAR2(50) NOT NULL,
"mesto" VARCHAR2(50) NOT NULL,
"psc" SMALLINT NOT NULL
    CHECK(LENGTH("psc") = 5),
"rc" VARCHAR2(11) UNIQUE NOT NULL
    CHECK (LENGTH("rc") BETWEEN 9 AND 10 AND MOD(TO_NUMBER("rc"),11) = 0 AND REGEXP_LIKE("rc", '^[0-9]+$') AND
           SUBSTR("rc", 1, 2) BETWEEN '00' AND '99' AND
           (SUBSTR("rc", 3, 2) BETWEEN '01' AND '12' OR SUBSTR("rc", 3, 2) BETWEEN '51' AND '62') AND
           SUBSTR("rc", 5, 2) BETWEEN '01' AND '31')

);

CREATE TABLE "TTeritorium" (
"ID_teritoria" INT GENERATED AS IDENTITY NOT NULL PRIMARY KEY,
"nazev" VARCHAR2(50) NOT NULL,
"typ" VARCHAR2(100),
"kapacita" INT NOT NULL
);


-- Generalizaci jsme řešili způsobem, že jsme vše dali do jedné tabulky.
-- jelikož máme pouze jednu specializaci.
-- Přidali jsme sloupec datum_umrti a zpusob_umrti a odkaz na teritorium, ve kterém život skončil.
-- Tyto sloupce jsou NULLABLE v připadě, že život ještě není ukončen.
CREATE TABLE "TZivot" (
"poradi_zivota" INT NOT NULL
        CHECK ("poradi_zivota" BETWEEN 1 AND 9),
"datum_narozeni" DATE NOT NULL,
"misto_narozeni" VARCHAR2(50),
"datum_umrti" DATE DEFAULT NULL,
"zpusob_umrti" VARCHAR2(100) DEFAULT NULL,
"id_kocky" INT NOT NULL,
"id_teritoria" INT DEFAULT NULL,
CONSTRAINT "ID_kocka_zivot"
        PRIMARY KEY ("id_kocky", "poradi_zivota"),
CONSTRAINT "zivot_kockaID_fk"
        FOREIGN KEY ("id_kocky") REFERENCES "TKocka" ("kocici_cislo")
        ON DELETE CASCADE,
CONSTRAINT "zivot_teritoriumID_fk"
        FOREIGN KEY ("id_teritoria") REFERENCES "TTeritorium" ("ID_teritoria")
        ON DELETE SET NULL
);

CREATE TABLE "TPredmet"(
"ID_predmetu" INT GENERATED AS IDENTITY NOT NULL PRIMARY KEY,
"nazev" VARCHAR2(50) NOT NULL,
"typ" VARCHAR2(50) NOT NULL,
"id_hostitele" INT,
"id_teritoria" INT,
CONSTRAINT "predmet_hostitelID_fk"
        FOREIGN KEY ("id_hostitele") REFERENCES "THostitel" ("ID_hostitele")
        ON DELETE SET NULL,
CONSTRAINT "predmet_teritoriumID_fk"
        FOREIGN KEY ("id_teritoria") REFERENCES "TTeritorium" ("ID_teritoria")
        ON DELETE SET NULL

);

CREATE TABLE "TKockaTeritorium"(
"id_kocky" INT NOT NULL,
"id_teritoria" INT NOT NULL,
CONSTRAINT "ID_kocka_teritorium"
        PRIMARY KEY ("id_kocky", "id_teritoria"),
CONSTRAINT "kockaID_teritorium_fk"
        FOREIGN KEY ("id_kocky") REFERENCES "TKocka" ("kocici_cislo")
        ON DELETE CASCADE,
CONSTRAINT "kocka_teritoriumID_fk"
        FOREIGN KEY ("id_teritoria") REFERENCES "TTeritorium" ("ID_teritoria")
        ON DELETE CASCADE
);

CREATE TABLE "TKockaHostitel"(
"id_kocky" INT NOT NULL,
"id_hostitele" INT NOT NULL,
CONSTRAINT "ID_kocka_hostitel"
        PRIMARY KEY ("id_kocky", "id_hostitele"),
CONSTRAINT "kockaID_hostitel_fk"
        FOREIGN KEY ("id_kocky") REFERENCES "TKocka" ("kocici_cislo")
        ON DELETE CASCADE,
CONSTRAINT "kocka_hostitelID_fk"
        FOREIGN KEY ("id_hostitele") REFERENCES "THostitel" ("ID_hostitele")
        ON DELETE CASCADE

);

CREATE TABLE "TRasaHostitel"(
"id_hostitele" INT NOT NULL,
"nazev_rasy" VARCHAR2(100) NOT NULL,
CONSTRAINT "ID_rasa_hostitel"
        PRIMARY KEY ("nazev_rasy", "id_hostitele"),
CONSTRAINT "rasaID_hostitel_fk"
        FOREIGN KEY ("nazev_rasy") REFERENCES "TRasa" ("nazev_rasy")
        ON DELETE CASCADE,
CONSTRAINT "rasa_hostitelID_fk"
        FOREIGN KEY ("id_hostitele") REFERENCES "THostitel" ("ID_hostitele")
        ON DELETE CASCADE
);

CREATE TABLE "TKockaPredmet"(
"id_kocky" INT NOT NULL,
"id_predmetu" INT NOT NULL,
"od" DATE NOT NULL,
"do" DATE,
CONSTRAINT "ID_kocka_predmet_od"
        PRIMARY KEY ("id_kocky", "id_predmetu", "od"),
CONSTRAINT "kockaID_predmet_fk"
        FOREIGN KEY ("id_kocky") REFERENCES "TKocka" ("kocici_cislo")
        ON DELETE CASCADE,
CONSTRAINT "kocka_predmetID_fk"
        FOREIGN KEY ("id_predmetu") REFERENCES "TPredmet" ("ID_predmetu")
        ON DELETE CASCADE
);

-- TRIGGER --

-- 1) Automaticky generuje kocici cislo --
CREATE SEQUENCE "sekvence_kc" START WITH 1 INCREMENT BY 1;
CREATE OR REPLACE TRIGGER "sekvence_kc"
    BEFORE INSERT ON "TKocka"
    FOR EACH ROW
BEGIN
    IF :NEW."kocici_cislo" IS NULL THEN
        :NEW."kocici_cislo" := "sekvence_kc".nextval;

    END IF;
END;

-- 2) Kontroluje, zda se rodne cislo shoduje s datumem narozeni --
CREATE OR REPLACE TRIGGER "rc_datum_validator"
    AFTER INSERT ON "THostitel"
    FOR EACH ROW
BEGIN
    IF SUBSTR(:NEW."rc", 1, 2) != TO_CHAR(:NEW."datum_narozeni", 'YY') THEN
        RAISE_APPLICATION_ERROR(-20001, 'Rok narození se neshoduje s rodným číslem');
    END IF;

    IF SUBSTR(:NEW."rc", 3, 2) != TO_CHAR(:NEW."datum_narozeni", 'MM') THEN
        RAISE_APPLICATION_ERROR(-20001, 'Měsíc narození se neshoduje s rodným číslem');
    END IF;

    IF SUBSTR(:NEW."rc", 5, 2) != TO_CHAR(:NEW."datum_narozeni", 'DD') THEN
        RAISE_APPLICATION_ERROR(-20001, 'Den narození se neshoduje s rodným číslem');
    END IF;
END;

-- INSERTING TESTING DATA --
INSERT INTO "TRasa"("nazev_rasy", "barva_oci", "puvod", "prumerna_hmotnost", "prumerny_vek", "charakter")
VALUES ('Arabská', 'červená', 'Finsko', 20.0, 12, 'klidná, inteligentní, hravá, společenská');
INSERT INTO "TRasa"("nazev_rasy", "barva_oci", "puvod", "prumerna_hmotnost", "prumerny_vek", "charakter")
VALUES ('Bengálská','modrá','USA', 7.5, 10,'aktivní, temperamentní, svalnaté a pružné tělo');
INSERT INTO "TRasa"("nazev_rasy", "barva_oci", "puvod", "prumerna_hmotnost", "prumerny_vek", "charakter")
VALUES ('Siamská','zelená','Thajsko', 5.0, 15,'inteligentní, aktivní, hlasitá');
INSERT INTO "TRasa"("nazev_rasy", "barva_oci", "puvod", "prumerna_hmotnost", "prumerny_vek", "charakter")
VALUES ('Sfinga','žlutá','Egypt', 4.0, 20,'bezsrstá, inteligentní, hravá');

INSERT INTO "TKocka"("jmeno", "pohlavi", "hmotnost", "barva_srsti", "opravneni", "rasa")
VALUES ('Kocouroš','Muž', 12.0,'oranžová','Uživatel','Arabská');
INSERT INTO "TKocka"("jmeno", "pohlavi", "hmotnost", "barva_srsti", "opravneni", "rasa")
VALUES ('Maxík','Muž', 6.7,'černá','Admin','Bengálská');
INSERT INTO "TKocka"("jmeno", "pohlavi", "hmotnost", "barva_srsti", "opravneni", "rasa")
VALUES ('Lívaneček', 'Muž', 4.5, 'bílá', 'Uživatel', 'Sfinga');
INSERT INTO "TKocka"("jmeno", "pohlavi", "hmotnost", "barva_srsti", "opravneni", "rasa")
VALUES('Micinka', 'Žena', 3.5, 'šedá', 'Uživatel', 'Siamská');
INSERT INTO "TKocka"("jmeno", "pohlavi", "hmotnost", "barva_srsti", "opravneni", "rasa")
VALUES('Míša', 'Žena', 4.0, 'černá', 'Uživatel', 'Sfinga');

INSERT INTO "THostitel"("jmeno","datum_narozeni","pohlavi","ulice","mesto","psc","rc")
VALUES ('Alfons Mucha', TO_DATE('1952.03.20', 'yyyy/mm/dd'),'Muž','Kolínská 17','Kolín nad Rýnem',71701,'5203205634');
INSERT INTO "THostitel"("jmeno","datum_narozeni","pohlavi","ulice","mesto","psc","rc")
VALUES ('Kristýna Bačíková', TO_DATE('2004.02.11', 'yyyy/mm/dd'),'Žena','507','Petrov',69665,'0402111875');
INSERT INTO "THostitel"("jmeno","datum_narozeni","pohlavi","ulice","mesto","psc","rc")
VALUES ('Josefína Nováková', TO_DATE('1978.04.23', 'yyyy/mm/dd'), 'Žena', 'Chaloupky 105', 'Kyjov', 69701, '7804235043');
INSERT INTO "THostitel"("jmeno","datum_narozeni","pohlavi","ulice","mesto","psc","rc")
VALUES('David Čermák', TO_DATE('2002.10.07', 'yyyy/mm/dd'), 'Muž', 'Třešňová 1014', 'Strážnice', 69662, '0210074601');

INSERT INTO "TTeritorium"("nazev","typ","kapacita")
VALUES ('Zahrada','Domov',5);
INSERT INTO "TTeritorium"("nazev","typ","kapacita")
VALUES ('Kočičí klub','Klub',20);
INSERT INTO "TTeritorium"("nazev","typ","kapacita")
VALUES ('Skládka','Nebezpečí',50);
INSERT INTO "TTeritorium"("nazev","typ","kapacita")
VALUES ('Kuchyně','Domov',3);

INSERT INTO "TPredmet"("nazev", "typ", "id_hostitele", "id_teritoria")
VALUES ('Klubko', 'hra' ,NULL, 1);
INSERT INTO "TPredmet"("nazev", "typ", "id_hostitele", "id_teritoria")
VALUES ('Myš', 'hra', 2, 2);
INSERT INTO "TPredmet"("nazev", "typ", "id_hostitele", "id_teritoria")
VALUES ('Kočičí WC', 'toaleta' ,NULL, 4);
INSERT INTO "TPredmet"("nazev", "typ", "id_hostitele", "id_teritoria")
VALUES ('Pilník', 'zbraň', 4, 4);

INSERT INTO "TZivot"("poradi_zivota", "datum_narozeni","misto_narozeni","datum_umrti","zpusob_umrti","id_kocky","id_teritoria")
VALUES (1, TO_DATE('2019.01.10', 'yyyy/mm/dd'), 'Praha', TO_DATE('2021.10.02', 'yyyy/mm/dd'), 'umrznutí', 1, 3);
INSERT INTO "TZivot"("poradi_zivota", "datum_narozeni","misto_narozeni","datum_umrti","zpusob_umrti","id_kocky","id_teritoria")
VALUES (2, TO_DATE('2021.10.02', 'yyyy/mm/dd'), 'Praha', NULL, NULL, 1, NULL);
INSERT INTO "TZivot"("poradi_zivota", "datum_narozeni","misto_narozeni","datum_umrti","zpusob_umrti","id_kocky","id_teritoria")
VALUES (1, TO_DATE('2017.12.24', 'yyyy/mm/dd'), 'Kyjov', NULL, NULL, 2, NULL);
INSERT INTO "TZivot"("poradi_zivota", "datum_narozeni","misto_narozeni","datum_umrti","zpusob_umrti","id_kocky","id_teritoria")
VALUES (1, TO_DATE('2018.05.05', 'yyyy/mm/dd'), 'Brno', NULL, NULL, 3, NULL);
INSERT INTO "TZivot"("poradi_zivota", "datum_narozeni","misto_narozeni","datum_umrti","zpusob_umrti","id_kocky","id_teritoria")
VALUES (1, TO_DATE('2019.01.10', 'yyyy/mm/dd'), 'Veselí nad Moravou', TO_DATE('2021.10.02', 'yyyy/mm/dd'), 'zastřelení', 4, 3);
INSERT INTO "TZivot"("poradi_zivota", "datum_narozeni","misto_narozeni","datum_umrti","zpusob_umrti","id_kocky","id_teritoria")
VALUES (2, TO_DATE('2021.10.02', 'yyyy/mm/dd'), 'Veselí nad Moravou', TO_DATE('2023.05.05', 'yyyy/mm/dd'), 'pád z výšky', 4, 1);
INSERT INTO "TZivot"("poradi_zivota", "datum_narozeni","misto_narozeni","datum_umrti","zpusob_umrti","id_kocky","id_teritoria")
VALUES (3, TO_DATE('2023.05.05', 'yyyy/mm/dd'), 'Uherský Ostroh', NULL, NULL, 4, NULL);

INSERT INTO "TKockaTeritorium"("id_kocky","id_teritoria")
VALUES (1,1);
INSERT INTO "TKockaTeritorium"("id_kocky","id_teritoria")
VALUES (1,3);
INSERT INTO "TKockaTeritorium"("id_kocky","id_teritoria")
VALUES (2,2);
INSERT INTO "TKockaTeritorium"("id_kocky","id_teritoria")
VALUES (3,4);
INSERT INTO "TKockaTeritorium"("id_kocky","id_teritoria")
VALUES (4,2);

INSERT INTO "TKockaHostitel"("id_kocky","id_hostitele")
VALUES (1,1);
INSERT INTO "TKockaHostitel"("id_kocky","id_hostitele")
VALUES (2,2);
INSERT INTO "TKockaHostitel"("id_kocky","id_hostitele")
VALUES (3,3);
INSERT INTO "TKockaHostitel"("id_kocky","id_hostitele")
VALUES (4,4);
INSERT INTO "TKockaHostitel"("id_kocky","id_hostitele")
VALUES (4,3);

INSERT INTO "TRasaHostitel"("nazev_rasy","id_hostitele")
VALUES ('Arabská',1);
INSERT INTO "TRasaHostitel"("nazev_rasy","id_hostitele")
VALUES ('Bengálská',3);
INSERT INTO "TRasaHostitel"("nazev_rasy","id_hostitele")
VALUES ('Sfinga',3);
INSERT INTO "TRasaHostitel"("nazev_rasy","id_hostitele")
VALUES ('Siamská',4);
INSERT INTO "TRasaHostitel"("nazev_rasy","id_hostitele")
VALUES ('Sfinga',2);

INSERT INTO "TKockaPredmet"("id_kocky","id_predmetu","od","do")
VALUES (1,1,TO_DATE('2021.10.05', 'yyyy/mm/dd'),NULL);
INSERT INTO "TKockaPredmet"("id_kocky","id_predmetu","od","do")
VALUES (2,2,TO_DATE('2023.05.05', 'yyyy/mm/dd'), TO_DATE('2024.01.01', 'yyyy/mm/dd'));
INSERT INTO "TKockaPredmet"("id_kocky","id_predmetu","od","do")
VALUES (3,3,TO_DATE('2022.11.12', 'yyyy/mm/dd'),NULL);
INSERT INTO "TKockaPredmet"("id_kocky","id_predmetu","od","do")
VALUES (4,4,TO_DATE('2020.12.24', 'yyyy/mm/dd'),NULL);
INSERT INTO "TKockaPredmet"("id_kocky","id_predmetu","od","do")
VALUES (4,2,TO_DATE('2024.01.03', 'yyyy/mm/dd'),NULL);

COMMIT;

-- Demonstrace triggerů --

-- Demonstrace triggeru 1: Podle vložených dat by kočky měly mít primární klíč ("kocici_cislo")
-- v tomto pořadí:
-- kocici_cislo | jmeno
--            1 | Kocouroš
--            2 | Maxík
--            3 | Lívaneček
--            4 | Micinka
--            5 | Míša
SELECT * from "TKocka";

-- Demonstrace triggeru 2: Po zadání datumu narození tak, aby nekorespondovalo s rodným číslem,
-- dojde k chybě

-- Neshoda roku
INSERT INTO "THostitel"("jmeno","datum_narozeni","pohlavi","ulice","mesto","psc","rc")
VALUES ('Monty Python', TO_DATE('1992.05.12', 'yyyy/mm/dd'),'Muž','Bozetechova 45','Kaliningrad',42014,'8905123414');

-- Neshoda měsíce
INSERT INTO "THostitel"("jmeno","datum_narozeni","pohlavi","ulice","mesto","psc","rc")
VALUES ('Monty Python', TO_DATE('1989.06.12', 'yyyy/mm/dd'),'Muž','Bozetechova 45','Kaliningrad',42014,'8905123414');

--Neshoda dne
INSERT INTO "THostitel"("jmeno","datum_narozeni","pohlavi","ulice","mesto","psc","rc")
VALUES ('Monty Python', TO_DATE('1989.05.15', 'yyyy/mm/dd'),'Muž','Bozetechova 45','Kaliningrad',42014,'8905123414');

-- Uložené procedury --

-- Procedura počítá, kolik procent evidovaných hostitelů si podmanila kočka s daným kočičím číslem.
CREATE OR REPLACE PROCEDURE "how_many_hosts_procent" (kocici_cislo INT) AS
    pocet_hostitelu INT;
    pocet_podmanenych INT;
    jmeno_kocky "TKocka"."jmeno"%TYPE;
    procent NUMBER(5,2);

    BEGIN
        SELECT COUNT(*) INTO pocet_hostitelu FROM "THostitel";

        SELECT COUNT(*) INTO pocet_podmanenych
        FROM "TKockaHostitel" KH
        WHERE KH."id_kocky" = kocici_cislo;

        SELECT K."jmeno" INTO jmeno_kocky
        FROM "TKocka" K
        WHERE "kocici_cislo" = kocici_cislo;

        procent := (pocet_podmanenych / pocet_hostitelu) * 100;

        DBMS_OUTPUT.PUT_LINE('Kočka ' || jmeno_kocky || ' s kočičím číslem ' || kocici_cislo || ' si podmanila ' || procent || '% evidovaných hostitelů.');

    EXCEPTION
    WHEN ZERO_DIVIDE THEN
        BEGIN
            DBMS_OUTPUT.PUT_LINE('Nejsou evidování žádní hostitelé.');
        END;

    WHEN NO_DATA_FOUND THEN
        BEGIN
            DBMS_OUTPUT.PUT_LINE('Chybné kočičí číslo.');
        END;
    END;

-- Procedura počítá kolik životů bylo ukončeno v daném teritoriu a vyhodnotí míru nebezpečí tohoto teritoria. --
CREATE OR REPLACE PROCEDURE "how_dangerous" (ID_teritoria INT) AS
    CURSOR cursor_deaths IS
        SELECT Z."id_teritoria"
        FROM "TZivot" Z
        WHERE Z."id_teritoria" = ID_teritoria;
    pocet_umrti INT;
    v_id_teritoria "TZivot"."id_teritoria"%TYPE;
    nazev_teritoria "TTeritorium"."nazev"%TYPE;

    BEGIN
        pocet_umrti := 0;
        SELECT "nazev" INTO nazev_teritoria
        FROM "TTeritorium" T
        WHERE T."ID_teritoria" = ID_teritoria;

        FOR v_id_teritoria IN cursor_deaths LOOP
                    pocet_umrti := pocet_umrti + 1;
        END LOOP;

        DBMS_OUTPUT.PUT_LINE('V teritoriu ' || nazev_teritoria || ' s identifikačním číslem ' || ID_teritoria || ' bylo ukončeno životů: ' || pocet_umrti || '.');
        IF pocet_umrti < 2 THEN
            DBMS_OUTPUT.PUT_LINE('Teritorium je bezpečné.');
        ELSIF pocet_umrti < 10 THEN
            DBMS_OUTPUT.PUT_LINE('Teritorium je středně nebezpečné.');
        ELSE
            DBMS_OUTPUT.PUT_LINE('Teritorium je velmi nebezpečné.');
        END IF;

        EXCEPTION WHEN NO_DATA_FOUND THEN
        BEGIN
            DBMS_OUTPUT.PUT_LINE('Chybné identifikační číslo teritoria.');
        END;
    END;

-- Příklad použití procedury how_many_hosts --
BEGIN "how_many_hosts_procent"(4); END;

-- Příklad použití procedury how_dangerous --
BEGIN "how_dangerous"(3); END;

-- Které životy kočky Micinky byly ukončeny rukou člověka a které ne --
WITH prozite_zivoty AS (
SELECT "poradi_zivota" Pořadí, "misto_narozeni" Místo_narození, "datum_narozeni" Datum_narození, "datum_umrti" Datum_úmrtí, "zpusob_umrti" Způsob_úmrtí
FROM "TZivot" Z NATURAL JOIN "TKocka" K
WHERE Z."id_kocky" = K."kocici_cislo"
  AND K."jmeno" = 'Micinka' AND K."kocici_cislo" = 4
ORDER BY "poradi_zivota"
)
SELECT
    Datum_úmrtí,
    Způsob_úmrtí,
    CASE
        WHEN Způsob_úmrtí = 'zastřelení' THEN 'Ano'
        WHEN Způsob_úmrtí = 'umlácení baseballkou' THEN 'Ano'
        WHEN Způsob_úmrtí = 'shozena z FSI' THEN 'Ano'
        WHEN Způsob_úmrtí IS NULL AND Datum_úmrtí IS NULL THEN 'Stále žije'
        ELSE 'Ne'
    END AS zabita_clovekem
FROM
    prozite_zivoty;


-- EXPLAIN PLAN před vytvořením indexu --

-- Kolik životů prožily jednotlivé kočky?
EXPLAIN PLAN FOR
SELECT K."kocici_cislo" Kočičí_číslo, K."jmeno" Jméno, K."pohlavi" Pohlaví, K."rasa" Rasa, COUNT(*) Počet_životů
FROM "TKocka" K NATURAL JOIN "TZivot" Z
WHERE K."kocici_cislo" = Z."id_kocky"
GROUP BY K."kocici_cislo", K."jmeno",K."pohlavi", K."rasa"
ORDER BY K."jmeno", K."kocici_cislo";

SELECT * FROM TABLE(DBMS_XPLAN.DISPLAY);

-- Vytvoření indexu

CREATE INDEX "index_id_kocky" ON "TZivot"("id_kocky");

-- EXPLAIN PLAN po vytvoření indexu --

EXPLAIN PLAN FOR
SELECT K."kocici_cislo" Kočičí_číslo, K."jmeno" Jméno, K."pohlavi" Pohlaví, K."rasa" Rasa, COUNT(*) Počet_životů
FROM "TKocka" K NATURAL JOIN "TZivot" Z
WHERE K."kocici_cislo" = Z."id_kocky"
GROUP BY K."kocici_cislo", K."jmeno",K."pohlavi", K."rasa"
ORDER BY K."jmeno", K."kocici_cislo";

SELECT * FROM TABLE(DBMS_XPLAN.DISPLAY);

DROP INDEX "index_id_kocky";

-- Přístupová práva --

GRANT SELECT ON "TKocka" TO xhorut01;
GRANT ALL ON "THostitel" TO xhorut01;
GRANT SELECT ON "TTeritorium" TO xhorut01;
GRANT ALL ON "TPredmet" TO xhorut01;
GRANT ALL ON "TZivot" TO xhorut01;
GRANT SELECT ON "TRasa" TO xhorut01;
GRANT ALL ON "TKockaTeritorium" TO xhorut01;
GRANT ALL ON "TKockaHostitel" TO xhorut01;
GRANT SELECT ON "TRasaHostitel" TO xhorut01;
GRANT ALL ON "TKockaPredmet" TO xhorut01;

GRANT EXECUTE ON "how_many_hosts_procent" TO xhorut01;
GRANT EXECUTE ON "how_dangerous" TO xhorut01;


CREATE MATERIALIZED VIEW LOG ON "TZivot" WITH PRIMARY KEY, ROWID INCLUDING NEW VALUES;
CREATE MATERIALIZED VIEW LOG ON "TKocka" WITH ROWID, SEQUENCE("kocici_cislo", "jmeno", "pohlavi", "rasa") INCLUDING NEW VALUES;

-- Vytvoření materailizovaného pohledu, který vypisuje jednotlivé kočky a kolik mají zaevidovaných životů.
CREATE MATERIALIZED VIEW "kocky_zivoty"
    NOLOGGING
    CACHE
    BUILD IMMEDIATE
    REFRESH FAST ON COMMIT
    ENABLE QUERY REWRITE
    AS
        SELECT K."kocici_cislo" Kočičí_číslo, K."jmeno" Jméno, K."pohlavi" Pohlaví, K."rasa" Rasa, COUNT(*) Počet_životů
        FROM "TKocka" K NATURAL JOIN "TZivot" Z
        WHERE K."kocici_cislo" = Z."id_kocky"
        GROUP BY K."kocici_cislo", K."jmeno",K."pohlavi", K."rasa"
        ORDER BY K."kocici_cislo";


GRANT ALL ON "kocky_zivoty" TO xhorut01;

-- Demonstrace pohledu
SELECT * FROM "kocky_zivoty";

-- změna pohlaví kočky s kočičím číslem 1 na "Jiné"
UPDATE "TKocka"
SET "pohlavi" = 'Jiné'
WHERE "kocici_cislo" = 1;

-- Změna se v materialozovaném pohledu projeví po commitu.
SELECT * FROM "kocky_zivoty";

COMMIT;

SELECT * FROM "kocky_zivoty";
