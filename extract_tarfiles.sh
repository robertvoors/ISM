#! /bin/bash

# First: sftp to the filetransfer site
# Next: check the available data: TBD come up with a reasonable filter of osme sort
# when appropriate data is available: download
# Note: for ease of storage as well as alignment with the currently existing bahs script: fist zip all the relevant files into a simgle file

# Note: THIS DOES NO YET WORK!!!!!
#curl  -k "sftp://filetransfer.airbusds.nl" --user "rb77098:eenYi7B2"
#export SSHPASS=eenYi7B2
#sshpass -e sftp -oBatchMode=no -b - rb77098@filetransfer.airbusds.nl << !
#   ls
#   #cd incoming
#   #put your-log-file.log
#   #bye
#!


# Arguments on the prompt are year and month
# First check if two arguments are given:
if test -z "$2"
then
	echo "Usage:  ./extract_tarfiles arg1 arg2"
	echo "Expected in rundir: a file of the format ISM_Data_YYYY_MM.zip \
	     where MM (arg2) is a 2-letter month code (e.g. 01) \
	     and YYYY (arg1) is a 4-letter code forthe year (e.g. 2023)"
	exit -1
fi

echo "Year: "$1
echo "Month: "$2

# unzip file that was created by zipping all the relevant files in the filetransfer directory
MONTH=$2
YEAR=$1
ZIPFILE="ISM_Data_$1_$2.zip"
unzip $ZIPFILE

# Voor een gegeven maand en jaar, zet alle beschikbare .gz files in een tekst file
#  in dit voorbeeld jaar:2023, maand:01
ls *$1.$2*.tar.gz > ls_targzfiles.txt

# unzip all files in generated text file: ls_targzfiles.txt
while IFS= read -r line; do
    echo "Unzipping: $line"
    gunzip $line
done < ls_targzfiles.txt

# Voor een gegeven maand en jaar, zet alle beschikbare tarfiles in een tekst file
#  in dit voorbeeld $1 = jaar:2023   en $2 = maand:01
ls *$1.$2*.tar > ls_tarfiles.txt

# unpack all files in generated text file: ls_tarfiles.txt
while IFS= read -r line; do
    echo "Extracting: $line"
    tar -xf $line
done < ls_tarfiles.txt


# De files komen dan terecht in e.g. ./home/ism/Seeing_Monitor/FTP/allskyBinning/2023.01/
# Deze files moeten dan worden verplaatst naar ./allskyBinning/2023.01/ etcetera
# 1. Check eerst of de directory bestaat: zo ja, doe niks, zo nee, maak 'm aan
# 2. Dan kunnen de files worden verplaatst
# bv mv ./home/ism/Seeing_Monitor/FTP/allskyBinning/2023.01/* ./allskyBinning/2023.01/

# loop over all files in ls_tarfiles.txt
while IFS= read -r line; do
    echo "Text read from file: $line"
    dirname=${line%%_*}"/"$1"."$2
    echo $dirname
    # Create dirname if it does not exist
    if [ ! -d "$dirname" ]; then
       # Control will enter here if $dirname doesn't exist.
       mkdir $dirname > /dev/null
       echo "creating: "$dirname
    else
       echo "directory exists: "$dirname 
    fi
    echo "moving data from ./home/ism/Seeing_Monitor/FTP/"$dirname" to "$dirname/  
    mv ./home/ism/Seeing_Monitor/FTP/$dirname/* $dirname/
done < ls_tarfiles.txt

echo ""
echo "Finished unzipping, unpacking and moving files in "$ZIPFILE
