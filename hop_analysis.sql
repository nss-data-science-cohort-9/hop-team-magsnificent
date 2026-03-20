# Hop Teaming Analysis: Nashville Referral Network

## Overview
In this project, you will analyze referral patterns between healthcare providers in the Nashville CBSA using the Hop Teaming dataset. The goal is to explore how primary care physicians (PCPs) refer patients to hospitals, understand referral communities, and create an interactive dashboard to visualize your insights.  

You will work with a PostgreSQL database containing the data you need. Additionally, you will use Neo4j to explore provider networks and apply community detection algorithms, and R Shiny to build an interactive visualization of referral patterns.

SELECT *
FROM hop_team
LIMIT 5;

## Datasets Provided
The data for this project can be downloaded as a postgres backup from https://drive.google.com/file/d/1AqwuVf2DM7a-w8VM9wIX_p4nzOEUbQLM/view?usp=drive_link

**PostgreSQL Database:** Contains four main tables:  
   - `hop_team`:  Referral transactions between providers
   - `nppes`: Provider metadata
   - `nucc`: Taxonomy grouping, classification, and specialization
   - `zip_cbsa`: Zip Code/CBSA crosswalk

---

## Project Focus
To narrow the scope of the analysis, apply the following filters:
- For each provider, identify their primary taxonomy code. In the NPPES data, this is the taxonomy code whose corresponding taxonomy switch column is marked with 'Y'.
- For the referring providers, filter to Primary Care Physicians (PCPs) only: You can look for classifications of "Family Medicine", "Internal Medicine", "Pediatrics", and "General Practice"
- For the receiving providers, filter to hospitals.
- Only referrals in the Nashville CBSA.  
- To avoid incidental or low-volume referrals, look for significant referral relationships, meaning `transaction_count >= 50` and `avg_day_wait < 50`.

---

## Tasks

### 1. Create an Analytical Dataset
Create a materialized view that joins the necessary tables and applies the project filters:
- Primary taxonomy for each provider
- PCP specialties for referring providers
- Hospitals for receiving providers
- Nashville CBSA
- Significant referral relationships

This dataset will serve as the foundation for your SQL analysis, Neo4j network export, and Shiny dashboard.

select npi, case
				when healthcare_primary_taxonomy_switch_1 in ('Y','X') then healthcare_taxonomy_code_1
				when healthcare_primary_taxonomy_switch_2 in ('Y','X') then healthcare_taxonomy_code_2
				when healthcare_primary_taxonomy_switch_3 in ('Y','X') then healthcare_taxonomy_code_3
				when healthcare_primary_taxonomy_switch_4 in ('Y','X') then healthcare_taxonomy_code_4
				when healthcare_primary_taxonomy_switch_5 in ('Y','X') then healthcare_taxonomy_code_5
				when healthcare_primary_taxonomy_switch_6 in ('Y','X') then healthcare_taxonomy_code_6
				when healthcare_primary_taxonomy_switch_7 in ('Y','X') then healthcare_taxonomy_code_7
				when healthcare_primary_taxonomy_switch_8 in ('Y','X') then healthcare_taxonomy_code_8
				when healthcare_primary_taxonomy_switch_9 in ('Y','X') then healthcare_taxonomy_code_9
				when healthcare_primary_taxonomy_switch_10 in ('Y','X') then healthcare_taxonomy_code_10
				when healthcare_primary_taxonomy_switch_11 in ('Y','X') then healthcare_taxonomy_code_11
				when healthcare_primary_taxonomy_switch_12 in ('Y','X') then healthcare_taxonomy_code_12
				when healthcare_primary_taxonomy_switch_13 in ('Y','X') then healthcare_taxonomy_code_13
				when healthcare_primary_taxonomy_switch_14 in ('Y','X') then healthcare_taxonomy_code_14
				when healthcare_primary_taxonomy_switch_15 in ('Y','X') then healthcare_taxonomy_code_15
			end as primary_taxonomy_code
from nppes;

WITH primary_taxonomy AS(
select npi, case
				when healthcare_primary_taxonomy_switch_1 in ('Y','X') then healthcare_taxonomy_code_1
				when healthcare_primary_taxonomy_switch_2 in ('Y','X') then healthcare_taxonomy_code_2
				when healthcare_primary_taxonomy_switch_3 in ('Y','X') then healthcare_taxonomy_code_3
				when healthcare_primary_taxonomy_switch_4 in ('Y','X') then healthcare_taxonomy_code_4
				when healthcare_primary_taxonomy_switch_5 in ('Y','X') then healthcare_taxonomy_code_5
				when healthcare_primary_taxonomy_switch_6 in ('Y','X') then healthcare_taxonomy_code_6
				when healthcare_primary_taxonomy_switch_7 in ('Y','X') then healthcare_taxonomy_code_7
				when healthcare_primary_taxonomy_switch_8 in ('Y','X') then healthcare_taxonomy_code_8
				when healthcare_primary_taxonomy_switch_9 in ('Y','X') then healthcare_taxonomy_code_9
				when healthcare_primary_taxonomy_switch_10 in ('Y','X') then healthcare_taxonomy_code_10
				when healthcare_primary_taxonomy_switch_11 in ('Y','X') then healthcare_taxonomy_code_11
				when healthcare_primary_taxonomy_switch_12 in ('Y','X') then healthcare_taxonomy_code_12
				when healthcare_primary_taxonomy_switch_13 in ('Y','X') then healthcare_taxonomy_code_13
				when healthcare_primary_taxonomy_switch_14 in ('Y','X') then healthcare_taxonomy_code_14
				when healthcare_primary_taxonomy_switch_15 in ('Y','X') then healthcare_taxonomy_code_15
			end as primary_taxonomy_code
FROM nppes
),


npi_primary_code AS(
SELECT *
FROM primary_taxonomy p
INNER JOIN NPPES n
ON p.npi = n.npi
)


SELECT *
FROM npi_primary_code npip
JOIN zip_cbsa c 
ON LEFT(npip.address_postal_code::TEXT, 5) = c.zipcode::TEXT





SELECT *
FROM zip_cbsa
WHERE usps_zip_pref_city = 'NASHVILLE';

SELECT * 
FROM nucc n;

SELECT * 
FROM NPPES;

SELECT * 
FROM hop_team;

WITH pcp_hop AS(
SELECT *
FROM NUCC
WHERE CLASSIFICATION ILIKE ANY(
ARRAY[
'FAMILY MEDICINE',
'INTERNAL MEDICINE',
'PEDIATRICS',
'GENERAL PRACTICE'
]
)
)

SELECT *
FROM zip_cbsa
INNER JOIN pcp_hop p
ON p.code = 
WHERE usps_zip_pref_city = 'NASHVILLE';


SELECT *
FROM NUCC n
WHERE n.CLASSIFICATION ILIKE ANY(
    ARRAY[
        'FAMILY MEDICINE',
        'INTERNAL MEDICINE',
        'PEDIATRICS',
        'GENERAL PRACTICE'
    ]
)
AND n.grouping ILIKE '%hospitals%';



CREATE MATERIALIZED VIEW pcp_nucc_mv AS
SELECT *
FROM NUCC
WHERE CLASSIFICATION ILIKE ANY(
ARRAY[
'FAMILY MEDICINE',
'INTERNAL MEDICINE',
'PEDIATRICS',
'GENERAL PRACTICE'
]
)
ORDER BY CODE;	-- 68 ROWS



WITH nashville_hop AS(
SELECT *
FROM zip_cbsa
WHERE usps_zip_pref_city = 'NASHVILLE')



SELECT *
FROM nucc n 
WHERE n."grouping" ILIKE '%hospitals%'


SELECT *
nppes




-- HOW TO GET COLUMN NAMES --
SELECT COLUMN_NAME
FROM information_schema.columns
WHERE TABLE_NAME = 'nppes'
	AND COLUMN_NAME LIKE 'healthcare_primary_taxonomy_switch%'


- Understand referral patterns and provider network dynamics in a real-world healthcare context.