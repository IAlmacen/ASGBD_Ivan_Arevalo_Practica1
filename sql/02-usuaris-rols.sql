-- Rols globals
CREATE ROLE rol_rrhh;
CREATE ROLE rol_analistes;

-- ERP
CREATE USER erp_owner PASSWORD 'erp_owner_pass' VALID UNTIL 'infinity';
CREATE USER erp_user WITH PASSWORD 'erp_password_123' CONNECTION LIMIT 45 VALID UNTIL 'infinity';

-- Funció d'automatització de 90 dies
CREATE OR REPLACE FUNCTION afegir_personal(p_usuari TEXT, p_password TEXT, p_rol TEXT)
RETURNS VOID AS $$
DECLARE
    v_caducitat TIMESTAMP;
BEGIN
    v_caducitat := CURRENT_TIMESTAMP + INTERVAL '90 days';
    EXECUTE format('CREATE USER %I PASSWORD %L VALID UNTIL %L', p_usuari, p_password, v_caducitat);
    EXECUTE format('GRANT %I TO %I', p_rol, p_usuari);
END;
$$ LANGUAGE plpgsql;

-- Crear el personal inicial
SELECT afegir_personal('usuari_rrhh1', 'rrhh1_pass', 'rol_rrhh');
SELECT afegir_personal('usuari_analista1', 'analista1_pass', 'rol_analistes');