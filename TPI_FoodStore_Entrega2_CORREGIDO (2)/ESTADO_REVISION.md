# Estado de revisión técnica · 10/11/2026

## Correcciones aplicadas al ZIP

- Scripts Bash de backup/restauración: sintaxis Bash válida, manejo de errores, archivo temporal, validación de respaldo, retención parametrizable, credenciales fuera del código y restauración a base nueva sin sobrescritura.
- Scripts FNBC y desnormalización: objetos aislados en esquemas `u4_fnbc_lab` y `u4_desnormalizacion_lab` para no borrar accidentalmente tablas de `public`.
- Unidad 4: especificación Kiro de requisitos/diseño/tareas y script de prueba reversible de reconstrucción.
- Unidad 5: roles con permisos acotados a catálogo/pedidos; sin `GRANT` global de escritura; sin contraseñas hardcodeadas. Se corrigió la documentación: `log_statement='mod'` no registra SELECT y no sirve para probar por sí solo una lectura masiva.
- Unidad 6: Kiro requirements/design/tasks y plan operativo revisado.
- Unidad 7: fixture reproducible de cinco documentos ficticios, validador JSON Schema, índices y ocho consultas sin resultados hardcodeados. El informe separa resultados esperados de evidencia real.
- Unidad 8: corregida la ruta `movil/postgres` en `simulacion_completa.py`.
- README actualizado y pendientes identificados.

## Pruebas ejecutadas en esta revisión

- `bash -n relacional/u6_backup_programado.sh relacional/u6_restauracion.sh`: **OK** (sintaxis Bash).
- `python -m py_compile movil/simulacion_completa.py`: **OK** (compilación Python).
- Copia temporal de `movil/foodstore_movil.db`: `PRAGMA integrity_check` devolvió **ok**; `PRAGMA foreign_key_check` devolvió **0 filas**.
- Conteos observados en la base SQLite incluida: `producto_cache=8`, `pedido_borrador=4`, `item_borrador=4`, `cola_sync=5`, `snapshot_servidor=8`.
- Rutas de `movil/postgres`, esquema SQLite y fixture MongoDB: **existencia comprobada**.

No se ejecutaron `pg_dump`, `pg_restore`, scripts SQL PostgreSQL ni `mongosh`: esas herramientas no están disponibles en el entorno de revisión.

## Pendientes que requieren el equipo del alumno

1. Ejecutar Unidad 4 en PostgreSQL de pruebas y guardar salida de FNBC, `EXCEPT` en ambas direcciones y reversión.
2. Ejecutar roles/auditoría en PostgreSQL. Configurar pgAudit o auditoría READ equivalente; obtener log real anonimizado.
3. Ejecutar backup y restauración de Unidad 6 sobre una base de prueba; medir RTO y comparar conteos/huellas.
4. Ejecutar fixture y consultas en MongoDB (`mongosh`); guardar salida real y contrastar IDs contra PostgreSQL.
5. Ejecutar simulación completa SQLite/PostgreSQL de Unidad 8 después de hacer copia de la base incluida; guardar salida real.
6. Ejecutar code review final de todos los scripts con OpenCode; registrar cada hallazgo, decisión humana y evidencia. Este ZIP no inventa resultados de OpenCode.
7. Inicializar/actualizar Git, confirmar commits y adjuntar URL/estado del repositorio.
8. Leer cada script línea por línea y preparar defensa oral. La asistencia de IA debe declararse y comprenderse.

## Límite de esta revisión

La inspección estática y las pruebas de SQLite/Python no equivalen a ejecutar PostgreSQL, MongoDB, Kiro u OpenCode. No se certifica la entrega integral hasta completar los pendientes anteriores.
