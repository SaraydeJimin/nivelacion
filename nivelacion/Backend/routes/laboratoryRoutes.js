const express = require("express");

const protected = require("../middlewares/AuthMiddleware");
const {
  getAllLaboratorios,
  getLaboratoriosByPaciente,
  createLaboratorio,
  updateLaboratorio,
  deleteLaboratorio
} = require("../controllers/laboratoryController");

const router = express.Router();
router.get("/all", protected, getAllLaboratorios);
router.get("/paciente/:id", protected, getLaboratoriosByPaciente);
router.post("/", protected, createLaboratorio);
router.put("/:id", protected, updateLaboratorio);
router.delete("/:id", protected, deleteLaboratorio);

module.exports = router;
