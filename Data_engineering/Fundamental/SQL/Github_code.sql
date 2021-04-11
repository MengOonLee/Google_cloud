
# break out individual lines of code into new lines
WITH lines_of_code AS (
    SELECT 
        SPLIT(content, "\n") AS line,
        sample_path,
        sample_repo_name
    FROM `bigquery-public-data.github_repos.sample_contents`
),

# lets flatten the array to we can parse it more easily
flattened_lines_of_code AS (
    SELECT 
        flattened_line,
        sample_path,
        sample_repo_name
    FROM lines_of_code, UNNEST(line) AS flattened_line
),

# parse the first character from every line of code
parse_first_character AS (
    SELECT 
        SUBSTR(flattened_line, 1, 1) AS first_character,
        flattened_line,
        sample_path,
        sample_repo_name
    FROM flattened_lines_of_code
),

# filter for code lines that begin with tab or space only
tabs_or_spaces AS(
    SELECT 
        first_character,
        IF(REGEXP_CONTAINS(first_character, r"[\t]"), 1, 0) AS tab_count,
        IF(REGEXP_CONTAINS(first_character, r"[ ]"), 1, 0) AS space_count,
        flattened_line,
        sample_path,
        sample_repo_name
    FROM parse_first_character
    WHERE REGEXP_CONTAINS(first_character, r"[ \t]")
),

# aggregate and filter by entire code file
tabs_or_spaces_count AS (
    SELECT 
        COUNT(flattened_line) AS lines,
        SUM(tab_count) AS tabs_count,
        SUM(space_count) AS space_count,
        IF(SUM(tab_count) > SUM(space_count), 1, 0) AS tab_winner,
        IF(SUM(tab_count) < SUM(space_count), 1, 0) AS space_winner,
        REGEXP_EXTRACT(sample_path, r"\.([^\.]*)$") AS extension,
        sample_path,
        sample_repo_name
    FROM tabs_or_spaces 
    GROUP BY sample_path, sample_repo_name
    HAVING tabs_count > 10 OR space_count > 10
),

# aggregate all files by code extension (.jave etc.)
tabs_or_spaces_by_extension AS (
    SELECT 
        extension,
        COUNT(lines) AS files,
        SUM(lines) AS lines,
        SUM(tab_winner) AS tabs,
        SUM(space_winner) AS spaces,
        LOG((SUM(space_winner)+1)/(SUM(tab_winner)+1)) AS lratio
    FROM tabs_or_spaces_count
    GROUP BY extension
    ORDER BY files DESC
    LIMIT 100
)

# Format() for demo readability on screen, don't use otherwise.
# Leave that for Data Studio
SELECT
    extension,
    FORMAT("%d", files) AS files,
    FORMAT("%d", lines) AS lines,
    FORMAT("%d", tabs) AS tabs,
    FORMAT("%d", spaces) AS spaces,
    ROUND(lratio, 5) AS lratio
FROM tabs_or_spaces_by_extension
