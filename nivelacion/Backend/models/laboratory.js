const Joi = require("joi");

// Esquema para crear un laboratorio
const laboratorioForCreation = Joi.object({
  id_cita: Joi.number()
    .integer()
    .required()
    .messages({
      "number.base": "El ID de la cita debe ser un número.",
      "any.required": "El ID de la cita es requerido."
    }),

  id_paciente: Joi.number()
    .integer()
    .required()
    .messages({
      "number.base": "El ID del paciente debe ser un número.",
      "any.required": "El ID del paciente es requerido."
    }),

  id_medico: Joi.number()
    .integer()
    .required()
    .messages({
      "number.base": "El ID del médico debe ser un número.",
      "any.required": "El ID del médico es requerido."
    }),

  tipo_prueba: Joi.string()
    .max(100)
    .required()
    .messages({
      "string.max": "El tipo de prueba no puede exceder los 100 caracteres.",
      "string.empty": "El tipo de prueba es requerido."
    }),

  resultados: Joi.string()
    .optional()
    .messages({
      "string.base": "Los resultados deben ser texto."
    }),

  fecha: Joi.date()
    .required()
    .messages({
      "date.base": "La fecha debe ser válida.",
      "any.required": "La fecha es requerida."
    })
});

// Esquema para actualizar un laboratorio
const laboratorioForUpdate = Joi.object({
  id_cita: Joi.number().integer().required(),
  id_paciente: Joi.number().integer().required(),
  id_medico: Joi.number().integer().required(),
  tipo_prueba: Joi.string().max(100).required(),
  resultados: Joi.string().optional(),
  fecha: Joi.date().required()
});

// Esquema para buscar laboratorios por paciente
const laboratorioForSearch = Joi.object({
  id_paciente: Joi.number().integer().required()
});

// Esquema para eliminar un laboratorio
const laboratorioForDelete = Joi.object({
  id_laboratorio: Joi.number().integer().required()
});

module.exports = {
  laboratorioForCreation,
  laboratorioForUpdate,
  laboratorioForSearch,
  laboratorioForDelete
};
