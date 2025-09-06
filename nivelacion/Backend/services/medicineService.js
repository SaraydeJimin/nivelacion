const connectDB = require("../config/database");

// Obtener todos los medicamentos
const getAllMedicamentosService = async () => {
  let connection;
  try {
    connection = await connectDB();
    const [medicamentos] = await connection.execute(`
      SELECT 
        id_medicamento,
        nombre,
        descripcion,
        concentracion,
        presentacion
      FROM medicamento
    `);
    return medicamentos;
  } catch (error) {
    console.error("Error al obtener medicamentos: ", error.message);
    throw error;
  } finally {
    if (connection) await connection.end();
  }
};

// Obtener medicamento por ID
const getMedicamentoByIdService = async (id_medicamento) => {
  let connection;
  try {
    connection = await connectDB();
    const [rows] = await connection.execute(
      "SELECT * FROM medicamento WHERE id_medicamento = ?",
      [id_medicamento]
    );
    return rows[0] || null;
  } catch (error) {
    console.error("Error al obtener medicamento por ID: ", error.message);
    throw error;
  } finally {
    if (connection) await connection.end();
  }
};

// Filtros dinámicos
const getMedicamentosWithFiltersService = async (filters) => {
  let connection;
  try {
    connection = await connectDB();
    let query = `
      SELECT 
        id_medicamento,
        nombre,
        descripcion,
        concentracion,
        presentacion
      FROM medicamento
      WHERE 1=1
    `;
    const params = [];

    if (filters.nombre) {
      query += " AND nombre LIKE ?";
      params.push(`%${filters.nombre}%`);
    }
    if (filters.concentracion) {
      query += " AND concentracion LIKE ?";
      params.push(`%${filters.concentracion}%`);
    }
    if (filters.presentacion) {
      query += " AND presentacion LIKE ?";
      params.push(`%${filters.presentacion}%`);
    }

    const [medicamentos] = await connection.execute(query, params);
    return medicamentos;
  } catch (error) {
    console.error("Error en filtros de medicamentos: ", error.message);
    throw error;
  } finally {
    if (connection) await connection.end();
  }
};

// Crear medicamento
const createMedicamentoService = async (data) => {
  const { nombre, descripcion, concentracion, presentacion } = data;
  let connection;
  try {
    connection = await connectDB();

    // Verificar nombre único
    const [existing] = await connection.execute(
      "SELECT id_medicamento FROM medicamento WHERE nombre = ?",
      [nombre]
    );
    if (existing.length > 0) {
      throw new Error("Ya existe un medicamento con ese nombre");
    }

    const [result] = await connection.execute(
      `INSERT INTO medicamento (nombre, descripcion, concentracion, presentacion)
       VALUES (?, ?, ?, ?)`,
      [nombre, descripcion, concentracion, presentacion]
    );

    return {
      id: result.insertId,
      nombre,
      descripcion,
      concentracion,
      presentacion,
    };
  } catch (error) {
    console.error("Error en crear medicamento: ", error.message);
    throw error;
  } finally {
    if (connection) await connection.end();
  }
};

// Actualizar medicamento
const updateMedicamentoService = async (id, data) => {
  let connection;
  try {
    connection = await connectDB();

    // Verificar si existe
    const [rows] = await connection.execute(
      "SELECT * FROM medicamento WHERE id_medicamento = ?",
      [id]
    );
    if (rows.length === 0) {
      return { status: false, message: "Medicamento no encontrado" };
    }
    const current = rows[0];

    // Verificar nombre único si cambia
    const nameToCheck = data.nombre ?? current.nombre;
    if (nameToCheck !== current.nombre) {
      const [existing] = await connection.execute(
        "SELECT id_medicamento FROM medicamento WHERE nombre = ? AND id_medicamento != ?",
        [nameToCheck, id]
      );
      if (existing.length > 0) {
        return { status: false, message: "Otro medicamento ya usa ese nombre" };
      }
    }

    // Actualizar
    const nombre = data.nombre ?? current.nombre;
    const descripcion = data.descripcion ?? current.descripcion;
    const concentracion = data.concentracion ?? current.concentracion;
    const presentacion = data.presentacion ?? current.presentacion;

    const [result] = await connection.execute(
      `UPDATE medicamento
       SET nombre = ?, descripcion = ?, concentracion = ?, presentacion = ?
       WHERE id_medicamento = ?`,
      [nombre, descripcion, concentracion, presentacion, id]
    );

    if (result.affectedRows === 0) {
      return { status: false, message: "Medicamento no actualizado" };
    }
    return { status: true, message: "Medicamento actualizado correctamente" };
  } catch (error) {
    console.error("Error en updateMedicamentoService:", error.message);
    throw error;
  } finally {
    if (connection) await connection.end();
  }
};

// Eliminar medicamento
const deleteMedicamentoService = async (id_medicamento) => {
  let connection;
  try {
    connection = await connectDB();
    const [result] = await connection.execute(
      "DELETE FROM medicamento WHERE id_medicamento = ?",
      [id_medicamento]
    );
    if (result.affectedRows === 0) {
      return { status: false, message: "Medicamento no encontrado o ya eliminado" };
    }
    return { status: true, message: "Medicamento eliminado correctamente" };
  } catch (error) {
    console.error("Error en deleteMedicamentoService:", error);
    throw error;
  } finally {
    if (connection) await connection.end();
  }
};

module.exports = {
  getAllMedicamentosService,
  getMedicamentoByIdService,
  getMedicamentosWithFiltersService,
  createMedicamentoService,
  updateMedicamentoService,
  deleteMedicamentoService,
};
