const {
  getAllCitasService,
  getCitaByIdService,
  getCitasByPacienteService,
  createCitaService,
  updateCitaService,
  deleteCitaService
} = require("../services/appointmentService");

const {
  citaForCreation,
  citaForUpdate,
  citaForDelete
} = require("../models/appointment");

// Obtener todas las citas
const getAllCitas = async (req, res) => {
  try {
    let idMedico = null;
    if (req.user.rol === 2) {
      idMedico = req.user.idMedico;
    }
    const response = await getAllCitasService(idMedico);
    res.status(200).json({ response });
  } catch (error) {
    console.error("Error al obtener las citas:", error.message);
    res.status(500).json({ error: "Error en el servidor" });
  }
};

// Obtener cita por ID
const getCitaById = async (req, res) => {
  const id_cita = Number(req.params.id);
  if (isNaN(id_cita)) {
    return res.status(400).json({ error: "El ID de la cita debe ser numérico" });
  }
  try {
    const response = await getCitaByIdService(id_cita);
    if (!response) {
      return res.status(404).json({ message: "Cita no encontrada" });
    }
    res.status(200).json({ response });
  } catch (error) {
    console.error("Error al obtener cita:", error.message);
    res.status(500).json({ error: "Error en el servidor" });
  }
};

const getCitasByPaciente = async (req, res) => {
  try {
    const { idPaciente } = req.params;
    const citas = await getCitasByPacienteService(idPaciente);
    return res.json({
      status: true,
      response: citas
    });
  } catch (error) {
    console.error("Error en getCitasByPaciente:", error.message);
    return res.status(500).json({
      status: false,
      message: "Error al obtener citas por paciente"
    });
  }
};

// Crear cita
const createCita = async (req, res) => {
  const { error } = citaForCreation.validate(req.body);
  if (error) {
    return res.status(400).json({ error: error.details[0].message });
  }
  try {
    const response = await createCitaService(req.body);
    res.status(201).json({
      message: "Cita creada exitosamente",
      response
    });
  } catch (error) {
    console.error("Error al crear cita:", error.message);
    res.status(500).json({ error: "Error en el servidor" });
  }
};

// Actualizar cita
const updateCita = async (req, res) => {
  const { error } = citaForUpdate.validate({ ...req.body, id_cita: req.params.id });
  if (error) {
    return res.status(400).json({ error: error.details[0].message });
  }
  try {
    const id_cita = Number(req.params.id);
    const response = await updateCitaService(id_cita, req.body);
    if (response.status) {
      return res.status(200).json({ message: response.message });
    } else {
      return res.status(404).json({ message: response.message });
    }
  } catch (error) {
    console.error("Error al actualizar cita:", error.message);
    res.status(500).json({ error: "Error en el servidor" });
  }
};

// Eliminar cita
const deleteCita = async (req, res) => {
  const id_cita = Number(req.params.id);
  const { error } = citaForDelete.validate({ id_cita });
  if (error) {
    return res.status(400).json({ error: error.details[0].message });
  }
  try {
    const response = await deleteCitaService(id_cita);
    if (response.status) {
      res.status(200).json({ message: response.message });
    } else {
      res.status(404).json({ message: response.message });
    }
  } catch (error) {
    console.error("Error al eliminar cita:", error.message);
    res.status(500).json({ error: "Error en el servidor" });
  }
};

module.exports = {
  getAllCitas,
  getCitaById,
  createCita,
  getCitasByPaciente,
  updateCita,
  deleteCita
};
