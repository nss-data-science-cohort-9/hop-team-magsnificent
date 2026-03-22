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
-- ZIP CBSA
--------------------------------------------------

-- Create a materialized view for Nashville CBSA (34980)
-- CREATE MATERIALIZED VIEW zip_cbsa_nashville_mv AS
SELECT *
FROM zip_cbsa
WHERE cbsa = '34980'; -- 157 rows


--------------------------------------------------
-- NPPES
--------------------------------------------------

-- Create a materialized view for NPPES in Nashville with primary taxonomy column and formatted zip code
-- CREATE MATERIALIZED VIEW nppes_nashville_mv AS
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
FROM nppes n
	INNER JOIN zip_cbsa_nashville_mv z ON LEFT(n.address_postal_code::TEXT, 5) = z.zip::TEXT
ORDER BY npi; -- 50824 rows

--------------------------------------------------
-- REFERRING PROVIDERS
--------------------------------------------------
-- PCP only: Family Medicine, Internal Medicine, Pediatrics, General Practice
-- nucc.classification=<pcp>
-- nppes.type=1 (people)

-- Create a materialized view for NPPES PCPs in Nashville
-- CREATE MATERIALIZED VIEW nppes_nashville_pcp_mv AS
WITH nucc_pcp AS (
	SELECT *
	FROM nucc
	WHERE classification ILIKE ANY(
		ARRAY[
			'family medicine',
			'internal medicine',
			'pediatrics',
			'general practice'
		]
	)
) -- 68 ROWS
SELECT *
FROM nppes_nashville_mv n
	INNER JOIN nucc_pcp p ON n.primary_taxonomy_code = p.code
WHERE entity_type_code = 1;	-- 3621 rows


--------------------------------------------------
-- RECEIVING PROVIDERS
--------------------------------------------------
-- Hospitals only
-- nucc.grouping=hospital
-- nppes.entity_type=2 (orgs)

-- Create a materialized view for NPPES hospitals in Nashville
-- CREATE MATERIALIZED VIEW nppes_nashville_hospital_mv AS
WITH nucc_hospital AS (
	SELECT *
	FROM nucc
	WHERE grouping ILIKE '%hospital%'
) -- 23 ROWS
SELECT *
FROM nppes_nashville_mv n
	INNER JOIN nucc_hospital h ON n.primary_taxonomy_code = h.code
WHERE entity_type_code = 2; -- 204 rows


--------------------------------------------------
-- HOP TEAM
--------------------------------------------------

-- Create a materialized view for hop_team in Nashville with PCP referals and receiving hosptals
-- Filter significant referral relationships to avoid incidental or low-volume referrals
-- CREATE MATERIALIZED VIEW hop_team_nashville_mv AS
SELECT
	h.from_npi AS referring_pcp_npi,
	np.first_name || ' ' || np.last_name AS pcp,
	np.grouping AS pcp_grouping,
	np.classification AS pcp_classification,
	np.specialization AS pcp_specialization,
	h.to_npi AS receiving_hospital_npi,
	nh.organization_name AS hospital,
	nh.grouping AS hospital_grouping,
	nh.classification AS hospital_classification,
	nh.specialization AS hospital_specialization,
	h.patient_count,
	h.transaction_count,
	h.average_day_wait,
	h.std_day_wait
FROM hop_team h
	INNER JOIN nppes_nashville_pcp_mv np ON h.from_npi = np.npi
	INNER JOIN nppes_nashville_hospital_mv nh ON h.to_npi = nh.npi
WHERE transaction_count >= 50
	AND average_day_wait < 50
ORDER BY hospital, pcp; -- 2785 rows