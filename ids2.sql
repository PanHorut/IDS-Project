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
DROP SEQUENCE LIFESEQUENCE;

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
"kocici_cislo" INT GENERATED AS IDENTITY NOT NULL PRIMARY KEY,
"jmeno" VARCHAR2(50) NOT NULL,
"pohlavi" VARCHAR2(10) NOT NULL
            CHECK("pohlavi" IN ('Male', 'Female', 'Other')) ,
"hmotnost" NUMBER(4,1) NOT NULL ,
"barva_srsti" VARCHAR2(50) NOT NULL ,
"opravneni" VARCHAR2(10) NOT NULL
            CHECK ("opravneni" IN ('User', 'Admin')),
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
            CHECK ("pohlavi" IN ('Male', 'Female', 'Other')),
"ulice" VARCHAR2(50) NOT NULL,
"mesto" VARCHAR2(50) NOT NULL,
"psc" SMALLINT NOT NULL
    CHECK(LENGTH("psc") = 5),
"rc" VARCHAR2(10) UNIQUE NOT NULL
    CHECK (LENGTH("rc") BETWEEN 9 AND 10 AND MOD(TO_NUMBER("rc"),11) = 0)

);

CREATE TABLE "TTeritorium" (
"ID_teritoria" INT GENERATED AS IDENTITY NOT NULL PRIMARY KEY,
"nazev" VARCHAR2(50),
"typ" VARCHAR2(100),
"kapacita" INT
);

CREATE SEQUENCE LIFESEQUENCE
    START WITH 1
    INCREMENT BY 1
    MINVALUE 1
    MAXVALUE 9
    NOCYCLE
    NOCACHE;

CREATE TABLE "TZivot" (
"poradi_zivota" INT GENERATED AS IDENTITY NOT NULL,
"datum_narozeni" DATE NOT NULL,
"misto_narozeni" VARCHAR2(50),
"datum_umrti" DATE DEFAULT NULL,
"zpusob_umrti" VARCHAR2(100) DEFAULT NULL,
"id_kocky" INT NOT NULL,
"id_teritoria" INT,
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
"id_kocky" INT,
"id_teritoria" INT,
CONSTRAINT "ID_kocka_teritorium"
        PRIMARY KEY ("id_kocky", "id_teritoria"),
CONSTRAINT "kockaID_teritorium_fk"
        FOREIGN KEY ("id_kocky") REFERENCES "TKocka" ("kocici_cislo")
        ON DELETE SET NULL,
CONSTRAINT "kocka_teritoriumID_fk"
        FOREIGN KEY ("id_teritoria") REFERENCES "TTeritorium" ("ID_teritoria")
        ON DELETE SET NULL
);

CREATE TABLE "TKockaHostitel"(
"id_kocky" INT,
"id_hostitele" INT,
CONSTRAINT "ID_kocka_hostitel"
        PRIMARY KEY ("id_kocky", "id_hostitele"),
CONSTRAINT "kockaID_hostitel_fk"
        FOREIGN KEY ("id_kocky") REFERENCES "TKocka" ("kocici_cislo")
        ON DELETE SET NULL,
CONSTRAINT "kocka_hostitelID_fk"
        FOREIGN KEY ("id_hostitele") REFERENCES "THostitel" ("ID_hostitele")
        ON DELETE SET NULL

);

CREATE TABLE "TRasaHostitel"(
"id_rasy" VARCHAR2(100),
"id_hostitele" INT,
CONSTRAINT "ID_rasa_hostitel"
        PRIMARY KEY ("id_rasy", "id_hostitele"),
CONSTRAINT "rasaID_hostitel_fk"
        FOREIGN KEY ("id_rasy") REFERENCES "TRasa" ("nazev_rasy")
        ON DELETE SET NULL,
CONSTRAINT "rasa_hostitelID_fk"
        FOREIGN KEY ("id_hostitele") REFERENCES "THostitel" ("ID_hostitele")
        ON DELETE SET NULL
);

CREATE TABLE "TKockaPredmet"(
"id_kocky" INT,
"id_predmetu" INT,
"od" DATE NOT NULL,
"do" DATE,
CONSTRAINT "ID_kocka_predmet"
        PRIMARY KEY ("id_kocky", "id_predmetu", "od"), -- Added "od" into primary key in case of one cat owns single item twice
CONSTRAINT "kockaID_predmet_fk"
        FOREIGN KEY ("id_kocky") REFERENCES "TKocka" ("kocici_cislo")
        ON DELETE SET NULL,
CONSTRAINT "kocka_predmetID_fk"
        FOREIGN KEY ("id_predmetu") REFERENCES "TPredmet" ("ID_predmetu")
        ON DELETE SET NULL
);


-- INSERTING TESTING DATA --
INSERT INTO "TRasa"("nazev_rasy", "barva_oci", "puvod", "prumerna_hmotnost", "prumerny_vek", "charakter")
VALUES ('Arabská','red','finsko','44.0','12','celkem svina');
INSERT INTO "TRasa"("nazev_rasy", "barva_oci", "puvod", "prumerna_hmotnost", "prumerny_vek", "charakter")
VALUES ('Bengálská','blue','USA','7.5','10','aktivní, temperamentní kočka, svalnaté a pružné tělo');

INSERT INTO "TKocka"("jmeno", "pohlavi", "hmotnost", "barva_srsti", "opravneni", "rasa")
VALUES ('Kocouroš','Male','12.0','orange','User','Arabská');
INSERT INTO "TKocka"("jmeno", "pohlavi", "hmotnost", "barva_srsti", "opravneni", "rasa")
VALUES ('Maxík','Male','6.7','black','Admin','Bengálská');

INSERT INTO "THostitel"("jmeno","datum_narozeni","pohlavi","ulice","mesto","psc","rc")
VALUES ('Alfons Mucha', TO_DATE('1952.03.20', 'yyyy/mm/dd'),'Male','Kolínská 17','Kolín nad Rýnem','71701','0304125635');
INSERT INTO "THostitel"("jmeno","datum_narozeni","pohlavi","ulice","mesto","psc","rc")
VALUES ('Kristýna Bačíková', TO_DATE('2004.02.11', 'yyyy/mm/dd'),'Female','507','Petrov','69665','0452115026');

INSERT INTO "TTeritorium"("nazev","typ","kapacita")
VALUES ('Zahrada','Domov',5);
INSERT INTO "TTeritorium"("nazev","typ","kapacita")
VALUES ('Kočičí klub','Klub',20);
INSERT INTO "TTeritorium"("nazev","typ","kapacita")
VALUES ('Skládka','Nebezpečí',50);

INSERT INTO "TPredmet"("nazev", "typ", "id_hostitele", "id_teritoria")
VALUES ('Klubko','hra',NULL,1);
INSERT INTO "TPredmet"("nazev", "typ", "id_hostitele", "id_teritoria")
VALUES ('Myš','hra',2,2);

INSERT INTO "TZivot"("datum_narozeni","misto_narozeni","datum_umrti","zpusob_umrti","id_kocky","id_teritoria")
VALUES (TO_DATE('2019.01.10', 'yyyy/mm/dd'),'Praha',TO_DATE('2021.10.02', 'yyyy/mm/dd'),'umrznutí',1,3);
INSERT INTO "TZivot"("datum_narozeni","misto_narozeni","datum_umrti","zpusob_umrti","id_kocky","id_teritoria")
VALUES (TO_DATE('2021.10.02', 'yyyy/mm/dd'),'Praha',NULL,NULL,1,NULL);
INSERT INTO "TZivot"("datum_narozeni","misto_narozeni","datum_umrti","zpusob_umrti","id_kocky","id_teritoria")
VALUES (TO_DATE('2017.12.24', 'yyyy/mm/dd'),'Kyjov',NULL,NULL,2,NULL);
INSERT INTO "TKockaTeritorium"("id_kocky","id_teritoria")
VALUES (1,1);

INSERT INTO "TKockaTeritorium"("id_kocky","id_teritoria")
VALUES (1,3);
INSERT INTO "TKockaTeritorium"("id_kocky","id_teritoria")
VALUES (2,2);
INSERT INTO "TKockaHostitel"("id_kocky","id_hostitele")
VALUES (1,1);

INSERT INTO "TKockaHostitel"("id_kocky","id_hostitele")
VALUES (2,2);
INSERT INTO "TRasaHostitel"("id_rasy","id_hostitele")
VALUES ('Arabská',1);

INSERT INTO "TKockaPredmet"("id_kocky","id_predmetu","od","do")
VALUES (1,1,TO_DATE('2021.10.05', 'yyyy/mm/dd'),NULL);

INSERT INTO "TKockaPredmet"("id_kocky","id_predmetu","od","do")
VALUES (2,2,TO_DATE('2023.05.05', 'yyyy/mm/dd'), TO_DATE('2024.01.01', 'yyyy/mm/dd'));

COMMIT;
