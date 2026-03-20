
--  For each provider, identify their primary taxonomy code. In the NPPES data, this is the taxonomy code whose corresponding taxonomy switch column is marked with 'Y'.

-- NOTE: there are providers with multiple primary codes. Right now we just select the first one that applies. Improve this later?

with primary_code as (select npi, address_state_name, case
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
			end as code 
from nppes)
select p.npi, p.code, n.grouping, n.classification, n.specialization
from primary_code p
left join nucc n 
using(code)
where p.address_state_name in ('TN', 'Tennessee');


with primary_code as (select npi, address_state_name, case
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
			end as code 
from nppes)
select count(*)
from primary_code
where not code is null
and address_state_name in ('TN', 'Tennessee');
--By choosing the first "x" or "y" as the primary specialty, we found 138,120 Tennessee doctors with a primary specialty


with indiv_sums as (select 
COUNT(*) FILTER (WHERE healthcare_primary_taxonomy_switch_1 in ('Y','X')) AS sum1,
COUNT(*) FILTER (WHERE healthcare_primary_taxonomy_switch_2 in ('Y','X')) AS sum2,
COUNT(*) FILTER (WHERE healthcare_primary_taxonomy_switch_3 in ('Y','X')) AS sum3,
COUNT(*) FILTER (WHERE healthcare_primary_taxonomy_switch_4 in ('Y','X')) AS sum4,
COUNT(*) FILTER (WHERE healthcare_primary_taxonomy_switch_5 in ('Y','X')) AS sum5,
COUNT(*) FILTER (WHERE healthcare_primary_taxonomy_switch_6 in ('Y','X')) AS sum6,
COUNT(*) FILTER (WHERE healthcare_primary_taxonomy_switch_7 in ('Y','X')) AS sum7,
COUNT(*) FILTER (WHERE healthcare_primary_taxonomy_switch_8 in ('Y','X')) AS sum8,
COUNT(*) FILTER (WHERE healthcare_primary_taxonomy_switch_9 in ('Y','X')) AS sum9,
COUNT(*) FILTER (WHERE healthcare_primary_taxonomy_switch_10 in ('Y','X')) AS sum10,
COUNT(*) FILTER (WHERE healthcare_primary_taxonomy_switch_11 in ('Y','X')) AS sum11,
COUNT(*) FILTER (WHERE healthcare_primary_taxonomy_switch_12 in ('Y','X')) AS sum12,
COUNT(*) FILTER (WHERE healthcare_primary_taxonomy_switch_13 in ('Y','X')) AS sum13,
COUNT(*) FILTER (WHERE healthcare_primary_taxonomy_switch_14 in ('Y','X')) AS sum14,
COUNT(*) FILTER (WHERE healthcare_primary_taxonomy_switch_15 in ('Y','X')) AS sum15
from nppes
where address_state_name in ('TN', 'Tennessee')
)
select sum1 + sum2 + sum3 + sum4 + sum5 + sum6 + sum7 + sum8 + sum9 + sum10 + sum11 + sum12 + sum13 + sum14 + sum15 as total_yes
from indiv_sums;

--The sum of all "x" and "y" values for all Tennessee doctors is 139,165, which indicates that 1,045 (0.75%) of Tennessee doctors have multiple primary specialties listed in the database. Ex:

select npi, healthcare_taxonomy_code_1, healthcare_primary_taxonomy_switch_1, healthcare_taxonomy_code_2, healthcare_primary_taxonomy_switch_2
from nppes
where npi = 1649269366;



-- Overall query:

with primary_code as (
select npi, 
		entity_type_code,
		first_name,
		last_name,
		organization_name,
		address_state_name,
		case
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
		end as code 
from nppes
),
primary_spec as (
select *
from primary_code p
inner join nucc n 
using(code)
where p.address_state_name in ('TN', 'Tennessee')
),
from_npis_of_interest as (
select p.npi, p.first_name, p.last_name
from primary_spec p
-- For the referring providers, filter to Primary Care Physicians (PCPs) only: You can look for classifications of "Family Medicine", "Internal Medicine", "Pediatrics", and "General Practice".
where classification in ('Family Medicine', 'Internal Medicine', 'Pediatrics', 'General Practice')
and entity_type_code = 1
),
to_npis_of_interest as (
select p.npi, p.organization_name 
from primary_spec p
-- For the receiving providers, filter to hospitals.
where grouping ilike '%hospital%'
and entity_type_code = 2
)
select h.from_npi, f.first_name || ' ' || f.last_name as providername, h.to_npi, t.organization_name, h.patient_count, h.transaction_count, h.average_day_wait, h.std_day_wait
from hop_team h
inner join from_npis_of_interest f
on h.from_npi = f.npi
inner join to_npis_of_interest t
on h.to_npi = t.npi
-- To avoid incidental or low-volume referrals, look for significant referral relationships, meaning transaction_count >= 50 and avg_day_wait < 5
where h.transaction_count >= 50
and h.average_day_wait < 50;



  --  Only referrals in the Nashville CBSA.
 -- Figure out how to join zip_cbsa table with nppes table


select * from nppes limit 5;

select * from zip_cbsa limit 5;