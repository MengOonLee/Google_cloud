-- SELECT and FROM
SELECT end_station_name 
FROM `bigquery-public-data.london_bicycles.cycle_hire`;


-- WHERE
SELECT * 
FROM `bigquery-public-data.london_bicycles.cycle_hire` 
WHERE duration>=1200;



-- GROUP BY
SELECT start_station_name 
FROM `bigquery-public-data.london_bicycles.cycle_hire` 
GROUP BY start_station_name;



-- COUNT
SELECT 
start_station_name, 
COUNT(*) 
FROM `bigquery-public-data.london_bicycles.cycle_hire` 
GROUP BY start_station_name;



-- AS
SELECT 
start_station_name, 
COUNT(*) AS num_starts 
FROM `bigquery-public-data.london_bicycles.cycle_hire` 
GROUP BY start_station_name;



-- ORDER BY
SELECT 
start_station_name, 
COUNT(*) AS num 
FROM `bigquery-public-data.london_bicycles.cycle_hire` 
GROUP BY start_station_name 
ORDER BY num DESC;



-- WHERE, GROUP BY
#standardSQL
SELECT
 SUM(word_count) AS count
FROM
 `babynames.names_2014`
WHERE
 word LIKE "%raisin%"
GROUP BY
  word;



-- GROUP BY, HAVING
#standardSQL
SELECT
  COUNT(*) as num_duplicate_rows
FROM
  `data-to-insights.ecommerce.all_sessions_raw`
GROUP BY
  fullVisitorId, channelGrouping
HAVING 
  num_duplicate_rows > 1;