// Importa las funciones del servicio de login y registro
const {
  loginService,
  registerService,
  getAllLoginService,
  getLoginByIdService,
  deleteLoginService,
  UpdateLoginService,
} = require("../services/loginService");

// Importamos la librería para manejar JWT (JSON Web Token)
const jwt = require("jsonwebtoken");

// Importamos los modelos de validación con Joi
const { login, userForSearch, userForUpdate, userForDelete } = require("../models/login");

// Obtener todos los usuarios con rol Paciente
const getAllLogin = async (req, res) => {
  try {
    const response = await getAllLoginService();
    res.status(200).json({ users: response });
  } catch (error) {
    console.error("Error al intentar obtener los usuarios:", error);
    res.status(500).json({ error: "Error en el servidor" });
  }
};

// Login con DOCUMENTO y password
const postLog = async (req, res) => {
  const { documento, password } = req.body;

  // Validación con Joi
  const { error } = login.validate({ documento, password });
  if (error) {
    return res.status(400).json({
      status: false,
      message: "Error de validación",
      details: error.details.map((d) => d.message),
    });
  }

  try {
    const response = await loginService(documento, password);

    if (response.status) {
      const token = jwt.sign(
        {
          id_usuario: response.user.id_usuario,
          id_rol: response.user.id_rol,
          id_medico: response.user.id_medico || null,
        },
        process.env.SECRET_KEY,
        { expiresIn: "2h" }
      );

      return res.status(200).json({
        status: true,
        user: response.user,
        access_token: token,
      });
    } else {
      return res.status(401).json({
        status: false,
        message: response.message,
      });
    }
  } catch (err) {
    console.error("Error en el controlador de login:", err.message);
    return res.status(500).json({ message: err.message || "Error en el servidor" });
  }
};

// Registrar usuario
const registerUser = async (req, res) => {
  // Validar con Joi (usa el esquema userForUpdate porque no tienes userForRegister)
  const { error } = userForUpdate.validate(req.body, { abortEarly: false });
  if (error) {
    return res.status(400).json({
      status: false,
      message: "Error de validación",
      details: error.details.map((d) => d.message),
    });
  }

  try {
    const result = await registerService(req.body);
    if (result.status) {
      return res.status(201).json({
        status: true,
        id_usuario: result.id_usuario,
      });
    } else {
      return res.status(400).json(result);
    }
  } catch (err) {
    console.error("Error en el controlador de registro:", err.message);
    return res.status(500).json({ error: "Error en el servidor" });
  }
};

// Obtener usuario por ID
const getLoginById = async (req, res) => {
  const { id_usuario } = req.params;

  const { error } = userForSearch.validate({ id_usuario });
  if (error) {
    return res.status(400).json({ error: error.details[0].message });
  }

  try {
    const response = await getLoginByIdService(id_usuario);
    if (!response.status) {
      return res.status(404).json({ error: response.message });
    }
    return res.status(200).json({ user: response.user });
  } catch (error) {
    console.error("Error en el controlador getLoginById:", error.message);
    return res.status(500).json({ error: "Error en el servidor" });
  }
};

// Actualizar usuario
const UpdateLogin = async (req, res) => {
  const { id_usuario } = req.params;

  // Validamos los datos con Joi
  const { error } = userForUpdate.validate(req.body, { abortEarly: false });
  if (error) {
    return res.status(400).json({ error: error.details.map((d) => d.message) });
  }

  try {
    const response = await UpdateLoginService(id_usuario, req.body);
    res.status(200).json({
      status: true,
      message: "Usuario actualizado correctamente",
      response,
    });
  } catch (error) {
    console.error("Error en el controlador de update:", error.message);
    return res.status(500).json({ error: error.message });
  }
};

// Eliminar usuario
const deleteLogin = async (req, res) => {
  const { id_usuario } = req.params;

  const { error } = userForDelete.validate({ id_usuario });
  if (error) {
    return res.status(400).json({ error: error.details[0].message });
  }

  try {
    const response = await deleteLoginService(id_usuario);
    if (response.status) {
      return res.status(200).json({ message: response.message });
    } else {
      return res.status(404).json({ message: response.message });
    }
  } catch (error) {
    console.error("Error en el controlador de delete:", error.message);
    return res.status(500).json({ error: "Error en el servidor" });
  }
};

// Exportamos
module.exports = {
  postLog,
  registerUser,
  getAllLogin,
  getLoginById,
  UpdateLogin,
  deleteLogin,
};
