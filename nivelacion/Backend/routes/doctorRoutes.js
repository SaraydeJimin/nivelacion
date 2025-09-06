const express = require("express");

const protected = require("../middlewares/AuthMiddleware");
const {
  getAllMedicos,
  getMedicoById,
  getMedicoByNombre,
  getMedicoByEspecialidad,
  createMedico,
  updateMedico,
  deleteMedico
} = require("../controllers/doctorController");

const router = express.Router();
router.get("/all", protected, getAllMedicos);
router.get("/:id", protected, getMedicoById);
router.post("/", protected, createMedico);
router.put("/:id", protected, updateMedico);
router.delete("/:id", protected, deleteMedico);
router.get("/nombre/:nombre", protected, getMedicoByNombre);
router.get("/especialidad/:especialidad", protected, getMedicoByEspecialidad);

module.exports = router;