const {
  getAllDetallesService,
  searchDetallesService,
  createDetalleService,
  updateDetalleService,
  deleteDetalleService
} = require("../services/forDetailService");

const {
  detalleFormulaForCreation,
  detalleFormulaForUpdate,
  detalleFormulaForSearch,
  detalleFormulaForDelete
} = require("../models/forDetail");

// 🔹 Obtener todos los detalles
const getAllDetalles = async (req, res) => {
  try {
    const response = await getAllDetallesService();
    res.json({ response });
  } catch (error) {
    console.error("Error al obtener detalles de fórmula:", error.message);
    res.status(500).json({ error: "Error en el servidor" });
  }
};

// 🔹 Buscar detalles (por id_formula o id_medicamento)
const searchDetalles = async (req, res) => {
  const { error } = detalleFormulaForSearch.validate(req.query);
  if (error) {
    return res.status(400).json({ error: error.details[0].message });
  }
  try {
    const response = await searchDetallesService(req.query);
    res.json({ response });
  } catch (err) {
    console.error("Error al buscar detalles:", err.message);
    res.status(500).json({ error: "Error en el servidor" });
  }
};

// 🔹 Crear detalle
const createDetalle = async (req, res) => {
  const { error } = detalleFormulaForCreation.validate(req.body);
  if (error) {
    return res.status(400).json({ error: error.details.map(e => e.message) });
  }
  try {
    const response = await createDetalleService(req.body);
    res.status(201).json({ message: "Detalle de fórmula creado exitosamente", response });
  } catch (err) {
    console.error("Error al crear detalle de fórmula:", err.message);
    res.status(500).json({ error: "Error en el servidor" });
  }
};

// 🔹 Actualizar detalle
const updateDetalle = async (req, res) => {
  const { error } = detalleFormulaForUpdate.validate(req.body);
  if (error) {
    return res.status(400).json({ error: error.details.map(e => e.message) });
  }
  try {
    const response = await updateDetalleService(req.body);
    if (response.status) {
      return res.status(200).json({ message: response.message });
    } else {
      return res.status(404).json({ message: response.message });
    }
  } catch (err) {
    console.error("Error al actualizar detalle:", err.message);
    res.status(500).json({ error: "Error en el servidor" });
  }
};

// 🔹 Eliminar detalle
const deleteDetalle = async (req, res) => {
  const { error } = detalleFormulaForDelete.validate(req.params);
  if (error) {
    return res.status(400).json({ error: error.details.map(e => e.message) });
  }
  try {
    const response = await deleteDetalleService(req.params.id_detalle);
    if (response.status) {
      res.status(200).json({ message: response.message });
    } else {
      res.status(404).json({ message: response.message });
    }
  } catch (err) {
    console.error("Error al eliminar detalle:", err.message);
    res.status(500).json({ error: "Error en el servidor" });
  }
};

module.exports = {
  getAllDetalles,
  searchDetalles,
  createDetalle,
  updateDetalle,
  deleteDetalle
};
