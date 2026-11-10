# Kiro · Unidad 4 · Diseño y reversión

## Diseño lógico
- `responsable_deposito(responsable_control_id PK, deposito_id)` representa la DF `responsable_control_id → deposito_id`.
- `control_lote(lote_id, responsable_control_id)` representa qué responsable controla cada lote.
- Las claves foráneas mantienen la referencia al responsable; las restricciones y triggers preservan las reglas de negocio adicionales.

## Estrategia de migración
1. Crear las relaciones destino sin eliminar el origen.
2. Copiar responsables y asignaciones con `INSERT ... SELECT`.
3. Comparar el origen y la reconstrucción con `EXCEPT` en ambos sentidos.
4. Ejecutar pruebas de restricciones dentro de transacciones que terminan en `ROLLBACK`.
5. Solo tras revisión humana, marcar el esquema nuevo como activo. No borrar el origen durante la etapa académica.

## Plan de reversión obligatorio
- Detener escrituras de la aplicación en el entorno intervenido.
- Crear `control_lote_almacen_reconstruida` desde JOIN de `control_lote` y `responsable_deposito`.
- Comparar contra la copia preservada con `EXCEPT` en ambas direcciones.
- Si hay diferencias, abortar y no renombrar.
- Si coincide, renombrar la relación reconstruida al nombre anterior en una transacción; conservar las tablas nuevas hasta cerrar la revisión.
- En pruebas, envolver todo en `BEGIN`/`ROLLBACK`; nunca ejecutar sobre producción sin backup validado.

## Desnormalización controlada
La tabla resumen de ventas se mantiene por triggers transaccionales. Se acepta el costo extra de escritura para acelerar reportes frecuentes. Salvaguardas: triggers en la misma transacción, índice de consulta, vista de auditoría y reconciliación periódica. La tabla resumen no es fuente de verdad.
