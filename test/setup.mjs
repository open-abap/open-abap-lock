import {PostgresDatabaseClient} from "@abaplint/database-pg";

export async function preFunction(abap, schemas, insert) {
  abap.context.databaseConnections["DEFAULT"] = new PostgresDatabaseClient({
      user: "postgres",
      host: "localhost",
      database: "postgres",
      password: "postgres",
      port: 5432,
    });
  await abap.context.databaseConnections["DEFAULT"].connect();
  await abap.context.databaseConnections["DEFAULT"].execute(schemas.sqlite);
  await abap.context.databaseConnections["DEFAULT"].execute(insert);
}