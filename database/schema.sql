-- Database is already created by docker-compose environment variables
-- So we skip the CREATE DATABASE and just set up the schema

-- CREATE DATABASE my_fitness_db
--     WITH  OWNER = my_fitness_db
--     ENCODING = 'UTF8'
--     LC_COLLATE = 'en_US.utf8'
--     LC_CTYPE = 'en_US.utf8'
--     TABLESPACE = pg_default
--     CONNECTION LIMIT = -1;

-- \c my_fitness_db  -- Not needed, we're already in the right database


-- Create schema
CREATE SCHEMA IF NOT EXISTS my_fitness_schema;

-- Set search path to include schema
SET search_path TO my_fitness_schema;

-- Create types
CREATE TYPE gender AS ENUM ('male', 'female');

CREATE TYPE units AS ENUM ('imperial', 'metric');

CREATE TYPE user_goal AS ENUM (
  'general_fitness',
  'functional_fitness',
  'weight_loss',
  'fat_loss',
  'muscle_building',
  'strength_training',
  'cardiovascular_health',
  'endurance_building',
  'flexibility',
  'mobility',
  'injury_prevention',
  'injury_recovery',
  'event_training',
  'sport_performance',
  'stress_management'
);

CREATE TYPE log_type AS ENUM ('height', 'weight', 'bodyfat_percent', 'waist', 'muscle_mass');

CREATE TYPE workout_type AS ENUM ('duration', 'sets_reps');

CREATE TYPE auth_provider AS ENUM ('local', 'google', 'facebook');

CREATE TYPE difficulty_level AS ENUM ('beginner', 'intermediate', 'advanced');

-- Create tables

CREATE TABLE IF NOT EXISTS Users (
    id serial PRIMARY KEY,
    username VARCHAR(50) UNIQUE NOT NULL,
    main_email VARCHAR(200) UNIQUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    last_active TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    is_active BOOLEAN DEFAULT TRUE,
    is_admin BOOLEAN DEFAULT FALSE,
    user_valid BOOLEAN DEFAULT FALSE NOT NULL,
    gender gender,
    date_of_birth DATE,
    is_over_13 BOOLEAN NOT NULL,
    display_name VARCHAR(100),
    preferred_units units DEFAULT 'metric' NOT NULL,
    CONSTRAINT valid_date_of_birth CHECK (
        date_of_birth IS NULL OR 
        (date_of_birth <= CURRENT_DATE AND date_of_birth >= '1900-01-01')
    )
);

CREATE TABLE IF NOT EXISTS User_Auth_Methods (
    id serial PRIMARY KEY,
    user_id int REFERENCES Users(id) ON DELETE CASCADE,
    auth_provider auth_provider NOT NULL,
    provider_user_id VARCHAR(255), -- OAuth provider's unique ID (null for local)
    provider_email VARCHAR(200), -- Email from OAuth provider
    password_hash VARCHAR(255), -- Only populated for local auth
    linked_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    last_used TIMESTAMP,
    is_primary BOOLEAN DEFAULT FALSE,
    UNIQUE(user_id, auth_provider), -- One method per provider per user
    UNIQUE(auth_provider, provider_user_id), -- Each OAuth account links to one user only
    CONSTRAINT local_auth_requires_password CHECK (
        (auth_provider = 'local' AND password_hash IS NOT NULL) OR
        (auth_provider != 'local' AND password_hash IS NULL)
    )
);

CREATE INDEX idx_user_auth_methods_user_id ON User_Auth_Methods(user_id);

-- Optional but recommended: ensure only one primary method per user
CREATE UNIQUE INDEX idx_one_primary_per_user 
ON User_Auth_Methods(user_id) 
WHERE is_primary = TRUE;

CREATE TABLE IF NOT EXISTS Exercises (
    id serial PRIMARY KEY,
    name VARCHAR(100) UNIQUE NOT NULL, -- Admin-created exercises only
    workout_type workout_type NOT NULL,
    description TEXT,
    difficulty difficulty_level,
    tags JSONB, -- Structure: {"muscle_group": ["chest", "triceps"], "equipment": ["barbell"], ...}
    is_official BOOLEAN DEFAULT TRUE, -- All exercises are official (admin-created)
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    is_active BOOLEAN DEFAULT TRUE
);

-- Create GIN index for fast JSONB querying
CREATE INDEX idx_exercise_tags ON Exercises USING GIN (tags);
CREATE INDEX idx_exercises_active ON Exercises(is_active);

CREATE TABLE IF NOT EXISTS User_Favorite_Exercises (
    user_id int REFERENCES Users(id) ON DELETE CASCADE,
    exercise_id int REFERENCES Exercises(id) ON DELETE CASCADE,
    PRIMARY KEY (user_id, exercise_id)
);

CREATE TABLE IF NOT EXISTS Workout_Routines (
    id serial PRIMARY KEY,
    user_id int REFERENCES Users(id) ON DELETE SET NULL, -- NULL means orphaned (deleted user)
    routine_name VARCHAR(100) NOT NULL,
    description TEXT,
    is_public BOOLEAN DEFAULT FALSE, -- Public routines persist after user deletion
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    is_active BOOLEAN DEFAULT TRUE,
    is_favorite BOOLEAN DEFAULT FALSE
);

CREATE TABLE IF NOT EXISTS Routine_Exercises (
    id serial PRIMARY KEY,
    routine_id int REFERENCES Workout_Routines(id) ON DELETE CASCADE,
    exercise_id int REFERENCES Exercises(id) ON DELETE RESTRICT, -- Protect exercises in use
    order_in_routine smallint NOT NULL,
    target_sets smallint,
    target_reps smallint,
    target_weight_kg decimal(6, 2),
    target_duration_minutes smallint,
    rest_seconds smallint,
    notes TEXT
);

CREATE TABLE IF NOT EXISTS Workout_History (
    id bigserial PRIMARY KEY,
    user_id int REFERENCES Users(id) ON DELETE CASCADE, -- Delete workout history with user
    routine_id int REFERENCES Workout_Routines(id) ON DELETE SET NULL,
    workout_name VARCHAR(100),
    workout_date DATE NOT NULL,
    logged_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    duration_minutes smallint,
    calories_burned smallint,
    rating smallint CHECK (rating >= 1 AND rating <= 5),
    notes TEXT,
    CONSTRAINT valid_workout_date CHECK (workout_date <= CURRENT_DATE),
    CONSTRAINT valid_duration CHECK (duration_minutes IS NULL OR duration_minutes > 0),
    CONSTRAINT valid_calories CHECK (calories_burned IS NULL OR calories_burned > 0)
);

CREATE TABLE IF NOT EXISTS Session_Exercises (
    id bigserial PRIMARY KEY,
    workout_id bigint REFERENCES Workout_History(id) ON DELETE CASCADE, -- Delete with workout
    exercise_id int REFERENCES Exercises(id) ON DELETE RESTRICT, -- Protect exercises in use
    order_in_workout smallint NOT NULL,
    set_data JSONB, -- [{"set": 1, "reps": 10, "weight_kg": 61.2, "rest_seconds": 90}, ...]
    duration_minutes smallint,
    distance_km decimal(6, 2),
    pace_min_per_km decimal(4, 2),
    calories_burned smallint,
    notes TEXT,
    completed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS User_Measurement_Logs (
    id bigserial PRIMARY KEY,
    user_id int REFERENCES Users(id) ON DELETE CASCADE, -- Delete measurements with user
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    weight_kg decimal(5, 2),
    height_cm decimal(5, 1),
    bodyfat_percent decimal(5, 2),
    waist_cm decimal(5, 1),
    muscle_mass_kg decimal(5, 2),
    notes TEXT,
    CONSTRAINT at_least_one_measurement CHECK (
        weight_kg IS NOT NULL OR 
        height_cm IS NOT NULL OR 
        bodyfat_percent IS NOT NULL OR 
        waist_cm IS NOT NULL OR 
        muscle_mass_kg IS NOT NULL
    ),
    CONSTRAINT valid_weight CHECK (weight_kg IS NULL OR weight_kg > 0),
    CONSTRAINT valid_height CHECK (height_cm IS NULL OR height_cm > 0),
    CONSTRAINT valid_bodyfat CHECK (bodyfat_percent IS NULL OR (bodyfat_percent >= 0 AND bodyfat_percent <= 100)),
    CONSTRAINT valid_waist CHECK (waist_cm IS NULL OR waist_cm > 0),
    CONSTRAINT valid_muscle_mass CHECK (muscle_mass_kg IS NULL OR muscle_mass_kg > 0)
);

-- Indexes for foreign keys and common queries
CREATE INDEX idx_user_auth_methods_user_id ON User_Auth_Methods(user_id);
CREATE INDEX idx_workout_routines_user_id ON Workout_Routines(user_id);
CREATE INDEX idx_workout_routines_public ON Workout_Routines(is_public, is_active);
CREATE INDEX idx_routine_exercises_routine_id ON Routine_Exercises(routine_id);
CREATE INDEX idx_routine_exercises_exercise_id ON Routine_Exercises(exercise_id);
CREATE INDEX idx_workout_history_user_id ON Workout_History(user_id);
CREATE INDEX idx_workout_history_routine_id ON Workout_History(routine_id);
CREATE INDEX idx_workout_history_workout_date ON Workout_History(workout_date);
CREATE INDEX idx_workout_history_user_date ON Workout_History(user_id, workout_date DESC);
CREATE INDEX idx_session_exercises_workout_id ON Session_Exercises(workout_id);
CREATE INDEX idx_session_exercises_exercise_id ON Session_Exercises(exercise_id);
CREATE INDEX idx_session_exercise_set_data ON Session_Exercises USING GIN (set_data);
CREATE INDEX idx_measurement_logs_user_id ON User_Measurement_Logs(user_id);
CREATE INDEX idx_measurement_logs_created_at ON User_Measurement_Logs(created_at);

-- Trigger to delete private routines when user is deleted
CREATE OR REPLACE FUNCTION delete_private_routines_on_user_deletion()
RETURNS TRIGGER AS $$
BEGIN
    DELETE FROM Workout_Routines 
    WHERE user_id IS NULL 
    AND is_public = FALSE 
    AND id IN (
        SELECT id FROM Workout_Routines WHERE user_id = OLD.id
    );
    RETURN OLD;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER cleanup_private_routines
AFTER UPDATE OF user_id ON Workout_Routines
FOR EACH ROW
WHEN (NEW.user_id IS NULL AND OLD.user_id IS NOT NULL)
EXECUTE FUNCTION delete_private_routines_on_user_deletion();

-- Example JSONB structures for reference:
-- Exercise tags:
-- {
--   "muscle_group": ["chest", "triceps", "shoulders"],
--   "equipment": ["barbell", "bench"],
--   "movement_pattern": ["push", "compound"],
--   "training_style": ["strength", "hypertrophy"]
-- }

-- Set data:
-- [
--   {"set": 1, "reps": 10, "weight_kg": 61.2, "rest_seconds": 90},
--   {"set": 2, "reps": 8, "weight_kg": 65.8, "rest_seconds": 90},
--   {"set": 3, "reps": 6, "weight_kg": 70.3, "rest_seconds": 120}
-- ]