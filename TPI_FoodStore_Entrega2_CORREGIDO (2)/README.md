# TPI Food Store · Segunda entrega · Unidades 4 a 8

Proyecto académico de capa de datos: PostgreSQL (relacional), MongoDB (documental) y SQLite (móvil).

## Estructura

- `relacional/`: normalización FNBC, desnormalización controlada, roles/auditoría y mantenimiento.
- `nosql/`: modelo documental, fixture ficticio y ocho consultas MongoDB.
- `movil/`: esquema SQLite, datos de prueba y simulación de sincronización.
- `docs/kiro/`: requisitos, diseño y tareas por unidad.
- `docs/evidencias/`: salidas disponibles y plantillas marcadas como pendientes.
- `DUIA.md`, `bitacora_IA.md`: declaración y registro de asistencia de IA.
- `ESTADO_REVISION.md`: alcance de la revisión y pruebas que faltan ejecutar localmente.

## Seguridad antes de ejecutar

1. Trabajar exclusivamente en bases de prueba con datos ficticios/anonimizados.
2. Leer los scripts completos y entenderlos antes de ejecutarlos.
3. No guardar contraseñas en archivos SQL o shell. Configurar `.pgpass`/`PGPASSFILE` con permisos restrictivos.
4. No ejecutar scripts destructivos contra producción.
5. Los scripts de Unidad 4 ahora aíslan sus objetos en `u4_fnbc_lab` y `u4_desnormalizacion_lab`.
6. La restauración de Unidad 6 crea una base nueva y se niega a sobrescribir una existente.

## Unidad 4 · PostgreSQL

En una base PostgreSQL de laboratorio:

```bash
psql -d food_store_pruebas -f relacional/u4_fnbc_control_lote.sql
psql -d food_store_pruebas -f relacional/u4_plan_reversion.sql
psql -d food_store_pruebas -f relacional/u4_desnormalizacion_top_categorias.sql
```

Los scripts crean objetos dentro de esquemas propios. Revisar las salidas y guardar evidencia real.

## Unidad 5 · Roles y auditoría

Ejecutar `relacional/u5_roles_permisos.sql` como administrador en una base de pruebas. El script no asigna contraseñas; configurar credenciales por un canal seguro. La auditoría `log_statement='mod'` no registra SELECT. Para demostrar lectura masiva debe configurarse pgAudit u otro mecanismo que audite READ, según las instrucciones de `docs/u5_informe_auditoria.md`.

## Unidad 6 · Mantenimiento

En Linux, WSL o Git Bash con herramientas PostgreSQL en PATH:

```bash
DB_NAME=food_store BACKUP_DIR="$HOME/respaldos" ./relacional/u6_backup_programado.sh
./relacional/u6_restauracion.sh "$HOME/respaldos/food_store_FECHA.backup" food_store_restaurada
```

Ajustar `DB_HOST`, `DB_PORT`, `DB_USER`, `DB_NAME` y `BACKUP_DIR` según el laboratorio. Usar `.pgpass`/`PGPASSFILE`; no pegar contraseñas en comandos compartidos. La restauración se niega a usar un nombre de base ya existente.

`relacional/u6_plan_mantenimiento.sql` contiene tareas SQL para las tablas del esquema Food Store y debe ejecutarse conectado a una copia compatible.

## Unidad 7 · MongoDB

Requiere `mongosh`. Ejecutar desde la raíz del proyecto:

```javascript
load('nosql/datos_prueba/crear_datos_mongodb.js')
use foodstore_nosql_prueba
load('nosql/consultas/consultas_mongodb.js')
```

El fixture elimina/recrea solamente la colección `foodstore_nosql_prueba.pedidos`. No usar en producción. Guardar la salida real en `docs/evidencias/u7_salida_mongodb.txt` y completar la comparación de IDs con PostgreSQL.

## Unidad 8 · SQLite y sincronización simulada

La base incluida es `movil/foodstore_movil.db`. Para verificar integridad con Python:

```bash
python -c "import sqlite3; c=sqlite3.connect('movil/foodstore_movil.db'); print(c.execute('PRAGMA integrity_check').fetchall()); print(c.execute('PRAGMA foreign_key_check').fetchall()); c.close()"
```

La simulación completa requiere PostgreSQL local, `psql` en PATH y una base de prueba llamada `foodstore_prueba`. Ejecutar desde `movil/`:

```bash
python simulacion_completa.py
```

El simulador crea `foodstore_movil_simulacion.db` para no sobrescribir la base incluida y reinicializa las tablas del esquema de prueba PostgreSQL en `foodstore_prueba`; usar esa base solo para el laboratorio.

## Estado de entrega

La corrección estática y las verificaciones locales de SQLite/Python se detallan en `ESTADO_REVISION.md`. Las evidencias que dependen de PostgreSQL, MongoDB, Kiro y OpenCode deben generarse en el equipo del alumno y no se consideran ejecutadas por el solo hecho de incluir los scripts.
