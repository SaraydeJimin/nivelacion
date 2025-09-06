const bcrypt = require("bcryptjs");

async function generarHash() {
  const password = "123JuanG#"; // aquí pones la contraseña real
  const hash = await bcrypt.hash(password, 10);
  console.log("Hash generado:", hash);
}

generarHash();
