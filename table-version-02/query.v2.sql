.timer ON 

EXPLAIN QUERY PLAN
SELECT *
FROM material_gwp_view2
WHERE category = 'Building service engineering';

EXPLAIN QUERY PLAN
SELECT category, AVG(total) AS average_total
FROM material_gwp_view2
WHERE total < 50
GROUP BY category;


EXPLAIN QUERY PLAN
SELECT material_name, category 
FROM materials 
WHERE unit_type = 'm3'
LIMIT 3;


EXPLAIN QUERY PLAN
SELECT COUNT(DISTINCT(material_name)) AS Number_Materials
FROM material_gwp_view2;


EXPLAIN QUERY PLAN
SELECT *
FROM material_gwp_view2
WHERE category = 'Building service engineering'
LIMIT 3;


EXPLAIN QUERY PLAN
SELECT category, AVG(total) AS average_total
FROM material_gwp_view2
WHERE total < 50
GROUP BY category;


EXPLAIN QUERY PLAN
SELECT *
FROM material_gwp_view2
WHERE material_name LIKE '%concrete%' 
    LIMIT 5;


EXPLAIN QUERY PLAN
SELECT *
FROM material_reuse_stage
WHERE material_name LIKE '%concrete%' 
    AND stage_D < 10;


