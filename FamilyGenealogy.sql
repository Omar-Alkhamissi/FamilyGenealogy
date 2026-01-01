USE master;
GO

DROP DATABASE IF EXISTS Family;
GO

CREATE DATABASE Family;
GO

USE Family;
GO


CREATE TABLE dbo.Person (
    PersonID       INT IDENTITY NOT NULL,
    SIN            CHAR(9) NOT NULL,
    FatherPersonID INT NULL,
    MotherPersonID INT NULL,    
    FirstName      NVARCHAR(60) NULL,
    LastName       NVARCHAR(70) NULL,
    DateOfBirth    DATE NULL,
    DateOfDeath    DATE NULL,
    NetWorth       MONEY,

    CONSTRAINT PK_Person PRIMARY KEY CLUSTERED ( PersonID ),
    CONSTRAINT AK_Person_SIN UNIQUE ( SIN )
);
GO

SET IDENTITY_INSERT dbo.Person ON;
GO

INSERT INTO dbo.Person ( PersonID, SIN, FatherPersonID, MotherPersonID, FirstName, LastName, DateOfBirth, DateOfDeath, NetWorth)
VALUES -- GENERATION 1
       (  1, '152250116', NULL, NULL, 'Harry',   'Martin',   '1912-02-16', '1963-04-15', NULL),
       (  2, '152250213', NULL, NULL, 'Marie',   'LeFleur',  '1916-04-13', '1963-04-15' , NULL),
       (  3, '152250321', NULL, NULL, 'Ron',     'Jones',    '1917-05-21', '2002-11-30' , NULL),
       (  4, '152250426', NULL, NULL, 'Sarah',   'Kim',      '1917-03-26', '2006-10-09', NULL ),
       (  5, '152250522', NULL, NULL, 'Fred',    'Cooper',   '1915-11-22', '2000-12-11' , NULL),
       (  6, '152250630', NULL, NULL, 'Audrey',  'Maclean',  '1920-06-30', '2007-03-31' , NULL),
       (  7, '152250721', NULL, NULL, 'Leo',     'Sanchez',  '1916-08-21', '2004-02-29' , NULL),
       (  8, '152250804', NULL, NULL, 'Sarah',   'Black',    '1917-08-04', '2005-08-07' , NULL),
       (  9, '152250912', NULL, NULL, 'Hui',     'Peng',     '1919-11-12', '1971-06-15' , NULL),
       ( 10, '152251002', NULL, NULL, 'Rita',    'Yang',     '1921-08-02', '1990-12-03' , NULL),
       ( 11, '152251109', NULL, NULL, 'Jerry',   'Gold',     '1919-07-09', '1998-05-04' , NULL),
       ( 12, '152251106', NULL, NULL, 'Kate',    'Lyall',    '1920-04-06', NULL , 2000000),
                                    
       -- GENERATION 2              
       ( 13, '351250142',    1,    2, 'Peter',   'Martin',   '1942-01-02', NULL, 1100000 ),
       ( 14, '351250241',    3,    4, 'Erin',    'Jones',    '1941-02-14', '1968-07-02', 1400000 ),
       ( 15, '351250340',    5,    6, 'Ben',     'Cooper',   '1940-10-31', '2017-09-21' , NULL),
       ( 16, '351250444',    7,    8, 'Tina',    'Sanchez',  '1944-12-25', NULL , 1300000),
       ( 17, '351250541',    9,   10, 'Jeff',    'Peng',     '1941-09-23', '2018-02-12', 1200000 ),
       ( 18, '351250643',    11,  12, 'Anne',    'Gold',     '1943-01-17', NULL, 1500000 ),
                                    
       -- GENERATION 3              
       ( 19, '457280107',   13,   14, 'Ari',     'Martin',   '1968-07-02', NULL, 600000 ),
       ( 20, '457280211',   15,   16, 'Judy',    'Cooper',   '1970-11-11', NULL , 600000),
       ( 21, '457280310',   15,   16, 'Daniel',  'Cooper',   '1968-10-04', NULL, 800000 ),
       ( 22, '457280403',   17,   18, 'Kate',    'Peng',     '1969-03-07', NULL, 300000 ),
                                    
       -- GENERATION 4              
       ( 23, '551250100',   19,   20, 'Devon',   'Martin',   '1996-07-11', NULL , 60000), 
       ( 24, '551250201',   19,   20, 'Jillian', 'Martin',   '1997-09-15', NULL , 70000), 
       ( 25, '551250399',   19,   20, 'Brie',    'Martin',   '1999-01-19', NULL , 90000), 
       ( 26, '551250499',   21,   22, 'Stan',    'Cooper',   '1998-05-21', NULL, 80000 ), 
       ( 27, '551250505',   21,   22, 'Ian',     'Cooper',   '1999-08-25', NULL , 200000);

SET IDENTITY_INSERT dbo.Person OFF;
GO

CREATE FUNCTION dbo.GetPersonIDBySIN (@SIN INT)
RETURNS INT
AS
BEGIN
    DECLARE @PersonID INT;

    SELECT @PersonID = PersonID
    FROM Person
    WHERE SIN = @SIN;

    RETURN @PersonID;
END;
GO

CREATE PROCEDURE dbo.CreatePerson
    @SIN INT,
    @FirstName NVARCHAR(50),
    @LastName NVARCHAR(50),
    @FatherSIN INT = NULL,
    @MotherSIN INT = NULL,
    @NetWorth DECIMAL(18,2) = 65000,
    @DateOfBirth DATE = NULL,
    @DateOfDeath DATE = NULL,
    @PersonID INT OUTPUT
AS
BEGIN
    SET XACT_ABORT ON;
    BEGIN TRANSACTION;

    BEGIN TRY
        -- Lookup FatherPersonID using dbo.GetPersonIDBySIN
        DECLARE @FatherPersonID INT = NULL;
        IF (@FatherSIN IS NOT NULL)
        BEGIN
            SELECT @FatherPersonID = dbo.GetPersonIDBySIN(@FatherSIN);

            -- Insert Father if not exists
            IF (@FatherPersonID IS NULL)
            BEGIN
                INSERT INTO Person (SIN, FirstName, LastName)
                VALUES (@FatherSIN, 'UnknownFather', 'Unknown');

                SET @FatherPersonID = SCOPE_IDENTITY();
            END
        END

        -- Lookup MotherPersonID using dbo.GetPersonIDBySIN
        DECLARE @MotherPersonID INT = NULL;
        IF (@MotherSIN IS NOT NULL)
        BEGIN
            SELECT @MotherPersonID = dbo.GetPersonIDBySIN(@MotherSIN);

            -- Insert Mother if not exists
            IF (@MotherPersonID IS NULL)
            BEGIN
                INSERT INTO Person (SIN, FirstName, LastName)
                VALUES (@MotherSIN, 'UnknownMother', 'Unknown');

                SET @MotherPersonID = SCOPE_IDENTITY();
            END
        END

        -- Insert New Person
        INSERT INTO Person (SIN, FirstName, LastName, FatherPersonID, MotherPersonID, NetWorth, DateOfBirth, DateOfDeath)
        VALUES (@SIN, @FirstName, @LastName, @FatherPersonID, @MotherPersonID, @NetWorth, @DateOfBirth, @DateOfDeath);

        -- Retrieve the new PersonID
        SET @PersonID = SCOPE_IDENTITY();

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END;
GO

DECLARE @PersonID INT;

EXEC dbo.CreatePerson
    @SIN = '623456777',
    @FirstName = 'Garth',
    @LastName = 'Martin',
    @FatherSIN = '551250100',
    @MotherSIN = '665561001',
    @DateOfBirth = '2022-12-19',
    @DateOfDeath = NULL,
    @PersonID = @PersonID OUTPUT;

SELECT @PersonID AS NewPersonID;
GO

DECLARE @PersonID INT;

EXEC dbo.CreatePerson
    @SIN = '633444677',
    @FirstName = 'Omar',
    @LastName = 'Alkhamissi',
    @FatherSIN = '797999211',
    @MotherSIN = '457280211',
    @DateOfBirth = '2003-12-20',
    @DateOfDeath = NULL,
    @PersonID = @PersonID OUTPUT;

SELECT @PersonID AS NewPersonID;
GO

CREATE FUNCTION dbo.GetPersonNetWorth(@MinNetWorth INT)
RETURNS TABLE
AS
RETURN
(
    SELECT *
    FROM Person
    WHERE NetWorth >= @MinNetWorth
);
GO


-- Test the function
SELECT * FROM dbo.GetPersonNetWorth(65000);
SELECT * FROM dbo.GetPersonNetWorth(600000);

SELECT 
    FirstName,
    LastName,
    NetWorth,
    RANK() OVER (PARTITION BY LastName ORDER BY NetWorth DESC) AS RankByNetWorth,
    AVG(NetWorth) OVER (PARTITION BY LastName) AS AvgNetWorthByLastName
FROM Person
WHERE NetWorth IS NOT NULL;
GO

WITH PaternalLineage AS (
     SELECT 
        FirstName,
        LastName,
        1 AS Depth, 
        0 AS NumLivingAncestors, 
        PersonID,
        FatherPersonID,
        CASE WHEN DateOfDeath IS NULL THEN 1 ELSE 0 END AS IsAlive 
    FROM dbo.Person
    WHERE FatherPersonID IS NULL 

    UNION ALL

    SELECT 
        p.FirstName,
        p.LastName,
        pl.Depth + 1 AS Depth, 
        pl.NumLivingAncestors + pl.IsAlive AS NumLivingAncestors, 
        p.PersonID,
        p.MotherPersonID,
        CASE WHEN p.DateOfDeath IS NULL THEN 1 ELSE 0 END AS IsAlive 
    FROM dbo.Person p
    JOIN PaternalLineage pl
        ON p.MotherPersonID = pl.PersonID 
)
SELECT 
    FirstName,
    LastName,
    Depth,
    NumLivingAncestors
FROM PaternalLineage
ORDER BY NumLivingAncestors asc, Depth asc;
GO


