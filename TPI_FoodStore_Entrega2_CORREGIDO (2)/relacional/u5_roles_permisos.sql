-- Unidad 5 · Roles y permisos Food Store (PostgreSQL)
-- Ejecutar como propietario/superusuario en la base de PRUEBAS.
-- No contiene contraseñas: asignarlas por canal seguro con \password en psql.
-- Diseño de mínimo privilegio: permisos por objeto/operación, no ALL TABLES.

\set ON_ERROR_STOP on

DO $$ BEGIN
  EXECUTE 'CREATE ROLE rol_app_lectura NOLOGIN';
EXCEPTION WHEN duplicate_object THEN NULL; END $$;
DO $$ BEGIN
  EXECUTE 'CREATE ROLE rol_app_escritura NOLOGIN';
EXCEPTION WHEN duplicate_object THEN NULL; END $$;
DO $$ BEGIN
  EXECUTE 'CREATE ROLE rol_soporte NOLOGIN';
EXCEPTION WHEN duplicate_object THEN NULL; END $$;
DO $$ BEGIN
  EXECUTE 'CREATE ROLE rol_reportes NOLOGIN';
EXCEPTION WHEN duplicate_object THEN NULL; END $$;
DO $$ BEGIN
  EXECUTE 'CREATE ROLE app_web LOGIN';
EXCEPTION WHEN duplicate_object THEN NULL; END $$;
DO $$ BEGIN
  EXECUTE 'CREATE ROLE admin_datos LOGIN';
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

GRANT CONNECT ON DATABASE food_store TO app_web;
GRANT CONNECT ON DATABASE food_store TO admin_datos;
GRANT rol_app_lectura, rol_app_escritura TO app_web;
GRANT rol_soporte, rol_reportes TO admin_datos;
GRANT USAGE ON SCHEMA public TO rol_app_lectura, rol_app_escritura, rol_reportes, rol_soporte;

-- Lectura de catálogo: solo objetos necesarios para consultar productos.
DO $$ BEGIN
  IF to_regclass('public.categoria') IS NOT NULL THEN
    EXECUTE 'GRANT SELECT ON TABLE public.categoria TO rol_app_lectura';
  END IF;
  IF to_regclass('public.producto') IS NOT NULL THEN
    EXECUTE 'GRANT SELECT ON TABLE public.producto TO rol_app_lectura';
  END IF;
  IF to_regclass('public.etiqueta') IS NOT NULL THEN
    EXECUTE 'GRANT SELECT ON TABLE public.etiqueta TO rol_app_lectura';
  END IF;
  IF to_regclass('public.producto_etiqueta') IS NOT NULL THEN
    EXECUTE 'GRANT SELECT ON TABLE public.producto_etiqueta TO rol_app_lectura';
  END IF;
END $$;

-- Escritura limitada al circuito de pedidos; no permite borrar catálogo ni usuarios.
DO $$ BEGIN
  IF to_regclass('public.pedido') IS NOT NULL THEN
    EXECUTE 'GRANT SELECT, INSERT, UPDATE ON TABLE public.pedido TO rol_app_escritura';
  END IF;
  IF to_regclass('public.detalle_pedido') IS NOT NULL THEN
    EXECUTE 'GRANT SELECT, INSERT, UPDATE, DELETE ON TABLE public.detalle_pedido TO rol_app_escritura';
  END IF;
END $$;

-- Acceso a secuencias requerido por columnas SERIAL/IDENTITY de pedidos.
DO $$ DECLARE r record; BEGIN
  FOR r IN
    SELECT c.oid::regclass AS nombre
    FROM pg_class c JOIN pg_namespace n ON n.oid = c.relnamespace
    WHERE n.nspname = 'public' AND c.relkind = 'S'
      AND c.relname IN ('pedido_id_seq')
  LOOP
    EXECUTE format('GRANT USAGE, SELECT ON SEQUENCE %s TO rol_app_escritura', r.nombre);
  END LOOP;
END $$;

-- Reportes: preferir una vista anonimizada. No se concede SELECT sobre usuario.
DO $$ BEGIN
  IF to_regclass('public.usuario_anon') IS NOT NULL THEN
    EXECUTE 'GRANT SELECT ON TABLE public.usuario_anon TO rol_reportes';
  END IF;
END $$;

-- Soporte: conexión y metadatos básicos; sin permisos de escritura sobre datos.
GRANT SELECT ON TABLE pg_catalog.pg_tables TO rol_soporte;

-- Auditoría: registrar conexiones y sentencias relevantes en postgresql.conf.
-- Aplicar en el servidor y reiniciar/recargar según corresponda:
--   log_destination = 'stderr'
--   logging_collector = on
--   log_connections = on
--   log_disconnections = on
--   log_statement = 'mod'       # DDL/DML; NO registra SELECT
-- Para auditar SELECT, usar pgAudit (pgaudit.log = 'read, write, ddl') o una
-- política de logging específica. Evaluar volumen y proteger logs: pueden contener
-- literales sensibles. No activar log_statement='all' en producción sin análisis.

-- Comprobación rápida de privilegios efectivos (ejecutar tras el script):
-- SELECT grantee, table_name, privilege_type
-- FROM information_schema.role_table_grants
-- WHERE grantee IN ('rol_app_lectura','rol_app_escritura','rol_reportes','rol_soporte')
-- ORDER BY grantee, table_name, privilege_type;
-- SELECT has_table_privilege('app_web','public.usuario','SELECT') AS app_web_lee_usuarios;
-- Resultado esperado para la última columna: false.
