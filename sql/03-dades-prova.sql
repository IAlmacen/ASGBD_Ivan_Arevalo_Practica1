-- Taula d'empleats a l'espai de RRHH
CREATE TABLE empleats (
    id SERIAL PRIMARY KEY,
    nom VARCHAR(50),
    departament VARCHAR(50),
    salari NUMERIC(10, 2)
) TABLESPACE tbs_rrhh;

-- Inserció de dades de prova
INSERT INTO empleats (nom, departament, salari) VALUES 
('Anna Garcia', 'RRHH', 2500.00),
('Joan Puig', 'IT', 3000.00);

-- Vista per a analistes que amaga la columna de salaris (Requisit 8)
CREATE VIEW vista_empleats_sense_salari AS 
SELECT id, nom, departament 
FROM empleats;

-- Atorgar permisos al rol d'analistes només sobre la vista (i no sobre la taula original amb salaris)
GRANT SELECT ON vista_empleats_sense_salari TO rol_analistes;
GRANT SELECT, INSERT, UPDATE, DELETE ON TABLE empleats TO rol_rrhh;

CREATE TABLE erp_comandes (
    id SERIAL PRIMARY KEY,
    article VARCHAR(100),
    quantitat INT
) TABLESPACE tbs_erp;

ALTER TABLE erp_comandes OWNER TO erp_owner;
GRANT SELECT, INSERT, UPDATE, DELETE ON erp_comandes TO erp_user;
GRANT USAGE, SELECT ON SEQUENCE erp_comandes_id_seq TO erp_user;