import 'package:flutter/material.dart'; // Importa el paquete de material design
import 'package:http/http.dart'
    as http; // Importa el paquete http para realizar peticiones
import 'dart:convert';

Future<List<Map<String, dynamic>>> obtenerProductos({String? categoria}) async {
  // Función para obtener los productos de la base de datos
  try {
    // Manejo de errores
    final url = categoria != null &&
            categoria !=
                'Todos' // Si la categoría no es nula y no es 'Todos' entonces obtén los productos por categoría
        ? 'http://localhost:3000/productos?categoria=${Uri.encodeComponent(categoria)}' // URL con la categoría
        : 'http://localhost:3000/productos'; // URL sin categoría

    print('Requesting URL: $url'); // Log para verificar la URL solicitada

    final response =
        await http.get(Uri.parse(url)); // Realiza una petición GET a la URL

    if (response.statusCode == 200) {
      // Si la petición fue exitosa
      List productos = jsonDecode(response
          .body); // Decodifica la respuesta a JSON y obtén los productos
      return productos
          .map((producto) => {
                // Mapea los productos a un mapa de datos
                'id': producto['_id'],
                'nombre': producto['name'],
                'descripcion': producto['description'],
                'precio': double.parse(producto['price']
                    .toString()), // Asegúrate de convertir a double
                'categoria': producto['category'],
                'stock': int.parse(producto['stock']
                    .toString()), // Asegúrate de convertir a int
                'imagen': producto['image'],
              })
          .toList(); // Convierte a lista
    } else {
      throw Exception(
          'Fallo al cargar los productos, código de estado: ${response.statusCode}'); // Lanza una excepción si la petición falla
    }
  } catch (e) {
    print('Error al obtener los productos: $e');
    rethrow;
  }
}

class PantallaInicio extends StatefulWidget {
  final String nombre; // Atributo nombre de tipo String requerido
  final String email; // Atributo email de tipo String requerido

  const PantallaInicio({
    // Constructor de la clase PantallaInicio con los parámetros requeridos nombre y email
    super.key,
    required this.nombre,
    required this.email,
  });

  @override
  State<PantallaInicio> createState() => _PantallaInicio();
}

class _PantallaInicio extends State<PantallaInicio> {
  // Estado de la clase PantallaInicio
  Future<List<Map<String, dynamic>>>?
      productos; // Variable de tipo Future que contendrá los productos a obtener
  String categoriaSeleccionada =
      'Todos'; // Variable de tipo String para la categoría seleccionada por defecto
  List<Map<String, dynamic>> productosEnCarrito =
      []; // Lista de productos que se agregan a la cotización

  @override
  void initState() {
    // Método initState para inicializar el estado del widget antes de que se construya
    super.initState();
    productos = obtenerProductos();
  }

  void cargarProductosPorCategoria(String? categoria) {
    // Método para cargar los productos por categoría seleccionada
    setState(() {
      categoriaSeleccionada =
          categoria ?? 'Todos'; // Actualiza la categoría seleccionada
      productos = obtenerProductos(
          categoria: categoria); // Obtiene los productos por categoría
    });
  }

  void cerrarSesion() {
    Navigator.pushReplacementNamed(context, '/');
  }

  void agregarProductoACarrito(Map<String, dynamic> producto, int cantidad) {
    // Método para agregar un producto a la cotización
    setState(() {
      producto['cantidad'] = cantidad; // Actualiza la cantidad del producto
      productosEnCarrito.add(producto); // Agrega el producto a la cotización
    });
  }

  void navegarACotizacion() {
    // Método para navegar a la pantalla de cotización
    Navigator.pushNamed(
      context,
      '/cotizacion',
      arguments: {
        'productosEnCarrito': productosEnCarrito
      }, // Argumentos a enviar a la pantalla de cotización
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<String> categorias = [
      // Lista de categorías de productos
      'Todos',
      'BEBIDAS DE PROTEINA',
      'BARRAS DE PROTEINAS',
      'PROTEINAS CERO CARBOHIDRATOS',
      'PROTEINAS MASS',
      'PROTEINAS VEGANAS',
      'PROTEINAS DE SUERO DE LECHE'
    ];
    List<ListTile> tiles = [
      // Lista de elementos de la barra lateral
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
        iconTheme: const IconThemeData(color: Colors.white), // Tema de iconos
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
                  border: Border.all(color: Colors.blueAccent),
                ),
                child: DropdownButtonHideUnderline(
                  // Oculta la línea del DropdownButton
                  child: DropdownButton<String>(
                    // DropdownButton para seleccionar la categoría
                    value:
                        categoriaSeleccionada, // Valor de la categoría seleccionada
                    onChanged: (String? nuevoValor) {
                      // Método para cambiar la categoría seleccionada
                      setState(() {
                        categoriaSeleccionada = nuevoValor ??
                            'Todos'; // Actualiza la categoría seleccionada
                      });
                      cargarProductosPorCategoria(
                          nuevoValor); // Carga los productos por la categoría seleccionada
                    },
                    items: categorias
                        .map<DropdownMenuItem<String>>((String categoria) {
                      // Mapea las categorías a un DropdownMenuItem
                      return DropdownMenuItem<String>(
                        // Retorna un DropdownMenuItem con la categoría
                        value: categoria,
                        child: Text(categoria),
                      );
                    }).toList(), // Convierte a lista
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
              // Widget que se expande para llenar el espacio disponible
              child: FutureBuilder<List<Map<String, dynamic>>>(
                // FutureBuilder para construir la lista de productos
                future: productos,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    // Si la conexión está en espera
                    return const Center(
                      // Muestra un indicador de progreso
                      child: CircularProgressIndicator(),
                    );
                  } else if (snapshot.hasError) {
                    // Si hay un error
                    return Center(
                      child:
                          Text('Error: ${snapshot.error}'), // Muestra el error
                    );
                  } else {
                    List<Map<String, dynamic>> productos =
                        snapshot.data ?? []; // Obtiene los productos
                    return GridView.builder(
                      // Construye un GridView con los productos
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
  _TarjetaProductoState createState() => _TarjetaProductoState();
}

class _TarjetaProductoState extends State<TarjetaProducto> {
  int cantidad = 1;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.pushNamed(
          context,
          '/detalles_producto',
          arguments: {'producto': widget.producto},
        );
      },
      child: Card(
        elevation: 5,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Center(
                child: ClipRRect(
                  borderRadius: const BorderRadius.only(
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
                    fontSize: 17,
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
                          ? '\$${widget.producto['precio']}'
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
                padding: const EdgeInsets.all(8.0),
                child: Center(
                  child: ElevatedButton(
                    onPressed: () {
                      widget.agregarProductoACotizacion(
                          widget.producto, cantidad);
                      // final snackBar = SnackBar(
                      //   content: Text('Producto añadido a cotizacion'),
                      //   action: SnackBarAction(
                      //     label: 'Deshacer',
                      //     onPressed: () {
                      //       // código para deshacer la acción
                      //     },
                      //   ),
                      // );

                      // ScaffoldMessenger.of(context).showSnackBar(snackBar);
                    },
                    child: const Text('Agregar a cotizacion'),
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
