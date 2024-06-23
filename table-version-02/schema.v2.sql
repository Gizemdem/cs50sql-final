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

-- OPTION 2
-- Table for materials global warning potential
CREATE TABLE gwp_impact2 (
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

-- Left join table method 20 second
INSERT INTO gwp_impact2 (
    material_id, stage_A1_A3, stage_A4, stage_A5,
    stage_B1, stage_B2, stage_B3, stage_B4, stage_B5, stage_B6, stage_B7,
    stage_C1, stage_C2, stage_C3, stage_C4, stage_D
)
SELECT 
    main.UUID AS material_id,
    COALESCE(a1_a3.GWP, 0) AS stage_A1_A3,
    COALESCE(a4.GWP, 0) AS stage_A4,
    COALESCE(a5.GWP, 0) AS stage_A5,
    COALESCE(b1.GWP, 0) AS stage_B1,
    COALESCE(b2.GWP, 0) AS stage_B2,
    COALESCE(b3.GWP, 0) AS stage_B3,
    COALESCE(b4.GWP, 0) AS stage_B4,
    COALESCE(b5.GWP, 0) AS stage_B5,
    COALESCE(b6.GWP, 0) AS stage_B6,
    COALESCE(b7.GWP, 0) AS stage_B7,
    COALESCE(c1.GWP, 0) AS stage_C1,
    COALESCE(c2.GWP, 0) AS stage_C2,
    COALESCE(c3.GWP, 0) AS stage_C3,
    COALESCE(c4.GWP, 0) AS stage_C4,
    COALESCE(d.GWP, 0) AS stage_D
FROM 
    temp_ökobaudat AS main
LEFT JOIN temp_ökobaudat AS a1_a3 ON main.UUID = a1_a3.UUID AND a1_a3.Stage = 'A1-A3'
LEFT JOIN temp_ökobaudat AS a4 ON main.UUID = a4.UUID AND a4.Stage = 'A4'
LEFT JOIN temp_ökobaudat AS a5 ON main.UUID = a5.UUID AND a5.Stage = 'A5'
LEFT JOIN temp_ökobaudat AS b1 ON main.UUID = b1.UUID AND b1.Stage = 'B1'
LEFT JOIN temp_ökobaudat AS b2 ON main.UUID = b2.UUID AND b2.Stage = 'B2'
LEFT JOIN temp_ökobaudat AS b3 ON main.UUID = b3.UUID AND b3.Stage = 'B3'
LEFT JOIN temp_ökobaudat AS b4 ON main.UUID = b4.UUID AND b4.Stage = 'B4'
LEFT JOIN temp_ökobaudat AS b5 ON main.UUID = b5.UUID AND b5.Stage = 'B5'
LEFT JOIN temp_ökobaudat AS b6 ON main.UUID = b6.UUID AND b6.Stage = 'B6'
LEFT JOIN temp_ökobaudat AS b7 ON main.UUID = b7.UUID AND b7.Stage = 'B7'
LEFT JOIN temp_ökobaudat AS c1 ON main.UUID = c1.UUID AND c1.Stage = 'C1'
LEFT JOIN temp_ökobaudat AS c2 ON main.UUID = c2.UUID AND c2.Stage = 'C2'
LEFT JOIN temp_ökobaudat AS c3 ON main.UUID = c3.UUID AND c3.Stage = 'C3'
LEFT JOIN temp_ökobaudat AS c4 ON main.UUID = c4.UUID AND c4.Stage = 'C4'
LEFT JOIN temp_ökobaudat AS d ON main.UUID = d.UUID AND d.Stage = 'D'
GROUP BY main.UUID;


-- Create a view for joined material and gwp impact
CREATE VIEW material_gwp_view2 AS
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
JOIN gwp_impact2 AS g ON m.material_id = g.material_id;

