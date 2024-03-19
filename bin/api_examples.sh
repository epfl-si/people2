#!/bin/bash
# Examples of queries to api.epfl.ch that can be useful
# ./bin/api_epfl.sh > api_examples.txt

. .env
. ${KBPATH:-/keybase/team/epfl_people.prod}/${SECRETS:-secrets_prod.sh}
BASE=${API_BASEURL:-https://api.epfl.ch/v1}
GIO=121769
NAT=116080
EDO=229105
FRA=363674
OLI=107931

apiget() {
	echo "# $1 | jq -r '$2'"
  curl --basic --user "people:${EPFLAPI_PASSWORD}" \
       -X GET "$1" 2>/dev/null | jq -r "$2"
}

rawapiget() {
     echo "# $1"
  curl --basic --user "people:${EPFLAPI_PASSWORD}" \
       -X GET "$1" 2>/dev/null
}

echo "#----------------------------------------------- Similarly (array result)"
apiget "$BASE/persons?persid=${GIO}"

echo "#------------------------------------------------------ Similarly by name"
apiget "$BASE/persons?firstname=giovanni&lastname=cangiani"

echo "#--------------------------- Similarly for multiple sciper (array result)"
apiget "$BASE/persons?persid=${GIO},${NAT}"

echo "#-------------------------------- Profile for all the members of IDEV-FSD"
apiget "$BASE/persons?unitid=13030"

echo "#------------- To much informations. Let's get just the scipers and names"
apiget "$BASE/persons?unitid=13030" '.persons[] | [.id, .display] | @tsv'

echo "#---------------------------------- The accreditations for a given sciper"
apiget "$BASE/accreds?persid=${GIO}"

echo "#-------- The list of unitsid to which a person with given sciper belongs"
apiget "$BASE/accreds?persid=${GIO}"  '.accreds[].unitid'

echo "#------------------------ Same but only active accreds for a given person"
apiget "$BASE/accreds?persid=${GIO}&status=active"  '.accreds[].unitid'

echo "#---------------------------- The active authorisation for a given person"
apiget "$BASE/authorizations?persid=${NAT}&status=active"

echo "#----------- The active authorisation of type property for a given person"
apiget "$BASE/authorizations?persid=${NAT}&status=active&type=property"

echo "#-- The active authorisation of type property for a given person and unit"
apiget "$BASE/authorizations?persid=${NAT}&resid=14214&status=active&type=property"

echo "#----------------------- Fetch web visibility for all accreds of a person"
apiget "$BASE/authorizations?persid=${NAT}&status=active&type=property&authid=botweb" \
     '.authorizations[] | [.resourceid, .value] | @tsv'

echo "#--------Check if Natalie's accred for unit 14214 should appear on people"
apiget "$BASE/authorizations?persid=${NAT}&resid=14214&status=active&type=property&authid=botweb" \
     '.authorizations[] | .value'

echo "#---------------------------- Check if person can edit its people profile"
apiget "$BASE/authorizations?persid=${GIO}&authid=gestprofil&type=property&status=active" \
     '.authorizations[] | .value'

echo "#- Check if person is prof that needs annual report (has AAR.report.control right)"
apiget "$BASE/authorizations?persid=${EDO}&authid=AAR.report.control&type=right&status=active" \
     '.authorizations[] | .value'

echo "#------------------------------------- Get infos about unit with id 14214"
apiget "$BASE/units/14214"

