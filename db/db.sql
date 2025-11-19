-- Database generated with pgModeler (PostgreSQL Database Modeler).
-- pgModeler version: 1.1.6
-- PostgreSQL version: 17.0
-- Project Site: pgmodeler.io
-- Model Author: ---
-- Tablespaces creation must be performed outside a multi lined SQL file. 
-- These commands were put in this file only as a convenience.
-- 
-- object: "Users" | type: TABLESPACE --
-- DROP TABLESPACE IF EXISTS "Users" CASCADE;
CREATE TABLESPACE "Users"
	OWNER postgres
	LOCATION 'myfitnessfriend';

-- ddl-end --



-- Database creation must be performed outside a multi lined SQL file. 
-- These commands were put in this file only as a convenience.
-- 
-- object: new_database | type: DATABASE --
-- DROP DATABASE IF EXISTS new_database;
CREATE DATABASE new_database;
-- ddl-end --


-- object: "MyFitnessDB" | type: SCHEMA --
-- DROP SCHEMA IF EXISTS "MyFitnessDB" CASCADE;
CREATE SCHEMA "MyFitnessDB";
-- ddl-end --
ALTER SCHEMA "MyFitnessDB" OWNER TO postgres;
-- ddl-end --

SET search_path TO pg_catalog,public,"MyFitnessDB";
-- ddl-end --

-- object: "MyFitnessDB"."Users" | type: TABLE --
-- DROP TABLE IF EXISTS "MyFitnessDB"."Users" CASCADE;
CREATE TABLE "MyFitnessDB"."Users" (
	user_id serial NOT NULL,
	username varchar(50) NOT NULL,
	email varchar(255) NOT NULL,
	password_hash varchar(255) NOT NULL,
	account_validated boolean DEFAULT FALSE,
	first_name varchar(100) NOT NULL,
	last_name varchar(100),
	age smallint,
	date_of_birth date NOT NULL,
	gender "MyFitnessDB".gender,
	created_at timestamptz NOT NULL DEFAULT CURRENT_TIMESTAMP,
	last_active timestamptz NOT NULL DEFAULT CURRENT_TIMESTAMP,
	units "MyFitnessDB".units NOT NULL,
	CONSTRAINT "Users_pk" PRIMARY KEY (user_id),
	CONSTRAINT username_uq UNIQUE (username),
	CONSTRAINT email_uq UNIQUE (email),
	CONSTRAINT username_lower CHECK (username = lower(username)),
	CONSTRAINT height_check CHECK (height_cm IS NULL OR height_cm BETWEEN 50 AND 300),
	CONSTRAINT dob_check CHECK (date_of_birth IS NULL OR (date_of_birth >= '1900-01-01' AND date_of_birth <= CURRENT_DATE - INTERVAL '13 years')),
	CONSTRAINT email_format_check CHECK (email ~* '^[^@]+@[^@]+\.[^@]+$')
);
-- ddl-end --
COMMENT ON COLUMN "MyFitnessDB"."Users".email IS E'Let users know that unverified users cannot share workouts.';
-- ddl-end --
ALTER TABLE "MyFitnessDB"."Users" OWNER TO postgres;
-- ddl-end --

-- object: "MyFitnessDB"."Exercises" | type: TABLE --
-- DROP TABLE IF EXISTS "MyFitnessDB"."Exercises" CASCADE;
CREATE TABLE "MyFitnessDB"."Exercises" (
	exercise_id serial NOT NULL,
	exercise_name varchar(200) NOT NULL,
	exercise_metric "MyFitnessDB".exercise_metric NOT NULL,
	uses_weights boolean NOT NULL,
	notes text,
	instructions text NOT NULL,
	difficulty_level smallint NOT NULL,
	tags jsonb NOT NULL,
	CONSTRAINT "Exercises_pk" PRIMARY KEY (exercise_id)
);
-- ddl-end --
COMMENT ON COLUMN "MyFitnessDB"."Exercises".difficulty_level IS E'Complexity of workout/technique difficulty: 1 - Beginner, 2 - Intermediate, 3 - Hard';
-- ddl-end --
COMMENT ON COLUMN "MyFitnessDB"."Exercises".tags IS E'/* \nEXERCISE TAGS - Use any combination in JSONB array\n\nMOVEMENT TYPES:\n- strength, cardio, flexibility, balance, coordination, power, endurance\n\nEQUIPMENT:\n- bodyweight, barbell, dumbbell, kettlebell, resistance_band, cable_machine, \n- smith_machine, pull_up_bar, dip_bars, medicine_ball, stability_ball, \n- bosu_ball, foam_roller, treadmill, bike, rowing_machine, elliptical\n\nBODY PARTS:\n- upper_body, lower_body, full_body, core, chest, back, shoulders, arms, \n- biceps, triceps, forearms, abs, glutes, quads, hamstrings, calves, neck\n\nTRAINING STYLE:\n- circuit, hiit, tabata, superset, dropset, pyramid, isometric, plyometric,\n- compound, isolation, unilateral, bilateral, explosive, slow_tempo\n\nSPECIAL CATEGORIES:\n- rehabilitation, pregnancy_safe, senior_friendly, low_impact, high_impact,\n- sports_specific, functional, powerlifting, bodybuilding, crossfit, yoga,\n- pilates, martial_arts, dance\n\nEXAMPLE:\n- Push-ups: ["strength", "bodyweight", "chest", "triceps", "upper_body", "compound", "beginner", "home"]\n*/';
-- ddl-end --
ALTER TABLE "MyFitnessDB"."Exercises" OWNER TO postgres;
-- ddl-end --

-- object: "MyFitnessDB"."Workout_History" | type: TABLE --
-- DROP TABLE IF EXISTS "MyFitnessDB"."Workout_History" CASCADE;
CREATE TABLE "MyFitnessDB"."Workout_History" (
	session_id bigserial NOT NULL,
	"user_id_Users" integer NOT NULL,
	"routine_id_Routines" bigint,
	workout_date date NOT NULL,
	session_name varchar(200) NOT NULL,
	total_duration_minutes smallint,
	session_notes text,
	created_at timestamptz NOT NULL DEFAULT CURRENT_TIMESTAMP,
	CONSTRAINT "Workout_History_pk" PRIMARY KEY (session_id)
);
-- ddl-end --
ALTER TABLE "MyFitnessDB"."Workout_History" OWNER TO postgres;
-- ddl-end --

-- object: "MyFitnessDB"."Session_Exercises" | type: TABLE --
-- DROP TABLE IF EXISTS "MyFitnessDB"."Session_Exercises" CASCADE;
CREATE TABLE "MyFitnessDB"."Session_Exercises" (
	workout_exercise_id bigserial NOT NULL,
	sets smallint,
	reps_per_set smallint,
	weight_used_kg decimal,
	duration decimal,
	CONSTRAINT "Workout_Exercises_pk" PRIMARY KEY (workout_exercise_id)
);
-- ddl-end --
ALTER TABLE "MyFitnessDB"."Session_Exercises" OWNER TO postgres;
-- ddl-end --

-- object: "MyFitnessDB"."Measurement_Log" | type: TABLE --
-- DROP TABLE IF EXISTS "MyFitnessDB"."Measurement_Log" CASCADE;
CREATE TABLE "MyFitnessDB"."Measurement_Log" (
	log_id bigserial NOT NULL,
	"user_id_Users" integer NOT NULL,
	created_date timestamptz NOT NULL DEFAULT CURRENT_TIMESTAMP,
	log_date date NOT NULL,
	height_cm decimal(5,2),
	weight_kg decimal(5,2),
	bodyfat_percent decimal(4,2),
	muscle_mass_kg decimal(5,2),
	resting_heart_rate smallint,
	waist_cm decimal(5,2),
	notes text,
	CONSTRAINT "User_Body_Data_pk" PRIMARY KEY (log_id),
	CONSTRAINT height_check CHECK (height_cm IS NULL OR height_cm BETWEEN 50 AND 300),
	CONSTRAINT weight_check CHECK (weight_kg IS NULL OR weight_kg BETWEEN 20 AND 500),
	CONSTRAINT bodyfat_check CHECK (bodyfat_percent IS NULL OR bodyfat_percent BETWEEN 1 AND 70),
	CONSTRAINT muscle_mass_check CHECK (muscle_mass_kg IS NULL OR muscle_mass_kg BETWEEN 10 AND 200),
	CONSTRAINT waist_check CHECK (waist_cm IS NULL OR waist_cm BETWEEN 30 AND 300),
	CONSTRAINT rhr_check CHECK (resting_heart_rate IS NULL OR resting_heart_rate BETWEEN 30 AND 220)
);
-- ddl-end --
ALTER TABLE "MyFitnessDB"."Measurement_Log" OWNER TO postgres;
-- ddl-end --

-- object: "MyFitnessDB"."Routines" | type: TABLE --
-- DROP TABLE IF EXISTS "MyFitnessDB"."Routines" CASCADE;
CREATE TABLE "MyFitnessDB"."Routines" (
	routine_id bigserial NOT NULL,
	session_name varchar(200) NOT NULL,
	created_at timestamptz NOT NULL DEFAULT CURRENT_TIMESTAMP,
	total_duration_minutes smallint,
	times_used bigint NOT NULL,
	public boolean NOT NULL,
	rating decimal,
	notes text,
	CONSTRAINT "Routine_pk" PRIMARY KEY (routine_id)
);
-- ddl-end --
ALTER TABLE "MyFitnessDB"."Routines" OWNER TO postgres;
-- ddl-end --

-- object: "MyFitnessDB"."Routine_Exercises" | type: TABLE --
-- DROP TABLE IF EXISTS "MyFitnessDB"."Routine_Exercises" CASCADE;
CREATE TABLE "MyFitnessDB"."Routine_Exercises" (
	sets smallint,
	reps_per_set smallint,
	weight_used_kg decimal,
	duration_minutes decimal

);
-- ddl-end --
ALTER TABLE "MyFitnessDB"."Routine_Exercises" OWNER TO postgres;
-- ddl-end --

-- object: "MyFitnessDB".exercise_metric | type: TYPE --
-- DROP TYPE IF EXISTS "MyFitnessDB".exercise_metric CASCADE;
CREATE TYPE "MyFitnessDB".exercise_metric AS
ENUM ('duration','reps_sets');
-- ddl-end --
ALTER TYPE "MyFitnessDB".exercise_metric OWNER TO postgres;
-- ddl-end --

-- object: "MyFitnessDB".gender | type: TYPE --
-- DROP TYPE IF EXISTS "MyFitnessDB".gender CASCADE;
CREATE TYPE "MyFitnessDB".gender AS
ENUM ('male','female');
-- ddl-end --
ALTER TYPE "MyFitnessDB".gender OWNER TO postgres;
-- ddl-end --

-- object: "MyFitnessDB".units | type: TYPE --
-- DROP TYPE IF EXISTS "MyFitnessDB".units CASCADE;
CREATE TYPE "MyFitnessDB".units AS
ENUM ('metric','imperial');
-- ddl-end --
ALTER TYPE "MyFitnessDB".units OWNER TO postgres;
-- ddl-end --

-- object: users_last_active_idx | type: INDEX --
-- DROP INDEX IF EXISTS "MyFitnessDB".users_last_active_idx CASCADE;
CREATE INDEX users_last_active_idx ON "MyFitnessDB"."Users"
USING btree
(
	last_active
);
-- ddl-end --

-- object: "Users_fk" | type: CONSTRAINT --
-- ALTER TABLE "MyFitnessDB"."Workout_History" DROP CONSTRAINT IF EXISTS "Users_fk" CASCADE;
ALTER TABLE "MyFitnessDB"."Workout_History" ADD CONSTRAINT "Users_fk" FOREIGN KEY ("user_id_Users")
REFERENCES "MyFitnessDB"."Users" (user_id) MATCH FULL
ON DELETE RESTRICT ON UPDATE CASCADE;
-- ddl-end --

-- object: "Routines_fk" | type: CONSTRAINT --
-- ALTER TABLE "MyFitnessDB"."Workout_History" DROP CONSTRAINT IF EXISTS "Routines_fk" CASCADE;
ALTER TABLE "MyFitnessDB"."Workout_History" ADD CONSTRAINT "Routines_fk" FOREIGN KEY ("routine_id_Routines")
REFERENCES "MyFitnessDB"."Routines" (routine_id) MATCH FULL
ON DELETE SET NULL ON UPDATE CASCADE;
-- ddl-end --

-- object: "MyFitnessDB"."Favorite_User_Exercises" | type: TABLE --
-- DROP TABLE IF EXISTS "MyFitnessDB"."Favorite_User_Exercises" CASCADE;
CREATE TABLE "MyFitnessDB"."Favorite_User_Exercises" (
	"user_id_Users" integer NOT NULL,
	"exercise_id_Exercises" integer NOT NULL

);
-- ddl-end --
ALTER TABLE "MyFitnessDB"."Favorite_User_Exercises" OWNER TO postgres;
-- ddl-end --

-- object: "Users_fk" | type: CONSTRAINT --
-- ALTER TABLE "MyFitnessDB"."Favorite_User_Exercises" DROP CONSTRAINT IF EXISTS "Users_fk" CASCADE;
ALTER TABLE "MyFitnessDB"."Favorite_User_Exercises" ADD CONSTRAINT "Users_fk" FOREIGN KEY ("user_id_Users")
REFERENCES "MyFitnessDB"."Users" (user_id) MATCH FULL
ON DELETE RESTRICT ON UPDATE CASCADE;
-- ddl-end --

-- object: "Exercises_fk" | type: CONSTRAINT --
-- ALTER TABLE "MyFitnessDB"."Favorite_User_Exercises" DROP CONSTRAINT IF EXISTS "Exercises_fk" CASCADE;
ALTER TABLE "MyFitnessDB"."Favorite_User_Exercises" ADD CONSTRAINT "Exercises_fk" FOREIGN KEY ("exercise_id_Exercises")
REFERENCES "MyFitnessDB"."Exercises" (exercise_id) MATCH FULL
ON DELETE RESTRICT ON UPDATE CASCADE;
-- ddl-end --

-- object: "MyFitnessDB"."Favorite_User_Routines" | type: TABLE --
-- DROP TABLE IF EXISTS "MyFitnessDB"."Favorite_User_Routines" CASCADE;
CREATE TABLE "MyFitnessDB"."Favorite_User_Routines" (
	"user_id_Users" integer NOT NULL,
	"routine_id_Routines" bigint

);
-- ddl-end --
ALTER TABLE "MyFitnessDB"."Favorite_User_Routines" OWNER TO postgres;
-- ddl-end --

-- object: "Users_fk" | type: CONSTRAINT --
-- ALTER TABLE "MyFitnessDB"."Favorite_User_Routines" DROP CONSTRAINT IF EXISTS "Users_fk" CASCADE;
ALTER TABLE "MyFitnessDB"."Favorite_User_Routines" ADD CONSTRAINT "Users_fk" FOREIGN KEY ("user_id_Users")
REFERENCES "MyFitnessDB"."Users" (user_id) MATCH FULL
ON DELETE RESTRICT ON UPDATE CASCADE;
-- ddl-end --

-- object: "Routines_fk" | type: CONSTRAINT --
-- ALTER TABLE "MyFitnessDB"."Favorite_User_Routines" DROP CONSTRAINT IF EXISTS "Routines_fk" CASCADE;
ALTER TABLE "MyFitnessDB"."Favorite_User_Routines" ADD CONSTRAINT "Routines_fk" FOREIGN KEY ("routine_id_Routines")
REFERENCES "MyFitnessDB"."Routines" (routine_id) MATCH FULL
ON DELETE SET NULL ON UPDATE CASCADE;
-- ddl-end --

-- object: "Users_fk" | type: CONSTRAINT --
-- ALTER TABLE "MyFitnessDB"."Measurement_Log" DROP CONSTRAINT IF EXISTS "Users_fk" CASCADE;
ALTER TABLE "MyFitnessDB"."Measurement_Log" ADD CONSTRAINT "Users_fk" FOREIGN KEY ("user_id_Users")
REFERENCES "MyFitnessDB"."Users" (user_id) MATCH FULL
ON DELETE RESTRICT ON UPDATE CASCADE;
-- ddl-end --

-- object: measurement_user_date_idx | type: INDEX --
-- DROP INDEX IF EXISTS "MyFitnessDB".measurement_user_date_idx CASCADE;
CREATE INDEX measurement_user_date_idx ON "MyFitnessDB"."Measurement_Log"
USING btree
(
	"user_id_Users" ASC NULLS LAST,
	log_date DESC NULLS LAST
);
-- ddl-end --


