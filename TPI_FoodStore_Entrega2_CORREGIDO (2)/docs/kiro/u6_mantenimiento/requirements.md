# Kiro · Unidad 6 · Requisitos de mantenimiento y recuperación

- REQ-U6-01: El backup DEBE generarse con `pg_dump` en formato custom y nombre con fecha/hora.
- REQ-U6-02: El proceso DEBE fallar si `pg_dump` falla o el archivo resultante está vacío.
- REQ-U6-03: Las credenciales NO DEBEN almacenarse en los scripts; usar `.pgpass`/`PGPASSFILE` o mecanismo seguro equivalente.
- REQ-U6-04: La retención DEBE ser configurable y eliminar solo archivos de respaldo/log del patrón de la aplicación.
- REQ-U6-05: La restauración DEBE validar el archivo antes de crear una base destino nueva y NO sobrescribir una base existente.
- REQ-U6-06: La restauración DEBE finalizar con comprobación de conexión y enumeración de tablas; el responsable debe comparar conteos/huellas del dominio.
- REQ-U6-07: El plan DEBE incluir ANALYZE, VACUUM, integridad referencial, revisión de logs y prueba periódica de restore.
- REQ-U6-08: El simulacro DEBE medir RTO observado y documentar RPO, alcance, resultado y acciones correctivas.

## Criterios de aceptación
Backup no vacío; `pg_restore --list` legible; restauración en base separada; conteos y huellas comparados; ninguna operación destructiva sobre la base original.
