const express = require('express');
const path = require('path');
const pool = require('./config/db');
require('dotenv').config();

const app = express();
const port = process.env.PORT || 3001;

// Set EJS as templating engine
app.set('view engine', 'ejs');
app.set('views', path.join(__dirname, 'views'));

// Middleware
app.use(express.urlencoded({ extended: true }));
app.use(express.json());
app.use(express.static(path.join(__dirname, 'public')));

// API Routes
app.get('/api/exercises', async (req, res) => {
    const { bodyPart, equipment, search } = req.query;
    const options = {
        method: 'GET',
        headers: {
            'x-rapidapi-host': 'exercisedb.p.rapidapi.com',
            'x-rapidapi-key': process.env.RAPIDAPI_KEY
        }
    };
  
    try {
        let url = 'https://exercisedb.p.rapidapi.com/exercises';
        
        // Add query parameters if they exist
        if (bodyPart && bodyPart !== 'all') {
            url = `https://exercisedb.p.rapidapi.com/exercises/bodyPart/${bodyPart}`;
        } else if (equipment && equipment !== 'all') {
            url = `https://exercisedb.p.rapidapi.com/exercises/equipment/${equipment}`;
        }
        
        console.log('Fetching from URL:', url); // Debug log
        const response = await fetch(url, options);
        
        if (!response.ok) {
            const errorText = await response.text();
            console.error('API Response not OK:', response.status, errorText);
            throw new Error(`HTTP error! status: ${response.status}`);
        }
        
        let data = await response.json();
        
        // Apply search filter if it exists
        if (search) {
            const searchLower = search.toLowerCase();
            data = data.filter(exercise => 
                exercise.name.toLowerCase().includes(searchLower) ||
                exercise.bodyPart.toLowerCase().includes(searchLower) ||
                exercise.equipment.toLowerCase().includes(searchLower)
            );
        }
        
        res.json(data);
    } catch (error) {
        console.error('API Error:', error);
        res.status(500).json({ error: 'Failed to fetch exercises' });
    }
});

// Test database connection
pool.connect((err, client, release) => {
  if (err) {
    return console.error('Error acquiring db client', err.stack);
  }
  console.log('Connected to PostgreSQL database');
  release();
});

// Routes
app.get('/', (req, res) => {
  res.render('index', { title: 'Home Page' });
});

//exercises page route
app.get('/exercises', (req, res) => {
    res.render('pages/exercises', { title: 'Workout Library' });
});

//bmi page route
app.get('/bmi', (req, res) => {
    res.render('pages/bmi', { title: 'BMI Calculator' });
});

// 404 route
app.use((req, res) => {
    res.status(404).render('pages/404', { 
        title: 'Page Not Found',
        url: req.url
    });
});

// Example database route
app.get('/users', async (req, res) => {
  try {
    const result = await pool.query('SELECT * FROM users');
    res.render('pages/users', { users: result.rows });
  } catch (err) {
    console.error(err);
    res.status(500).send('Server error');
  }
});

app.listen(port, () => {
  console.log(`Server is running on http://localhost:${port}`);
});