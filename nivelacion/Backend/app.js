// Cargar variables de entorno desde un archivo .env
require("dotenv").config();

// Importar dependencias necesarias
const express = require("express");
const morgan = require("morgan");
const connectDB = require("./config/database");
const appointmentRoutes = require("./routes/appointmentRoutes");
const loginRoutes = require("./routes/loginRoutes");
const doctorRoutes = require("./routes/doctorRoutes");
const forRoutes = require("./routes/forRoutes");
const formDetailRoutes = require("./routes/formDetailRoutes");
const laboratoryRoutes = require("./routes/laboratoryRoutes");
const medicineRoutes = require("./routes/medicineRoutes");
const cors = require("cors");
const bodyParser = require("body-parser");
const fileUpload = require("express-fileupload");


// Crear una instancia de la aplicación Express
const app = express();
const port = process.env.PORT || 3000;

// Conectar a la base de datos
connectDB()
  .then(() => console.log("Conexión exitosa a la base de datos"))
  .catch((error) => {
    console.error("Error al conectar con la base de datos:", error.message);
    process.exit(1);
  });

// Configuración de CORS
const corsOptions = {
  origin: function (origin, callback) {
    const allowedOrigins = ["http://localhost:5173", "http://localhost:63077" ];
    if (!origin || allowedOrigins.includes(origin)) {
      callback(null, true);
    } else {
      callback(new Error("No autorizado por CORS"));
    }
  },
  methods: ["GET", "POST", "PUT", "DELETE"],
  allowedHeaders: ["Content-Type", "Authorization"],
  credentials: true,
};

// Middlewares
app.use(cors(corsOptions));
app.use(bodyParser.json({ limit: "10mb" }));
app.use(bodyParser.urlencoded({ limit: "10mb", extended: true }));
app.use(express.json());
app.use(morgan("dev"));
app.use(fileUpload({
  useTempFiles: true,
  tempFileDir: "/tmp/"
}));

app.use("/appointment", appointmentRoutes);
app.use("/login", loginRoutes);
app.use("/doctor", doctorRoutes);
app.use("/for", forRoutes);
app.use("/formDetail", formDetailRoutes);
app.use("/laboratory", laboratoryRoutes);
app.use("/medicine", medicineRoutes);

app.get("/isAlive", (req, res) => {
  res.send(`Servidor corriendo en la dirección http://localhost:${port}`);
});

app.use((req, res) => {
  res.status(404).json({ error: "Ruta no encontrada" });
});

app.use((err, req, res, next) => {
  console.error("Error en el servidor:", err.message || err);
  res.status(err.status || 500).json({
    error: err.message || "Error interno del servidor",
  });
});

// Iniciar servidor
app.listen(port, () => {
  console.log(`Servidor escuchando en http://localhost:${port}`);
});
