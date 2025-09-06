const connectDB = require("../config/database");

// Obtener todos los médicos con datos del usuario
const getAllMedicosService = async () => {
  let connection;
  try {
    connection = await connectDB();
    const [medicos] = await connection.execute(`
      SELECT 
        m.id_medico,
        m.id_usuario,
        u.nombre AS nombre_usuario,
        u.email AS email_usuario,
        m.especialidad,
        m.registro_profesional
      FROM medico m
      JOIN usuario u ON m.id_usuario = u.id_usuario
    `);
    return medicos;
  } catch (error) {
    console.error("Error al obtener todos los médicos: ", error.message);
    throw error;
  } finally {
    if (connection) await connection.end();
  }
};

// Buscar médico por ID
const getMedicoByIdService = async (id_medico) => {
  let connection;
  try {
    connection = await connectDB();
    const [rows] = await connection.execute(
      `SELECT 
         m.id_medico,
         m.id_usuario,
         u.nombre AS nombre_usuario,
         u.email AS email_usuario,
         m.especialidad,
         m.registro_profesional
       FROM medico m
       JOIN usuario u ON m.id_usuario = u.id_usuario
       WHERE m.id_medico = ?`,
      [id_medico]
    );
    return rows[0] || null;
  } catch (error) {
    console.error("Error al obtener médico por ID: ", error.message);
    throw error;
  } finally {
    if (connection) await connection.end();
  }
};

// Crear un nuevo médico
const createMedicoService = async (data) => {
  const { id_usuario, especialidad, registro_profesional } = data;
  let connection;
  try {
    connection = await connectDB();

    // Validar si ya existe un médico con ese registro profesional
    const [existing] = await connection.execute(
      "SELECT id_medico FROM medico WHERE registro_profesional = ?",
      [registro_profesional]
    );
    if (existing.length > 0) {
      throw new Error("Ya existe un médico con ese registro profesional");
    }

    const [result] = await connection.execute(
      `INSERT INTO medico (id_usuario, especialidad, registro_profesional)
       VALUES (?, ?, ?)`,
      [id_usuario, especialidad, registro_profesional]
    );

    return {
      id_medico: result.insertId,
      id_usuario,
      especialidad,
      registro_profesional
    };
  } catch (error) {
    console.error("Error en crear médico: ", error.message);
    throw error;
  } finally {
    if (connection) await connection.end();
  }
};

// Actualizar médico
const updateMedicoService = async (id_medico, data) => {
  let connection;
  try {
    connection = await connectDB();

    // Verificar si existe el médico
    const [rows] = await connection.execute(
      "SELECT * FROM medico WHERE id_medico = ?",
      [id_medico]
    );
    if (rows.length === 0) {
      return { status: false, message: "Médico no encontrado" };
    }
    const currentMedico = rows[0];

    // Validar registro_profesional único si cambia
    const registroToCheck = data.registro_profesional ?? currentMedico.registro_profesional;
    if (registroToCheck !== currentMedico.registro_profesional) {
      const [existing] = await connection.execute(
        "SELECT id_medico FROM medico WHERE registro_profesional = ? AND id_medico != ?",
        [registroToCheck, id_medico]
      );
      if (existing.length > 0) {
        return { status: false, message: "Otro médico ya usa ese registro profesional" };
      }
    }

    // Actualizar datos
    const especialidad = data.especialidad ?? currentMedico.especialidad;
    const registro_profesional = data.registro_profesional ?? currentMedico.registro_profesional;

    const [result] = await connection.execute(
      `UPDATE medico
       SET especialidad = ?, registro_profesional = ?
       WHERE id_medico = ?`,
      [especialidad, registro_profesional, id_medico]
    );

    if (result.affectedRows === 0) {
      return { status: false, message: "Médico no encontrado" };
    }
    return { status: true, message: "Médico actualizado correctamente" };
  } catch (error) {
    console.error("Error en updateMedicoService:", error.message);
    throw error;
  } finally {
    if (connection) await connection.end();
  }
};

// Eliminar médico
const deleteMedicoService = async (id_medico) => {
  let connection;
  try {
    connection = await connectDB();

    // Verificar si tiene citas asociadas
    const [citas] = await connection.execute(
      "SELECT id_cita FROM cita_medica WHERE id_medico = ?",
      [id_medico]
    );

    if (citas.length > 0) {
      return { status: false, message: "No se puede eliminar el médico porque tiene citas registradas." };
    }

    const [result] = await connection.execute(
      "DELETE FROM medico WHERE id_medico = ?", 
      [id_medico]
    );

    if (result.affectedRows === 0) {
      return { status: false, message: "Médico no encontrado o ya eliminado" };
    }

    return { status: true, message: "Médico eliminado correctamente" };
  } catch (error) {
    console.error("Error en deleteMedicoService:", error.message);
    throw error;
  } finally {
    if (connection) await connection.end();
  }
};

// Buscar médico por nombre
const getMedicoByNombreService = async (nombre) => {
  let connection;
  try {
    connection = await connectDB();
    const [rows] = await connection.execute(
      `SELECT 
         m.id_medico,
         m.id_usuario,
         u.nombre AS nombre_usuario,
         u.email AS email_usuario,
         m.especialidad,
         m.registro_profesional
       FROM medico m
       JOIN usuario u ON m.id_usuario = u.id_usuario
       WHERE u.nombre LIKE ?`,
      [`%${nombre}%`] // busca coincidencias parciales
    );
    return rows;
  } catch (error) {
    console.error("Error al obtener médico por nombre: ", error.message);
    throw error;
  } finally {
    if (connection) await connection.end();
  }
};

// Buscar médicos por especialidad
const getMedicoByEspecialidadService = async (especialidad) => {
  let connection;
  try {
    connection = await connectDB();
    const [rows] = await connection.execute(
      `SELECT 
         m.id_medico,
         m.id_usuario,
         u.nombre AS nombre_usuario,
         u.email AS email_usuario,
         m.especialidad,
         m.registro_profesional
       FROM medico m
       JOIN usuario u ON m.id_usuario = u.id_usuario
       WHERE m.especialidad LIKE ?`,
      [`%${especialidad}%`]
    );
    return rows;
  } catch (error) {
    console.error("Error al obtener médicos por especialidad: ", error.message);
    throw error;
  } finally {
    if (connection) await connection.end();
  }
};

module.exports = {
  getAllMedicosService,
  getMedicoByIdService,
  getMedicoByNombreService,
  getMedicoByEspecialidadService,
  createMedicoService,
  updateMedicoService,
  deleteMedicoService
};
