/*
HOP TEAM EXPLORATORY ANALYSIS

NOTES:
- RECEIVING PROVIDERS: NUCC.GROUPING=<hospitals> AND NPPES.TYPE=1 (orgs)
- CBSA: 34980
- NPPES POSTAL CODE DOES NOT DIRECTLY MATCH THE ZIP_CBSA ZIP
- NPPES TAXONOMY SWITCH VALUES CAN BE ('Y' or 'N') OR ('X' or NULL)
*/

-- nppes (TN): 138156 rows
SELECT *
FROM nppes
WHERE address_state_name ILIKE ANY(ARRAY['tennessee', 'tn'])
ORDER BY address_postal_code;

-- hop_team: 217911308 rows
-- SELECT COUNT(*)
-- FROM hop_team;

select *
from hop_team
limit 5;

-- nucc: 883 rows
SELECT *
FROM nucc;

-- cbsa (34980): 157 rows
SELECT *
FROM zip_cbsa
WHERE cbsa = 34980
ORDER BY zip;

-- SELECT column_name
-- FROM information_schema.columns
-- WHERE table_name = 'nppes'
-- 	AND column_name LIKE 'healthcare_primary_taxonomy_switch%'

--------------------------------------------------
-- REFERRING PROVIDERS
--------------------------------------------------
-- PCP only: Family Medicine, Internal Medicine, Pediatrics, General Practice
-- nucc.classification=<pcp>
-- nppes.type=1 (people)

-- Create a materialized view for NUCC PCPs
-- CREATE MATERIALIZED VIEW nucc_pcp_mv AS
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
ORDER BY CODE;
-- 68 ROWS

-- Create a materialized view for NPPES in TN with primary taxonomy column
-- CREATE MATERIALIZED VIEW nppes_tn_primary_taxonomy_mv AS
SELECT
	*,
	CASE
		WHEN healthcare_primary_taxonomy_switch_1 IN ('Y', 'X') THEN healthcare_taxonomy_code_1
		WHEN healthcare_primary_taxonomy_switch_2 IN ('Y', 'X') THEN healthcare_taxonomy_code_2
		WHEN healthcare_primary_taxonomy_switch_3 IN ('Y', 'X') THEN healthcare_taxonomy_code_3
		WHEN healthcare_primary_taxonomy_switch_4 IN ('Y', 'X') THEN healthcare_taxonomy_code_4
		WHEN healthcare_primary_taxonomy_switch_5 IN ('Y', 'X') THEN healthcare_taxonomy_code_5
		WHEN healthcare_primary_taxonomy_switch_6 IN ('Y', 'X') THEN healthcare_taxonomy_code_6
		WHEN healthcare_primary_taxonomy_switch_7 IN ('Y', 'X') THEN healthcare_taxonomy_code_7
		WHEN healthcare_primary_taxonomy_switch_8 IN ('Y', 'X') THEN healthcare_taxonomy_code_8
		WHEN healthcare_primary_taxonomy_switch_9 IN ('Y', 'X') THEN healthcare_taxonomy_code_9
		WHEN healthcare_primary_taxonomy_switch_10 IN ('Y', 'X') THEN healthcare_taxonomy_code_10
		WHEN healthcare_primary_taxonomy_switch_11 IN ('Y', 'X') THEN healthcare_taxonomy_code_11
		WHEN healthcare_primary_taxonomy_switch_12 IN ('Y', 'X') THEN healthcare_taxonomy_code_12
		WHEN healthcare_primary_taxonomy_switch_13 IN ('Y', 'X') THEN healthcare_taxonomy_code_13
		WHEN healthcare_primary_taxonomy_switch_14 IN ('Y', 'X') THEN healthcare_taxonomy_code_14
		WHEN healthcare_primary_taxonomy_switch_15 IN ('Y', 'X') THEN healthcare_taxonomy_code_15
		ELSE NULL
	END AS primary_taxonomy_code
FROM nppes
WHERE address_state_name IN ('TENNESSEE', 'TN')
ORDER BY npi;
-- 138156 rows



-- Create a materialized view for NPPES PCPs in TN with primary taxonomy column
SELECT *
FROM nppes_tn_primary_taxonomy_mv n
	INNER JOIN nucc_pcp_mv p ON n.primary_taxonomy_code = p.code
WHERE entity_type_code = 1;	
-- 13157 rows


--------------------------------------------------
-- RECEIVING PROVIDERS
--------------------------------------------------
-- Hospitals only
-- nucc.grouping=hospital
-- nppes.entity_type=2 (orgs)

-- Create a materialized view for NUCC Hospitals
-- CREATE MATERIALIZED VIEW nucc_hospitals_mv AS
SELECT *
FROM nucc
WHERE grouping ILIKE '%hospital%'
ORDER BY code;
-- 23 ROWS

-- CREATE A VIEW WITH THIS QUERY: TN_HOSPITALS
WITH 
	HOSPITAL_CLASSIFICATIONS AS (
		SELECT *
			-- CODE,
			-- CLASSIFICATION
		FROM NUCC
		WHERE GROUPING ILIKE '%HOSPITAL%'
	),
	TN_NPPES_PRIMARY_TAXONOMY_CODES AS (
		SELECT
			NPI,
			CASE
				WHEN HEALTHCARE_PRIMARY_TAXONOMY_SWITCH_1 = 'Y' THEN HEALTHCARE_TAXONOMY_CODE_1
				WHEN HEALTHCARE_PRIMARY_TAXONOMY_SWITCH_2 = 'Y' THEN HEALTHCARE_TAXONOMY_CODE_2
				WHEN HEALTHCARE_PRIMARY_TAXONOMY_SWITCH_3 = 'Y' THEN HEALTHCARE_TAXONOMY_CODE_3
				WHEN HEALTHCARE_PRIMARY_TAXONOMY_SWITCH_4 = 'Y' THEN HEALTHCARE_TAXONOMY_CODE_4
				WHEN HEALTHCARE_PRIMARY_TAXONOMY_SWITCH_5 = 'Y' THEN HEALTHCARE_TAXONOMY_CODE_5
				WHEN HEALTHCARE_PRIMARY_TAXONOMY_SWITCH_6 = 'Y' THEN HEALTHCARE_TAXONOMY_CODE_6
				WHEN HEALTHCARE_PRIMARY_TAXONOMY_SWITCH_7 = 'Y' THEN HEALTHCARE_TAXONOMY_CODE_7
				WHEN HEALTHCARE_PRIMARY_TAXONOMY_SWITCH_8 = 'Y' THEN HEALTHCARE_TAXONOMY_CODE_8
				WHEN HEALTHCARE_PRIMARY_TAXONOMY_SWITCH_9 = 'Y' THEN HEALTHCARE_TAXONOMY_CODE_9
				WHEN HEALTHCARE_PRIMARY_TAXONOMY_SWITCH_10 = 'Y' THEN HEALTHCARE_TAXONOMY_CODE_10
				WHEN HEALTHCARE_PRIMARY_TAXONOMY_SWITCH_11 = 'Y' THEN HEALTHCARE_TAXONOMY_CODE_11
				WHEN HEALTHCARE_PRIMARY_TAXONOMY_SWITCH_12 = 'Y' THEN HEALTHCARE_TAXONOMY_CODE_12
				WHEN HEALTHCARE_PRIMARY_TAXONOMY_SWITCH_13 = 'Y' THEN HEALTHCARE_TAXONOMY_CODE_13
				WHEN HEALTHCARE_PRIMARY_TAXONOMY_SWITCH_14 = 'Y' THEN HEALTHCARE_TAXONOMY_CODE_14
				WHEN HEALTHCARE_PRIMARY_TAXONOMY_SWITCH_15 = 'Y' THEN HEALTHCARE_TAXONOMY_CODE_15
				ELSE NULL
			END AS HEALTHCARE_PRIMARY_TAXONOMY_CODE
		FROM NPPES
		WHERE ADDRESS_STATE_NAME IN ('TENNESSEE', 'TN')
	)
SELECT
	N.NPI,
	N.ORGANIZATION_NAME,
	N.FIRST_NAME || ' ' || N.LAST_NAME AS pcp,
	T.HEALTHCARE_PRIMARY_TAXONOMY_CODE,
	C.CLASSIFICATION
FROM NPPES N
	INNER JOIN TN_NPPES_PRIMARY_TAXONOMY_CODES T USING (NPI)
	INNER JOIN HOSPITAL_CLASSIFICATIONS C ON T.HEALTHCARE_PRIMARY_TAXONOMY_CODE = C.CODE
ORDER BY N.NPI; -- 1124 ROWS


-- Identify PCPs who refer patients and the distribution of their referrals across major hospitals.
-- Find PCPs who refer few or no patients to Vanderbilt but send patients to competitor hospitals.
-- Aggregate by PCP specialty to understand which specialties are underrepresented in Vanderbilt’s referral network.