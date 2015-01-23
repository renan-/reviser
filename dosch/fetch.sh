#!/bin/bash

# Exit now in case of any kind of problem
set -e

rm -rf arche.univ-nancy2.fr zip

# récupérer le cookie avec Live HTTP headers
wget -r -A ZIP,zip,rar,RAR,gz --header "Cookie: MoodleSession=k6bu39p237hlv1r1d37l9jfip6; MoodleSessionTest=7xrxXUrcty; MOODLEID_=%25E7%25C3%250DO%25BB" http://arche.univ-nancy2.fr/mod/assignment/submissions.php?id=6651
mkdir zip

find arche.univ-nancy2.fr/file.php -type f -exec cp --no-clobber {} zip/ \;
rm -rf arche.univ-nancy2.fr
