// Importamos la librería Joi
const Joi = require("joi");

// Esquema para registrar un médico
const medicoForRegister = Joi.object({
  id_usuario: Joi.number()
    .integer()
    .required()
    .messages({
      "number.base": "El ID de usuario debe ser un número entero.",
      "any.required": "El ID de usuario es requerido.",
    }),

  especialidad: Joi.string()
    .min(3)
    .max(100)
    .required()
    .messages({
      "string.min": "La especialidad debe tener al menos 3 caracteres.",
      "string.max": "La especialidad no puede exceder los 100 caracteres.",
      "string.empty": "La especialidad es requerida.",
    }),

  registro_profesional: Joi.string()
    .max(50)
    .required()
    .messages({
      "string.max": "El registro profesional no puede exceder los 50 caracteres.",
      "string.empty": "El registro profesional es requerido.",
    }),
});

// Esquema para buscar médico por ID
const medicoForSearch = Joi.object({
  id_medico: Joi.number()
    .integer()
    .required()
    .messages({
      "number.base": "El ID del médico debe ser un número entero.",
      "any.required": "El ID del médico es requerido.",
    }),
});

// Esquema para actualizar datos del médico
const medicoForUpdate = Joi.object({
  especialidad: Joi.string()
    .min(3)
    .max(100)
    .required()
    .messages({
      "string.min": "La especialidad debe tener al menos 3 caracteres.",
      "string.max": "La especialidad no puede exceder los 100 caracteres.",
      "string.empty": "La especialidad es requerida.",
    }),

  registro_profesional: Joi.string()
    .max(50)
    .required()
    .messages({
      "string.max": "El registro profesional no puede exceder los 50 caracteres.",
      "string.empty": "El registro profesional es requerido.",
    }),
});

// Esquema para eliminar médico
const medicoForDelete = Joi.object({
  id_medico: Joi.number()
    .integer()
    .required()
    .messages({
      "number.base": "El ID del médico debe ser un número entero.",
      "any.required": "El ID del médico es requerido.",
    }),
});

// Esquema para buscar médico por nombre
const medicoForSearchByName = Joi.object({
  nombre: Joi.string()
    .min(2)
    .max(100)
    .required()
    .messages({
      "string.empty": "El nombre es requerido.",
      "string.min": "El nombre debe tener al menos 2 caracteres.",
      "string.max": "El nombre no puede exceder los 100 caracteres."
    }),
});

// Esquema para buscar médico por especialidad
const medicoForSearchByEspecialidad = Joi.object({
  especialidad: Joi.string()
    .min(3)
    .max(100)
    .required()
    .messages({
      "string.empty": "La especialidad es requerida.",
      "string.min": "La especialidad debe tener al menos 3 caracteres.",
      "string.max": "La especialidad no puede exceder los 100 caracteres."
    }),
});

module.exports = { 
  medicoForRegister, 
  medicoForSearch, 
  medicoForSearchByName, 
  medicoForSearchByEspecialidad, 
  medicoForUpdate, 
  medicoForDelete 
};