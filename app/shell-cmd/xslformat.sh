#!/bin/bash

# produces xml text file with any formatting supplied
# as arguments: eg. indent, force-newline, auto-trim
# and format-mixed-content
#
# requires Saxon XSLT 2.0 processor (replace SAXONJAR below)

SAXONJAR=$SAXON_HOME_JAR
# entry point is XMLSpectrum's highlight-file xsl stylesheet:
XMLSPECTRUM=$(dirname $0)/../xsl/highlight-file.xsl

# first arg must be the source file path

if [[ $# -eq 0 ]]
    then
        echo "no source file name"
elif [[ $1 == '-?' ]]
    then
        :
elif [[ $1 == /* ]]
    then
    relpath=$1
    filename=$(basename $1)
else
    tmppath=$(pwd)/$1
    filename=$(basename $1)
    dirpath=$(dirname $tmppath)
    relpath="$(cd "$dirpath" && pwd)/$filename"
fi

if [[ $# -eq 0 || $1 == '-?' ]]
    then
        echo "XMLSpectrum: xml formatter script"
        echo ""
        echo "Usage:"
        echo "xslformat.sh source_file_path [params]"
        echo "params: param=value"
        java -jar $SAXONJAR -xsl:$XMLSPECTRUM -it:main sourcepath=?
    elif [ -f $relpath ]
    then
        newpath=$(dirname $relpath)/xmsxsl-out
        java -jar $SAXONJAR -xsl:$XMLSPECTRUM -it:main sourcepath=$relpath output-path=$newpath output-method=text $2 $3 $4 $5 $6 $7 $8 $9
        newfilepath=$newpath/$filename.text
        cat $newfilepath
        echo "---------------------------"
        echo "output file is at: $newfilepath"
    else
        echo "file not found: $relpath"
fi