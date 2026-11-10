# Declaración de Uso de IA (DUIA) · TPI Food Store · Segunda Entrega

**Asignatura:** Base de Datos II · TUP · UTN · Ciclo 2026  
**Integrantes:** Agustín Ponti, David Rodrigues  
**Trabajo:** TPI Food Store · Segunda Entrega (Unidades 4 a 8)  
**Fecha:** 2026-11-09

---

## 1. Herramientas utilizadas

| Herramienta | Proveedor | Finalidad |
|-------------|-----------|-----------|
| Claude | Anthropic | Generación de scripts SQL, documentos de diseño, informes, consultas MongoDB, redacción de DUIA y bitácora |
| Kiro | (cátedra) | Requisitos EARS, diseño de roles y permisos, diseño de sincronización móvil, tareas del TP |
| OpenCode (agente Plan) | OpenCode | Revisión de código (roles, backup, restauración), generación de specs, asistencia en integración (pendiente adjuntar revisión final verificable) |
| ChatGPT (GPT-6) | OpenAI | Revisión estática del ZIP, corrección de scripts/documentación, generación de fixture MongoDB y especificaciones Kiro faltantes |

---

## 2. Qué se hizo con IA

- Redacción inicial de scripts SQL (roles, auditoría, simulacro, mantenimiento, desnormalización).
- Generación de consultas MongoDB (`consultas_mongodb.js`).
- Redacción de informes (auditoría, incidente, post-incidente, técnico).
- Generación de specs de Kiro (requisitos EARS, diseño de sincronización móvil).
- Revisión de código de `roles.sql` y scripts de backup/restauración; la revisión final con OpenCode de todos los scripts continúa pendiente.
- Redacción de la bitácora de uso de IA y esta DUIA.

---

## 3. Qué NO se hizo con IA

- Las decisiones finales de diseño (FNBC, desnormalización por triggers, PostgreSQL como fuente de verdad, mínimo privilegio, UPSERT sin borrar filas en SQLite).
- La revisión línea por línea por parte del alumno y la ejecución de todos los scripts deben completarse y documentarse antes de entregar. La asistencia de ChatGPT incluyó revisión estática y cambios en esta versión.
- Los datos de prueba son todos inventados; no se usaron datos personales reales.
- El mapa de MongoDB de la Unidad 7 y las decisiones del plan de mantenimiento de la Unidad 6 fueron tomadas por el alumno.

---

## 4. Propuestas de IA aceptadas, corregidas o descartadas

### Unidad 4 · Normalización
- **IA:** Sugirió descomposición FNBC en `responsable_deposito` + `control_lote`.  
  **Decisión:** Aceptada. Verificada con EXCEPT en ambas direcciones (0 filas de diferencia).
- **IA:** Sugirió triggers para preservar DF1.  
  **Decisión:** Aceptada. Implementados y probados (rechazan dos responsables del mismo depósito en un lote).

### Unidad 4 · Desnormalización
- **IA:** Sugirió tabla resumen mantenida por triggers (no vista materializada).  
  **Decisión:** Aceptada. Mejora de ~10,000× en consulta (113 ms → 0.011 ms).
- **IA:** Sugirió VACUUM FULL para limpieza rutinaria.  
  **Decisión:** Descartada. VACUUM FULL bloquea la tabla; se usa VACUUM normal para no afectar lecturas.

### Unidad 5 · Seguridad
- **IA:** Sugirió `GRANT ALL PRIVILEGES ON ALL TABLES TO app_web`.  
  **Decisión:** **Rechazado.** Rompe el principio de mínimo privilegio exigido por la cátedra.
- **IA:** Interpretó el escalamiento de privilegios en el simulacro como exitoso.  
  **Decisión:** **Corregida.** El log muestra `ERROR: must have admin option on role "Admin_Sintetico"`; el escalamiento falló.
- **IA:** Generó consulta `SELECT rol, COUNT(id) FROM usuario_anon GROUP BY rol;`.  
  **Decisión:** Aceptada. Sintaxis correcta, equivalencia verificada con tabla real.

### Unidad 6 · Mantenimiento
- **IA:** Generó y luego se corrigieron scripts de backup (`pg_dump -F c -b`) y restauración (`pg_restore`).  
  **Decisión:** Se incorporaron validación de archivo, salida temporal, retención configurable y restauración a una base nueva. Sintaxis Bash comprobada; la ejecución real con PostgreSQL queda pendiente.
- **IA:** Sugirió archivado de WAL cada 30 min para PITR.  
  **Decisión:** Aceptada. Incluida en el plan de mantenimiento como RPO < 1 hora.

### Unidad 7 · NoSQL
- **IA:** Sugirió embebido de líneas y cliente en el documento `pedidos`.  
  **Decisión:** Aceptada. Las líneas no existen sin el pedido y se leen siempre juntas.
- **IA:** Sugirió MongoDB como fuente de verdad para pedidos.  
  **Decisión:** **Descartada.** PostgreSQL se mantiene como fuente de verdad; MongoDB solo como réplica de lectura.

### Unidad 8 · Móvil
- **IA:** Generó `schema_sqlite.sql` con tablas STRICT, precios en centavos, CHECK constraints.  
  **Decisión:** Aceptada. Verificado con `PRAGMA integrity_check` y `foreign_key_check`.
- **IA:** Sugirió `DELETE FROM producto_cache` + recarga completa para bajas lógicas.  
  **Decisión:** **Descartada.** Rompería las FK de `item_borrador`; se usa UPSERT con `eliminado = 1`.
- **IA:** El code review final de todos los scripts con OpenCode sigue pendiente; no se declara completado.

---

## 5. Protocolo de uso de IA sobre datos

- ☐ Antes de entregar, los integrantes deben leer línea por línea, comprender y probar cada script en una copia o transacción reversible. Las pruebas no ejecutadas se identifican como pendientes en `ESTADO_REVISION.md`.
- ☐ Generar y verificar respaldo previo antes de ejecutar las migraciones que correspondan.
- ✅ Para la asistencia de IA de esta versión se utilizaron archivos del proyecto y datos de ejemplo; no se deben compartir datos personales/sensibles de la base.
- ✅ La asistencia utilizada se declara en esta DUIA y en la bitácora de IA; completar prompts exactos y fecha según el registro real de los integrantes.
- ☐ Cada integrante debe poder explicar los scripts y decisiones en la defensa oral; no declarar esta condición cumplida hasta prepararla.

---

## 6. Declaración

Esta declaración debe ser confirmada y firmada por los integrantes solo después de leer, ejecutar y comprender los scripts. La asistencia de IA no sustituye la revisión humana.

**Firma / fecha:** Agustín Ponti, David Rodrigues  2026-11-09