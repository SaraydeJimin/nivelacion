const connectDB = require("../config/database");

// Obtener todas las fórmulas médicas
const getAllFormulasService = async () => {
  let connection;
  try {
    connection = await connectDB();
    const [formulas] = await connection.execute(`
      SELECT 
        f.id_formula,
        f.id_cita,
        f.id_medico,
        f.id_paciente,
        f.fecha,
        f.observaciones,
        u1.nombre AS nombre_medico,
        u2.nombre AS nombre_paciente
      FROM formula_medica f
      JOIN medico m ON f.id_medico = m.id_medico
      JOIN usuario u1 ON m.id_usuario = u1.id_usuario
      JOIN usuario u2 ON f.id_paciente = u2.id_usuario
      `);
    return formulas;
  } catch (error) {
    console.error("Error al obtener todas las fórmulas médicas:", error.message);
    throw error;
  } finally {
    if (connection) await connection.end();
  }
};

// Obtener fórmulas por paciente
const getFormulasByPacienteService = async (id_paciente) => {
  let connection;
  try {
    connection = await connectDB();
    const [formulas] = await connection.execute(
      `SELECT 
        f.id_formula,
        f.id_cita,
        f.id_medico,
        f.id_paciente,
        f.fecha,
        f.observaciones,
        u1.nombre AS nombre_medico
      FROM formula_medica f
      JOIN medico m ON f.id_medico = m.id_medico
      JOIN usuario u1 ON m.id_usuario = u1.id_usuario
      WHERE f.id_paciente = ?`,
      [id_paciente]
      );
    return formulas;
  } catch (error) {
    console.error("Error al obtener fórmulas por paciente:", error.message);
    throw error;
  } finally {
    if (connection) await connection.end();
  }
};

// Crear una nueva fórmula médica
const createFormulaService = async (data) => {
  const { id_cita, id_medico, id_paciente, fecha, observaciones } = data;
  let connection;
  try {
    connection = await connectDB();

    // Verificar que la cita exista
    const [citaRows] = await connection.execute(
      "SELECT * FROM cita_medica WHERE id_cita = ?",
      [id_cita]
    );
    if (citaRows.length === 0) {
      return { status: false, message: "La cita médica no existe" };
    }

    // Insertar fórmula
    const [result] = await connection.execute(
      `INSERT INTO formula_medica (id_cita, id_medico, id_paciente, fecha, observaciones)
       VALUES (?, ?, ?, ?, ?)`,
      [id_cita, id_medico, id_paciente, fecha, observaciones || null]
    );

    return {
      status: true,
      message: "Fórmula creada correctamente",
      id_formula: result.insertId,
      id_cita,
      id_medico,
      id_paciente,
      fecha,
      observaciones,
    };
  } catch (error) {
    console.error("Error al crear fórmula médica:", error.message);
    throw error;
  } finally {
    if (connection) await connection.end();
  }
};

// Actualizar una fórmula médica
const updateFormulaService = async (id_formula, data) => {
  let connection;
  try {
    connection = await connectDB();

    const [rows] = await connection.execute(
      "SELECT * FROM formula_medica WHERE id_formula = ?",
      [id_formula]
    );
    if (rows.length === 0) {
      return { status: false, message: "Fórmula médica no encontrada" };
    }

    const current = rows[0];
    const fecha = data.fecha ?? current.fecha;
    const observaciones = data.observaciones ?? current.observaciones;

    const [result] = await connection.execute(
      `UPDATE formula_medica
       SET fecha = ?, observaciones = ?
       WHERE id_formula = ?`,
      [fecha, observaciones, id_formula]
    );

    if (result.affectedRows === 0) {
      return { status: false, message: "No se actualizó la fórmula médica" };
    }

    return { status: true, message: "Fórmula médica actualizada correctamente" };
  } catch (error) {
    console.error("Error al actualizar fórmula médica:", error.message);
    throw error;
  } finally {
    if (connection) await connection.end();
  }
};

// Eliminar fórmula médica
const deleteFormulaService = async (id_formula) => {
  let connection;
  try {
    connection = await connectDB();
    const [result] = await connection.execute(
      "DELETE FROM formula_medica WHERE id_formula = ?",
      [id_formula]
    );
    if (result.affectedRows === 0) {
      return { status: false, message: "Fórmula médica no encontrada o ya eliminada" };
    }
    return { status: true, message: "Fórmula médica eliminada correctamente" };
  } catch (error) {
    console.error("Error al eliminar fórmula médica:", error.message);
    throw error;
  } finally {
    if (connection) await connection.end();
  }
};

module.exports = {
  getAllFormulasService,
  getFormulasByPacienteService,
  createFormulaService,
  updateFormulaService,
  deleteFormulaService,
};
