#!/bin/bash

# --- Command Line Argument --- #
SCRIPTNAME=$(basename $0)
INPUTDIR=$1
OUTDIR=$2

# --- Color --- #
RED="\e[31m"
GREEN="\e[32m"
BLUE="\e[34m"
RESET="\e[0m"

# --- Displaye a colorful usage ---#
function usage(){
    echo -e "$GREEN [!] Description: $RESET $SCRIPTNAME: A script to create a photo album from a set of photos taken by a digital camera or a smartphone $GREEN [!] $RESET"
    echo -e "$GREEN [?] Usage: $RESET $SCRIPTNAME <Input Directory> <Output Directory> $GREEN [!] $RESET"
}


# --- Check if the user supply nessecary argument ---#
# --- If no display the usage  ---#
if [ $# -lt 2 ];then
	usage
	exit 1
fi

# --- If Input Directory doesn't exist then stop and exit from the script --- #
if [ ! -d $INPUTDIR ];then
    echo -e "$RED [-] $RESET No such directory $RED [-] $RESET"
    exit 1
fi


# --- Check if output dir already exist  --- #
# --- If no create it  --- #
if [ ! -d $OUTDIR ];then
    mkdir $OUTDIR
fi


for image in $(ls $INPUTDIR);do

        idate=$(exif $INPUTDIR/$image | grep "Date and Time  " | cut -d "|" -f2)
        idate=${idate:0:10}
        iyear=${idate:0:4}
        imonth=${idate:5:2}
        iday=${idate:8:2}

        # --- Transform 2021:08:26 to 2021_08_26 --- #
        # --- And save it into a variable directory date--- #
        dirdate=$(echo $idate | tr ":" "_")

        if [ ! -d $OUTDIR/$iyear ];then
            mkdir $OUTDIR/$iyear
        fi

        destdir=$OUTDIR/$iyear/$dirdate

        if [ ! -d $destdir ];then
            mkdir $destdir
            mkdir $destdir/.thumbs
        fi

        mv $INPUTDIR/$image $destdir/${dirdate}-$image
        
        convert -thumbnail x150 $destdir/${dirdate}-$image $destdir/.thumbs/${dirdate}-${image%.*}-thumb.jpg
done

# --- A variable used to declare  --- #
yeartag=""

for year in $(ls $OUTDIR);do
    if [ $year != "index.html" ];then
        yeartag=$yeartag"\n<h1 style=\"display: inline; padding: 20px; text-align: center; background-color: rgb(200, 200, 200);\"><a style = \"text-decoration: none; color: #fff;\" href=\"$year/index.html\" >$year</a></h1>\n"
    fi
done

html="<!DOCTYPE html>\n<html>\n<head>\n<title>album</title>\n<meta charset=\"utf-8\"/>\n</head>\n<body>$yeartag</body>\n</html>"

echo -e $html > $OUTDIR/index.html



for year in $(ls $OUTDIR);do

    datetag=""
    if [ $year != "index.html" ]
    then
    for date in $(ls $OUTDIR/$year | tr "_" " " | sort -n | tr " " "_")
    do
         if [ $date != "index.html" ]
         then
         datetag=$datetag"<h1 style=\"background-color: rgb(200, 200, 200); color: #fff; max-width: 200px; padding: 10px;\">$date</h1>"
         thumbnailtag=""
         for thumbnail in $(ls $OUTDIR/$year/$date/.thumbs)
         do
            thumbnailtag=$thumbnailtag"<a href=\"$date/${thumbnail%-*}.jpg\"><img style=\"padding: 10px\" src=\"$date/.thumbs/$thumbnail\" /></a>"
         done
         datetag=$datetag$thumbnailtag
         fi
    done
    
    html="<!DOCTYPE html>\n<html>\n<head>\n<title>album</title>\n<meta charset=\"utf-8\"/>\n</head>\n<body>$datetag</body>\n</html>"
    echo -e $html > $OUTDIR/$year/index.html
    
    fi
done

