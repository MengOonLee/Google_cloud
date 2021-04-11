
# This query retrieves the top 5 baby names for US males in 2014.
SELECT
    name, count
FROM
    `babynames.names_2014`
WHERE
    gender='M'
ORDER BY
    count DESC
LIMIT
    5
