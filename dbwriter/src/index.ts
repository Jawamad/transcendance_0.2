import express, { Request, Response } from "express";
import sqlite3 from "sqlite3";
import { open, Database } from "sqlite";
import path from "path";

const PORT = process.env.PORT ? Number(process.env.PORT) : 4000;
const DB_FILE = process.env.DATABASE_URL ?? "/app/data/database.sqlite";

let db: Database<sqlite3.Database, sqlite3.Statement>;

async function initDb() {
  // Nettoie et résout le chemin du fichier DB
  const filename = DB_FILE.startsWith("file:") ? DB_FILE.replace(/^file:/, "") : DB_FILE;
  const resolved = path.resolve(filename);

  db = await open({
    filename: resolved,
    driver: sqlite3.Database
  });

  // Crée les tables si elles n’existent pas déjà
  await db.exec(`
    CREATE TABLE IF NOT EXISTS player (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      username TEXT NOT NULL UNIQUE,
      mail TEXT NOT NULL UNIQUE,
      password TEXT NOT NULL,
      wallet_adress TEXT
    );

    CREATE TABLE IF NOT EXISTS tournament (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      name TEXT NOT NULL,
      creator_id INTEGER NOT NULL,
      status INTEGER NOT NULL,
      created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
      finished_at TIMESTAMP,
      FOREIGN KEY (creator_id) REFERENCES player(id)
    );

    CREATE TABLE IF NOT EXISTS game (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      tournament_id INTEGER NOT NULL,
      player1_id INTEGER NOT NULL,
      player2_id INTEGER NOT NULL,
      score1 INTEGER DEFAULT 0,
      score2 INTEGER DEFAULT 0,
      played_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
      FOREIGN KEY (tournament_id) REFERENCES tournament(id),
      FOREIGN KEY (player1_id) REFERENCES player(id),
      FOREIGN KEY (player2_id) REFERENCES player(id)
    );

    CREATE TABLE IF NOT EXISTS tournement_competitor (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      tournament_id INTEGER NOT NULL,
      player_id INTEGER NOT NULL,
      FOREIGN KEY (tournament_id) REFERENCES tournament(id),
      FOREIGN KEY (player_id) REFERENCES player(id),
      UNIQUE (tournament_id, player_id)
    );
  `);
}

async function startServer() {
  await initDb();
  const app = express();
  app.use(express.json());

  // --- Healthcheck ---
  app.get("/health", (_req: Request, res: Response) => {
    res.json({ status: "ok", service: "dbwriter" });
  });

  // --- Créer un joueur ---
  app.post("/players", async (req: Request, res: Response) => {
    try {
      const { username, mail, password, wallet_adress } = req.body;

      if (!username || !mail || !password) {
        return res.status(400).json({ error: "username, mail et password sont requis" });
      }

      const result = await db.run(
        `INSERT INTO player (username, mail, password, wallet_adress)
         VALUES (?, ?, ?, ?)`,
        [username, mail, password, wallet_adress ?? null]
      );

      const created = await db.get("SELECT * FROM player WHERE id = ?", [result.lastID]);
      res.status(201).json(created);
    } catch (err: any) {
      console.error("POST /players error:", err);
      if (err.message.includes("UNIQUE constraint failed")) {
        res.status(409).json({ error: "username ou mail déjà utilisé" });
      } else {
        res.status(500).json({ error: "Erreur interne du serveur" });
      }
    }
  });

  // --- Lister tous les joueurs ---
  app.get("/players", async (_req: Request, res: Response) => {
    try {
      const players = await db.all("SELECT * FROM player ORDER BY id ASC");
      res.json(players);
    } catch (err) {
      console.error("GET /players error:", err);
      res.status(500).json({ error: "Erreur interne du serveur" });
    }
  });

  // --- Obtenir un joueur par ID ---
  app.get("/players/:id", async (req: Request, res: Response) => {
    const id = Number(req.params.id);
    if (Number.isNaN(id)) return res.status(400).json({ error: "ID invalide" });

    try {
      const player = await db.get("SELECT * FROM player WHERE id = ?", [id]);
      if (!player) return res.status(404).json({ error: "Joueur non trouvé" });
      res.json(player);
    } catch (err) {
      console.error("GET /players/:id error:", err);
      res.status(500).json({ error: "Erreur interne du serveur" });
    }
  });

  // --- Supprimer un joueur ---
  app.delete("/players/:id", async (req: Request, res: Response) => {
    const id = Number(req.params.id);
    if (Number.isNaN(id)) return res.status(400).json({ error: "ID invalide" });

    try {
      const result = await db.run("DELETE FROM player WHERE id = ?", [id]);
      if (result.changes === 0) return res.status(404).json({ error: "Joueur non trouvé" });
      res.json({ success: true });
    } catch (err) {
      console.error("DELETE /players/:id error:", err);
      res.status(500).json({ error: "Erreur interne du serveur" });
    }
  });

  app.listen(PORT, () => {
    console.log(`✅ Serveur en ligne sur le port ${PORT} — DB : ${DB_FILE}`);
  });
}

startServer().catch((err) => {
  console.error("❌ Erreur au démarrage :", err);
  process.exit(1);
});
