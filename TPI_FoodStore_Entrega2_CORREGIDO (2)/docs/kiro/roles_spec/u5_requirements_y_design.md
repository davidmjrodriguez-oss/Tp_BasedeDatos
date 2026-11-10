# Kiro · Unidad 5 · Requisitos y diseño de roles/permisos

## Objetivo
Separar acceso de aplicación, soporte y reportes bajo mínimo privilegio. El diseño no debe conceder `ALL` ni permisos generales sobre todas las tablas.

## Requisitos
- REQ-U5-01: Los roles de grupo DEBEN ser `NOLOGIN` y las cuentas de conexión deben recibir únicamente los grupos requeridos.
- REQ-U5-02: El rol de lectura DEBE leer solo las tablas del catálogo necesarias.
- REQ-U5-03: El rol de escritura DEBE operar solo sobre pedido/detalle de pedido; no debe modificar catálogo ni usuarios.
- REQ-U5-04: El rol de reportes DEBE leer una vista/tabla anonimizada y no la tabla de usuarios real.
- REQ-U5-05: El rol de soporte NO DEBE recibir permisos de escritura sobre datos de negocio.
- REQ-U5-06: Las contraseñas NO DEBEN estar hardcodeadas en SQL o repositorio.
- REQ-U5-07: La auditoría DEBE registrar conexiones, cambios y lecturas sensibles; la lectura debe probarse con pgAudit o equivalente porque `log_statement='mod'` no registra SELECT.

## Diseño
- `rol_app_lectura`: SELECT limitado a `categoria`, `producto`, `etiqueta`, `producto_etiqueta` si existen.
- `rol_app_escritura`: SELECT/INSERT/UPDATE en `pedido`; SELECT/INSERT/UPDATE/DELETE en `detalle_pedido`; secuencia de pedido si corresponde.
- `rol_reportes`: SELECT solo sobre `usuario_anon` si existe.
- `rol_soporte`: acceso de metadatos sin escritura sobre tablas de negocio.
- `app_web`: membresía en lectura y escritura.
- `admin_datos`: membresía en soporte/reportes; no es superusuario.

## Criterios de aceptación
`has_table_privilege('app_web','public.usuario','SELECT')` debe ser false; los grants deben listar solo los objetos requeridos; SELECT sensible debe aparecer en el log de auditoría configurado; el intento de GRANT desde `app_web` debe fallar.

## Operación
Ejecutar `relacional/u5_roles_permisos.sql` como administrador en una base de prueba. Adaptar nombres de tablas/secuencias al esquema real. Asignar contraseñas de forma interactiva con `\\password` o un gestor de secretos. No guardar credenciales en Git.
