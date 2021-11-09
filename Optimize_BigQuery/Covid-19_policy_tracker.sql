-- Create a table partitioned by date
CREATE OR REPLACE TABLE covid_607.oxford_policy_tracker_110
PARTITION BY date
OPTIONS (
    partition_expiration_days=90
) AS 
SELECT 
*
FROM `bigquery-public-data.covid19_govt_response.oxford_policy_tracker`
WHERE alpha_3_code NOT IN ('GBR', 'BRA', 'CAN', 'USA');



-- Add new columns to table
ALTER TABLE covid_607.oxford_policy_tracker_110
SET OPTIONS(partition_expiration_days=NULL)
  ADD COLUMN population INTEGER,
  ADD COLUMN country_area FLOAT64,
  ADD COLUMN mobility STRUCT<
    avg_retail FLOAT64,
    avg_grocery FLOAT64,
    avg_parks FLOAT64,
    avg_transit FLOAT64,
    avg_workplace FLOAT64,
    avg_residential FLOAT64
  >



-- Add country population data to the population column
UPDATE
    covid_607.oxford_policy_tracker_110 AS t0
SET
    t0.population = t1.pop_data_2019
FROM
    (SELECT DISTINCT 
        country_territory_code, pop_data_2019 
    FROM 
        `bigquery-public-data.covid19_ecdc.covid_19_geographic_distribution_worldwide`
    ) AS t1
WHERE
    t0.alpha_3_code = t1.country_territory_code;



-- Add country area data to the country_area column
UPDATE
    covid_607.oxford_policy_tracker_110 t0
SET
    t0.country_area = t1.country_area
FROM
    (SELECT DISTINCT 
        country_name, country_area
    FROM 
        `bigquery-public-data.census_bureau_international.country_names_area`
    ) AS t1
WHERE 
    t0.country_name = t1.country_name;



-- Populate the mobility record data
UPDATE
   covid_607.oxford_policy_tracker_110 AS t0
SET
    t0.mobility.avg_retail = t1.avg_retail,
    t0.mobility.avg_grocery = t1.avg_grocery,
    t0.mobility.avg_parks = t1.avg_parks,
    t0.mobility.avg_transit = t1.avg_transit,
    t0.mobility.avg_workplace = t1.avg_workplace,
    t0.mobility.avg_residential = t1.avg_residential
FROM
    (SELECT country_region, date,
        AVG(retail_and_recreation_percent_change_from_baseline) as avg_retail,
        AVG(grocery_and_pharmacy_percent_change_from_baseline) as avg_grocery,
        AVG(parks_percent_change_from_baseline) as avg_parks,
        AVG(transit_stations_percent_change_from_baseline) as avg_transit,
        AVG(workplaces_percent_change_from_baseline) as avg_workplace,
        AVG(residential_percent_change_from_baseline) as avg_residential
    FROM 
        `bigquery-public-data.covid19_google_mobility.mobility_report`
    GROUP BY 
        country_region, date
    ) AS t1
WHERE
    t0.country_name = t1.country_region
    AND t0.date = t1.date;



-- Query missing data in population & country_area columns
SELECT DISTINCT 
country_name
FROM covid_607.oxford_policy_tracker_110
WHERE population IS NULL
UNION ALL 
SELECT DISTINCT 
country_name
FROM covid_607.oxford_policy_tracker_110
WHERE country_area IS NULL 
ORDER BY country_name;