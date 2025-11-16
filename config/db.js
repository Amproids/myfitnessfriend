const { Pool } = require('pg');
const connectionString = process.env.DATABASE_URL;

if (!connectionString) {
    console.error('Error: DATABASE_URL environment variable is not set');
    throw new Error('DATABASE_URL environment variable is not set');
}

const pool = new Pool({
    connectionString: connectionString,
    // Other config settings go here.
})

module.exports = pool;