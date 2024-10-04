CREATE TABLE User(
    UserID INTEGER PRIMARY KEY,
    Name VARCHAR(50) NOT NULL,
    Age INTEGER NOT NULL, -- Need to enforce 13 <= age <= 100
    Gender VARCHAR(1) NOT NULL, -- Need to enforce this is in the set 'M', 'F', 'O'
    BodyWeight DECIMAL(5, 2) NOT NULL -- Need to enforce that this is positive
    TrainingHistoryLength INTEGER NOT NULL
);

CREATE TABLE TrainingPlan(
    TrainingPlanID INTEGER PRIMARY KEY,
    Level VARCHAR(50) NOT NULL, -- Need to enforce this is in the set 'Beginner', 'Intermediate', 'Advanced'
    IsDeload BOOLEAN NOT NULL,
    VolumeAdjustmentPercentage DECIMAL(3, 2), -- Need to enforce that this is positive and less than 2.00
);

-- Need to enforce that one of VolumePercentage or IntensityPercentage are  <= 1.00 for it to be a deload
CREATE TABLE DeloadTrainingPlan(
    TrainingPlanId INTEGER PRIMARY KEY,
    VolumePercentage DECIMAL(3, 2) NOT NULL, -- Need to enforce that this is positive and <= to 1.00 for it to be a deload
    IntensityPercentage DECIMAL(3, 2) NOT NULL, -- Need to enforce that this is positive and <= to 1.00 for it to be a deload
    FOREIGN KEY (TrainingPlanId) REFERENCES TrainingPlan(TrainingPlanId) ON DELETE CASCADE,
);


-- Added foreign keys for the (exactly one) relationship with TrainingPlan and User.
CREATE TABLE Workout(
    WorkoutId INTEGER PRIMARY KEY,
    SequenceNumber INTEGER NOT NULL, -- Need to enforce this is unique within the context of a TrainingPlanId
    ScheduledDate DATETIME NOT NULL,
    PerformedDate DATETIME, -- Can be NULL, since we will schedule Workouts to be performed in the future.
    Stress INTEGER NOT NULL, -- Need to enforce that this is in the range 1 to 5
    Soreness INTEGER NOT NULL, -- Need to enforce that this is in the range 1 to 5
    SleepQuality INTEGER NOT NULL, -- Need to enforce that this is in the range 1 to 5
    TrainingPlanId INTEGER NOT NULL,
    PerformingUserId INTEGER NOT NULL,
    FOREIGN KEY (TrainingPlanId) REFERENCES TrainingPlan(TrainingPlanId) ON DELETE CASCADE,
    FOREIGN KEY (PerformingUserId) REFERENCES User(UserId) ON DELETE CASCADE
);

-- Cannot currently capture constraint that MinSets <= MaxSets.
CREATE TABLE WorkoutExercise(
    WorkoutExerciseId INTEGER PRIMARY KEY,
    MinSets INTEGER NOT NULL,
    MaxSets INTEGER, -- Might be NULL until the workout is started, and then we set this based on their "readiness" score
    ExerciseOrder INTEGER NOT NULL, -- Need to enforce this is unique within the context of a WorkoutId (i.e. no two WorkoutExercises will be in the same 'position' in the Workout)
    ExerciseName VARCHAR(100) NOT NULL, -- For the relationship with Exercise
    WorkoutId INTEGER NOT NULL, -- For the relationship with Workout
    FOREIGN KEY (ExerciseName) REFERENCES Exercise(Name) ON DELETE CASCADE,
    FOREIGN KEY (WorkoutId) REFERENCES Workout(WorkoutId) ON DELETE CASCADE
);

-- WorkoutSet is part of a weak entity set, merged with Involves
-- Cannot currently capture constraint that MinReps <= MaxReps.
CREATE TABLE WorkoutSet(
    WorkoutExerciseId INTEGER,
    SetOrder INTEGER,
    MinReps INTEGER NOT NULL,
    MaxReps INTEGER NOT NULL,
    TargetWeight DECIMAL(6, 2), -- Might be NULL for example on the first workout when we have no reference to go on for the weight. Need to enforce this is not negative
    PRIMARY KEY(WorkoutExerciseId, SetOrder),
    FOREIGN KEY (WorkoutExerciseId) REFERENCES WorkoutExercise(WorkoutExerciseId) ON DELETE CASCADE
);

CREATE TABLE Exercise(
    Name VARCHAR(100) PRIMARY KEY,
    Description VARCHAR(250),
    IsMainLift BOOLEAN NOT NULL
);

-- Captures the associate relationship (Records) between WorkoutSet and ExercisePerformance
-- Every ExercisePerformance record must be linked to exactly one WorkoutSet
CREATE TABLE ExercisePerformance (
    PerformanceId INTEGER PRIMARY KEY,
    WorkoutExerciseId INTEGER NOT NULL,
    SetOrder INTEGER NOT NULL,
    ActualReps INTEGER NOT NULL, -- Need to enforce that this must be > 0
    ActualWeightUsed DECIMAL(6, 2) NOT NULL, -- Need to enforce this is positive
    CompletionTime DATETIME NOT NULL,
    FOREIGN KEY (WorkoutExerciseId, SetOrder) REFERENCES WorkoutSet(WorkoutExerciseId, SetOrder) ON DELETE CASCADE
);

-- Relationship set table(s) --
-- Follows (User --> Training Plan): We can't yet enforce the participation constraint that every User is associated with a TrainingPlan
CREATE TABLE Follows(
    UserID INTEGER NOT NULL,
    TrainingPlanID INTEGER NOT NULL,
    PRIMARY KEY (UserID, TrainingPlanID), -- Not sure about this!
    FOREIGN KEY (UserID) REFERENCES User(UserID),
    FOREIGN KEY (TrainingPlanID) REFERENCES TrainingPlan(TrainingPlanID) ON DELETE CASCADE
);
