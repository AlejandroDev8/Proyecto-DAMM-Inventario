import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:login/screens/pantalla_inicio.dart';
import 'dart:convert';

class Login extends StatefulWidget {
  const Login({super.key}); //super.key es un parametro opcional

  @override
  State<Login> createState() =>
      _LoginViewState(); //retorna el estado de la clase _LoginViewState
}

class _LoginViewState extends State<Login> {
  final _formfield = GlobalKey<
      FormState>(); //variable global de tipo FormState para validar el formulario
  final emailController =
      TextEditingController(); //variable global de tipo TextEditingController para obtener el valor del campo de texto
  final passController = TextEditingController();
  bool passToggle =
      true; //variable global de tipo booleano para mostrar u ocultar la contraseña

  Future<String?> authenticateUser(String email, String password) async {
    //funcion asincrona que recibe dos parametros de tipo String
    //el future es una forma de ejecutar una operacion asincrona y obtener un resultado en el futuro, es decir que no se bloquea el hilo principal
    //en otras palabras es una operacion que no se ejecuta de manera inmediata pero que se espera se ejecute en algun momento despues de ser llamada
    //funcion asincrona que recibe dos parametros de tipo String
    try {
      final response = await http.post(
        //variable de tipo http.Response que realiza una peticion POST
        Uri.parse(
            'http://localhost:3000/login'), //direccion del servidor para ejecucion, en el telfono tiene que apuntar a la dirrecion ip del servidor por ejemplo http://192.168.1.79:3000:login
        body: jsonEncode(<String, String>{
          'email': email, //parametros que se envian al servidor
          'password': password,
        }),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );
      //imprime en consola el estado de la respuesta y el cuerpo de la respuesta
      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        Map<String, dynamic> data =
            jsonDecode(response.body); //decodifica el json
        if (data['authenticated'] == true) {
          //si el usuario esta autenticado
          return data['nombre']; //retorna el nombre del usuario
        }
      }
    } catch (e) {
      //captura el error
      print('Error: $e');
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 60),
          child: Form(
            key:
                _formfield, //asigna la variable global _formfield al formulario
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Container(
                  width: 300,
                  height: 300,
                  decoration: const BoxDecoration(
                      shape: BoxShape.circle, color: Color(0xff283673)),
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Image.asset("assets/logo.jpeg"),
                  ),
                ),
                const SizedBox(height: 50),
                TextFormField(
                  keyboardType: TextInputType.emailAddress,
                  controller:
                      emailController, //un controller es un objeto que permite manipular el campo de texto
                  decoration: const InputDecoration(
                    labelText: "Correo",
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.email),
                  ),
                  validator: (value) {
                    //valida el campo de texto
                    if (value!.isEmpty) {
                      //si el campo esta vacio
                      return 'Ingrese su correo';
                    }
                    bool emailValid = RegExp(
                            r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$') //expresion regular para validar el correo
                        .hasMatch(value);
                    if (!emailValid) {
                      return 'Ingrese un correo valido';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                TextFormField(
                    keyboardType: TextInputType.visiblePassword,
                    controller: passController,
                    obscureText: passToggle,
                    decoration: InputDecoration(
                      labelText: "Contraseña",
                      border: const OutlineInputBorder(),
                      prefixIcon: const Icon(Icons.lock),
                      suffix: InkWell(
                        onTap: () {
                          setState(() {
                            passToggle =
                                !passToggle; //muestra u oculta la contraseña
                          });
                        },
                        child: Icon(
                            passToggle //muestra el icono de visibilidad o de ocultar contraseña
                                ? Icons.visibility
                                : Icons.visibility_off),
                      ),
                    ),
                    validator: (value) {
                      if (value!.isEmpty) {
                        //si el campo esta vacio
                        return 'Ingrese su contraseña';
                      }
                      if (value.length < 8) {
                        //si la contraseña tiene menos de 8 caracteres
                        return 'La contraseña debe tener al menos 8 caracteres';
                      }
                      return null;
                    }),
                const SizedBox(height: 50),
                GestureDetector(
                  //detecta el gesto
                  onTap: () async {
                    if (_formfield.currentState?.validate() ?? false) {
                      //si el formulario es valido
                      String? nombre = await authenticateUser(
                        //llama a la funcion authenticateUser
                        emailController.text, //parametros que recibe la funcion
                        passController.text,
                      );

                      if (nombre != null) {
                        //si el nombre no es nulo
                        Navigator.pushReplacement(
                          //navega a la pantalla de inicio
                          context,
                          MaterialPageRoute(
                            builder: (context) => PantallaInicio(
                              //envia los parametros a la pantalla de inicio
                              nombre: nombre,
                              email: emailController.text,
                            ),
                          ),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          //muestra un mensaje emergente
                          const SnackBar(
                              content: Text('Email o contraseña incorrectos')),
                        );
                      }
                    }
                  },
                  child: Container(
                    height: 50,
                    decoration: BoxDecoration(
                      color: const Color(0xff283673),
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: const Center(
                      child: Text(
                        'Iniciar sesión',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("¿No tienes una cuenta?",
                        style: TextStyle(fontSize: 16)),
                    TextButton(
                      onPressed: () {
                        Navigator.pushNamed(context, '/registro');
                      },
                      child: const Text(
                        "Registrate",
                        style: TextStyle(
                          fontSize: 16,
                          color: Color(0xff283673),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
