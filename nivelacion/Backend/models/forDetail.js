const Joi = require("joi");

// Esquema para creación de detalle de fórmula
const detalleFormulaForCreation = Joi.object({
  id_formula: Joi.number().integer().required().messages({
    "number.base": "El ID de la fórmula debe ser un número.",
    "any.required": "El ID de la fórmula es requerido."
  }),
  id_medicamento: Joi.number().integer().required().messages({
    "number.base": "El ID del medicamento debe ser un número.",
    "any.required": "El ID del medicamento es requerido."
  }),
  cantidad: Joi.number().integer().min(1).required().messages({
    "number.base": "La cantidad debe ser un número entero.",
    "number.min": "La cantidad mínima es 1.",
    "any.required": "La cantidad es requerida."
  }),
  dosis: Joi.string().max(100).optional().messages({
    "string.max": "La dosis no puede exceder los 100 caracteres."
  }),
  duracion: Joi.string().max(50).optional().messages({
    "string.max": "La duración no puede exceder los 50 caracteres."
  })
}).options({ abortEarly: false, convert: true });

// Esquema para actualización
const detalleFormulaForUpdate = Joi.object({
  id_detalle: Joi.number().integer().required().messages({
    "number.base": "El ID del detalle debe ser un número.",
    "any.required": "El ID del detalle es requerido."
  }),
  cantidad: Joi.number().integer().min(1).optional(),
  dosis: Joi.string().max(100).optional(),
  duracion: Joi.string().max(50).optional()
}).options({ abortEarly: false, convert: true });

// Esquema para búsqueda
const detalleFormulaForSearch = Joi.object({
  id_formula: Joi.number().integer().optional(),
  id_medicamento: Joi.number().integer().optional(),
}).or("id_formula", "id_medicamento");

// Esquema para eliminación
const detalleFormulaForDelete = Joi.object({
  id_detalle: Joi.number().integer().required().messages({
    "number.base": "El ID del detalle debe ser un número.",
    "any.required": "El ID del detalle es requerido."
  })
});

module.exports = {
  detalleFormulaForCreation,
  detalleFormulaForUpdate,
  detalleFormulaForSearch,
  detalleFormulaForDelete
};
