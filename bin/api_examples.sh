#!/bin/bash
# Examples of queries to api.epfl.ch that can be useful
# ./bin/api_epfl.sh > api_examples.txt

api=$(dirname $0)/api.sh

GIO=121769
NAT=116080
EDO=229105
FRA=363674
OLI=107931

echo "#---------------------------------------- fuzzy search on first/last name"
$api "persons?query=giova%20cangi" -r '.persons[] | [.id, .display] | @tsv'
$api "persons?query=leonardo%20surdez" -r '.persons[] | [.id, .display] | @tsv'
echo "# -- query=francesco dal peraro"
$api "persons?query=francesco%20dal%20peraro" -r '.persons[] | [.id, .display] | @tsv'
echo "# -- query=francesco dalperaro"
$api "persons?query=francesco%20dalperaro" -r '.persons[] | [.id, .display] | @tsv'
echo "# -- query=francesco.dalperaro"
$api "persons?query=francesco.dalperaro" -r '.persons[] | [.id, .display] | @tsv'

echo "#----------------------------------------------- Similarly (array result)"
$api "persons/${GIO}"

echo "#------------------------------------------------------ Similarly by name"
$api "persons?firstname=giovanni&lastname=cangiani"

echo "#--------------------------- Similarly for multiple sciper (array result)"
$api "persons?persid=${GIO},${NAT}"

echo "#-------------------------------- Profile for all the members of IDEV-FSD"
$api "persons?unitid=13030"

echo "#------------- To much informations. Let's get just the scipers and names"
$api "persons?unitid=13030" -r '.persons[] | [.id, .display] | @tsv'

echo "#------------------------------------- Get infos about unit with id 14214"
$api "units/14214"

echo "#------------------------------------- Get infos about unit ISAS-FSD unit"
$api "units?query=ISAS-FSD"

echo "#---------------------------------- The accreditations for a given sciper"
$api "accreds?persid=${GIO}"

echo "#-------- The list of unitsid to which a person with given sciper belongs"
$api "accreds?persid=${GIO}" -r '.accreds[].unitid'

echo "#------------------------ Same but only active accreds for a given person"
$api "accreds?persid=${GIO}&status=active" -r '.accreds[].unitid'

echo "#---------------------------- The active authorisation for a given person"
$api "authorizations?persid=${NAT}&status=active"

echo "#----------- The active authorisation of type property for a given person"
$api "authorizations?persid=${NAT}&status=active&type=property"

echo "#-- The active authorisation of type property for a given person and unit"
$api "authorizations?persid=${NAT}&resid=14214&status=active&type=property"

echo "#----------------------- Fetch web visibility for all accreds of a person"
$api "authorizations?persid=${NAT}&status=active&type=property&authid=botweb" \
     -r '.authorizations[] | [.resourceid, .value] | @tsv'

echo "#--------Check if Natalie's accred for unit 14214 should appear on people"
$api "authorizations?persid=${NAT}&resid=14214&status=active&type=property&authid=botweb" \
     -r '.authorizations[] | .value'

echo "#---------------------------- Check if person can edit its people profile"
$api "authorizations?persid=${GIO}&authid=gestprofil&type=property&status=active" \
     -r '.authorizations[] | .value'

echo "#- Check if person is prof that needs annual report (has AAR.report.control right)"
$api "authorizations?persid=${EDO}&authid=AAR.report.control&type=right&status=active" \
     -r '.authorizations[] | .value'

echo "#---------------------------- List the sciper of who can edit my profile"
$api "authorizations?type=right&authid=12&state=active&onpersid=${GIO}" \
     -r '.authorizations[] | .persid' 
