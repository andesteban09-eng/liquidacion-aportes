const express = require("express");
const conexion = require("./conexion.js");

const app = express();
const port = 3000;

app.use(express.json());
app.use(express.static("public"));

app.post("/liquidaciones", async (req, res) => {
  try {
    const liquidacion = req.body;
    async function calcular(liquidacion) {
      const sueldo = Number(liquidacion.sueldo);
      if (!Number.isFinite(sueldo) || sueldo < 0) {
        throw new Error("Sueldo debe ser un número positivo");
      }
      liquidacion.ibc = sueldo * 0.4;
      if (!liquidacion.ibc || liquidacion.ibc < 1750000) {
        liquidacion.ibc = 1750000;
      }
      if (!liquidacion.tarifaArl_id) {
        liquidacion.tarifaArl_id = 1;
      }
      const ibc = liquidacion.ibc;
      const salud = liquidacion.ibc * 0.125;
      const pension = liquidacion.ibc * 0.16;
      const data = await conexion.query(
        "SELECT nivelArl, porcentaje FROM tarifaArl WHERE id = $1",
        [liquidacion.tarifaArl_id],
      );
      const dataArl = data.rows[0];
      if (!dataArl) {
        throw new Error("Tarifa ARL no encontrada");
      }
      const calculoArl = (ibc, porcentaje) => {
        return ibc * porcentaje;
      };
      const arl = calculoArl(ibc, dataArl.porcentaje);
      const total = salud + pension + arl;
      return {
        ibc,
        salud,
        pension,
        arl,
        total,
        tarifaArl_id: liquidacion.tarifaArl_id,
      };
    }
    const resultado = await calcular(liquidacion);
    const data = await conexion.query(
      `INSERT INTO liquidacion (ibc, salud, pension, arl, total, tarifaArl_id) VALUES ($1, $2, $3, $4, $5, $6) RETURNING *`,
      [
        resultado.ibc,
        resultado.salud,
        resultado.pension,
        resultado.arl,
        resultado.total,
        resultado.tarifaArl_id,
      ],
    );

    return res.status(201).json(data.rows[0]);
  } catch (error) {
    console.error(error);
    res.status(500).json({
      error: "Error al consultar la liquidación de aportes",
    });
  }
});

app.get("/arl", async (req, res) => {
  try {
    const data = await conexion.query("SELECT * FROM tarifaArl");
    res.json(data.rows);
  } catch (error) {
    console.error(error);
    res.status(500).json({
      error: "Error al consultar la liquidación de aportes",
    });
  }
});

app.get("/liquidaciones", async (req, res) => {
  try {
    const data = await conexion.query(
      "SELECT l.*, a.nivelArl, a.porcentaje FROM liquidacion l JOIN tarifaArl a ON l.tarifaArl_id = a.id ORDER BY l.fecha_creacion DESC",
    );
    res.json(data.rows);
  } catch (error) {
    console.error(error);
    res.status(500).json({
      error: "Error al consultar la liquidación de aportes",
    });
  }
});

app.get("/liquidaciones/:id", async (req, res) => {
  try {
    const id = req.params.id;
    const data = await conexion.query(
      "SELECT l.*, a.nivelArl, a.porcentaje FROM liquidacion l JOIN tarifaArl a ON l.tarifaArl_id = a.id WHERE l.id = $1",
      [id],
    );
    if (data.rows.length === 0) {
      return res.status(404).json({
        error: "Liquidación no encontrada",
      });
    }
    res.json(data.rows[0]);
  } catch (error) {
    console.error(error);
    res.status(500).json({
      error: "Error al consultar la liquidación de aportes",
    });
  }
});
app.listen(port, () => {
  console.log(`Servidor escuchando en http://localhost:${port}`);
});
