import {PostgresDatabaseClient} from "@abaplint/database-pg";

export async function setup(abap, schemas, insert) {
  abap.context.databaseConnections["DEFAULT"] = new PostgresDatabaseClient();
  await abap.context.databaseConnections["DEFAULT"].connect();
  await abap.context.databaseConnections["DEFAULT"].execute(schemas.sqlite);
  await abap.context.databaseConnections["DEFAULT"].execute(insert);
}