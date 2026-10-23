-- Creació del compte propietari i aplicació ERP
CREATE USER erp_owner PASSWORD 'erp_owner_secure_pass';
CREATE USER erp_user PASSWORD 'erp_user_secure_pass' CONNECTION LIMIT 45 VALID UNTIL 'infinity';

-- Creació de rols per al personal de RRHH i Analistes
CREATE ROLE rol_rrhh;
CREATE ROLE rol_analistes;

-- Usuaris individuals de prova (amb caducitat de contrasenya a 90 dies)
CREATE USER usuari_rrhh1 PASSWORD 'rrhh1_pass' VALID UNTIL CURRENT_TIMESTAMP + INTERVAL '90 days';
CREATE USER usuari_analista1 PASSWORD 'analista1_pass' VALID UNTIL CURRENT_TIMESTAMP + INTERVAL '90 days';

-- Assignació de rols
GRANT rol_rrhh TO usuari_rrhh1;
GRANT rol_analistes TO usuari_analista1;