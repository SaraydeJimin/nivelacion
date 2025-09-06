// controllers/medicamentoController.js
const {
  getAllMedicamentosService,
  getMedicamentoByIdService,
  getMedicamentosWithFiltersService,
  createMedicamentoService,
  updateMedicamentoService,
  deleteMedicamentoService,
} = require("../services/medicineService");

const {
  medicamentoForCreation,
  medicamentoForUpdate,
  medicamentoForSearch,
} = require("../models/medicine");

// ✅ Obtener todos los medicamentos
const getAllMedicamentos = async (req, res) => {
  try {
    const response = await getAllMedicamentosService();
    res.json({ response });
  } catch (error) {
    console.error("Error al obtener los medicamentos:", error.message);
    res.status(500).json({ error: "Error en el servidor" });
  }
};

// ✅ Obtener medicamento por ID
const getMedicamentoById = async (req, res) => {
  const { error } = medicamentoForSearch.validate({
    id_medicamento: req.params.id,
  });
  if (error) {
    return res.status(400).json({ error: "ID inválido para buscar medicamento" });
  }
  try {
    const response = await getMedicamentoByIdService(req.params.id);
    if (!response) {
      return res.status(404).json({ message: "Medicamento no encontrado" });
    }
    res.json({ response });
  } catch (err) {
    console.error("Error al obtener medicamento por ID:", err.message);
    res.status(500).json({ error: "Error en el servidor" });
  }
};

// ✅ Obtener medicamentos con filtros dinámicos
const getMedicamentosWithFilters = async (req, res) => {
  try {
    const filters = {
      nombre: req.query.nombre || null,
      concentracion: req.query.concentracion || null,
      presentacion: req.query.presentacion || null,
    };

    const response = await getMedicamentosWithFiltersService(filters);
    res.json({ response });
  } catch (error) {
    console.error("Error al filtrar medicamentos:", error.message);
    res.status(500).json({ error: "Error en el servidor" });
  }
};

// ✅ Crear medicamento
const createMedicamento = async (req, res) => {
  const { error } = medicamentoForCreation.validate(req.body);
  if (error) {
    return res.status(400).json({ error: error.details[0].message });
  }
  try {
    const response = await createMedicamentoService(req.body);
    res
      .status(201)
      .json({ message: "Medicamento registrado exitosamente", response });
  } catch (err) {
    console.error("Error en crear medicamento:", err.message);
    res.status(500).json({ error: err.message });
  }
};

// ✅ Actualizar medicamento
const updateMedicamento = async (req, res) => {
  const { error } = medicamentoForUpdate.validate(req.body);
  if (error) {
    return res.status(400).json({ error: error.details[0].message });
  }
  try {
    const { id } = req.params;
    const response = await updateMedicamentoService(id, req.body);

    if (response.status) {
      return res.status(200).json({ message: response.message });
    } else {
      return res.status(404).json({ message: response.message });
    }
  } catch (err) {
    console.error("Error en updateMedicamento:", err.message);
    res.status(500).json({ error: "Error en el servidor" });
  }
};

// ✅ Eliminar medicamento
const deleteMedicamento = async (req, res) => {
  const { error } = medicamentoForSearch.validate({
    id_medicamento: req.params.id,
  });
  if (error) {
    return res.status(400).json({ error: "ID inválido para eliminar medicamento" });
  }
  try {
    const response = await deleteMedicamentoService(req.params.id);
    if (response.status) {
      res.status(200).json({ message: response.message });
    } else {
      res.status(404).json({ message: response.message });
    }
  } catch (err) {
    console.error("Error en deleteMedicamento:", err.message);
    res.status(500).json({ error: "Error en el servidor" });
  }
};

module.exports = {
  getAllMedicamentos,
  getMedicamentoById,
  getMedicamentosWithFilters,
  createMedicamento,
  updateMedicamento,
  deleteMedicamento,
};
