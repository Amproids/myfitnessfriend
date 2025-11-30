SET search_path TO my_fitness_schema;

-- Insert a test user
INSERT INTO users (username, main_email, gender, date_of_birth, is_over_13, display_name, user_valid)
VALUES ('testuser', 'test@example.com', 'male', '1990-01-01', true, 'Test User', true);

-- Insert some test exercises
INSERT INTO exercises (name, workout_type, description, difficulty, tags)
VALUES 
  ('Bench Press', 'sets_reps', 'Chest exercise', 'intermediate', 
   '{"muscle_group": ["chest", "triceps"], "equipment": ["barbell"]}'),
  ('Running', 'duration', 'Cardio exercise', 'beginner',
   '{"muscle_group": ["legs"], "equipment": ["none"]}');