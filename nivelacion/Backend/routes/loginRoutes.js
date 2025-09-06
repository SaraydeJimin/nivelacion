const express = require("express");
const protected = require("../middlewares/AuthMiddleware");

const {
  postLog,
  registerUser,
  getAllLogin,
  getLoginById,
  UpdateLogin,
  deleteLogin,
} = require("../controllers/loginController");

const router = express.Router();
router.post("/login", postLog);
router.post("/register", registerUser);
router.get("/all", protected, getAllLogin);
router.get("/:id_usuario", protected, getLoginById);
router.put("/:id_usuario", protected, UpdateLogin);
router.delete("/:id_usuario", protected, deleteLogin);

module.exports = router;
