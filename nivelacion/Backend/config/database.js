// Cargamos las variables de entorno desde el archivo .env
require("dotenv").config();

// Importamos la librería mysql2 en su versión "promise", para usar async/await
const mysql = require("mysql2/promise");

// Definimos la función async para establecer la conexión a la base de datos
const connectDB = async () => {
  try {
    // Intentamos crear una conexión a la base de datos utilizando las variables de entorno
    const connection = await mysql.createConnection({
      // La configuración de conexión usa variables de entorno definidas en el archivo .env
      host: process.env.BDSENA_HOST,  // Dirección del servidor de base de datos
      user: process.env.BDSENA_USER,  // Usuario de la base de datos
      password: process.env.BDSENA_PASSWORD,  // Contraseña de la base de datos
      database: process.env.BDSENA_DATABASE,  // Nombre de la base de datos
      port: 3306,  // Puerto predeterminado de MySQL (en este caso, el puerto 3306 de XAMPP)
    });

    // Si la conexión es exitosa, se muestra un mensaje en consola
    console.log("Conexión exitosa a la base de datos MySQL.");
    // Retornamos la conexión para que pueda usarse en otras partes del código
    return connection;
  } catch (error) {
    // Si hay algún error, lo mostramos en consola
    console.error("Error conectando a la base de datos:", error.message, error.stack);
    // Lanzamos el error para que se pueda manejar adecuadamente fuera de esta función
    throw error;
  }
};

// Exportamos la función para que pueda ser utilizada en otras partes del proyecto
module.exports = connectDB;
