const connectDB = require("../config/database");

const getAllDetallesService = async (idPaciente = null) => {
  let connection;
  try {
    connection = await connectDB();

    // Base del query
    let query = `
      SELECT 
        df.id_detalle,
        df.id_formula,
        df.id_medicamento,
        m.nombre AS nombre_medicamento,
        df.cantidad,
        df.dosis,
        df.duracion
      FROM detalle_formula df
      JOIN medicamento m ON df.id_medicamento = m.id_medicamento
      JOIN formula_medica f ON df.id_formula = f.id_formula
    `;
    
    const params = [];
    
    if (idPaciente !== null) {
      query += " WHERE f.id_paciente = ?";
      params.push(idPaciente);
    }

    const [rows] = await connection.execute(query, params);
    return rows;
  } catch (error) {
    console.error("Error en getAllDetallesService:", error.message);
    throw error;
  } finally {
    if (connection) await connection.end();
  }
};

const searchDetallesService = async (filters) => {
  let connection;
  try {
    connection = await connectDB();
    let query = `
      SELECT 
        df.id_detalle,
        df.id_formula,
        df.id_medicamento,
        m.nombre AS nombre_medicamento,
        df.cantidad,
        df.dosis,
        df.duracion
      FROM detalle_formula df
      JOIN medicamento m ON df.id_medicamento = m.id_medicamento
      WHERE 1=1
    `;
    const params = [];

    if (filters.id_formula) {
      query += " AND df.id_formula = ?";
      params.push(filters.id_formula);
    }
    if (filters.id_medicamento) {
      query += " AND df.id_medicamento = ?";
      params.push(filters.id_medicamento);
    }

    const [rows] = await connection.execute(query, params);
    return rows;
  } catch (error) {
    console.error("Error en searchDetallesService:", error.message);
    throw error;
  } finally {
    if (connection) await connection.end();
  }
};

const createDetalleService = async (data) => {
  const { id_formula, id_medicamento, cantidad, dosis, duracion } = data;
  let connection;
  try {
    connection = await connectDB();

    const [formulaRows] = await connection.execute(
      "SELECT id_formula FROM formula_medica WHERE id_formula = ?",
      [id_formula]
    );
    if (formulaRows.length === 0) {
      return { status: false, message: "La fórmula médica no existe" };
    }

    const [medRows] = await connection.execute(
      "SELECT id_medicamento FROM medicamento WHERE id_medicamento = ?",
      [id_medicamento]
    );
    if (medRows.length === 0) {
      return { status: false, message: "El medicamento no existe" };
    }

    const [result] = await connection.execute(
      `INSERT INTO detalle_formula (id_formula, id_medicamento, cantidad, dosis, duracion)
       VALUES (?, ?, ?, ?, ?)`,
      [id_formula, id_medicamento, cantidad, dosis ?? null, duracion ?? null]
    );

    return {
      status: true,
      id_detalle: result.insertId,
      id_formula,
      id_medicamento,
      cantidad,
      dosis,
      duracion,
    };
  } catch (error) {
    console.error("Error en createDetalleService:", error.message);
    throw error;
  } finally {
    if (connection) await connection.end();
  }
};

// 🔹 Actualizar un detalle
const updateDetalleService = async (data) => {
  const { id_detalle, cantidad, dosis, duracion } = data;
  let connection;
  try {
    connection = await connectDB();

    // Verificar si existe
    const [rows] = await connection.execute(
      "SELECT * FROM detalle_formula WHERE id_detalle = ?",
      [id_detalle]
    );
    if (rows.length === 0) {
      return { status: false, message: "Detalle no encontrado" };
    }

    // Actualizar solo campos enviados
    const newCantidad = cantidad ?? rows[0].cantidad;
    const newDosis = dosis ?? rows[0].dosis;
    const newDuracion = duracion ?? rows[0].duracion;

    const [result] = await connection.execute(
      `UPDATE detalle_formula
       SET cantidad = ?, dosis = ?, duracion = ?
       WHERE id_detalle = ?`,
      [newCantidad, newDosis, newDuracion, id_detalle]
    );

    if (result.affectedRows === 0) {
      return { status: false, message: "No se pudo actualizar el detalle" };
    }

    return { status: true, message: "Detalle actualizado correctamente" };
  } catch (error) {
    console.error("Error en updateDetalleService:", error.message);
    throw error;
  } finally {
    if (connection) await connection.end();
  }
};

// 🔹 Eliminar un detalle
const deleteDetalleService = async (id_detalle) => {
  let connection;
  try {
    connection = await connectDB();
    const [result] = await connection.execute(
      "DELETE FROM detalle_formula WHERE id_detalle = ?",
      [id_detalle]
    );

    if (result.affectedRows === 0) {
      return { status: false, message: "Detalle no encontrado o ya eliminado" };
    }
    return { status: true, message: "Detalle eliminado correctamente" };
  } catch (error) {
    console.error("Error en deleteDetalleService:", error.message);
    throw error;
  } finally {
    if (connection) await connection.end();
  }
};

module.exports = {
  getAllDetallesService,
  searchDetallesService,
  createDetalleService,
  updateDetalleService,
  deleteDetalleService
};