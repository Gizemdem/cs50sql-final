DROP VIEW IF EXISTS material_product_stage;
DROP VIEW IF EXISTS material_construction_stage;
DROP VIEW IF EXISTS material_reuse_stage;
DROP INDEX IF EXISTS material_name_index;
DROP INDEX IF EXISTS category_index;

-- Create index
CREATE INDEX material_name_index ON materials(material_name);

-- Create category index
CREATE INDEX category_index ON materials(category);

-- Create view product stage queries
CREATE VIEW material_product_stage AS
SELECT material_name, stage_A1_A3
FROM material_gwp_view2;

-- Create view for constrution queries
CREATE VIEW material_construction_stage AS
SELECT material_name, stage_B1, stage_B2, stage_B3, stage_B4
FROM material_gwp_view2;

-- Create view for reuse queries
CREATE VIEW material_reuse_stage AS
SELECT material_name, stage_D
FROM material_gwp_view2;
