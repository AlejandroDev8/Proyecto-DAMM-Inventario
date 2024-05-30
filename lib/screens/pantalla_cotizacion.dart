import 'package:flutter/material.dart';

class PantallaCotizacion extends StatefulWidget {
  final List<Map<String, dynamic>> productosEnCotizacion; //variable global de tipo lista de mapas de tipo String y dynamic

  const PantallaCotizacion({super.key, required this.productosEnCotizacion}); //constructor de la clase PantallaCotizacion que recibe un parametro obligatorio

  @override
  State<PantallaCotizacion> createState() => _PantallaCotizacionState();
}

class _PantallaCotizacionState extends State<PantallaCotizacion> {
  @override
  Widget build(BuildContext context) {
    //variable de tipo double que suma el precio por la cantidad de los productos en la lista productosEnCotizacion
    double total = widget.productosEnCotizacion.fold(0, (sum, item) => sum + (item['precio'] * item['cantidad'])); 

    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text('Cotizacion de Productos', style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xff283673),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            Expanded( //widget que se expande para llenar el espacio disponible
              child: ListView.builder( //constructor de lista que crea una lista de elementos de acuerdo a los elementos de la lista productosEnCarrito
                itemCount: widget.productosEnCotizacion.length, //numero de elementos de la lista
                itemBuilder: (context, index) {
                  return ListTile( //widget de tipo ListTile que muestra un elemento de la lista
                    leading: Image.network(
                      widget.productosEnCotizacion[index]['imagen'],
                      width: 50,
                      height: 50,
                      fit: BoxFit.cover,
                    ),
                    title: Text(widget.productosEnCotizacion[index]['nombre']),
                    subtitle: Text('Cantidad: ${widget.productosEnCotizacion[index]['cantidad']}'),
                    trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  //muestra el precio total del producto
                  Text('\$${(widget.productosEnCotizacion[index]['precio'] * widget.productosEnCotizacion[index]['cantidad']).toStringAsFixed(2)}'),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: const Text("Confirmar"),
                            content: const Text("¿Estás seguro de que quieres eliminar este producto?"),
                            actions: <Widget>[
                              TextButton(
                                child: const Text("Cancelar"),
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                              ),
                              TextButton(
                                child: const Text("Eliminar"),
                                onPressed: () {
                                  setState(() {
                                    widget.productosEnCotizacion.removeAt(index);
                                  });
                                  Navigator.of(context).pop();
                                },
                              ),
                            ],
                          );
                        },
                      );
                    },
                  ),
                ],
              ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Total: \$${total.toStringAsFixed(2)}',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
              },
              child: const Text('Finalizar Cotizacion'),
            ),
          ],
        ),
      ),
    );
  }
}