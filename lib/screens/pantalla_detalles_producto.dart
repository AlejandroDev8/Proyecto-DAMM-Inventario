// pantalla_detalles.dart
import 'package:flutter/material.dart';

class PantallaDetallesProducto extends StatelessWidget {
  final Map<String, dynamic> producto;

  const PantallaDetallesProducto({super.key, required this.producto});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(producto['nombre'], style: const TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xff283673),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Center(
              child: Image.network(
                producto['imagen'],
                height: 200,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              producto['nombre'],
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Text(
              'Clave de producto: ${producto['id']}',
              style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: Colors.blueGrey),
            ),
            const SizedBox(height: 8),
            Text(
              'Stock: ${producto['stock']}',
              style: const TextStyle(fontSize: 16, color: Colors.blueGrey),
            ),
            const SizedBox(height: 8),
            Text(
              'Categoría: ${producto['categoria']}',
              style: const TextStyle(fontSize: 16, color: Colors.blueGrey),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Spacer(),
                Text(
                  '\$${producto['precio'].toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 24,
                    color: Colors.blueAccent,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              producto['descripcion'],
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 8),

          ],
        ),
      ),
    );
  }
}
