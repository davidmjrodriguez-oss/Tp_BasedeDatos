// Unidad 7 · Fixture reproducible con datos 100% ficticios.
// Ejecutar en mongosh sobre la base aislada foodstore_nosql_prueba.
// No importa ni copia datos personales desde PostgreSQL.
const dbPrueba = db.getSiblingDB('foodstore_nosql_prueba');
dbPrueba.pedidos.drop();
dbPrueba.createCollection('pedidos', {
  validator: {
    $jsonSchema: {
      bsonType: 'object',
      required: ['_id', 'fecha', 'estado', 'total', 'cliente', 'lineas'],
      properties: {
        _id: { bsonType: 'int' },
        fecha: { bsonType: 'string' },
        estado: { enum: ['PENDIENTE', 'PREPARANDO', 'ENTREGADO', 'CANCELADO'] },
        total: { bsonType: ['int', 'long', 'double'], minimum: 0 },
        cliente: { bsonType: 'object', required: ['id', 'nombre'] },
        lineas: { bsonType: 'array', minItems: 1, items: { bsonType: 'object', required: ['producto_id', 'producto', 'cantidad', 'precio_unitario'] } }
      }
    }
  },
  validationLevel: 'strict',
  validationAction: 'error'
});

dbPrueba.pedidos.insertMany([
  { _id: NumberInt(1001), fecha: '2026-10-10T12:00:00Z', estado: 'ENTREGADO', total: NumberInt(9400), cliente: { id: NumberInt(1), nombre: 'Cliente Demo Uno', apellido: 'Prueba', email: 'cliente1@example.test' }, lineas: [ { detalle_id: 1, producto_id: 4, producto: 'Gaseosa 500 ml', cantidad: 2, precio_unitario: 1200 }, { detalle_id: 2, producto_id: 1, producto: 'Hamburguesa clasica', cantidad: 2, precio_unitario: 3500 } ] },
  { _id: NumberInt(1002), fecha: '2026-10-10T13:15:00Z', estado: 'ENTREGADO', total: NumberInt(5400), cliente: { id: NumberInt(2), nombre: 'Cliente Demo Dos', apellido: 'Prueba', email: 'cliente2@example.test' }, lineas: [ { detalle_id: 3, producto_id: 4, producto: 'Gaseosa 500 ml', cantidad: 1, precio_unitario: 1200 }, { detalle_id: 4, producto_id: 3, producto: 'Papas fritas', cantidad: 1, precio_unitario: 1800 }, { detalle_id: 5, producto_id: 6, producto: 'Choripan', cantidad: 1, precio_unitario: 2400 } ] },
  { _id: NumberInt(1003), fecha: '2026-10-11T19:00:00Z', estado: 'ENTREGADO', total: NumberInt(6200), cliente: { id: NumberInt(1), nombre: 'Cliente Demo Uno', apellido: 'Prueba', email: 'cliente1@example.test' }, lineas: [ { detalle_id: 6, producto_id: 4, producto: 'Gaseosa 500 ml', cantidad: 2, precio_unitario: 1200 }, { detalle_id: 7, producto_id: 2, producto: 'Hamburguesa doble', cantidad: 1, precio_unitario: 3800 } ] },
  { _id: NumberInt(1004), fecha: '2026-10-12T20:30:00Z', estado: 'PREPARANDO', total: NumberInt(3500), cliente: { id: NumberInt(3), nombre: 'Cliente Demo Tres', apellido: 'Prueba', email: 'cliente3@example.test' }, lineas: [ { detalle_id: 8, producto_id: 1, producto: 'Hamburguesa clasica', cantidad: 1, precio_unitario: 3500 } ] },
  { _id: NumberInt(1005), fecha: '2026-10-13T10:30:00Z', estado: 'CANCELADO', total: NumberInt(1800), cliente: { id: NumberInt(2), nombre: 'Cliente Demo Dos', apellido: 'Prueba', email: 'cliente2@example.test' }, lineas: [ { detalle_id: 9, producto_id: 3, producto: 'Papas fritas', cantidad: 1, precio_unitario: 1800 } ] }
]);

dbPrueba.pedidos.createIndex({ estado: 1, fecha: -1 });
dbPrueba.pedidos.createIndex({ 'lineas.producto_id': 1 });
print('Fixture cargado en foodstore_nosql_prueba.pedidos: ' + dbPrueba.pedidos.countDocuments());
