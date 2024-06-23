DROP TABLE IF EXISTS temp_ökobaudat;
DROP TABLE IF EXISTS materials;

.timer ON

-- Temp table for the csv file
CREATE TABLE temp_ökobaudat(
    UUID TEXT,
    Version TEXT,
    MaterialName TEXT,
    Category TEXT,
    Unit TEXT,
    Stage TEXT,
    GWP REAL,
    ODP REAL,
    POCP REAL,
    AP REAL,
    EP REAL,
    ADPE REAL
);

.mode csv
.import --skip 1 ../okobaudat_cleaned_2.csv temp_ökobaudat

DELETE FROM temp_ökobaudat
WHERE Unit = 'a' OR Unit = '';

UPDATE temp_ökobaudat
SET Unit = 'm2'
WHERE Unit = 'qm';

CREATE TABLE materials (
    material_id TEXT PRIMARY KEY,
    material_name TEXT NOT NULL,
    category TEXT NOT NULL,
    unit_type TEXT NOT NULL CHECK( unit_type IN ('m', 'm2', 'm3', 'kg', 'pcs.', 'MJ', 'kgkm', 't*km'))
);

INSERT INTO materials (material_id, material_name, category, unit_type)
SELECT DISTINCT(UUID), MaterialName, Category, Unit FROM temp_ökobaudat;


-- OPTION 1
-- Table for materials global warning potential
CREATE TABLE gwp_impact (
    material_id TEXT PRIMARY KEY,
    stage_A1_A3 REAL,
    stage_A4 REAL,
    stage_A5 REAL,
    stage_A REAL GENERATED ALWAYS AS (stage_A1_A3 + stage_A4 + stage_A5),
    stage_B1 REAL,
    stage_B2 REAL,
    stage_B3 REAL,
    stage_B4 REAL,
    stage_B5 REAL,
    stage_B6 REAL,
    stage_B7 REAL,
    stage_B REAL GENERATED ALWAYS AS (stage_B1 + stage_B2 + stage_B3 + stage_B4 + stage_B5 + stage_B6 + stage_B7),
    stage_C1 REAL,
    stage_C2 REAL,
    stage_C3 REAL,
    stage_C4 REAL,
    stage_C REAL GENERATED ALWAYS AS (stage_C1 + stage_C2 + stage_C3 + stage_C4),
    stage_D REAL,
    total REAL GENERATED ALWAYS AS(stage_A + stage_B + stage_C + stage_D),
    FOREIGN KEY(material_id) REFERENCES materials (material_id)
);

-- insert values from temp_ökobaudat table to gwp_impact table 30 second
INSERT INTO gwp_impact (
    material_id, stage_A1_A3, stage_A4, stage_A5,
    stage_B1, stage_B2, stage_B3, stage_B4, stage_B5, stage_B6, stage_B7,
    stage_C1, stage_C2, stage_C3, stage_C4, stage_D
)
SELECT
    UUID AS material_id,
    -- Use subqueries for each stage to ensure proper data insertion
    (SELECT GWP FROM temp_ökobaudat AS sub WHERE sub.UUID = main.UUID AND sub.Stage = 'A1-A3') AS stage_A1_A3,
    (SELECT GWP FROM temp_ökobaudat AS sub WHERE sub.UUID = main.UUID AND sub.Stage = 'A4') AS stage_A4,
    (SELECT GWP FROM temp_ökobaudat AS sub WHERE sub.UUID = main.UUID AND sub.Stage = 'A5') AS stage_A5,
    (SELECT GWP FROM temp_ökobaudat AS sub WHERE sub.UUID = main.UUID AND sub.Stage = 'B1') AS stage_B1,
    (SELECT GWP FROM temp_ökobaudat AS sub WHERE sub.UUID = main.UUID AND sub.Stage = 'B2') AS stage_B2,
    (SELECT GWP FROM temp_ökobaudat AS sub WHERE sub.UUID = main.UUID AND sub.Stage = 'B3') AS stage_B3,
    (SELECT GWP FROM temp_ökobaudat AS sub WHERE sub.UUID = main.UUID AND sub.Stage = 'B4') AS stage_B4,
    (SELECT GWP FROM temp_ökobaudat AS sub WHERE sub.UUID = main.UUID AND sub.Stage = 'B5') AS stage_B5,
    (SELECT GWP FROM temp_ökobaudat AS sub WHERE sub.UUID = main.UUID AND sub.Stage = 'B6') AS stage_B6,
    (SELECT GWP FROM temp_ökobaudat AS sub WHERE sub.UUID = main.UUID AND sub.Stage = 'B7') AS stage_B7,
    (SELECT GWP FROM temp_ökobaudat AS sub WHERE sub.UUID = main.UUID AND sub.Stage = 'C1') AS stage_C1,
    (SELECT GWP FROM temp_ökobaudat AS sub WHERE sub.UUID = main.UUID AND sub.Stage = 'C2') AS stage_C2,
    (SELECT GWP FROM temp_ökobaudat AS sub WHERE sub.UUID = main.UUID AND sub.Stage = 'C3') AS stage_C3,
    (SELECT GWP FROM temp_ökobaudat AS sub WHERE sub.UUID = main.UUID AND sub.Stage = 'C4') AS stage_C4,
    (SELECT GWP FROM temp_ökobaudat AS sub WHERE sub.UUID = main.UUID AND sub.Stage = 'D') AS stage_D
FROM temp_ökobaudat AS main
GROUP BY UUID;


DROP TABLE temp_ökobaudat;

-- Create table for joined material and gwp impact
CREATE TABLE material_gwp (
    material_id TEXT PRIMARY KEY,
    material_name TEXT NOT NULL,
    category TEXT NOT NULL,
    unit_type TEXT NOT NULL,
    stage_A1_A3 REAL,
    stage_A4 REAL,
    stage_A5 REAL,
    stage_A REAL,
    stage_B1 REAL,
    stage_B2 REAL,
    stage_B3 REAL,
    stage_B4 REAL,
    stage_B5 REAL,
    stage_B6 REAL,
    stage_B7 REAL,
    stage_B REAL,
    stage_C1 REAL,
    stage_C2 REAL,
    stage_C3 REAL,
    stage_C4 REAL,
    stage_C REAL,
    stage_D REAL,
    total REAL
);

-- insert data
INSERT INTO material_gwp (
    material_id, material_name, category, unit_type,
    stage_A1_A3, stage_A4, stage_A5, stage_A,
    stage_B1, stage_B2, stage_B3, stage_B4, stage_B5, stage_B6, stage_B7, stage_B,
    stage_C1, stage_C2, stage_C3, stage_C4, stage_C,
    stage_D, total
)
SELECT
    m.material_id,
    m.material_name,
    m.category,
    m.unit_type,
    g.stage_A1_A3,
    g.stage_A4,
    g.stage_A5,
    g.stage_A,
    g.stage_B1,
    g.stage_B2,
    g.stage_B3,
    g.stage_B4,
    g.stage_B5,
    g.stage_B6,
    g.stage_B7,
    g.stage_B,
    g.stage_C1,
    g.stage_C2,
    g.stage_C3,
    g.stage_C4,
    g.stage_C,
    g.stage_D,
    g.total
FROM materials AS m
JOIN gwp_impact AS g ON m.material_id = g.material_id;
