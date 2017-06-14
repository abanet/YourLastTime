PRAGMA foreign_keys=OFF;
BEGIN TRANSACTION;
CREATE TABLE Eventos (id integer  PRIMARY KEY AUTOINCREMENT DEFAULT NULL,descripcion Varchar(200));
CREATE TABLE Ocurrencias (id integer  NOT NULL  PRIMARY KEY AUTOINCREMENT DEFAULT 0,fecha Date  DEFAULT NULL,hora Time  DEFAULT NULL,idEvento integer  NOT NULL DEFAULT 0);
DELETE FROM sqlite_sequence;
INSERT INTO "sqlite_sequence" VALUES('Eventos',0);
INSERT INTO "sqlite_sequence" VALUES('Ocurrencias',0);
COMMIT;
