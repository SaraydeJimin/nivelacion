const Joi = require("joi");

// Crear cita
const citaForCreation = Joi.object({
  id_paciente: Joi.number().integer().greater(0).required().messages({
    "number.base": "El ID del paciente debe ser un número.",
    "number.greater": "El ID del paciente debe ser mayor a 0.",
    "any.required": "El ID del paciente es obligatorio.",
  }),
  id_medico: Joi.number().integer().greater(0).required().messages({
    "number.base": "El ID del médico debe ser un número.",
    "number.greater": "El ID del médico debe ser mayor a 0.",
    "any.required": "El ID del médico es obligatorio.",
  }),
  fecha: Joi.date().required().messages({
    "date.base": "La fecha debe ser válida.",
    "any.required": "La fecha de la cita es obligatoria.",
  }),
  hora: Joi.string()
    .pattern(/^([01]\d|2[0-3]):([0-5]\d)$/) // HH:MM 24h
    .required()
    .messages({
      "string.pattern.base": "La hora debe estar en formato HH:MM (24 horas).",
      "any.required": "La hora de la cita es obligatoria.",
    }),
});

// Actualizar cita
const citaForUpdate = Joi.object({
  id_cita: Joi.number().integer().greater(0).required().messages({
    "number.base": "El ID de la cita debe ser un número.",
    "number.greater": "El ID de la cita debe ser mayor a 0.",
    "any.required": "El ID de la cita es obligatorio para actualizar.",
  }),
  fecha: Joi.date().optional(),
  hora: Joi.string()
    .pattern(/^([01]\d|2[0-3]):([0-5]\d)$/) // <- FIX del paréntesis
    .optional(),
});

// Eliminar cita
const citaForDelete = Joi.object({
  id_cita: Joi.number().integer().greater(0).required().messages({
    "number.base": "El ID de la cita debe ser un número.",
    "number.greater": "El ID de la cita debe ser mayor a 0.",
    "any.required": "El ID de la cita es obligatorio para eliminar.",
  }),
});

module.exports = { citaForCreation, citaForUpdate, citaForDelete };
