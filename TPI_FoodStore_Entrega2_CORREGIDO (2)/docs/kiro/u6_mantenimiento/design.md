# Kiro · Unidad 6 · Diseño operativo

## Flujo de respaldo
Programador (cron/Task Scheduler) → validación de herramientas/configuración → `pg_dump -Fc` a archivo temporal → comprobación de tamaño → renombre atómico a `.backup` → log → limpieza por retención.

## Flujo de restauración
Validar argumentos/archivo → `pg_restore --list` → comprobar que el destino no existe → `createdb` → `pg_restore --exit-on-error` → consulta de verificación → revisión de conteos/huellas por el operador.

## Salvaguardas
- La base original nunca se elimina ni se modifica durante la restauración de prueba.
- Contraseñas fuera del código; permisos restrictivos para archivos de respaldo.
- Ejecutar restauraciones periódicas en staging y medir RTO real.
- Un `pg_dump` completo diario no equivale por sí solo a PITR. Para RPO menor se requiere configurar y probar archivado continuo de WAL.

## Operación rutinaria
Diario: revisar resultado de backup y espacio libre. Semanal: `ANALYZE`, `VACUUM (ANALYZE)` según carga, revisión de FK y logs. Mensual: restauración de muestra, revisión de retención, permisos y recuperación documentada.
