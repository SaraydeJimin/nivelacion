const Joi = require("joi");

// Esquema para crear una fórmula médica
const formulaForCreation = Joi.object({
  id_cita: Joi.number().integer().positive().required().messages({
    "number.base": "El ID de la cita debe ser un número",
    "number.integer": "El ID de la cita debe ser un número entero",
    "number.positive": "El ID de la cita debe ser positivo",
    "any.required": "El ID de la cita es obligatorio",
  }),

  id_medico: Joi.number().integer().positive().required().messages({
    "number.base": "El ID del médico debe ser un número",
    "number.integer": "El ID del médico debe ser un número entero",
    "number.positive": "El ID del médico debe ser positivo",
    "any.required": "El ID del médico es obligatorio",
  }),

  id_paciente: Joi.number().integer().positive().required().messages({
    "number.base": "El ID del paciente debe ser un número",
    "number.integer": "El ID del paciente debe ser un número entero",
    "number.positive": "El ID del paciente debe ser positivo",
    "any.required": "El ID del paciente es obligatorio",
  }),

  fecha: Joi.date().required().messages({
    "date.base": "La fecha debe ser válida",
    "any.required": "La fecha es obligatoria",
  }),

  observaciones: Joi.string().max(500).optional().messages({
    "string.max": "Las observaciones no pueden exceder los 500 caracteres",
  }),
});

// Esquema para actualizar una fórmula médica
const formulaForUpdate = Joi.object({
  fecha: Joi.date().optional().messages({
    "date.base": "La fecha debe ser válida",
  }),

  observaciones: Joi.string().max(500).optional().messages({
    "string.max": "Las observaciones no pueden exceder los 500 caracteres",
  }),
});

// Esquema para buscar fórmula médica por paciente
const formulaForSearch = Joi.object({
  id_paciente: Joi.number().integer().positive().required().messages({
    "number.base": "El ID del paciente debe ser un número",
    "any.required": "El ID del paciente es obligatorio",
  }),
});

module.exports = {
  formulaForCreation,
  formulaForUpdate,
  formulaForSearch,
};
