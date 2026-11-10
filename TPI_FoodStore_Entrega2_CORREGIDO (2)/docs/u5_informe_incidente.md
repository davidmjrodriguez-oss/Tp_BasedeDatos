# Informe de incidente · Unidad 5

## Escenario de laboratorio
Simulacro de acceso indebido con intentos fallidos de autenticación, una conexión válida, intento de lectura de datos y un intento de elevar privilegios desde un rol de aplicación.

## Interpretación correcta
El registro de ejemplo muestra un error explícito en el `GRANT`: `must have admin option on role`. Por lo tanto, el escalamiento **no tuvo éxito**. No debe describirse como privilegio obtenido.

La lectura masiva solo puede afirmarse como detectada si el SELECT quedó registrado por pgAudit o un mecanismo de auditoría de lectura. `log_statement='mod'` no captura SELECT y no basta para sustentar esa conclusión.

## Contención propuesta
1. Revocar sesiones y credenciales potencialmente comprometidas; rotar secretos.
2. Bloquear temporalmente el origen en firewall si se confirma que es malicioso, evitando bloquear rangos compartidos sin análisis.
3. Revisar roles, membresías y grants; revocar privilegios innecesarios.
4. Preservar logs originales con permisos restringidos y calcular hash para mantener trazabilidad.
5. Evaluar alcance de datos leídos y obligaciones de notificación según normativa/política aplicable.
6. Restaurar el servicio solo después de validar credenciales, privilegios y monitoreo.

## Estado
Los logs incluidos son datos sintéticos/anónimos de demostración. Para afirmar que el simulacro se ejecutó, adjuntar un log generado por la instancia de pruebas con la auditoría READ activada.
