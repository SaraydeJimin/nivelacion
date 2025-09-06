const {
  getAllFormulasService,
  getFormulasByPacienteService,
  createFormulaService,
  updateFormulaService,
  deleteFormulaService,
} = require("../services/forService");

const {
  formulaForCreation,
  formulaForUpdate,
  formulaForSearch,
} = require("../models/for");

const getAllFormulas = async (req, res) => {
  try {
    const response = await getAllFormulasService();
    res.json({ response });
  } catch (error) {
    console.error("Error en el controlador al obtener fórmulas médicas:", error.message);
    res.status(500).json({ error: "Error en el servidor" });
  }
};

const getFormulasByPaciente = async (req, res) => {
  const { error } = formulaForSearch.validate({ id_paciente: req.params.id });
  if (error) {
    return res.status(400).json({ error: error.details[0].message });
  }
  try {
    const response = await getFormulasByPacienteService(req.params.id);
    res.json({ response });
  } catch (err) {
    console.error("Error en el controlador al obtener fórmulas por paciente:", err.message);
    res.status(500).json({ error: "Error en el servidor" });
  }
};

const createFormula = async (req, res) => {
  const { error } = formulaForCreation.validate(req.body);
  if (error) {
    return res.status(400).json({ error: error.details[0].message });
  }
  try {
    const response = await createFormulaService(req.body);
    res.status(201).json({ message: "Fórmula médica creada exitosamente", response });
  } catch (err) {
    console.error("Error en el controlador al crear fórmula médica:", err.message);
    res.status(500).json({ error: "Error en el servidor" });
  }
};

const updateFormula = async (req, res) => {
  const { error } = formulaForUpdate.validate(req.body);
  if (error) {
    return res.status(400).json({ error: error.details[0].message });
  }
  try {
    const { id } = req.params;
    const response = await updateFormulaService(id, req.body);
    if (response.status) {
      res.status(200).json({ message: response.message });
    } else {
      res.status(404).json({ message: response.message });
    }
  } catch (err) {
    console.error("Error en el controlador al actualizar fórmula médica:", err.message);
    res.status(500).json({ error: "Error en el servidor" });
  }
};

const deleteFormula = async (req, res) => {
  const id_formula = Number(req.params.id);
  if (!id_formula || isNaN(id_formula)) {
    return res.status(400).json({ error: "ID inválido para eliminar fórmula médica" });
  }
  try {
    const response = await deleteFormulaService(id_formula);
    if (response.status) {
      res.status(200).json({ message: response.message });
    } else {
      res.status(404).json({ message: response.message });
    }
  } catch (err) {
    console.error("Error en el controlador al eliminar fórmula médica:", err.message);
    res.status(500).json({ error: "Error en el servidor" });
  }
};

module.exports = {
  getAllFormulas,
  getFormulasByPaciente,
  createFormula,
  updateFormula,
  deleteFormula,
};
