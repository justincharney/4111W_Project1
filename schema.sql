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


-- WORK IN PROGRESS. Probably going to add some foreign keys for the relationship with TrainingPlan etc.
CREATE TABLE WORKOUT(
    WorkoutID INTEGER PRIMARY KEY,
    SequenceNumber INTEGER NOT NULL,
    ScheduluedDate DATETIME NOT NULL,
    PerformedDate DATETIME, -- Can be NULL, since we will schedule Workouts to be performed in the future
    Stress INTEGER NOT NULL,
    Soreness INTEGER NOT NULL,
    SleepQuality INTEGER NOT NULL
);
