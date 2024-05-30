const express = require("express"); // Importar el paquete express
const MongoClient = require("mongodb").MongoClient; // Importar el paquete mongodb
const cors = require("cors"); // Importar el paquete cors que permite peticiones entre servidores
const bodyParser = require("body-parser"); // Importar el paquete body-parser que permite leer el cuerpo de las peticiones

const app = express(); // Crear una instancia de express
app.use(cors()); // Habilitar las peticiones entre servidores
app.use(bodyParser.json()); // Habilitar la lectura del cuerpo de las peticiones

const uri =
  "mongodb+srv://alejandrodeveloper417:ccwh0XVcnzfphfT3@nutristock.fpenfkp.mongodb.net/nutristock"; // URI de la base de datos

const client = new MongoClient(uri); // Crear una instancia del cliente de MongoDB

//peticiones http
//200 quiere decir que todo esta bien
//500 quiere decir que hubo un error en el servidor
//404 quiere decir que no se encontro la pagina
//401 quiere decir que no estas autorizado para ver la pagina
//400 quiere decir que hubo un error en la peticion

app.get("/data", async (req, res) => {
  // Ruta para obtener los datos
  try {
    await client.connect(); // Conectar a la base de datos
    const collection = client.db("users").collection("workers"); // Conexión a la base de datos y colección
    const data = await collection.find({}).toArray(); // Obtener los datos de la colección
    console.log(data); // Mostrar los datos en consola
    res.json(data); // Enviar los datos como respuesta
  } catch (err) {
    console.error(err);
    res.status(500).send("Error connecting to database");
  } finally {
    await client.close();
  }
});

//puedes ayudarme a comentar el codigo

app.get("/productos", async (req, res) => {
  // Ruta para obtener los productos
  try {
    await client.connect();
    const collection = client.db("store").collection("products"); // Conexión a la base de datos y colección
    const categoria = req.query.categoria; // Obtener la categoría de la URL
    const nombre = req.query.nombre;
    let filter = {};

    if (categoria) {
      filter.category = categoria; //
    }

    if (nombre) {
      filter.name = { $regex: new RegExp(`^${nombre}`, "i") };
    }

    console.log("Filter:", filter); // Mostrar el filtro en consola
    const data = await collection.find(filter).toArray(); // Obtener los productos de la colección
    console.log(data);
    res.json(data); // Enviar los productos como respuesta
  } catch (err) {
    console.error(err);
    res.status(500).send("Error connecting to database"); // Enviar un mensaje de error si hay un problema
  } finally {
    await client.close(); // Cerrar la conexión a la base de datos
  }
});

app.post("/login", async (req, res) => {
  // Ruta para iniciar sesión
  const { email, password } = req.body; // Obtener el correo electrónico y la contraseña del cuerpo de la petición

  try {
    await client.connect(); // Conectar a la base de datos
    const collection = client.db("users").collection("workers"); // Conexión a la base de datos y colección
    const user = await collection.findOne({ email, password }); // Buscar un usuario con el correo electrónico y la contraseña

    if (user) {
      // Si se encontró un usuario
      res.status(200).send({ authenticated: true, nombre: user.nombre }); // Enviar una respuesta con el nombre del usuario
    } else {
      res.status(401).send({ authenticated: false }); // Enviar una respuesta de no autorizado
    }
  } catch (err) {
    console.error(err);
    res.status(500).send("Error connecting to database");
  } finally {
    await client.close();
  }
});

app.post("/register", async (req, res) => {
  // Ruta para registrar un usuario
  const { nombre, email, password } = req.body; // Obtener el nombre, correo electrónico y contraseña del cuerpo de la petición

  try {
    await client.connect();
    const collection = client.db("users").collection("workers");
    const user = await collection.findOne({ email }); // Buscar un usuario con el correo electrónico

    if (user) {
      res.status(400).send("El correo electrónico ya está en uso"); // Enviar un mensaje de error si el correo electrónico ya está en uso
    } else {
      await collection.insertOne({ nombre, email, password });
      res.sendStatus(200);
    }
  } catch (err) {
    console.error(err);
    res.status(500).send("Error connecting to database");
  } finally {
    await client.close();
  }
});

app.listen(3000, () => {
  console.log("Server is running on port 3000");
});
