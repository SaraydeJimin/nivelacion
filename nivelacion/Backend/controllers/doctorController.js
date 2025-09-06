const {
  getAllMedicosService,
  getMedicoByIdService,
  getMedicoByNombreService,
  getMedicoByEspecialidadService,
  createMedicoService,
  updateMedicoService,
  deleteMedicoService
} = require("../services/doctorService");

const {
  medicoForRegister,
  medicoForSearch,
  medicoForUpdate,
  medicoForDelete
} = require("../models/doctor");

// Buscar médico por nombre
const getMedicoByNombre = async (req, res) => {
  try {
    const { nombre } = req.params;
    const response = await getMedicoByNombreService(nombre);
    if (response.length === 0) {
      return res.status(404).json({ message: "No se encontraron médicos con ese nombre" });
    }
    res.status(200).json({ response });
  } catch (err) {
    console.error("Error en getMedicoByNombre:", err.message);
    res.status(500).json({ error: "Error en el servidor" });
  }
};

// Buscar médico por especialidad
const getMedicoByEspecialidad = async (req, res) => {
  try {
    const { especialidad } = req.params;
    const response = await getMedicoByEspecialidadService(especialidad);
    if (response.length === 0) {
      return res.status(404).json({ message: "No se encontraron médicos con esa especialidad" });
    }
    res.status(200).json({ response });
  } catch (err) {
    console.error("Error en getMedicoByEspecialidad:", err.message);
    res.status(500).json({ error: "Error en el servidor" });
  }
};

const getAllMedicos = async (req, res) => {
  try {
    const response = await getAllMedicosService();
    res.status(200).json({ response });
  } catch (error) {
    console.error("Error en getAllMedicos:", error.message);
    res.status(500).json({ error: "Error en el servidor" });
  }
};

// Obtener médico por ID
const getMedicoById = async (req, res) => {
  const { error } = medicoForSearch.validate({ id_medico: req.params.id });
  if (error) {
    return res.status(400).json({ error: "ID inválido para buscar médico" });
  }

  try {
    const response = await getMedicoByIdService(req.params.id);
    if (!response) {
      return res.status(404).json({ message: "Médico no encontrado" });
    }
    res.status(200).json({ response });
  } catch (err) {
    console.error("Error en getMedicoById:", err.message);
    res.status(500).json({ error: "Error en el servidor" });
  }
};

// Crear un nuevo médico
const createMedico = async (req, res) => {
  const { error } = medicoForRegister.validate(req.body);
  if (error) {
    return res.status(400).json({ error: error.details[0].message });
  }

  try {
    const response = await createMedicoService(req.body);
    res.status(201).json({ message: "Médico registrado exitosamente", response });
  } catch (err) {
    console.error("Error en createMedico:", err.message);
    res.status(500).json({ error: err.message });
  }
};

// Actualizar médico
const updateMedico = async (req, res) => {
  const { error } = medicoForUpdate.validate(req.body);
  if (error) {
    return res.status(400).json({ error: error.details[0].message });
  }

  try {
    const { id } = req.params;
    const response = await updateMedicoService(id, req.body);
    if (response.status) {
      res.status(200).json({ message: response.message });
    } else {
      res.status(404).json({ message: response.message });
    }
  } catch (err) {
    console.error("Error en updateMedico:", err.message);
    res.status(500).json({ error: "Error en el servidor" });
  }
};

// Eliminar médico
const deleteMedico = async (req, res) => {
  const { error } = medicoForDelete.validate({ id_medico: req.params.id });
  if (error) {
    return res.status(400).json({ error: "ID inválido para eliminar médico" });
  }

  try {
    const response = await deleteMedicoService(req.params.id);
    if (response.status) {
      res.status(200).json({ message: response.message });
    } else {
      res.status(404).json({ message: response.message });
    }
  } catch (err) {
    console.error("Error en deleteMedico:", err.message);
    res.status(500).json({ error: "Error en el servidor" });
  }
};


module.exports = {
  getAllMedicos,
  getMedicoById,
  getMedicoByNombre,
  getMedicoByEspecialidad,
  createMedico,
  updateMedico,
  deleteMedico
};