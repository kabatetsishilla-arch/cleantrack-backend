const fs = require("fs");
const path = require("path");
const mysql = require("mysql2/promise");
require("dotenv").config();

// Applies pending migration SQL files to an existing database without recreating it.
const migrateDatabase = async () => {
  const connection = await mysql.createConnection({
    host: process.env.DB_HOST || "localhost",
    user: process.env.DB_USER || "root",
    password: process.env.DB_PASSWORD || "",
    multipleStatements: true
  });

  const migrationsDir = path.join(__dirname, "..", "database", "migrations");
  const files = fs.readdirSync(migrationsDir).filter((file) => file.endsWith(".sql")).sort();

  for (const file of files) {
    const sql = fs.readFileSync(path.join(migrationsDir, file), "utf8");
    await connection.query(sql);
    console.log(`Applied migration: ${file}`);
  }

  await connection.end();
  console.log("Migrations complete.");
};

migrateDatabase().catch((error) => {
  console.error("Migration failed:", error.message);
  process.exit(1);
});
