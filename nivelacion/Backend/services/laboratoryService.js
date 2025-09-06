const connectDB = require("../config/database");

// Obtener todos los laboratorios con datos relacionados
const getAllLaboratoriosService = async () => {
  let connection;
  try {
    connection = await connectDB();
    const [rows] = await connection.execute(`
      SELECT 
        l.id_laboratorio,
        l.id_cita,
        l.id_paciente,
        u.nombre AS nombre_paciente,
        l.id_medico,
        um.nombre AS nombre_medico,
        l.tipo_prueba,
        l.resultados,
        l.fecha
      FROM laboratorio l
      JOIN usuario u ON l.id_paciente = u.id_usuario
      JOIN medico m ON l.id_medico = m.id_medico
      JOIN usuario um ON m.id_usuario = um.id_usuario
    `);
    return rows;
  } catch (error) {
    console.error("Error al obtener laboratorios:", error.message);
    throw error;
  } finally {
    if (connection) await connection.end();
  }
};

// Obtener laboratorios por paciente
const getLaboratoriosByPacienteService = async (id_paciente) => {
  let connection;
  try {
    connection = await connectDB();
    const [rows] = await connection.execute(
      `SELECT 
        l.id_laboratorio,
        l.id_cita,
        l.id_paciente,
        u.nombre AS nombre_paciente,
        l.id_medico,
        um.nombre AS nombre_medico,
        l.tipo_prueba,
        l.resultados,
        l.fecha
      FROM laboratorio l
      JOIN usuario u ON l.id_paciente = u.id_usuario
      JOIN medico m ON l.id_medico = m.id_medico
      JOIN usuario um ON m.id_usuario = um.id_usuario
      WHERE l.id_paciente = ?`,
      [id_paciente]
    );
    return rows;
  } catch (error) {
    console.error("Error al obtener laboratorios por paciente:", error.message);
    throw error;
  } finally {
    if (connection) await connection.end();
  }
};

// Crear un laboratorio
const createLaboratorioService = async (data) => {
  const { id_cita, id_paciente, id_medico, tipo_prueba, resultados, fecha } = data;
  let connection;

  try {
    connection = await connectDB();

    // Validar cita
    const [cita] = await connection.execute(
      "SELECT id_cita FROM cita_medica WHERE id_cita = ?",
      [id_cita]
    );
    if (cita.length === 0) {
      return { status: false, message: `La cita con id ${id_cita} no existe` };
    }

    // Validar paciente
    const [paciente] = await connection.execute(
      "SELECT id_usuario FROM usuario WHERE id_usuario = ?",
      [id_paciente]
    );
    if (paciente.length === 0) {
      return { status: false, message: `El paciente con id ${id_paciente} no existe` };
    }

    // Validar médico
    const [medico] = await connection.execute(
      "SELECT id_medico FROM medico WHERE id_medico = ?",
      [id_medico]
    );
    if (medico.length === 0) {
      return { status: false, message: `El médico con id ${id_medico} no existe` };
    }

    // Insertar laboratorio
    const [result] = await connection.execute(
      `INSERT INTO laboratorio (id_cita, id_paciente, id_medico, tipo_prueba, resultados, fecha)
       VALUES (?, ?, ?, ?, ?, ?)`,
      [id_cita, id_paciente, id_medico, tipo_prueba, resultados || null, fecha]
    );

    return {
      status: true,
      message: "Laboratorio creado correctamente",
      laboratorio: {
        id_laboratorio: result.insertId,
        id_cita,
        id_paciente,
        id_medico,
        tipo_prueba,
        resultados,
        fecha
      }
    };
  } catch (error) {
    console.error("Error al crear laboratorio:", error.message);
    throw error;
  } finally {
    if (connection) await connection.end();
  }
};

// Actualizar un laboratorio
const updateLaboratorioService = async (id_laboratorio, data) => {
  let connection;
  try {
    connection = await connectDB();

    // Verificar si existe
    const [rows] = await connection.execute(
      "SELECT * FROM laboratorio WHERE id_laboratorio = ?",
      [id_laboratorio]
    );
    if (rows.length === 0) {
      return { status: false, message: "Laboratorio no encontrado" };
    }

    const current = rows[0];

    // Solo actualizamos campos editables (NO foreign keys)
    const tipo_prueba = data.tipo_prueba ?? current.tipo_prueba;
    const resultados = data.resultados ?? current.resultados;
    const fecha = data.fecha ?? current.fecha;

    const [result] = await connection.execute(
      `UPDATE laboratorio
       SET tipo_prueba = ?, resultados = ?, fecha = ?
       WHERE id_laboratorio = ?`,
      [tipo_prueba, resultados, fecha, id_laboratorio]
    );

    if (result.affectedRows === 0) {
      return { status: false, message: "No se pudo actualizar el laboratorio" };
    }

    return { status: true, message: "Laboratorio actualizado correctamente" };
  } catch (error) {
    console.error("Error al actualizar laboratorio:", error.message);
    throw error;
  } finally {
    if (connection) await connection.end();
  }
};

// Eliminar un laboratorio
const deleteLaboratorioService = async (id_laboratorio) => {
  let connection;
  try {
    connection = await connectDB();
    const [result] = await connection.execute(
      "DELETE FROM laboratorio WHERE id_laboratorio = ?",
      [id_laboratorio]
    );
    if (result.affectedRows === 0) {
      return { status: false, message: "Laboratorio no encontrado o ya eliminado" };
    }
    return { status: true, message: "Laboratorio eliminado correctamente" };
  } catch (error) {
    console.error("Error al eliminar laboratorio:", error.message);
    throw error;
  } finally {
    if (connection) await connection.end();
  }
};

module.exports = {
  getAllLaboratoriosService,
  getLaboratoriosByPacienteService,
  createLaboratorioService,
  updateLaboratorioService,
  deleteLaboratorioService
};
