const express = require("express");

const protected = require("../middlewares/AuthMiddleware");
const {
  getAllCitas,
  getCitaById,
  createCita,
  getCitasByPaciente,
  updateCita,
  deleteCita
} = require("../controllers/appointmentController");

const router = express.Router();
router.get("/all", protected, getAllCitas);
router.get("/paciente/:idPaciente", getCitasByPaciente);
router.get("/:id", protected, getCitaById);
router.post("/", protected, createCita);
router.put("/:id", protected, updateCita);
router.delete("/:id", protected, deleteCita);

module.exports = router;