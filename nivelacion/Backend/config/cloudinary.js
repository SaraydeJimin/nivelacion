const cloudinary = require('cloudinary').v2;

// Configuración de Cloudinary con las variables de entorno
cloudinary.config({
  cloud_name: process.env.CLOUDINARY_CLOUD_NAME,
  api_key: process.env.CLOUDINARY_API_KEY,
  api_secret: process.env.CLOUDINARY_API_SECRET
});

const uploadImage = async (filePath) => {
  try {
    const result = await cloudinary.uploader.upload(filePath, {
      folder: "products"
    });
    console.log("Resultado de Cloudinary:", result); // Verifica el resultado aquí
    return result;
  } catch (error) {
    console.error("Cloudinary error:", error);
    throw new Error('Error al subir la imagen a Cloudinary');
  }
};

module.exports = { uploadImage };
