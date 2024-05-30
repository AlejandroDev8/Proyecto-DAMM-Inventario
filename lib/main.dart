import 'package:flutter/material.dart';
import 'screens/pantalla_inicio.dart';
import 'screens/pantalla_cotizacion.dart';
import 'screens/pantalla_detalles_producto.dart';
import 'screens/registro.dart';
import 'screens/login.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'NutriStock',
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      //onGenerateRoute se usa para generar rutas que requieren pasar argumentos o datos adicionales a la pantalla que se esta navegando
      onGenerateRoute: (settings) { 
        switch (settings.name) { //selecciona la ruta
          case '/inicio':
            final args = settings.arguments as Map<String, String>;
            return MaterialPageRoute(
              builder: (_) => PantallaInicio( //retorna la pantalla de inicio
                nombre: args['nombre']!, //nombre del usuario
                email: args['email']!, //correo del usuario
              ),
            );
            case '/cotizacion':
            final args = settings.arguments as Map<String, dynamic>;
            return MaterialPageRoute(
              builder: (_) => PantallaCotizacion(
                productosEnCotizacion: args['productosEnCarrito'],
              ),
            );
            case '/detalles_producto': // Nueva ruta para detalles de producto
            final args = settings.arguments as Map<String, dynamic>;
            return MaterialPageRoute(
              builder: (_) => PantallaDetallesProducto(
                producto: args['producto'],
              ),
            );
          default:
            throw Exception('Ruta no definida'); 
        }
      },
//routes se usa mas para generar rutas que no requieren pasar argumentos o datos adicionales a la pantalla que se esta navegando
      routes: { 
        '/': (context) => const Login(),        
        '/registro': (context) => const Registro(),
      },
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
    );
  }
}
