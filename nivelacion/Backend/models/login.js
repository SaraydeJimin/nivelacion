const Joi = require("joi");

// Esquema para login
const login = Joi.object({
  documento: Joi.string()
    .max(10)
    .required()
    .messages({
      "string.base": "El documento debe ser un texto.",
      "string.max": "El documento no puede exceder los 20 caracteres.",
      "string.empty": "El documento es requerido."
    }),

  password: Joi.string()
    .min(8)
    .max(255)
    .required()
    .messages({
      "string.min": "La contraseña debe tener al menos 8 caracteres.",
      "string.max": "La contraseña no puede exceder los 255 caracteres.",
      "string.empty": "La contraseña es requerida."
    })
});

// Esquema para buscar usuario por ID
const userForSearch = Joi.object({
  id_usuario: Joi.number()
    .integer()
    .required()
    .messages({
      "number.base": "El ID de usuario debe ser un número.",
      "any.required": "El ID de usuario es requerido."
    })
});

// Esquema para actualizar usuario
const userForUpdate = Joi.object({
  id_rol: Joi.number().integer().required(),

  tipo_documento: Joi.string()
    .valid("CC", "TI", "CE", "PAS")
    .required()
    .messages({
      "any.only": "El tipo de documento debe ser CC, TI, CE o PAS.",
      "string.empty": "El tipo de documento es requerido."
    }),

  documento: Joi.string()
    .max(10)
    .required()
    .messages({
      "string.max": "El documento no puede exceder los 20 caracteres.",
      "string.empty": "El documento es requerido."
    }),

  nombre: Joi.string().min(3).max(100).required(),
  apellido: Joi.string().min(3).max(100).required(),
  
  email: Joi.string().email().max(120).required(),

  password: Joi.string().min(8).max(255).required(),

  direccion: Joi.string().min(5).max(150).optional(),

  telefono: Joi.string()
    .pattern(/^[0-9]{10}$/)
    .required()
    .messages({
      "string.pattern.base": "El teléfono debe tener exactamente 10 dígitos y no puede empezar con +",
      "string.empty": "El teléfono es obligatorio",
    }),

  fecha_nacimiento: Joi.date()
    .less("now")
    .optional()
    .messages({
      "date.less": "La fecha de nacimiento debe ser anterior a hoy."
    })
});

// Esquema para eliminar usuario
const userForDelete = Joi.object({
  id_usuario: Joi.number().integer().required()
});

module.exports = { login, userForSearch, userForUpdate, userForDelete };
