// Importamos la librería 'jsonwebtoken' para trabajar con JWT (JSON Web Token)
const jwt = require("jsonwebtoken");

// Middleware para proteger las rutas y verificar si el usuario tiene un token válido
const protected = (req, res, next) => {
  // Obtenemos el token de los encabezados de la solicitud (header "Authorization")
  const token = req.headers["authorization"];

  // Si no se encuentra un token en la solicitud, respondemos con un error 403 (Acceso no autorizado)
  if (!token) {
    return res
      .status(403)
      .json({ success: false, message: "Access not authorized" });
  }

  // Si el token está presente, lo separamos para obtener solo la parte del token (sin "Bearer")
  const filterToken = token.split(" ")[1];

  try {
    // Verificamos que el token sea válido usando la clave secreta (SECRET_KEY) definida en el archivo .env
    const data = jwt.verify(filterToken, process.env.SECRET_KEY);

    // Si el token es válido, guardamos la información del usuario en 'req.user'
    req.user = data;

    // Llamamos a 'next()' para pasar al siguiente middleware o controlador
    next();
  } catch (error) {
    // Si ocurre un error al verificar el token (por ejemplo, si el token es inválido),
    // respondemos con un error 401 (Acceso no autorizado)
    return res.status(401).json({ success: false, message: "Invalid access" });
  }
};

// Exportamos el middleware para que pueda ser utilizado en otras partes del proyecto
module.exports = protected;