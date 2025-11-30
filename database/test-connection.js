const pool = require('../config/db');

async function testConnection() {
    try {
        // Test basic connection
        const client = await pool.connect();
        console.log('✅ Connected to PostgreSQL database');

        // Test schema exists
        const shcemaTest = await client.query(`
            SELECT schema_name
            FROM information_schema.schemata
            WHERE schema_name = 'my_fitness_schema'
        `);
        console.log('✅ Schema exists', shcemaTest.rows);

        // List all tables
        const tables = await client.query(`
            SELECT table_name
            FROM information_schema.tables
            WHERE table_schema = 'my_fitness_schema'
        `);
        console.log('✅ Tables exist', tables.rows);

        const enums = await client.query(`
            SELECT typname
            FROM pg_type
            WHERE typnamespace = (
                SELECT oid
                FROM pg_namespace
                WHERE nspname = 'my_fitness_schema'
            )
            AND typtype = 'e'
        `);
        console.log('✅ Enums exist', enums.rows);

        client.release();
        process.exit(0);
    } catch (err) {
        console.error('❌ Error connecting to PostgreSQL database', err);
        process.exit(1);
    }
}

testConnection();