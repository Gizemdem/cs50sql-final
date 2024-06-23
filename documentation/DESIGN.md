# Design Document

Project Title: Template LCA database for Construction Industry
Video overview: <URL HERE>
By Gizem Demirhan

## Scope

- What is the purpose of your database?
  The purpose of this database to create a database for the epd of the materials for the construction company. There is 2 different database options, each database uses slightly different approaches to create schema and do optimizations. In the schema.sql file, there are queries used to create the table schema, in optimization.sql file queries created index and views to optimize the queries in query.sql.
- Which people, places, things, etc. are you including in the scope of your database?
  This database for architects, life cycle analysis to create their own custom material database.
- Which people, places, things, etc. are _outside_ the scope of your database?
  Any materials unrelated with construction materials are scope of the database.

## Functional Requirements

- What should a user be able to do with your database?
  Add new materials and their global warming potentials in different life cycle of material, query materials environmental effect.
- What's beyond the scope of what a user should be able to do with your database?
  Can create the projects database and create a relation with materials table. Query the total global warming potentials and the list of materials used in the project.

## Representation

### Entities

#### 1. Materials

**Attributes:**

- `material_id` (TEXT, PRIMARY KEY)
- `material_name` (TEXT, NOT NULL)
- `category` (TEXT, NOT NULL)
- `unit_type` (TEXT, NOT NULL, CHECK(unit_type IN ('m', 'm2', 'm3', 'kg', 'pcs.', 'MJ', 'kgkm', 't\*km')))

**Explanation:**

- `material_id`: A unique identifier for each material.
- `material_name`: The name of the material.
- `category`: The category to which the material belongs.
- `unit_type`: The unit of measurement for the material. Constraints ensure that only valid units are used.

#### 2. GWP Impact

**Attributes:**

- `material_id` (TEXT, PRIMARY KEY)
- `stage_A1_A3` (REAL)
- `stage_A4` (REAL)
- `stage_A5` (REAL)
- `stage_A` (REAL GENERATED ALWAYS AS (stage_A1_A3 + stage_A4 + stage_A5))
- `stage_B1` (REAL)
- `stage_B2` (REAL)
- `stage_B3` (REAL)
- `stage_B4` (REAL)
- `stage_B5` (REAL)
- `stage_B6` (REAL)
- `stage_B7` (REAL)
- `stage_B` (REAL GENERATED ALWAYS AS (stage_B1 + stage_B2 + stage_B3 + stage_B4 + stage_B5 + stage_B6 + stage_B7))
- `stage_C1` (REAL)
- `stage_C2` (REAL)
- `stage_C3` (REAL)
- `stage_C4` (REAL)
- `stage_C` (REAL GENERATED ALWAYS AS (stage_C1 + stage_C2 + stage_C3 + stage_C4))
- `stage_D` (REAL)
- `total` (REAL GENERATED ALWAYS AS(stage_A + stage_B + stage_C + stage_D))

**Explanation:**

- `material_id`: A unique identifier for each material. This is a foreign key referencing `materials(material_id)`.
- `stage_A1_A3`, `stage_A4`, `stage_A5`, `stage_B1`, `stage_B2`, `stage_B3`, `stage_B4`, `stage_B5`, `stage_B6`, `stage_B7`, `stage_C1`, `stage_C2`, `stage_C3`, `stage_C4`, `stage_D`: Different stages of global warming potential (GWP) impact values.
- `stage_A`, `stage_B`, `stage_C`, `total`: Automatically calculated fields representing summed GWP impact values for respective stages and total.

#### 3. Material GWP

**Attributes:**

- `material_id` (TEXT, PRIMARY KEY)
- `material_name` (TEXT, NOT NULL)
- `category` (TEXT, NOT NULL)
- `unit_type` (TEXT, NOT NULL)
- `stage_A1_A3` (REAL)
- `stage_A4` (REAL)
- `stage_A5` (REAL)
- `stage_A` (REAL)
- `stage_B1` (REAL)
- `stage_B2` (REAL)
- `stage_B3` (REAL)
- `stage_B4` (REAL)
- `stage_B5` (REAL)
- `stage_B6` (REAL)
- `stage_B7` (REAL)
- `stage_B` (REAL)
- `stage_C1` (REAL)
- `stage_C2` (REAL)
- `stage_C3` (REAL)
- `stage_C4` (REAL)
- `stage_C` (REAL)
- `stage_D` (REAL)
- `total` (REAL)

**Explanation:**

- `material_id`: A unique identifier for each material.
- `material_name`, `category`, `unit_type`: Same attributes as in the `materials` table.
- `stage_A1_A3`, `stage_A4`, `stage_A5`, `stage_A`, `stage_B1`, `stage_B2`, `stage_B3`, `stage_B4`, `stage_B5`, `stage_B6`, `stage_B7`, `stage_B`, `stage_C1`, `stage_C2`, `stage_C3`, `stage_C4`, `stage_C`, `stage_D`, `total`: Same attributes as in the `gwp_impact` table, representing the different stages of GWP impact values and total.

### Relationships

#### Entity Relationship Diagram

```plaintext
+----------------------+
|      materials       |
+----------------------+
| material_id (PK)     |
| material_name        |
| category             |
| unit_type            |
+----------------------+
             |
             | 1
             |
             | N
+----------------------+
|     gwp_impact       |
+----------------------+
| material_id (PK, FK) |
| stage_A1_A3          |
| stage_A4             |
| stage_A5             |
| stage_A              |
| stage_B1             |
| stage_B2             |
| stage_B3             |
| stage_B4             |
| stage_B5             |
| stage_B6             |
| stage_B7             |
| stage_B              |
| stage_C1             |
| stage_C2             |
| stage_C3             |
| stage_C4             |
| stage_C              |
| stage_D              |
| total                |
+----------------------+

+----------------------+
|    material_gwp      |
+----------------------+
| material_id (PK)     |
| material_name        |
| category             |
| unit_type            |
| stage_A1_A3          |
| stage_A4             |
| stage_A5             |
| stage_A              |
| stage_B1             |
| stage_B2             |
| stage_B3             |
| stage_B4             |
| stage_B5             |
| stage_B6             |
| stage_B7             |
| stage_B              |
| stage_C1             |
| stage_C2             |
| stage_C3             |
| stage_C4             |
| stage_C              |
| stage_D              |
| total                |
+----------------------+
```

## Optimizations

- Which optimizations (e.g., indexes, views) did you create? Why?
  category_index and material_name_index are created to optimize the queries where material names and category used.
  material_product_stage, material_construction_stage and material_reuse_stage views created. By predefining this views, we can avoid repeatedly writing complex queries and ensure a consistent, easy-to-access representation of the product/construction and reuse stage data.

## Limitations

In this section you should answer the following questions:

- What are the limitations of your design?
  The database uses the downloaded csv from Ökobautdat. If Ökobaudat updates the materials value, the old values will be used. This problem can be solved with usng the Okobaudat API. Due to course scope one of the aim is to work with csv, thats why this method used for final project.
