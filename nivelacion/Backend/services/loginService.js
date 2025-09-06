const bcrypt = require("bcrypt");
const connectDB = require("../config/database");

const loginService = async (documento, password) => {
  let connection;
  try {
    connection = await connectDB();
    const [rows] = await connection.execute(
      `SELECT * FROM usuario WHERE documento = ?`,
      [documento]
    );
    if (rows.length === 0) {
      return { status: false, message: "Usuario no encontrado" };
    }
    const user = rows[0];
    const validPassword = await bcrypt.compare(password, user.password);
    if (!validPassword) {
      return { status: false, message: "password incorrecta" };
    }
    let id_medico = null;
    if (user.id_rol === 2) {
      const [medico] = await connection.execute(
        "SELECT id_medico FROM medico WHERE id_usuario = ?",
        [user.id_usuario]
      );
      if (medico.length > 0) {
        id_medico = medico[0].id_medico;
      }
    }

    return {
      status: true,
      user: {
        id_usuario: user.id_usuario,
        id_rol: user.id_rol,
        id_medico, 
        documento: user.documento,
        nombre: user.nombre,
        apellido: user.apellido,
        email: user.email,
        direccion: user.direccion,
        telefono: user.telefono,
      },
    };
  } catch (error) {
    console.error("Error en loginService:", error.message);
    throw error;
  } finally {
    if (connection) await connection.end();
  }
};

const getAllLoginService = async () => {
  let connection;
  try {
    connection = await connectDB();
    const [login] = await connection.execute(
      "SELECT * FROM usuario WHERE id_rol = 1"
    );
    return login;
  } catch (error) {
    console.error("Error al obtener los usuarios:", error.message);
    throw error;
  } finally {
    if (connection) await connection.end();
  }
};

// Registrar usuario
const registerService = async (user) => {
  try {
    const connection = await connectDB();
    const [existing] = await connection.execute(
      `SELECT * FROM usuario WHERE email = ? OR documento = ? OR telefono = ?`,
      [user.email, user.documento, user.telefono]
    );
    if (existing.length > 0) {
      return { status: false, message: "Email, documento o teléfono ya registrado" };
    }
    const hashedPassword = await bcrypt.hash(user.password, 10);
    const [result] = await connection.execute(
      `INSERT INTO usuario (id_rol, tipo_documento, documento, nombre, apellido, email, password, direccion, telefono, fecha_nacimiento) 
       VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)`,
      [
        user.id_rol,
        user.tipo_documento,
        user.documento,
        user.nombre,
        user.apellido,
        user.email,
        hashedPassword,
        user.direccion || null,
        user.telefono || null,
        user.fecha_nacimiento || null,
      ]
    );

    if (result.affectedRows === 1) {
      return {
        status: true,
        message: "Usuario registrado exitosamente",
        id_usuario: result.insertId,
      };
    } else {
      return { status: false, message: "No se pudo registrar el usuario" };
    }
  } catch (error) {
    console.error("Error en registerService:", error.stack || error);
    return { status: false, message: error.message || "Error interno del servidor" };
  }
};

// Obtener usuario por ID
const getLoginByIdService = async (id_usuario) => {
  let connection;
  try {
    connection = await connectDB();
    const [rows] = await connection.execute(
      `SELECT documento, nombre, apellido, email, direccion, telefono, fecha_nacimiento 
       FROM usuario WHERE id_usuario = ?`,
      [id_usuario]
    );

    if (rows.length === 0) {
      return { status: false, message: "Usuario no encontrado" };
    }

    return { status: true, user: rows[0] };
  } catch (error) {
    console.error("Error en getLoginByIdService:", error.message);
    throw error;
  } finally {
    if (connection) await connection.end();
  }
};

// Eliminar usuario por ID
const deleteLoginService = async (id_usuario) => {
  try {
    const connection = await connectDB();
    const result = await connection.execute(
      `DELETE FROM usuario WHERE id_usuario = ?`,
      [id_usuario]
    );

    if (result[0].affectedRows === 1) {
      return { status: true, message: "Cuenta eliminada exitosamente" };
    } else {
      return { status: false, message: "No se encontró la cuenta a eliminar" };
    }
  } catch (error) {
    console.error("Error en deleteLoginService:", error.message);
    throw error;
  }
};

// Actualizar usuario
const UpdateLoginService = async (id_usuario, data) => {
  let connection;
  try {
    connection = await connectDB();

    // Verificar existencia
    const [user] = await connection.execute(
      "SELECT * FROM usuario WHERE id_usuario = ?",
      [id_usuario]
    );
    if (user.length === 0) {
      throw new Error("El usuario no existe");
    }

    if (!data.password || data.password.trim() === "") {
      throw new Error("La password es obligatoria");
    }

    // Validar duplicados en otros usuarios
    const [existing] = await connection.execute(
      `SELECT * FROM usuario 
       WHERE (email = ? OR documento = ? OR telefono = ?) 
       AND id_usuario != ?`,
      [data.email, data.documento, data.telefono, id_usuario]
    );
    if (existing.length > 0) {
      throw new Error("El email, documento o teléfono ya está en uso por otro usuario");
    }

    // Encriptar nueva password
    const hashedPassword = await bcrypt.hash(data.password, 10);

    // Actualizar
    const [result] = await connection.execute(
      `UPDATE usuario SET 
        tipo_documento = ?,
        documento = ?,
        nombre = ?,
        apellido = ?,
        email = ?, 
        password = ?, 
        direccion = ?, 
        telefono = ?,
        fecha_nacimiento = ?
       WHERE id_usuario = ?`,
      [
        data.tipo_documento,
        data.documento,
        data.nombre,
        data.apellido,
        data.email,
        hashedPassword,
        data.direccion || null,
        data.telefono || null,
        data.fecha_nacimiento || null,
        id_usuario,
      ]
    );

    return {
      status: true,
      message: "Usuario actualizado correctamente",
      result,
    };
  } catch (error) {
    console.error("Error en UpdateLoginService:", error.message);
    throw error;
  } finally {
    if (connection) await connection.end();
  }
};

module.exports = {
  loginService,
  getAllLoginService,
  registerService,
  getLoginByIdService,
  deleteLoginService,
  UpdateLoginService,
};