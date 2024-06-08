
CREATE DATABASE IF NOT EXISTS celebal_assignment;
USE celebal_assignment;

CREATE TABLE IF NOT EXISTS counttotalworkinhours (
    START_DATE DATETIME,
    END_DATE DATETIME,
    NO_OF_HOURS INT
);
DELIMITER //

CREATE PROCEDURE CalculateWorkingHours(
    IN Start_Date DATETIME,
    IN End_Date DATETIME
)
BEGIN
    DECLARE CurrentDate DATETIME;
    DECLARE TotalHours INT DEFAULT 0;
    
    CREATE TEMPORARY TABLE Dates (Date DATETIME);
    
    SET CurrentDate = Start_Date;
    WHILE CurrentDate <= End_Date DO
        INSERT INTO Dates (Date) VALUES (CurrentDate);
        SET CurrentDate = DATE_ADD(CurrentDate, INTERVAL 1 DAY);
    END WHILE;

    -- Calculate the number of working hours
    SELECT SUM(
        CASE 
            WHEN DAYOFWEEK(Date) = 1 THEN 24 
            WHEN DAYOFWEEK(Date) = 7 AND (DAY(Date) <= 7 OR DAY(Date) <= 14) THEN 24
            ELSE 24 
        END
    ) INTO TotalHours
    FROM Dates
    WHERE
        (DAYOFWEEK(Date) != 1 AND (DAYOFWEEK(Date) != 7 OR (DAY(Date) <= 7 OR DAY(Date) <= 14)))
        OR Date = Start_Date
        OR Date = End_Date;

    INSERT INTO counttotalworkinhours (START_DATE, END_DATE, NO_OF_HOURS)
    VALUES (Start_Date, End_Date, TotalHours);
    DROP TEMPORARY TABLE Dates;
END //

DELIMITER ;

TRUNCATE TABLE counttotalworkinhours;


CALL CalculateWorkingHours('2023-07-12', '2023-07-13');
CALL CalculateWorkingHours('2023-07-01', '2023-07-17');

SELECT * FROM counttotalworkinhours;
