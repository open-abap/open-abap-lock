import {PostgresDatabaseClient} from "@abaplint/database-pg";

export async function preFunction(abap, schemas, insert) {
  abap.context.databaseConnections["DEFAULT"] = new PostgresDatabaseClient({
      trace: false,
      user: "postgres",
      host: "localhost",
      database: "postgres",
      password: "postgres",
      port: 5432,
    });
  await abap.context.databaseConnections["DEFAULT"].connect();

  for (let i = 0; i < schemas.pg.length; i++) {
    const element = schemas.pg[i];
    schemas.pg[i] = element.replace("CREATE TABLE ", "CREATE TABLE IF NOT EXISTS ");
  }
  await abap.context.databaseConnections["DEFAULT"].execute(schemas.pg);

  for (let i = 0; i < insert.length; i++) {
    const element = insert[i];
    insert[i] = element.replace(/;$/, "") + " ON CONFLICT DO NOTHING;";
  }
  await abap.context.databaseConnections["DEFAULT"].execute(insert);
}

export async function postFunction() {
  abap.Classes["KERNEL_LOCK"] = abap.Classes["KERNEL_LOCK_CONCURRENT"];
}