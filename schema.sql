CREATE TABLE User(
    UserID INTEGER PRIMARY KEY,
    Name VARCHAR(50) NOT NULL,
    Age INTEGER NOT NULL,
    Gender VARCHAR(1) NOT NULL,
    BodyWeight DECIMAL(5, 2) NOT NULL -- Can be in the range [-999.99, 999.99],
    TrainingHistoryLength INTEGER NOT NULL
);

CREATE TABLE TrainingPlan(
    TrainingPlanID INTEGER PRIMARY KEY,
    Level VARCHAR(50) NOT NULL,
    IsDeload BOOLEAN NOT NULL, -- Can be 0 for False and 1 for True Kostas: Apparently, BOOLEAN is preferred in PostgreSQL
    VolumeAdjustmentPercentage DECIMAL(3, 2), -- Can be in the range [-9.99, 9.99]
);

CREATE TABLE DeloadTrainingPlan(
    TrainingPlanId INTEGER PRIMARY KEY,
    VolumePercentage DECIMAL(3, 2) NOT NULL,
    IntensityPercentage DECIMAL(3, 2) NOT NULL,
    FOREIGN KEY (TrainingPlanId) REFERENCES TrainingPlan(TrainingPlanId) ON DELETE CASCADE,
);


-- Added foreign keys for the (exactly one) relationship with TrainingPlan and User.
CREATE TABLE Workout(
    WorkoutId INTEGER PRIMARY KEY,
    SequenceNumber INTEGER NOT NULL,
    ScheduledDate DATETIME NOT NULL,
    PerformedDate DATETIME, -- Can be NULL, since we will schedule Workouts to be performed in the future
    Stress INTEGER NOT NULL,
    Soreness INTEGER NOT NULL,
    SleepQuality INTEGER NOT NULL,
    TrainingPlanId INTEGER NOT NULL,
    PerformingUserId INTEGER NOT NULL,
    FOREIGN KEY (TrainingPlanId) REFERENCES TrainingPlan(TrainingPlanId) ON DELETE CASCADE,
    FOREIGN KEY (PerformingUserId) REFERENCES User(UserId) ON DELETE CASCADE
);

-- Cannot currently capture constraint that MinSets <= MaxSets. Same for MinReps and MaxReps.
CREATE TABLE WorkoutExercise(
    WorkoutExerciseId INTEGER PRIMARY KEY,
    MinSets INTEGER NOT NULL,
    MaxSets INTEGER, -- Might be NULL until the workout is started, and then we set this based on their "readiness" score
    ExerciseOrder INTEGER NOT NULL,
    UsesExerciseId INTEGER NOT NULL,
    IncludedInWorkoutId INTEGER NOT NULL,
    FOREIGN KEY (UsesExercise) REFERENCES Exercise(ExerciseId) ON DELETE CASCADE,
    FOREIGN KEY (IncludedInWorkout) REFERENCES Workout(WorkoutId) ON DELETE CASCADE
);

-- WorkoutSet is part of a weak entity set, merged with Involves
CREATE TABLE WorkoutSet_ForWorkoutExercise(
    WorkoutExerciseId INTEGER,
    SetId INTEGER, -- Specifies the order of the set in the WorkoutExercise
    MinReps INTEGER NOT NULL,
    MaxReps INTEGER NOT NULL,
    Weight INTEGER, -- Might be NULL for example on the first workout when we have no reference to go on for the weight
    PRIMARY KEY(WorkoutExerciseId, SetId),
    FOREIGN KEY (WorkoutExerciseId) REFERENCES WorkoutExercise(WorkoutExerciseId) ON DELETE CASCADE
);

-- PerformanceLog w/o constraints
CREATE TABLE PerformanceLog(
    PerformanceLogID INTEGER PRIMARY KEY,
    DateTime DATETIME,
    SetsCompleted INTEGER,
    RepsCompleted INTEGER,
    WeightUsed FLOAT,
    Estimated1RM FLOAT,
    PerformedDate TIMESTAMP, -- I changed this to TIMESTAMP as it is like this in Workout
    Stress INTEGER,
    Soreness INTEGER,
    SleepQuality INTEGER
);

-- Exercise w/o constraints
CREATE TABLE Exercise(
    ExerciseID INTEGER PRIMARY KEY,
    Name VARCHAR(100) NOT NULL
);


-- Relationship set from here on --

-- Follows (User --> Training Plan): We can't enforce that every User is associated with a TrainingPlan
CREATE TABLE Follows(
    UserID INTEGER NOT NULL,
    TrainingPlanID INTEGER NOT NULL,
    PRIMARY KEY (UserID, TrainingPlanID), -- Not sure about this!
    FOREIGN KEY (UserID) REFERENCES User(UserID),
    FOREIGN KEY (TrainingPlanID) REFERENCES TrainingPlan(TrainingPlanID)
);

-- Performs (User --> Workout): Each User can perform multiple Workouts,
-- but each Workout can be performed by only one User
CREATE TABLE Performs(
    UserID INTEGER NOT NULL,
    WorkoutID INTEGER,
    PRIMARY KEY (WorkoutID), -- Key constraint
    FOREIGN KEY (UserID) REFERENCES User(UserID),
    FOREIGN KEY (WorkoutID) REFERENCES Workout(WorkoutID)
);

-- Contains (Workout --> WorkoutExercise)
CREATE TABLE Contains(
    WorkoutID INTEGER,
    WorkoutExerciseID INTEGER,
    PRIMARY KEY (WorkoutID),  -- Key constraint
    FOREIGN KEY (WorkoutID) REFERENCES Workout(WorkoutID),
    FOREIGN KEY (WorkoutExerciseID) REFERENCES WorkoutExercise(WorkoutExerciseID)
);

-- Includes (WorkoutExercise --> Exercise)
CREATE TABLE Includes(
    WorkoutExerciseID INTEGER,
    ExerciseID INTEGER,
    PRIMARY KEY (WorkoutExerciseID, ExerciseID),
    FOREIGN KEY (WorkoutExerciseID) REFERENCES WorkoutExercise(WorkoutExerciseID),
    FOREIGN KEY (ExerciseID) REFERENCES Exercise(ExerciseID)
);

-- Records (PerformanceLog --> Exercise)
CREATE TABLE Records(
    PerformanceLogID INTEGER,
    ExerciseID INTEGER,
    PRIMARY KEY (PerformanceLogID, ExerciseID),
    FOREIGN KEY (PerformanceLogID) REFERENCES PerformanceLog(PerformanceLogID),
    FOREIGN KEY (ExerciseID) REFERENCES Exercise(ExerciseID)
);

-- Uses (WorkoutExercise --> Exercise)
CREATE TABLE Uses(
    WorkoutExerciseID INTEGER NOT NULL,
    ExerciseID INTEGER NOT NULL,
    PRIMARY KEY (WorkoutExerciseID),  -- Key Constraint
    FOREIGN KEY (WorkoutExerciseID) REFERENCES WorkoutExercise(WorkoutExerciseID),
    FOREIGN KEY (ExerciseID) REFERENCES Exercise(ExerciseID)
);


-- NOTES:
-- 1. Workout is linked to Contains and Performs with a total participation constraint 
-- AND a key constraint in both relationships. We cannot implement Option 2 discussed in class, 
-- since we would have to duplicate the Workout set and create WorkoutContains and WorkoutPerformed
-- with almost identical information. Therefore, we will focus only on the 

-- 2. WorkoutExercise could be merged with Uses if standalone in a binary relationship with Exercise,
-- but it is currently involved in a few other relationships, so we will have to omit the
-- participation constraint