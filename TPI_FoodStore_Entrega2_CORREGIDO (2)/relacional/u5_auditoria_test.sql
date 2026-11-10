-- Unidad 5 · Prueba funcional de privilegios y auditoría.
-- Ejecutar solo en una base de PRUEBAS con los roles creados.
-- Las escrituras quedan dentro de una transacción que se revierte.
\set ON_ERROR_STOP on
\echo '1) SELECT de prueba: esta sentencia solo aparecerá en logs si la auditoría READ está habilitada (pgaudit o logging específico).'
SELECT current_user, current_database(), now();

\echo '2) Verificación de mínimo privilegio: app_web no debe leer usuario.'
SELECT has_table_privilege('app_web', 'public.usuario', 'SELECT') AS app_web_puede_leer_usuario;

\echo '3) Escritura controlada: adaptar columnas a la tabla usuario real; ejecutar solo si existe y dentro de transacción.'
BEGIN;
DO $$ BEGIN
  IF to_regclass('public.usuario') IS NOT NULL
     AND EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema='public' AND table_name='usuario' AND column_name='nombre')
     AND EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema='public' AND table_name='usuario' AND column_name='email') THEN
    RAISE NOTICE 'Tabla usuario detectada. No se inserta información personal en esta prueba genérica.';
  ELSE
    RAISE NOTICE 'Tabla usuario/columnas no disponibles; se omite la prueba de escritura.';
  END IF;
END $$;
ROLLBACK;

\echo '4) Para probar SELECT auditado, iniciar sesión con rol de prueba y ejecutar SELECT; verificar evento READ en el log protegido.'
