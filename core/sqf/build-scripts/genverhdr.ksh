#!/bin/bash
###############################################################################
# @@@ START COPYRIGHT @@@
#
# Licensed to the Apache Software Foundation (ASF) under one
# or more contributor license agreements.  See the NOTICE file
# distributed with this work for additional information
# regarding copyright ownership.  The ASF licenses this file
# to you under the Apache License, Version 2.0 (the
# "License"); you may not use this file except in compliance
# with the License.  You may obtain a copy of the License at
#
#   http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing,
# software distributed under the License is distributed on an
# "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
# KIND, either express or implied.  See the License for the
# specific language governing permissions and limitations
# under the License.
#
# @@@ END COPYRIGHT @@@
#
# File:         genverhdr.ksh
# Description:  Script to automate creation of files with version strings and values
#
# Created:      04 Apr 2007
# Language:     bash
#
#
###############################################################################

# bash colorize
bldwht='\e[1;37m' # White
txtrst='\e[0m'    # Text Reset

#---------
# usage()
#---------

function print_usage_line {

    printf "       ${bldwht}$1${txtrst}\n"
    printf "$2" | fmt -w 70 | xargs -i printf "               %s\n" "{}"
}

function usage {
   printf "${bldwht}"
   echo "genverhdr.ksh - a script to create a version string "
   echo "Usage:  genverhdr.ksh [-r] [-l label_string] [-e version_string]"
   printf "${txtrst}"
   echo
   print_usage_line "-branch" "Specifies branch id in the version string."
   print_usage_line "-build" "Specifies build id in the version string."
   print_usage_line "-date" "Specifies date in the version string."
   print_usage_line "-flavor" "Specifies build number in the version string."
   print_usage_line "-funbranch" "Specifies branch id in the version string."
   print_usage_line "-h" "print this usage message"
   print_usage_line "-major" "Specifies major number in the version string."
   print_usage_line "-minor" "Specifies minor number in the version string."
   print_usage_line "-update" "Specifies update number in the version string."
   print_usage_line "-prodver" "Specifies product version(open,Ent,EntAdv) in the version string."
   
}

#---------------
# writeVerHdr()
#---------------

function writeVerHdr {

	umask 002

	cat > $TMPFILE <<EOF
/******************************************************************************
*
* File:         SCMBuildStr.h
* Description:  Autogenerated header file with current build version string
*               -- generated by genverhdr.ksh in build-scripts
* Language:     C
*
*******************************************************************************/

#ifndef SCMBUILDSTR_H
#define SCMBUILDSTR_H 1

/* unused for now */
static const char * SCMBuildStr = "";

/* product version */
#define VERS_PV_MAJ $major
#define VERS_PV_MIN $minor
#define VERS_PV_UPD $update

/* build version */
#define VERS_BR        $branch
#define VERS_BR2       $(echo $funbranch | sed -e "s:-:_dh_:g" -e "s:\.:_dt_:g" -e "s:\/:_sl_:g")
#define VERS_BR3       $(echo $funbranch | sed -e "s:_dh_.*::")
#define VERS_BV        $flavor
#define VERS_SCMBV     $build
#define VERS_SCMBV2    $(echo $build | sed -e "s:-:_dh_:g" -e "s:\.:_dt_:g" -e "s:\/:_sl_:g")

/* build date */
#define VERS_DT        $buildDate

/*prodver*/
#define VERS_PRODVER $prodver

/*copyright*/
#define COPYRIGHT $copyright

#endif

EOF

	cat > $TMPFILEJ <<EOF
Implementation-Version-2: Release $major.$minor.$update
Implementation-Version-3: Build $flavor
Implementation-Version-4: [$build]
Implementation-Version-5: branch $branch
Implementation-Version-6: date $buildDate
EOF
	cat > $TMPFILEJ2 <<EOF
#!/bin/sh
VER_PROD=`echo \$TRAFODION_VER_PROD | sed 's/ /_/'`
echo "Implementation-Version-1: Version \$* \$VER_PROD"
cat \$TRAF_HOME/export/include/SCMBuildMan.mf
EOF

	cat > $TMPFILEJ3 <<EOF
bldId=$branch
EOF

	chmod +x $TMPFILEJ2

	diff --brief --new-file $TMPFILE $hdrFile 2>&1 >/dev/null
	dh=$?
	diff --brief --new-file $TMPFILEJ $hdrFileJ 2>&1 >/dev/null
	dj=$?
	diff --brief --new-file $TMPFILEJ2 $hdrFileJ2 2>&1 >/dev/null
	dj2=$?
	diff --brief --new-file $TMPFILEJ3 $hdrFileJ3 2>&1 >/dev/null
	dj3=$?
	if [[ $dh -ne 0 || $dj -ne 0 || $dj2 -ne 0 || $dj3 -ne 0 ]]; then
		echo "Creating file $hdrFile"
		cp -f $TMPFILE $hdrFile
		echo "Creating file $hdrFileJ"
		cp -f $TMPFILEJ $hdrFileJ
		echo "Creating file $hdrFileJ2"
		cp -f $TMPFILEJ2 $hdrFileJ2
		echo "Creating file $hdrFileJ3"
		cp -f $TMPFILEJ3 $hdrFileJ3
	fi
	rm -f $TMPFILE $TMPFILEJ $TMPFILEJ2 $TMPFILEJ3
}


#------------
# Main body
#------------

#  Define the name of the header file
typeset TMPFILE=$(mktemp /tmp/SCMBuildStr.XXX)
typeset TMPFILEJ=$(mktemp /tmp/SCMBuildStr.XXX)
typeset TMPFILEJ2=$(mktemp /tmp/SCMBuildStr.XXX)
typeset TMPFILEJ3=$(mktemp /tmp/buildId.XXX)
typeset hdrFile="../export/include/SCMBuildStr.h"
typeset hdrFileJ="../export/include/SCMBuildMan.mf"
typeset hdrFileJ2="../export/include/SCMBuildJava.sh"
typeset hdrFileJ3="../export/include/buildId"

#  Input file
typeset VERFILE="../sqenvcom.sh"

#  Parse the command options:
typeset branch=
typeset build=
typeset flavor=
typeset funbranch=
typeset buildDate=
typeset major=
typeset minor=
typeset update=
typeset prodver=
typeset copyright=

while [ $# -gt 0 ]; do
   case $1 in
      -branch|-br)
         branch="${2}"
         shift
         ;;
      -build|-b)
         build="${2}"
         shift
         ;;
      -date|-d)
         buildDate="${2}"
         shift
         ;;
      -flavor|-f)
         flavor="${2}"
         shift
         ;;
      -funbranch|-fb)
         funbranch="${2}"
         shift
         ;;
      -major|-ma)
         major="${2}"
         shift
         ;;
      -minor|-mi)
         minor="${2}"
         shift
         ;;
      -update|-u)
         update="${2}"
         shift
         ;;
       -prodver|-pv)
         prodver="${2}"
         shift
         ;;       
      -h|*)
         usage
         exit 1
         ;;
  esac
  shift
done

# Set some defaults
[ -z "$branch" ] && branch=BRANCH
[ -z "$build" ] && build=DEV
[ -z "$buildDate" ] && buildDate=$(date +%d%b%y)
[ -z "$flavor" ] && flavor=debug
[ -z "$funbranch" ] && funbranch=FUNBRANCH

VER_VARIABLES="TRAFODION_VER_MAJOR  TRAFODION_VER_MINOR  TRAFODION_VER_UPDATE"
if [[ -z "${major}${minor}${update}" ]]; then
	for AVAR in $VER_VARIABLES ; do
		if [[ -z "$( eval "echo \$$(eval "echo $AVAR")" )" ]]; then
			echo "ERROR: Environment variable is null : $AVAR"
			exit 1
		fi
	done
fi

[ -z "$major" ]  && major="$( grep TRAFODION_VER_MAJOR=  $VERFILE | cut -f2 -d=)"
[ -z "$minor" ]  && minor="$( grep TRAFODION_VER_MINOR=  $VERFILE | cut -f2 -d=)"
[ -z "$update" ] && update="$(grep TRAFODION_VER_UPDATE= $VERFILE | cut -f2 -d=)"
[ -z "$prodver" ] && prodver="$(grep TRAFODION_VER_PROD= $VERFILE | cut -f2 -d=| sed 's/ /_/' | sed 's/\"//g')"
[ -z "$copyright" ] && copyright=" Copyright (c) $(grep PRODUCT_COPYRIGHT_HEADER= $VERFILE | cut -f2 -d=)"

writeVerHdr
