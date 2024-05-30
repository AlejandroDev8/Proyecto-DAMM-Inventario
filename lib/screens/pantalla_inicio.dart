import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

// Fetch products from the server with optional filtering by category or name
Future<List<Map<String, dynamic>>> obtenerProductos(
    {String? categoria, String? nombre}) async {
  try {
    String url;
    // Build the URL based on the category and name parameters
    if (categoria != null && categoria != 'Todos') {
      url =
          'http://localhost:3000/productos?categoria=${Uri.encodeComponent(categoria)}';
    } else if (nombre != null && nombre.isNotEmpty) {
      url =
          'http://localhost:3000/productos?nombre=${Uri.encodeComponent(nombre)}';
    } else {
      url = 'http://localhost:3000/productos';
    }

    print('Requesting URL: $url');

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      List productos = jsonDecode(response.body);
      return productos
          .map((producto) => {
                'id': producto['_id'],
                'nombre': producto['name'],
                'descripcion': producto['description'],
                'precio': double.parse(producto['price'].toString()),
                'categoria': producto['category'],
                'stock': int.parse(producto['stock'].toString()),
                'imagen': producto['image'],
              })
          .toList();
    } else {
      throw Exception(
          'Failed to load products, status code: ${response.statusCode}');
    }
  } catch (e) {
    print('Error fetching products: $e');
    rethrow;
  }
}

class PantallaInicio extends StatefulWidget {
  final String nombre;
  final String email;

  const PantallaInicio({super.key, required this.nombre, required this.email});

  @override
  State<PantallaInicio> createState() => _PantallaInicio();
}

class _PantallaInicio extends State<PantallaInicio> {
  Future<List<Map<String, dynamic>>>? productos;
  String categoriaSeleccionada = 'Todos';
  String nombreBusqueda = '';
  List<Map<String, dynamic>> productosEnCarrito = [];

  @override
  void initState() {
    super.initState();
    productos = obtenerProductos();
  }

  void cargarProductosPorCategoria(String? categoria) {
    setState(() {
      categoriaSeleccionada = categoria ?? 'Todos';
      productos = obtenerProductos(categoria: categoria);
    });
  }

  void cargarProductosPorNombre(String? nombre) {
    setState(() {
      nombreBusqueda = nombre ?? '';
      productos = obtenerProductos(nombre: nombre);
    });
  }

  void cerrarSesion() {
    Navigator.pushReplacementNamed(context, '/');
  }

  void agregarProductoACarrito(Map<String, dynamic> producto, int cantidad) {
    setState(() {
      producto['cantidad'] = cantidad;
      productosEnCarrito.add(producto);
    });
  }

  void navegarACotizacion() {
    Navigator.pushNamed(context, '/cotizacion',
        arguments: {'productosEnCarrito': productosEnCarrito});
  }

  @override
  Widget build(BuildContext context) {
    final busquedaController = TextEditingController();
    final List<String> categorias = [
      'Todos',
      'BEBIDAS DE PROTEINA',
      'BARRAS DE PROTEINAS',
      'PROTEINAS CERO CARBOHIDRATOS',
      'PROTEINAS MASS',
      'PROTEINAS VEGANAS',
      'PROTEINAS DE SUERO DE LECHE'
    ];
    List<ListTile> tiles = [
      ListTile(
          title: const Text("Inicio"),
          leading: const Icon(Icons.home),
          onTap: () {
            Navigator.pop(context);
          }),
      ListTile(
          title: const Text("Cotizaciones"),
          leading: const Icon(Icons.shopping_cart),
          onTap: () {
            navegarACotizacion();
          }),
      ListTile(
          title:
              const Text("Cerrar sesión", style: TextStyle(color: Colors.red)),
          leading: const Icon(Icons.logout, color: Colors.red),
          onTap: () {
            showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: const Text('Cerrar sesión'),
                    content: const Text(
                        '¿Estas seguro de que quieres cerrar sesión?'),
                    actions: <Widget>[
                      TextButton(
                        child: const Text('Cancelar'),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      ),
                      TextButton(
                        child: const Text('Si'),
                        onPressed: () {
                          cerrarSesion();
                        },
                      )
                    ],
                  );
                });
          }),
    ];

    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: const Color(0xff283673),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            const Expanded(
              child: Center(
                child: Text('NutriStock',
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.shopping_cart, color: Colors.white),
              onPressed: () {
                navegarACotizacion();
              },
            ),
          ],
        ),
      ),
      drawer: Theme(
        data: Theme.of(context).copyWith(
          iconTheme: const IconThemeData(color: Colors.white),
        ),
        child: Drawer(
          child: ListView(
            children: [
              UserAccountsDrawerHeader(
                accountName: Text(widget.nombre),
                accountEmail: Text(widget.email),
                currentAccountPicture: const CircleAvatar(
                  backgroundImage: AssetImage("assets/logo.jpeg"),
                ),
                decoration: const BoxDecoration(color: Color(0xff283673)),
              ),
              ...tiles
            ],
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Center(
                child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 20.0, vertical: 5.0),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30.0),
                  border: Border.all(color: Colors.blueAccent)),
              child: TextFormField(
                controller: busquedaController,
                decoration: InputDecoration(
                    labelText: "Buscar producto",
                    suffix: InkWell(
                      onTap: () {
                        cargarProductosPorNombre(busquedaController.text); 
                      },
                      child: const Icon(Icons.search),
                    )),
              ),
            )),
            const SizedBox(height: 7),
            Center(
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20.0, vertical: 5.0),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30.0),
                  border: Border.all(color: Colors.blueAccent),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: categoriaSeleccionada,
                    onChanged: (String? nuevoValor) {
                      setState(() {
                        categoriaSeleccionada = nuevoValor ?? 'Todos';
                      });
                      cargarProductosPorCategoria(nuevoValor);
                    },
                    items: categorias
                        .map<DropdownMenuItem<String>>((String categoria) {
                      return DropdownMenuItem<String>(
                        value: categoria,
                        child: Text(categoria),
                      );
                    }).toList(),
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.black87,
                    ),
                    dropdownColor: Colors.white,
                    icon: const Icon(Icons.arrow_drop_down,
                        color: Colors.blueAccent),
                    isExpanded: true,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: FutureBuilder<List<Map<String, dynamic>>>(
                future: productos,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  } else if (snapshot.hasError) {
                    return Center(
                      child: Text('Error: ${snapshot.error}'),
                    );
                  } else {
                    List<Map<String, dynamic>> productos = snapshot.data ?? [];
                    return GridView.builder(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 0.7,
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                      ),
                      itemCount: productos.length,
                      itemBuilder: (context, index) {
                        return TarjetaProducto(
                          producto: productos[index],
                          agregarProductoACotizacion: (producto, cantidad) {
                            agregarProductoACarrito(producto, cantidad);
                          },
                        );
                      },
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class TarjetaProducto extends StatefulWidget {
  final Map<String, dynamic> producto;
  final Function(Map<String, dynamic>, int) agregarProductoACotizacion;

  const TarjetaProducto({
    super.key,
    required this.producto,
    required this.agregarProductoACotizacion,
  });

  @override
  State<TarjetaProducto> createState() => _TarjetaProducto();
}

class _TarjetaProducto extends State<TarjetaProducto> {
  int cantidad = 1;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap:(){
        Navigator.pushNamed(
          context,
          '/detalles_producto',
          arguments: {'producto': widget.producto},
        );
      },
      child: Card(
        elevation: 4.0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Center(
                child: ClipRRect(
                  borderRadius:const BorderRadius.only(
                    topLeft: Radius.circular(15),
                    topRight: Radius.circular(15),
                  ),
                  child: Image.network(
                      widget.producto['imagen'],
                      height: 100,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return const Icon(Icons.broken_image, size: 100);
                      },
                    ),
                ),
              ),
              Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    widget.producto['nombre'] ?? 'Nombre no disponible',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      widget.producto['precio'] != null
                          ? '\$${widget.producto['precio'].toStringAsFixed(2)}'
                          : 'Precio no disponible',
                      style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Colors.blueAccent),
                    ),
                    Row(
                      children: [
                        IconButton(
                          onPressed: () {
                            setState(() {
                              if (cantidad > 1) {
                                cantidad--;
                              }
                            });
                          },
                          icon: const Icon(Icons.remove),
                        ),
                        Text(cantidad.toString()),
                        IconButton(
                          onPressed: () {
                            setState(() {
                              if (cantidad < widget.producto['stock']) {
                                cantidad++;
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content: Text(
                                          'No hay suficiente stock disponible')),
                                );
                              }
                            });
                          },
                          icon: const Icon(Icons.add),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(3.0),
                child: Center(
                  child: ElevatedButton(
                    onPressed: () {
                      widget.agregarProductoACotizacion(
                          widget.producto, cantidad);
                    },
                    child: const Text('Agregar al carrito'),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
