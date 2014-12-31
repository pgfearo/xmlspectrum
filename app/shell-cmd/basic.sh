#!/bin/bash

# syntax-highlight and color source code file for:
# xslt xquery xpath xsd schematron xproc
#
# requires Saxon XSLT 2.0 processor from http://saxonica.com (replace SAXONJAR below)

SAXONJAR="/Users/philipfearon/Applications/SaxonHE9-6-0-2J/saxon9he.jar"
# entry point is XMLSpectrum's highlight-file xsl stylesheet:
XMLSPECTRUM=$(dirname $0)/../xsl/basic-wrap.xsl

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
        echo "XMLSpectrum: code higlighter and formatter"
        echo ""
        echo "Usage:"
        echo "xmlspec.sh source_file_path [params]"
        echo "params: param=value"
        java -jar $SAXONJAR -xsl:$XMLSPECTRUM -it:main sourcepath=?
    elif [ -f "$relpath" ]
    then
        newpath=$(dirname $relpath)/xms-out
        newfilepath=$newpath/$filename
        java -jar $SAXONJAR -xsl:$XMLSPECTRUM -s:$relpath -o:$newfilepath $2 $3 $4 $5 $6 $7 $8 $9
        #cat $newfilepath
        xmlspec.sh $newfilepath force-newline=yes indent=2 color-theme=tomorrow-night
        echo ""
        echo "---------------------------"
        echo "output file is at: $newfilepath"
    else
        echo "file not found: $relpath"
fi