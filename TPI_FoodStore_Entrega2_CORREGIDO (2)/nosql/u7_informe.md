# TP Unidad 7 – NoSQL y nuevas formas de almacenamiento · Food Store

**Integrantes:** Agustín Ponti, David Rodrigues  
**Repositorio declarado en el proyecto:** https://github.com/AgustinPonti/TPI-FoodStore-Entrega2

> **Alcance de esta versión corregida:** se incluye un fixture MongoDB aislado, ficticio y reproducible (`datos_prueba/crear_datos_mongodb.js`) y el archivo de ocho consultas. No se declara que MongoDB fue ejecutado en esta revisión: las salidas reales deben generarse en el equipo donde esté instalado `mongosh` y pegarse en `docs/evidencias/u7_salida_mongodb.txt`.

## 1. Modelo documental

Colección `pedidos`: `_id`, `fecha`, `estado`, `total`, `cliente` embebido y `lineas` embebidas. Se embeben cliente y líneas porque el patrón de lectura habitual es recuperar el pedido completo. Cada línea conserva el identificador del producto y el precio histórico aplicado. El catálogo y el stock continúan siendo responsabilidad de PostgreSQL.

Reglas verificadas por consulta: el total declarado debe ser igual a la suma de cantidad × precio unitario; no debe haber pedidos sin líneas. El fixture aplica además un validador JSON Schema con campos obligatorios y estados permitidos.

## 2. Datos reproducibles y consultas

Los datos de prueba son ficticios y están en `nosql/datos_prueba/crear_datos_mongodb.js`. El script elimina y recrea únicamente `foodstore_nosql_prueba.pedidos`; **no debe apuntarse a una base de producción**.

### Ejecución

Desde una terminal con MongoDB Database Tools / mongosh:

```bash
mongosh
```

Dentro de `mongosh`:

```javascript
load('nosql/datos_prueba/crear_datos_mongodb.js')
use foodstore_nosql_prueba
load('nosql/consultas/consultas_mongodb.js')
```

Las ocho consultas incluidas son: pedidos entregados; pedidos con Gaseosa 500 ml; pedidos de valor alto; agregación de ventas por estado; diferencias entre total y líneas; pedidos sin líneas; top de clientes; ingresos mensuales de pedidos entregados.

### Resultados esperados del fixture (no son evidencia de ejecución)

| Control | Resultado esperado por construcción del fixture |
|---|---:|
| Documentos insertados | 5 |
| Estado ENTREGADO | 3 documentos (IDs 1001, 1002, 1003) |
| Contienen Gaseosa 500 ml | 3 documentos (IDs 1001, 1002, 1003) |
| Total > 4000 | 3 documentos |
| Totales inconsistentes | 0 |
| Pedidos sin líneas | 0 |

**Evidencia requerida:** guardar la salida de `mongosh` sin editar en `docs/evidencias/u7_salida_mongodb.txt`. Luego contrastar IDs y conteos con una consulta equivalente sobre una copia anonimizada de PostgreSQL. Si el esquema relacional real no coincide con los nombres del ejemplo, adaptar la consulta y documentar el mapeo; no afirmar equivalencia sin esa comparación.

## 3. Comparación relacional vs documental

| Criterio | PostgreSQL | MongoDB |
|---|---|---|
| Relaciones entre entidades | FK y restricciones declarativas | Referencias/embebido, integridad de dominio en aplicación/validator |
| Pedido completo | JOIN entre pedido, cliente y detalles | Un documento con cliente y líneas embebidos |
| Transacciones | ACID multi-tabla | Transacciones disponibles, con costo/operación adicional según despliegue |
| Cambios de catálogo | Normalizado y centralizado | La copia embebida puede quedar histórica/desactualizada |
| Uso elegido | Fuente de verdad de pedidos, stock y catálogo | Proyección documental de lectura si el patrón/volumen lo justifica |

**Decisión:** PostgreSQL se mantiene como fuente de verdad por la integridad referencial y las operaciones transaccionales del dominio. MongoDB puede servir como proyección de lectura para recuperar pedidos completos, pero requiere un proceso de sincronización y una estrategia de consistencia; no reemplaza automáticamente la base relacional.

## 4. Evaluación asistida por IA

Prompt registrado: “Food Store usa PostgreSQL con pedido/detalle_pedido normalizados. Casi siempre leemos el pedido completo con sus líneas y necesitamos coherencia entre cantidades y precios. Compará PostgreSQL y MongoDB para este subconjunto”.

La recomendación se contrastó con el patrón de acceso y las restricciones del dominio. La decisión humana fue mantener PostgreSQL como fuente de verdad y limitar MongoDB a una posible proyección de lectura. La IA no decide la tecnología por sí sola.

## 5. Pendiente antes de cerrar la unidad

- Ejecutar el fixture y las ocho consultas en `mongosh`.
- Guardar la salida real en `docs/evidencias/u7_salida_mongodb.txt`.
- Ejecutar consultas equivalentes sobre una copia de PostgreSQL y comparar identificadores, no solo cantidades.
- Completar la fecha, entorno y observaciones de la evidencia.
