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
    IsDeload BIT NOT NULL, -- Can be 0 for False and 1 for True
    VolumeAdjustmentPercentage DECIMAL(3, 2), -- Can be in the range [-9.99, 9.99]
);

CREATE TABLE DeloadTrainingPlan(
    TrainingPlanId INTEGER PRIMARY KEY,
    VolumePercentange DECIMAL(3, 2) NOT NULL,
    IntensityPercentage DECIMAL(3, 2) NOT NULL,
    FOREIGN KEY (TrainingPlanId) REFERENCES TrainingPlan(TrainingPlanId) ON DELETE CASCADE,
);


-- Added foreign keys for the (exactly one) relationship with TrainingPlan and User.
CREATE TABLE WORKOUT(
    WorkoutId INTEGER PRIMARY KEY,
    SequenceNumber INTEGER NOT NULL,
    ScheduluedDate DATETIME NOT NULL,
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
    FOREIGN KEY (UsesExercise) REFERENCES Exercise(ExerciseId) ON DELETE CASCADE,.
    FOREIGN KEY (IncludedInWorkout) REFERENCES Workout(WorkoutId) ON DELETE CASCADE
);

-- WorkoutSet is part of a weak entity set
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
    PerformedDate DATE,
    Stress INTEGER,
    Soreness INTEGER,
    SleepQuality INTEGER
);

-- Relationship set from here on --

-- Follows (User --> Training Plan)
CREATE TABLE Follows(
    UserID INTEGER,
    TrainingPlanID INTEGER,
    PRIMARY KEY (UserID, TrainingPlanID),
    FOREIGN KEY (UserID) REFERENCES User(UserID),
    FOREIGN KEY (TrainingPlanID) REFERENCES TrainingPlan(TrainingPlanID)
);

-- Performs (User --> Workout)
CREATE TABLE Performs (
    UserID INTEGER,
    WorkoutID INTEGER,
    PRIMARY KEY (UserID, WorkoutID),
    FOREIGN KEY (UserID) REFERENCES User(UserID),
    FOREIGN KEY (WorkoutID) REFERENCES Workout(WorkoutID)
);

