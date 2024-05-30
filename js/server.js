const express = require("express");
const MongoClient = require("mongodb").MongoClient;
const cors = require("cors");
const bodyParser = require("body-parser");

const app = express();
app.use(cors());
app.use(bodyParser.json());

const uri =
  "mongodb+srv://alejandrodeveloper417:ccwh0XVcnzfphfT3@nutristock.fpenfkp.mongodb.net/nutristock";

const client = new MongoClient(uri);

app.get("/data", async (req, res) => {
  try {
    await client.connect();
    const collection = client.db("users").collection("workers");
    const data = await collection.find({}).toArray();
    console.log(data);
    res.json(data);
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
    let filter = {};

    if (categoria) {
      filter = { category: categoria }; // Si hay una categoría, se filtra por ella
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
  const { email, password } = req.body;

  try {
    await client.connect();
    const collection = client.db("users").collection("workers");
    const user = await collection.findOne({ email, password });

    if (user) {
      res.status(200).send({ authenticated: true, nombre: user.nombre });
    } else {
      res.status(401).send({ authenticated: false });
    }
  } catch (err) {
    console.error(err);
    res.status(500).send("Error connecting to database");
  } finally {
    await client.close();
  }
});

app.post("/register", async (req, res) => {
  const { nombre, email, password } = req.body;

  try {
    await client.connect();
    const collection = client.db("users").collection("workers");
    const user = await collection.findOne({ email });

    if (user) {
      res.status(400).send("El correo electrónico ya está en uso");
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
