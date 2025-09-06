const express = require("express");

const protected = require("../middlewares/AuthMiddleware");
const {
  getAllMedicamentos,
  getMedicamentoById,
  getMedicamentosWithFilters,
  createMedicamento,
  updateMedicamento,
  deleteMedicamento,
} = require("../controllers/medicineController");

const router = express.Router();
router.get("/all", protected, getAllMedicamentos);
router.get("/:id", protected, getMedicamentoById);
router.get("/filter/search", protected, getMedicamentosWithFilters);
router.post("/", protected, createMedicamento);
router.put("/:id", protected, updateMedicamento);
router.delete("/:id", protected, deleteMedicamento);

module.exports = router;
