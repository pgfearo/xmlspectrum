#!/bin/bash

# syntax-highlight and color source code file for:
# xslt xquery xpath xsd schematron xproc
#
# requires Saxon XSLT 2.0 processor from http://saxonica.com (replace SAXONJAR below)

SAXONJAR=$SAXON_HOME_JAR
# entry point is basic-wrap.xsl
XMLENTRY=$(dirname $0)/../xsl/basic-wrap.xsl

# this script resolves relative paths in the sourcepath based on the current directory
# that the script is called from - not necessarily the script path

# first arg must be the source file path
# run script with no args to get full usage (returned by highllight-file.xsl)

if [[ $# -eq 0 ]]
    then
    echo "no source file name"
elif [[ $1 == '-?' ]]
    then
    :
elif [[ $1 == /* ]]
    then
    relpath=$1
else
    tmppath=$(pwd)/$1
    filename=$(basename $1)
    dirpath=$(dirname $tmppath)
    relpath="$(cd "$dirpath" && pwd)/$filename"
fi

if [[ $# -eq 0 || $1 == '-?' ]]
    then
        echo "XSLT runner - using $XMLENTRY"
        echo ""
        echo "Usage:"
        echo "basic.sh source_file_path [params]"
        echo "params: param=value"
    elif [ -f "$relpath" ]
    then
        newpath=$(dirname $relpath)/xms-out
        newfilepath=$newpath/$filename
        java -jar $SAXONJAR -xsl:$XMLENTRY -t -s:$relpath -o:$newfilepath $2 $3 $4 $5 $6 $7 $8 $9 &>javalog.log
        echo "---- Saxon log ---------"
        cat javalog.log
        echo "---- Saxon log ends ----"
        echo "output written to: $newfilepath"
        #cat $newfilepath
        xmlspec.sh $newfilepath force-newline=yes indent=2 auto-trim=yes color-theme=tomorrow-night &>xmlspec.log
        cat xmlspec.log
    else
        echo "file not found: $relpath"
fi