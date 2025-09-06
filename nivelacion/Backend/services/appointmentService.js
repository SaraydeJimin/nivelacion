const connectDB = require("../config/database");

// Obtener todas las citas (con info de paciente y médico)
const getAllCitasService = async (idMedico = null) => {
  let connection;
  try {
    connection = await connectDB();

    let query = `
  SELECT 
    c.id_cita,
    c.id_paciente,
    IFNULL(u.nombre, 'Desconocido') AS paciente,
    c.id_medico,
    IFNULL(um.nombre, 'Desconocido') AS medico,
    c.fecha,
    c.hora  
    FROM cita_medica c
  LEFT JOIN usuario u ON c.id_paciente = u.id_usuario
  LEFT JOIN medico m ON c.id_medico = m.id_medico
  LEFT JOIN usuario um ON m.id_usuario = um.id_usuario
`;

const params = [];
if (idMedico !== null) {
  query += " WHERE c.id_medico = ?";
  params.push(idMedico);
}

query += " ORDER BY c.fecha DESC, c.hora DESC";

    const [citas] = await connection.execute(query, params);
    return citas;
  } catch (error) {
    console.error("Error al obtener citas:", error.message);
    throw error;
  } finally {
    if (connection) await connection.end();
  }
};

// Obtener cita por ID
const getCitaByIdService = async (id_cita) => {
  let connection;
  try {
    connection = await connectDB();
    const [rows] = await connection.execute(
      `SELECT 
        c.id_cita,
        c.id_paciente,
        u.nombre AS paciente,
        c.id_medico,
        um.nombre AS medico,
        c.fecha,
        c.hora
      FROM cita_medica c
      JOIN usuario u ON c.id_paciente = u.id_usuario AND u.id_rol = 1
      JOIN medico m ON c.id_medico = m.id_medico
      JOIN usuario um ON m.id_usuario = um.id_usuario
      WHERE c.id_cita = ?`,
      [id_cita]
    );
    return rows[0] ?? null;
  } catch (error) {
    console.error("Error al obtener cita por ID:", error.message);
    throw error;
  } finally {
    if (connection) await connection.end();
  }
};

// Obtener citas por paciente
const getCitasByPacienteService = async (idPaciente) => {
  let connection;
  try {
    connection = await connectDB();
    const query = `
      SELECT 
  c.id_cita,
  c.id_paciente,
  u.nombre AS paciente,
  c.id_medico,
  um.nombre AS medico,
  c.fecha,
  c.hora
FROM cita_medica c
JOIN usuario u ON c.id_paciente = u.id_usuario  -- el paciente es un usuario
JOIN medico m ON c.id_medico = m.id_medico
JOIN usuario um ON m.id_usuario = um.id_usuario
WHERE c.id_paciente = ?
ORDER BY c.fecha DESC, c.hora DESC;

    `;

    const [citas] = await connection.execute(query, [idPaciente]);
    return citas;
  } catch (error) {
    console.error("Error al obtener citas por paciente:", error.message);
    throw error;
  } finally {
    if (connection) await connection.end();
  }
};

// Crear cita
const createCitaService = async (data) => {
  const { id_paciente, id_medico, fecha, hora } = data;
  let connection;
  try {
    connection = await connectDB();

    // Validar paciente
    const [paciente] = await connection.execute(
      "SELECT id_usuario FROM usuario WHERE id_usuario = ? AND id_rol = 1",
      [id_paciente]
    );
    if (paciente.length === 0) {
      return { status: false, message: `Paciente con id ${id_paciente} no existe` };
    }

    // Validar médico
    const [medico] = await connection.execute(
      "SELECT id_medico FROM medico WHERE id_medico = ?",
      [id_medico]
    );
    if (medico.length === 0) {
      return { status: false, message: `Médico con id ${id_medico} no existe` };
    }

    const [result] = await connection.execute(
  `INSERT INTO cita_medica (id_paciente, id_medico, fecha, hora)
   VALUES (?, ?, ?, ?)`,
  [id_paciente, id_medico, fecha, hora]
);


    return {
      status: true,
      message: "Cita creada correctamente",
      cita: {
        id_cita: result.insertId,
        id_paciente,
        id_medico,
        fecha,
        hora      
      },
    };
  } catch (error) {
    console.error("Error al crear cita:", error.message);
    throw error;
  } finally {
    if (connection) await connection.end();
  }
};

// Actualizar cita
const updateCitaService = async (id_cita, data) => {
  let connection;
  try {
    connection = await connectDB();

    // Verificar que exista la cita
    const [rows] = await connection.execute(
      "SELECT * FROM cita_medica WHERE id_cita = ?",
      [id_cita]
    );
    if (rows.length === 0) {
      return { status: false, message: "Cita no encontrada" };
    }

    const current = rows[0];
    const fecha = data.fecha ?? current.fecha;
    const hora = data.hora ?? current.hora;

    const [result] = await connection.execute(
      `UPDATE cita_medica
       SET fecha = ?, hora = ?
       WHERE id_cita = ?`,
      [fecha, hora, id_cita]
    );

    if (result.affectedRows === 0) {
      return { status: false, message: "No se pudo actualizar la cita" };
    }

    return { status: true, message: "Cita actualizada correctamente" };
  } catch (error) {
    console.error("Error en updateCitaService:", error.message);
    throw error;
  } finally {
    if (connection) await connection.end();
  }
};

// Eliminar cita
const deleteCitaService = async (id_cita) => {
  let connection;
  try {
    connection = await connectDB();
    const [result] = await connection.execute(
      "DELETE FROM cita_medica WHERE id_cita = ?",
      [id_cita]
    );
    if (result.affectedRows === 0) {
      return { status: false, message: "Cita no encontrada o ya eliminada" };
    }
    return { status: true, message: "Cita eliminada correctamente" };
  } catch (error) {
    console.error("Error en deleteCitaService:", error.message);
    throw error;
  } finally {
    if (connection) await connection.end();
  }
};

module.exports = {
  getAllCitasService,
  getCitaByIdService,
  getCitasByPacienteService,
  createCitaService,
  updateCitaService,
  deleteCitaService,
};
