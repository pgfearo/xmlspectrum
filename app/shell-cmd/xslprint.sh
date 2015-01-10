#!/bin/bash

# syntax-highlight and color source code files for
# xslt produces also an index html page with hyperlinks
# for global templates, functions and params/variables
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
        echo "XMLSpectrum: code higlighter and formatter"
        echo ""
        echo "Usage:"
        echo "xslprint.sh source_file_path [params]"
        echo "params: param=value"
        java -jar $SAXONJAR -xsl:$XMLSPECTRUM -it:main sourcepath=?
    elif [ -f $relpath ]
    then
        newpath=$(dirname $relpath)/xmsxsl-out
        java -jar $SAXONJAR -xsl:$XMLSPECTRUM -it:main sourcepath=$relpath output-path=$newpath link-names=yes $2 $3 $4 $5 $6 $7 $8 $9
        newfilepath=$newpath/index.html
        open $newfilepath
        echo "-----------------------------"
        echo "module toc output to $newfilepath"
    else
        echo "file not found: $relpath"
fi