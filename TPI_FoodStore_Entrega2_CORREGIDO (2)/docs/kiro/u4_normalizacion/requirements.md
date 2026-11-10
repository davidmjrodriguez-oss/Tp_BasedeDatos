# Kiro · Unidad 4 · Requisitos de normalización y migración

## Objetivo
Refactorizar la relación heredada `control_lote_almacen(lote_id, deposito_id, responsable_control_id)` hasta FNBC, preservando los datos y permitiendo reversión.

## Requisitos
- REQ-U4-01: El sistema DEBE documentar las dependencias funcionales reales y justificar las claves candidatas antes de descomponer.
- REQ-U4-02: La descomposición DEBE llevar cada relación resultante a FNBC respecto de las DF declaradas.
- REQ-U4-03: La migración DEBE ejecutarse en una transacción y abortar ante cualquier error (`ON_ERROR_STOP`).
- REQ-U4-04: La migración DEBE verificar pérdida cero comparando ambas direcciones con `EXCEPT`.
- REQ-U4-05: La migración DEBE conservar la tabla original como respaldo lógico hasta la aprobación humana.
- REQ-U4-06: El plan de reversión DEBE reconstruir la relación original desde las relaciones descompuestas y verificar equivalencia antes de restaurar el nombre original.
- REQ-U4-07: La desnormalización de reportes DEBE justificar patrón de lectura, costo de escritura y salvaguardas de consistencia.

## Criterios de aceptación
1. Diferencia entre origen y reconstrucción: cero filas en ambas direcciones.
2. Restricciones/triggers impiden estados que violen las DF del dominio.
3. `ROLLBACK` deja el esquema anterior intacto en la prueba reversible.
4. La tabla resumen coincide con la consulta fuente y la vista de auditoría no devuelve discrepancias.
