const express = require("express");

const protected = require("../middlewares/AuthMiddleware");

const {
  getAllFormulas,
  getFormulasByPaciente,
  createFormula,
  updateFormula,
  deleteFormula,
} = require("../controllers/forController");

const router = express.Router();
router.get("/all", protected, getAllFormulas);
router.get("/paciente/:id", protected, getFormulasByPaciente);
router.post("/", protected, createFormula);
router.put("/:id", protected, updateFormula);
router.delete("/:id", protected, deleteFormula);

module.exports = router;
