


Create materialized view TN_Referral_Network
as 
WITH prime_code As (Select 
	npi,
	last_name,
	first_name,
	first_line_address,
	entity_type_code,
	address_city_name,
	address_state_name,
	address_postal_code,
	organization_name,
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
		end as tax_code 
FROM
	NPPES
),
cbsa_nashville as(
select * 
from zip_cbsa zc
inner join nppes n 
on left (n.address_postal_code::TEXT, 5) = zc.zip::TEXT
Where address_state_name IN ('TN', 'Tennessee') and zc.cbsa = 34980
),
specialist_code as(
select *
from prime_code p  
inner join nucc n on p.tax_code = n.code
),
from_npi_pcp as(
select s.npi, s.last_name, s.first_name
from specialist_code s
where classification in ('Family Medicine', 'Internal medicine', 'Pediatrics', 'General Practice')
and entity_type_code = 1
),
to_npi_facilities as(
select s.npi, s.organization_name
from specialist_code s
where grouping ilike '%hospital%'
and entity_type_code = 2
)
Select h.from_npi, 
		pcp.first_name || ' ' || pcp.last_name as Provider,
		h.to_npi,
		f.organization_name,
		h.patient_count, 
		h.transaction_count,
		h.average_day_wait,
		h.std_day_wait 
from hop_team h
inner join from_npi_pcp pcp on h.from_npi = pcp.npi
inner join to_npi_facilities f on h.to_npi = f.npi
where h.transaction_count >= 50 
and average_day_wait < 50;
		
DROP MATERIALIZED VIEW TN_REFERRAL_NETWORK



