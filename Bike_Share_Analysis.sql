SELECT *
FROM tripdata_2024_10;

-- no duplicates
SELECT COUNT(*), COUNT(DISTINCT ride_id)
FROM tripdata_2024_10;

-- no nulls for the col we will analyze
SELECT COUNT(*) - COUNT(ride_id),
	COUNT(*) - COUNT(rideable_type),
	COUNT(*) - COUNT(started_at),
    COUNT(*) - COUNT(ended_at),
    COUNT(*) - COUNT(member_casual)
FROM tripdata_2024_10;

-- CREATE merged table with all 12 months of data
CREATE TABLE combined_trip_data LIKE tripdata_2024_10;

-- Insert values from 12 tables
INSERT INTO combined_trip_data
SELECT *
FROM tripdata_2024_10
UNION ALL
SELECT *
FROM tripdata_2024_11
UNION ALL
SELECT *
FROM tripdata_2024_12
UNION ALL
SELECT *
FROM tripdata_2025_01
UNION ALL
SELECT *
FROM tripdata_2025_02
UNION ALL
SELECT *
FROM tripdata_2025_03
UNION ALL
SELECT *
FROM tripdata_2025_04
UNION ALL
SELECT *
FROM tripdata_2025_05
UNION ALL
SELECT *
FROM tripdata_2025_06
UNION ALL
SELECT *
FROM tripdata_2025_07
UNION ALL
SELECT *
FROM tripdata_2025_08
UNION ALL
SELECT *
FROM tripdata_2025_09;

-- new table with union to get rid of duplicates
CREATE TABLE combined_trip_data_2 LIKE tripdata_2024_10;

SELECT *
FROM combined_trip_data_2;

INSERT INTO combined_trip_data_2
SELECT *
FROM tripdata_2024_10
UNION
SELECT *
FROM tripdata_2024_11
UNION
SELECT *
FROM tripdata_2024_12
UNION
SELECT *
FROM tripdata_2025_01
UNION
SELECT *
FROM tripdata_2025_02
UNION
SELECT *
FROM tripdata_2025_03
UNION
SELECT *
FROM tripdata_2025_04
UNION
SELECT *
FROM tripdata_2025_05
UNION
SELECT *
FROM tripdata_2025_06
UNION
SELECT *
FROM tripdata_2025_07
UNION
SELECT *
FROM tripdata_2025_08
UNION
SELECT *
FROM tripdata_2025_09;



-- Selecting everything
SELECT *
FROM combined_trip_data_2;

-- Check duplicates
SELECT COUNT(*), COUNT(DISTINCT ride_id)
FROM combined_trip_data_2;

-- Check nulls for the col
-- no nulls but lots of blanks for start and end stations
SELECT COUNT(*) - COUNT(ride_id) AS ride_id_nulls,
	COUNT(*) - COUNT(rideable_type) AS rideable_type_nulls,
	COUNT(*) - COUNT(started_at) AS started_at_nulls,
    COUNT(*) - COUNT(ended_at) AS ended_at_nulls,
    COUNT(*) - COUNT(start_station_name) AS start_station_name_nulls,
    COUNT(*) - COUNT(start_station_id) AS start_station_id_nulls,
    COUNT(*) - COUNT(end_station_name) AS end_station_name_nulls,
    COUNT(*) - COUNT(end_station_id) AS end_station_id_nulls,
    COUNT(*) - COUNT(start_lat) AS start_lat_nulls,
    COUNT(*) - COUNT(start_lng) AS start_lng_nulls,
    COUNT(*) - COUNT(end_lat) AS end_lat_nulls,
    COUNT(*) - COUNT(end_lng) AS end_lng_nulls,
    COUNT(*) - COUNT(member_casual) AS member_casual_nulls
FROM combined_trip_data_2;

-- Standardize the started_at and ended_at col to DATETIME

-- Use STR_TO_DATE on select statement
SELECT started_at,
	STR_TO_DATE(started_at, '%Y-%m-%d %H:%i:%s.%f') AS started_at_new_format,
    ended_at,
    STR_TO_DATE(ended_at, '%Y-%m-%d %H:%i:%s.%f') AS ended_at_new_format
FROM combined_trip_data_2;

-- Update the table with new dates
UPDATE combined_trip_data_2
SET started_at = STR_TO_DATE(started_at, '%Y-%m-%d %H:%i:%s.%f'),
    ended_at = STR_TO_DATE(ended_at, '%Y-%m-%d %H:%i:%s.%f');

SELECT *
FROM combined_trip_data_2;
-- Alter the started_at and ended_at to use DATETIME type
ALTER TABLE combined_trip_data_2 MODIFY started_at DATETIME;
ALTER TABLE combined_trip_data_2 MODIFY ended_at DATETIME;

-- Create new col ride_length
SELECT started_at,
	ended_at,
	TIMEDIFF(ended_at, started_at) AS ride_length
FROM combined_trip_data_2;

-- Create new col day_of_week
ALTER TABLE combined_trip_data_2 DROP COLUMN ride_length;
ALTER TABLE combined_trip_data_2 ADD COLUMN ride_length TIME;

SELECT *
FROM combined_trip_data_2;

UPDATE combined_trip_data_2
SET ride_length = TIMEDIFF(ended_at, started_at);

SELECT *
FROM combined_trip_data_2;

-- Add day_of_week col to the table
ALTER TABLE combined_trip_data_2 ADD COLUMN day_of_week TEXT;

SELECT *
FROM combined_trip_data_2;

SELECT started_at,
	WEEKDAY(started_at) AS week_day,
    CASE
		WHEN WEEKDAY(started_at) = 0 THEN 'Monday'
        WHEN WEEKDAY(started_at) = 1 THEN 'Tuesday'
        WHEN WEEKDAY(started_at) = 2 THEN 'Wednesday'
        WHEN WEEKDAY(started_at) = 3 THEN 'Thursday'
        WHEN WEEKDAY(started_at) = 4 THEN 'Friday'
        WHEN WEEKDAY(started_at) = 5 THEN 'Saturday'
        WHEN WEEKDAY(started_at) = 6 THEN 'Sunday'
    END AS week_day_text
FROM combined_trip_data_2;

UPDATE combined_trip_data_2
SET day_of_week =
CASE
	WHEN WEEKDAY(started_at) = 0 THEN 'Monday'
	WHEN WEEKDAY(started_at) = 1 THEN 'Tuesday'
	WHEN WEEKDAY(started_at) = 2 THEN 'Wednesday'
	WHEN WEEKDAY(started_at) = 3 THEN 'Thursday'
	WHEN WEEKDAY(started_at) = 4 THEN 'Friday'
	WHEN WEEKDAY(started_at) = 5 THEN 'Saturday'
	WHEN WEEKDAY(started_at) = 6 THEN 'Sunday'	
END;

SELECT *
FROM combined_trip_data_2;

-- Exploratory Data Analysis
-- checking values in other col
SELECT DISTINCT rideable_type -- values are electic_bike, classic_bike
FROM combined_trip_data_2;

SELECT COUNT(DISTINCT start_station_name) -- 1914 distinct station names
FROM combined_trip_data_2;

SELECT DISTINCT member_casual -- values are member, casual
FROM combined_trip_data_2;

SELECT COUNT(*) -- 3.54 mil members
FROM combined_trip_data_2
WHERE member_casual = 'member';

SELECT 3542596 / COUNT(*) -- 64.01% are members
FROM combined_trip_data_2;

SELECT COUNT(*) -- 1.99 mil casual
FROM combined_trip_data_2
WHERE member_casual = 'casual';

SELECT 1991483 / COUNT(*) -- 35.99% are casual
FROM combined_trip_data_2;

-- rideable type analysis
SELECT rideable_type, COUNT(*) -- electric 3462468, classic 2071611 preference for electic bikes for all users
FROM combined_trip_data_2
GROUP BY rideable_type;

SELECT 3462468 / COUNT(*) -- 62.25% electric
FROM combined_trip_data_2;

SELECT 2071611 / COUNT(*) -- 37.43% classic
FROM combined_trip_data_2;

SELECT member_casual, rideable_type, COUNT(*) -- both members and casuals prefer electric bikes
FROM combined_trip_data_2
GROUP BY rideable_type, member_casual;

-- Comparing members and casuals on bike preference not much difference
SELECT 2188355 / (2188355 + 1354241) AS member_electric_percent, -- 62%
	1354241 / (2188355 + 1354241) AS member_classic_percent, -- 38%
    1274113 / (1274113 + 717370) AS casual_electric_percent, -- 64%
    717370 / (1274113 + 717370) AS casual_classic_percent; -- 36%

-- Analyzing ride_length mean, max
SELECT SEC_TO_TIME(AVG(TIME_TO_SEC(ride_length))) AS avg_ride_length, -- 14 minutes average ride length
	MAX(ride_length) AS max_ride_length -- 1 day max
FROM combined_trip_data_2;

-- Comparing avg ride_length for members and casual riders
SELECT member_casual, 
	SEC_TO_TIME(AVG(TIME_TO_SEC(ride_length))) AS avg_ride_length, -- 12 minutes member, 19 minutes casual
	MAX(ride_length) AS max_ride_length -- 1 day
FROM combined_trip_data_2
GROUP BY member_casual;

-- members prefer weekdays, casuals prefer weekends
SELECT member_casual, day_of_week, COUNT(*) AS num_rides-- members ride Tuesdays the most, casuals ride Saturday the most
FROM combined_trip_data_2
GROUP BY day_of_week, member_casual
ORDER BY member_casual, num_rides DESC;

-- check most frequent months of rides, summer is most popular
SELECT member_casual, MONTH(started_at) AS month_of_ride, COUNT(*) AS num_rides -- casual riders prefer august, july, june. members prefer august, september, july
FROM combined_trip_data_2
GROUP BY month_of_ride, member_casual
ORDER BY member_casual, num_rides DESC;

-- check most frequent hours of rides, evenings most popular, then mornings, then midnight to sunrise
SELECT member_casual, HOUR(started_at) AS hour_of_ride, COUNT(*) AS num_rides -- members prefer 4-6pm, casuals prefer 4-6pm
FROM combined_trip_data_2
GROUP BY hour_of_ride, member_casual
ORDER BY member_casual, num_rides DESC;

-- exporting the table for use in tableau, error: Error Code: 1290. The MySQL server is running with the --secure-file-priv option so it cannot execute this statement
SELECT * FROM combined_trip_data_2
INTO OUTFILE '/Users/sarahturner/Downloads/tripdata_2024-10_to_2025-09.csv' 
FIELDS ENCLOSED BY '"' 
TERMINATED BY ',' 
ESCAPED BY '"' 
LINES TERMINATED BY '\r\n';





