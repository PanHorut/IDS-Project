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

--- CREATING TABLES
CREATE TABLE "TRasa"(
"nazev_rasy" VARCHAR2(20) NOT NULL PRIMARY KEY,
"barva_oci" VARCHAR2(20) NOT NULL,
"puvod" VARCHAR2(20) NOT NULL,
"prumerna_hmotnost" SMALLINT NOT NULL,
"prumerny_vek" SMALLINT NOT NULL,
"charakter" VARCHAR2(100) NOT NULL
);

CREATE TABLE "TKocka" (
"kocici_cislo" INT GENERATED AS IDENTITY NOT NULL PRIMARY KEY,
"jmeno" VARCHAR2(20) NOT NULL,
"pohlavi" VARCHAR2(6) NOT NULL ,
"hmotnost" SMALLINT NOT NULL ,
"barva_srsti" VARCHAR2(20) NOT NULL ,
"opravneni" VARCHAR2(3) NOT NULL,
"rasa" VARCHAR2(20),
CONSTRAINT "rasa_kocka_fk"
        FOREIGN KEY ("rasa") REFERENCES "TRasa" ("nazev_rasy")
        ON DELETE SET NULL
);

CREATE TABLE "THostitel"(
"ID_hostitele" INT GENERATED AS IDENTITY NOT NULL PRIMARY KEY,
"jmeno" VARCHAR2(20) NOT NULL,
"datum_narozeni" DATE NOT NULL,
"pohlavi" VARCHAR2(10) NOT NULL,
"ulice" VARCHAR2(20) NOT NULL,
"mesto" VARCHAR2(20) NOT NULL,
"psc" SMALLINT NOT NULL
    CHECK(LENGTH("psc") = 5),
"rc" SMALLINT NOT NULL
    CHECK (LENGTH(TO_CHAR("rc")) BETWEEN 9 AND 10 AND MOD("rc",11) = 0)

);

CREATE TABLE "TTeritorium" (
"ID_teritoria" INT GENERATED AS IDENTITY NOT NULL PRIMARY KEY,
"nazev" VARCHAR2(20),
"typ" VARCHAR2(20),
"kapacita" INT
);

CREATE TABLE "TZivot" (
"poradi_zivota" INT NOT NULL PRIMARY KEY,
"datum_narozeni" DATE NOT NULL,
"misto_narozeni" VARCHAR2(50),
"datum_umrti" DATE DEFAULT NULL,
"zpusob_umrti" VARCHAR2(50) DEFAULT NULL,
"id_kocky" INT,
"id_teritoria" INT,
CONSTRAINT "zivot_kockaID_fk"
        FOREIGN KEY ("id_kocky") REFERENCES "TKocka" ("kocici_cislo")
        ON DELETE CASCADE,
CONSTRAINT "zivot_teritoriumID_fk"
        FOREIGN KEY ("id_teritoria") REFERENCES "TTeritorium" ("ID_teritoria")
        ON DELETE SET NULL
);

CREATE TABLE "TPredmet"(
"ID_predmetu" INT GENERATED AS IDENTITY NOT NULL PRIMARY KEY,
"nazev" VARCHAR2(20) NOT NULL,
"typ" VARCHAR2(20) NOT NULL,
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
"id_rasy" VARCHAR2(20),
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
"do" DATE NOT NULL,
CONSTRAINT "ID_kocka_predmet"
        PRIMARY KEY ("id_kocky", "id_predmetu"),
CONSTRAINT "kockaID_predmet_fk"
        FOREIGN KEY ("id_kocky") REFERENCES "TKocka" ("kocici_cislo")
        ON DELETE SET NULL,
CONSTRAINT "kocka_predmetID_fk"
        FOREIGN KEY ("id_predmetu") REFERENCES "TPredmet" ("ID_predmetu")
        ON DELETE SET NULL
);

COMMIT;

INSERT INTO "TRasa"
VALUES ('arabska','red','finsko','44','12','celkem svina');

INSERT INTO "TKocka"("jmeno", "pohlavi", "hmotnost", "barva_srsti", "opravneni", "rasa")
VALUES ('kocouros','kocour','12','orange','usr','arabska');

INSERT INTO "THostitel"("jmeno","datum_narozeni","pohlavi","ulice","mesto","psc","rc")
VALUES ('alfons','20.3.1952','muz','kolinska','kolin nad rynem','71701','0304125635');

SELECT * FROM "THostitel";