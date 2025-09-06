// Importamos la librería express para gestionar las rutas y solicitudes HTTP
const express = require("express");

// Importamos el middleware 'protected' que asegura que el usuario esté autenticado antes de acceder a las rutas
const protected = require("../middlewares/AuthMiddleware");

// Importamos los controladores para manejar las solicitudes relacionadas con detalle_formula
const {
  getAllDetalles,
  searchDetalles,
  createDetalle,
  updateDetalle,
  deleteDetalle
} = require("../controllers/forDetailController");

// Creamos una instancia del enrutador de express
const router = express.Router();

// Obtener todos los detalles
router.get("/all", protected, getAllDetalles);

// Buscar detalles (por id_formula o id_medicamento)
router.get("/search", protected, searchDetalles);

// Crear un nuevo detalle de fórmula
router.post("/", protected, createDetalle);

// Actualizar un detalle de fórmula
router.put("/:id_detalle", protected, updateDetalle);

// Eliminar un detalle de fórmula
router.delete("/:id_detalle", protected, deleteDetalle);

// Exportamos el enrutador para que pueda ser utilizado en otras partes de la aplicación
module.exports = router;
