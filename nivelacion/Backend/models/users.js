// Importamos Joi
const Joi = require("joi");

const userForRegister = Joi.object({
  id_rol: Joi.number()
    .integer()
    .required()
    .messages({
      "number.base": "El ID de rol debe ser un número.",
      "any.required": "El ID de rol es requerido.",
    }),

  tipo_documento: Joi.string()
    .valid("CC", "TI", "CE", "PAS")
    .required()
    .messages({
      "any.only": "El tipo de documento debe ser CC, TI, CE o PAS.",
      "string.empty": "El tipo de documento es requerido.",
    }),

  documento: Joi.string()
    .max(20)
    .required()
    .messages({
      "string.max": "El documento no puede exceder los 20 caracteres.",
      "string.empty": "El documento es requerido.",
    }),

  nombre: Joi.string()
    .min(3)
    .max(100)
    .required()
    .messages({
      "string.min": "El nombre debe tener al menos 3 caracteres.",
      "string.max": "El nombre no puede exceder los 100 caracteres.",
      "string.empty": "El nombre es requerido.",
    }),

  apellido: Joi.string()
    .min(3)
    .max(100)
    .required()
    .messages({
      "string.min": "El apellido debe tener al menos 3 caracteres.",
      "string.max": "El apellido no puede exceder los 100 caracteres.",
      "string.empty": "El apellido es requerido.",
    }),

  email: Joi.string()
    .email()
    .max(120)
    .required()
    .messages({
      "string.email": "El correo electrónico debe ser válido.",
      "string.empty": "El correo electrónico es requerido.",
    }),

  contraseña: Joi.string()
    .min(8)
    .max(255)
    .required()
    .messages({
      "string.min": "La contraseña debe tener al menos 8 caracteres.",
      "string.empty": "La contraseña es requerida.",
    }),

  direccion: Joi.string()
    .min(5)
    .max(150)
    .optional()
    .messages({
      "string.min": "La dirección debe tener al menos 5 caracteres.",
      "string.max": "La dirección no puede exceder los 150 caracteres.",
    }),

  telefono: Joi.string()
    .pattern(/^\+?[0-9]{7,15}$/)
    .optional()
    .messages({
      "string.pattern.base":
        "El teléfono debe ser válido, con un mínimo de 7 y un máximo de 15 dígitos. Puede incluir el prefijo '+'.",
    }),

  fecha_nacimiento: Joi.date()
    .less("now")
    .optional()
    .messages({
      "date.base": "La fecha de nacimiento debe ser una fecha válida.",
      "date.less": "La fecha de nacimiento debe ser anterior a hoy.",
    }),
});

module.exports = { userForRegister };