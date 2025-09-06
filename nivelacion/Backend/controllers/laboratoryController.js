const {
  getAllLaboratoriosService,
  getLaboratoriosByPacienteService,
  createLaboratorioService,
  updateLaboratorioService,
  deleteLaboratorioService
} = require("../services/laboratoryService");

const {
  laboratorioForCreation,
  laboratorioForUpdate,
  laboratorioForSearch,
  laboratorioForDelete
} = require("../models/laboratory");

// Obtener todos los laboratorios
const getAllLaboratorios = async (req, res) => {
  try {
    const response = await getAllLaboratoriosService();
    res.json({ response });
  } catch (error) {
    console.error("Error al obtener los laboratorios:", error.message);
    res.status(500).json({ error: "Error en el servidor" });
  }
};

// Obtener laboratorios por paciente
const getLaboratoriosByPaciente = async (req, res) => {
  const { error } = laboratorioForSearch.validate({
    id_paciente: req.params.id
  });
  if (error) {
    return res.status(400).json({ error: error.details[0].message });
  }

  try {
    const response = await getLaboratoriosByPacienteService(req.params.id);
    res.json({ response });
  } catch (err) {
    console.error("Error al obtener laboratorios por paciente:", err.message);
    res.status(500).json({ error: "Error en el servidor" });
  }
};

// Crear laboratorio
const createLaboratorio = async (req, res) => {
  const { error } = laboratorioForCreation.validate(req.body);
  if (error) {
    return res.status(400).json({ error: error.details[0].message });
  }

  try {
    const response = await createLaboratorioService(req.body);
    res.status(201).json({
      message: "Laboratorio registrado exitosamente",
      response
    });
  } catch (err) {
    console.error("Error al crear laboratorio:", err.message);
    res.status(500).json({ error: "Error en el servidor" });
  }
};

// Actualizar laboratorio
const updateLaboratorio = async (req, res) => {
  const { error } = laboratorioForUpdate.validate(req.body);
  if (error) {
    return res.status(400).json({ error: error.details[0].message });
  }

  try {
    const { id } = req.params;
    const response = await updateLaboratorioService(id, req.body);

    if (response.status) {
      res.status(200).json({ message: response.message });
    } else {
      res.status(404).json({ message: response.message });
    }
  } catch (err) {
    console.error("Error al actualizar laboratorio:", err.message);
    res.status(500).json({ error: "Error en el servidor" });
  }
};

// Eliminar laboratorio
const deleteLaboratorio = async (req, res) => {
  const { error } = laboratorioForDelete.validate({
    id_laboratorio: req.params.id
  });
  if (error) {
    return res.status(400).json({ error: error.details[0].message });
  }

  try {
    const response = await deleteLaboratorioService(req.params.id);
    if (response.status) {
      res.status(200).json({ message: response.message });
    } else {
      res.status(404).json({ message: response.message });
    }
  } catch (err) {
    console.error("Error al eliminar laboratorio:", err.message);
    res.status(500).json({ error: "Error en el servidor" });
  }
};

module.exports = {
  getAllLaboratorios,
  getLaboratoriosByPaciente,
  createLaboratorio,
  updateLaboratorio,
  deleteLaboratorio
};
