-- Unidad 4 · Prueba reversible del plan de rollback FNBC.
-- Ejecutar después de u4_fnbc_control_lote.sql en el esquema u4_fnbc_lab.
-- Reconstruye el estado heredado en una tabla TEMPORAL y compara ambos sentidos.
-- La transacción termina en ROLLBACK: no modifica las tablas persistentes.
\set ON_ERROR_STOP on
SET search_path TO u4_fnbc_lab;
BEGIN;
CREATE TEMP TABLE control_lote_almacen_reconstruida ON COMMIT DROP AS
SELECT cl.lote_id, rd.deposito_id, cl.responsable_control_id
FROM control_lote cl
JOIN responsable_deposito rd
  ON rd.responsable_control_id = cl.responsable_control_id;

DO $$
DECLARE diferencias_origen BIGINT;
DECLARE diferencias_reconstruccion BIGINT;
BEGIN
  SELECT count(*) INTO diferencias_origen
  FROM (
    SELECT lote_id, deposito_id, responsable_control_id FROM control_lote_almacen
    EXCEPT
    SELECT lote_id, deposito_id, responsable_control_id FROM control_lote_almacen_reconstruida
  ) q;
  SELECT count(*) INTO diferencias_reconstruccion
  FROM (
    SELECT lote_id, deposito_id, responsable_control_id FROM control_lote_almacen_reconstruida
    EXCEPT
    SELECT lote_id, deposito_id, responsable_control_id FROM control_lote_almacen
  ) q;
  IF diferencias_origen <> 0 OR diferencias_reconstruccion <> 0 THEN
    RAISE EXCEPTION 'Rollback no equivalente: origen %, reconstrucción %', diferencias_origen, diferencias_reconstruccion;
  END IF;
  RAISE NOTICE 'Rollback lógico validado: 0 diferencias en ambas direcciones.';
END $$;
SELECT * FROM control_lote_almacen_reconstruida ORDER BY lote_id;
ROLLBACK;
