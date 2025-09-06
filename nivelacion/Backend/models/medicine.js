const Joi = require("joi");

// Esquema para crear un medicamento
const medicamentoForCreation = Joi.object({
  nombre: Joi.string()
    .max(100)
    .required()
    .messages({
      "string.base": "El nombre debe ser un texto",
      "string.empty": "El nombre es obligatorio",
      "string.max": "El nombre no puede superar los 100 caracteres",
      "any.required": "El nombre es obligatorio",
    }),

  descripcion: Joi.string()
    .allow(null, "")
    .messages({
      "string.base": "La descripción debe ser un texto",
    }),

  concentracion: Joi.string()
    .max(50)
    .allow(null, "")
    .messages({
      "string.base": "La concentración debe ser un texto",
      "string.max": "La concentración no puede superar los 50 caracteres",
    }),

  presentacion: Joi.string()
    .max(50)
    .allow(null, "")
    .messages({
      "string.base": "La presentación debe ser un texto",
      "string.max": "La presentación no puede superar los 50 caracteres",
    }),
});

// Esquema para actualizar un medicamento
const medicamentoForUpdate = Joi.object({
  nombre: Joi.string()
    .max(100)
    .optional()
    .messages({
      "string.base": "El nombre debe ser un texto",
      "string.max": "El nombre no puede superar los 100 caracteres",
    }),

  descripcion: Joi.string()
    .allow(null, "")
    .optional()
    .messages({
      "string.base": "La descripción debe ser un texto",
    }),

  concentracion: Joi.string()
    .max(50)
    .allow(null, "")
    .optional()
    .messages({
      "string.base": "La concentración debe ser un texto",
      "string.max": "La concentración no puede superar los 50 caracteres",
    }),

  presentacion: Joi.string()
    .max(50)
    .allow(null, "")
    .optional()
    .messages({
      "string.base": "La presentación debe ser un texto",
      "string.max": "La presentación no puede superar los 50 caracteres",
    }),
});

// Esquema para buscar medicamento por ID
const medicamentoForSearch = Joi.object({
  id_medicamento: Joi.number()
    .integer()
    .positive()
    .required()
    .messages({
      "number.base": "El ID del medicamento debe ser un número",
      "number.integer": "El ID del medicamento debe ser un número entero",
      "number.positive": "El ID del medicamento debe ser un número positivo",
      "any.required": "El ID del medicamento es obligatorio",
    }),
});

module.exports = {
  medicamentoForCreation,
  medicamentoForUpdate,
  medicamentoForSearch,
};
