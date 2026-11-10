-- Unidad 5 · Simulacro controlado de lectura y escalamiento fallido.
-- Ejecutar como administrador en una base de PRUEBAS. Solo usa datos ficticios.
-- Para que SELECT quede auditado, pgAudit/READ debe estar configurado previamente.
\set ON_ERROR_STOP on

CREATE SCHEMA IF NOT EXISTS u5_lab;
CREATE TABLE IF NOT EXISTS u5_lab.dato_sintetico (
  id INTEGER PRIMARY KEY,
  etiqueta TEXT NOT NULL
);
TRUNCATE u5_lab.dato_sintetico;
INSERT INTO u5_lab.dato_sintetico VALUES (1, 'registro_demo_A'), (2, 'registro_demo_B');

DO $$ BEGIN
  CREATE ROLE u5_lector NOLOGIN;
EXCEPTION WHEN duplicate_object THEN NULL; END $$;
DO $$ BEGIN
  CREATE ROLE u5_admin_objetivo NOLOGIN;
EXCEPTION WHEN duplicate_object THEN NULL; END $$;
GRANT USAGE ON SCHEMA u5_lab TO u5_lector;
GRANT SELECT ON u5_lab.dato_sintetico TO u5_lector;

\echo '=== Evento READ: debe aparecer en pgAudit si READ está habilitado ==='
SET ROLE u5_lector;
SELECT * FROM u5_lab.dato_sintetico ORDER BY id;

\echo '=== Intento de escalamiento: debe fallar por falta de admin option ==='
DO $$
BEGIN
  BEGIN
    EXECUTE 'GRANT u5_admin_objetivo TO u5_lector';
    RAISE EXCEPTION 'FALLO DE SEGURIDAD: el rol logró concederse otro rol';
  EXCEPTION WHEN insufficient_privilege THEN
    RAISE NOTICE 'Correcto: escalamiento bloqueado por falta de admin option.';
  END;
END $$;
RESET ROLE;

-- Intentos fallidos de conexión: ejecutar desde terminal (contraseña ficticia/no válida):
-- psql -h localhost -U app_web -d food_store_pruebas -W
-- Ingresar una contraseña deliberadamente incorrecta 2 o 3 veces y revisar FATAL
-- en el log. No registrar contraseñas reales en la evidencia.
