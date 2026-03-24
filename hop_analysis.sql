
---------------------------------------------------------------
-- Materialized View: nashville_pcp_hospital_referrals_mv
-- Description: Identifies significant referral relationships 
-- 				between hospitals and PCPs in Nashville area. 
--				Filters to referrals with >= 50 transactions and 
--				an average wait time under 50 days to exclude 
--				incidental or low-volume referral patterns.
-- Source Tables: nppes, zip_cbsa, nucc, hop_team
-- Last Updated:  2026-03-23
----------------------------------------------------------------

CREATE MATERIALIZED VIEW nashville_pcp_hospital_referrals_mv AS

-- Step 1: Find each NPIs primary taxonomy code
-- denoted by a following row with 'X' or 'Y' 

WITH npi_primary_code AS(
SELECT 
npi,
entity_type_code,
organization_name,
last_name,
first_name,
address_postal_code,
address_state_name,
address_city_name,
first_line_address,
second_line_address,
credential_text,
CASE
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

-- Step 2: Filter NPIs based on Nashville indicator
-- CBSA (34980) Join on related postal codes and zip codes.

primary_npi_nppes_zip AS(
SELECT *
FROM npi_primary_code npip
JOIN zip_cbsa c 
ON LEFT(npip.address_postal_code::TEXT, 5) = c.zip::TEXT
WHERE c.cbsa = '34980'),

-- Step 3: Identify hospital providers using NUCC grouping

hospitals AS(
SELECT *
FROM primary_npi_nppes_zip p
INNER JOIN nucc n
ON n.code = p.primary_taxonomy_code
WHERE n."grouping" ILIKE '%hospital%'),

-- Step 4: Identify PCPs by NUCC classification

pcps AS(
SELECT *
FROM primary_npi_nppes_zip p
INNER JOIN nucc n
ON p.primary_taxonomy_code = n.code
WHERE classification in ('Family Medicine', 'Internal Medicine', 'Pediatrics', 'General Practice')
and entity_type_code = 1)

-- Step 5: Join PCP and Hospitals to HOP_TEAMS and
-- apply filter for significant referall relationships.

SELECT 
p.npi AS npi_providers,
th.npi AS npi_hospitals,
p.entity_type_code AS pcp_entity_code,
th.entity_type_code AS hospital_entity_code,
p.organization_name AS pcp_organization_name,
th.organization_name AS hospital_organization_name,
p.first_name || ' ' || p.last_name AS provider_name,
p.address_city_name AS provider_address_city_name,
th.address_city_name AS hospital_address_city_name,
p.first_line_address AS provider_first_line_address,
th.first_line_address AS hospital_first_line_address,
p.second_line_address AS second_line_address,
p.primary_taxonomy_code AS primary_taxonomy_code,
p.zip AS provider_zipcode,
th.zip AS hospital_zipcode,
std_day_wait,
average_day_wait,
transaction_count,
patient_count,
to_npi,
from_npi,
th.display_name AS hospital_display_name, 
th.definition AS hospital_definition,
th.specialization AS hospital_specialization,
p.display_name AS provider_display_name, 
p.definition AS provider_definition,
p.specialization AS provider_specialization,
p.classification AS provider_classification,
th.classification AS hospital_classification,
p."section" AS provider_section,
th."section" AS hospitas_section,
p."grouping" AS provider_grouping,
th."grouping" AS hospital_grouping,
p.usps_zip_pref_city AS provvider_usps_zip_pref_city,
th.usps_zip_pref_city AS hospital_usps_zip_pref_city
FROM pcps p
INNER JOIN hop_team ht 
ON p.npi = ht.from_npi
INNER JOIN hospitals th 
ON ht.to_npi = th.npi
WHERE ht.transaction_count >= 50
AND ht.average_day_wait < 50;
