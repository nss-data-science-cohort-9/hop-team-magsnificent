Select npi 
from nppes;

select from_npi, to_npi
from hop_team;



select address_city_name, address_state_name
from nppes
where address_city_name ilike 'nashville' and address_state_name ilike 'TN'

WITH SigRelationship As (
SELECT
	TRANSACTION_COUNT,
	FROM_NPI,
	TO_NPI,
	AVERAGE_DAY_WAIT,
	last_name,
	first_name,
	address_city_name,
	address_state_name
FROM
	HOP_TEAM H
	INNER JOIN NPPES N ON H.FROM_NPI = N.NPI
WHERE
	TRANSACTION_COUNT >= 50
	AND AVERAGE_DAY_WAIT < 50
	and address_city_name ilike 'nashville'
	and address_state_name ilike 'TN'
	or address_state_name ilike 'Tennessee'
ORDER BY
	TRANSACTION_COUNT ASC;
)



SELECT
	*
FROM
	NPPES
WHERE
	NPI IS NOT NULL
	OR ENTITY_TYPE_CODE IS NOT NULL
	OR ORGANIZATION_NAME IS NOT NULL
	OR LAST_NAME IS NOT NULL
	OR FIRST_NAME IS NOT NULL
	OR NAME_PREFIX_TEXT IS NOT NULL
	OR CREDENTIAL_TEXT IS NOT NULL
	OR FIRST_LINE_ADDRESS IS NOT NULL
	OR SECOND_LINE_ADDRESS IS NOT NULL
	OR ADDRESS_CITY_NAME IS NOT NULL
	OR ADDRESS_STATE_NAME IS NOT NULL
	OR ADDRESS_POSTAL_CODE IS NOT NULL;

select *
from nucc
