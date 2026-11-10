# Informe de auditoría · Unidad 5

## Configuración y alcance
Configuración nativa de referencia en `postgresql.conf`:

```conf
logging_collector = on
log_destination = 'stderr'
log_connections = on
log_disconnections = on
log_statement = 'mod'
```

**Importante:** `log_statement = 'mod'` registra DDL/DML, pero no SELECT. Por lo tanto, por sí solo NO permite reconstruir una lectura masiva. Para auditar lecturas se debe instalar/configurar pgAudit (por ejemplo `shared_preload_libraries = 'pgaudit'`, reiniciar el servidor, `CREATE EXTENSION pgaudit` y `pgaudit.log = 'read, write, ddl'`) o una solución equivalente aprobada por el administrador. La disponibilidad y los pasos exactos dependen de la instalación PostgreSQL.

## Eventos a reconstruir
- Intentos de autenticación fallidos: usuario, fecha/hora, origen disponible en el log.
- Conexión exitosa.
- Lectura masiva: evento READ/SELECT registrado por pgAudit o mecanismo equivalente.
- Intento de elevación de privilegios: sentencia GRANT y resultado ERROR.

## Limitaciones y protección
Los logs no garantizan el detalle histórico de cada valor de fila. Los logs pueden contener consultas y literales sensibles: acceso restringido al administrador, retención definida y anonimización antes de compartir evidencias.

## Estado de evidencia
`docs/evidencias/u5_log_auditoria.txt` y `u5_log_simulacro.txt` son ejemplos anonimizados/sintéticos aportados al proyecto; no se presentan como captura verificable de una instancia activa en esta revisión. Antes de cerrar la unidad, activar el mecanismo elegido, ejecutar el simulacro en una base de pruebas y sustituirlos por logs reales anonimizados.
