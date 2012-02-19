#! /bin/sh

PATH=..:/bin:/usr/bin

# Regression tests for the template library
# Usage: ./test.sh [ -r ]
# The -r option causes the script to edit itself and renumber
# the tests in case any are added or removed.

# renumber the tests in this script

renumber() {
    cp $0 $0.old &&
    awk '/^TEST=[0-9].* ######/ {
        printf("TEST=%d  ########################################\n", ++i);
        next }
        { print }' $0.old > $0 &&
    /bin/rm $0.old
    exit
}

check () {
    if diff -c expected result; then
        echo "Test $TEST success"
    else
        echo "Test $TEST failure"
    fi
}

test "X$1" = X-r && renumber

TEST=1  ########################################

# Testing null input

cp /dev/null tmplfile

cp tmplfile expected

template tmplfile > result 2>&1

check

TEST=2  ########################################

# Testing one char input

printf X > tmplfile

cp tmplfile expected

template tmplfile > result 2>&1

check

TEST=3  ########################################

# Testing input with no tags

cat << "EOF" > tmplfile
Now is the time
for all good men
to come to the aid
of their country
EOF

cp tmplfile expected

template tmplfile var testvalue > result 2>&1

check

TEST=4  ########################################

# Testing tags with malformed attributes, which we consider ordinary text

cat << "EOF" > tmplfile

Testing a single bad attribute

{{LOOP name}}
{{LOOP name }}
{{LOOP =}}
{{LOOP = }}
{{LOOP "var"}}
{{LOOP "var" }}
{{LOOP name=}}
{{LOOP name = }}
{{LOOP ="var"}}
{{LOOP = "var" }}
{{LOOP name=*}}      * needs quotes
{{LOOP name = * }}   * needs quotes
{{LOOP name="var}}
{{LOOP name = "var }}
{{LOOP name='var}}
{{LOOP name = 'var }}
{{LOOP name=var"}}
{{LOOP name = var" }}
{{LOOP name=var'}}
{{LOOP name = var' }}
{{LOOP name="var'}}
{{LOOP name = "var' }}
{{LOOP name='var"}}
{{LOOP name = 'var" }}

{{!--LOOP name--}}
{{!-- LOOP name --}}
{{!--LOOP =--}}
{{!-- LOOP = --}}
{{!--LOOP "var"--}}
{{!-- LOOP "var" --}}
{{!--LOOP name=--}}
{{!-- LOOP name = --}}
{{!--LOOP ="var"--}}
{{!-- LOOP = "var" --}}
{{!--LOOP name=*--}}      * needs quotes
{{!-- LOOP name = * --}}   * needs quotes
{{!--LOOP name="var--}}
{{!-- LOOP name = "var --}}
{{!--LOOP name='var--}}
{{!-- LOOP name = 'var --}}
{{!--LOOP name=var"--}}
{{!-- LOOP name = var" --}}
{{!--LOOP name=var'--}}
{{!-- LOOP name = var' --}}
{{!--LOOP name="var'--}}
{{!-- LOOP name = "var' --}}
{{!--LOOP name='var"--}}
{{!-- LOOP name = 'var" --}}

Testing good attribute followed by bad

{{VAR default="value"name}}
{{VAR default = "value" name }}
{{VAR default="value"=}}
{{VAR default = "value" = }}
{{VAR default="value""var"}}
{{VAR default = "value" "var" }}
{{VAR default="value"name=}}
{{VAR default = "value" name = }}
{{VAR default="value"="var"}}
{{VAR default = "value" = "var" }}
{{VAR default="value"name=*}}         * needs quotes
{{VAR default = "value" name = * }}   * needs quotes
{{VAR default="value"name="var}}
{{VAR default = "value" name = "var }}
{{VAR default="value"name='var}}
{{VAR default = "value" name = 'var }}
{{VAR default="value"name=var"}}
{{VAR default = "value" name = var" }}
{{VAR default="value"name=var'}}
{{VAR default = "value" name = var' }}
{{VAR default="value"name="var'}}
{{VAR default = "value" name = "var' }}
{{VAR default="value"name='var"}}
{{VAR default = "value" name = 'var" }}

{{VAR default="value"name/}}
{{VAR default = "value" name /}}
{{VAR default="value"=/}}
{{VAR default = "value" = /}}
{{VAR default="value""var"/}}
{{VAR default = "value" "var" /}}
{{VAR default="value"name=/}}
{{VAR default = "value" name = /}}
{{VAR default="value"="var"/}}
{{VAR default = "value" = "var" /}}
{{VAR default="value"name=*/}}         * needs quotes
{{VAR default = "value" name = * /}}   * needs quotes
{{VAR default="value"name="var/}}
{{VAR default = "value" name = "var /}}
{{VAR default="value"name='var/}}
{{VAR default = "value" name = 'var /}}
{{VAR default="value"name=var"/}}
{{VAR default = "value" name = var" /}}
{{VAR default="value"name=var'/}}
{{VAR default = "value" name = var' /}}
{{VAR default="value"name="var'/}}
{{VAR default = "value" name = "var' /}}
{{VAR default="value"name='var"/}}
{{VAR default = "value" name = 'var" /}}

{{!--VAR default="value"name--}}
{{!-- VAR default = "value" name --}}
{{!--VAR default="value"=--}}
{{!-- VAR default = "value" = --}}
{{!--VAR default="value""var"--}}
{{!-- VAR default = "value" "var" --}}
{{!--VAR default="value"name=--}}
{{!-- VAR default = "value" name = --}}
{{!--VAR default="value"="var"--}}
{{!-- VAR default = "value" = "var" --}}
{{!--VAR default="value"name=*--}}         * needs quotes
{{!-- VAR default = "value" name = * --}}   * needs quotes
{{!--VAR default="value"name="var--}}
{{!-- VAR default = "value" name = "var --}}
{{!--VAR default="value"name='var--}}
{{!-- VAR default = "value" name = 'var --}}
{{!--VAR default="value"name=var"--}}
{{!-- VAR default = "value" name = var" --}}
{{!--VAR default="value"name=var'--}}
{{!-- VAR default = "value" name = var' --}}
{{!--VAR default="value"name="var'--}}
{{!-- VAR default = "value" name = "var' --}}
{{!--VAR default="value"name='var"--}}
{{!-- VAR default = "value" name = 'var" --}}

Testing bad attribute followed by good

{{VAR namedefault="value"}}
{{VAR name default = "value" }}
{{VAR =default="value"}}
{{VAR = default = "value" }}
{{VAR "var"default="value"}}
{{VAR "var" default = "value" }}
{{VAR name=default="value"}}
{{VAR name = default = "value" }}
{{VAR ="var"default="value"}}
{{VAR = "var" default = "value" }}
{{VAR name=*default="value"}}         * needs quotes
{{VAR name = * default = "value" }}   * needs quotes
{{VAR name="vardefault="value"}}
{{VAR name = "var default = "value" }}
{{VAR name='vardefault="value"}}
{{VAR name = 'var default = "value" }}
{{VAR name=var"default="value"}}
{{VAR name = var" default = "value" }}
{{VAR name=var'default="value"}}
{{VAR name = var' default = "value" }}
{{VAR name="var'default="value"}}
{{VAR name = "var' default = "value" }}
{{VAR name='var"default="value"}}
{{VAR name = 'var" default = "value" }}

{{VAR namedefault="value"/}}
{{VAR name default = "value" /}}
{{VAR =default="value"/}}
{{VAR = default = "value" /}}
{{VAR "var"default="value"/}}
{{VAR "var" default = "value" /}}
{{VAR name=default="value"/}}
{{VAR name = default = "value" /}}
{{VAR ="var"default="value"/}}
{{VAR = "var" default = "value" /}}
{{VAR name=*default="value"/}}         * needs quotes
{{VAR name = * default = "value" /}}   * needs quotes
{{VAR name="vardefault="value"/}}
{{VAR name = "var default = "value" /}}
{{VAR name='vardefault="value"/}}
{{VAR name = 'var default = "value" /}}
{{VAR name=var"default="value"/}}
{{VAR name = var" default = "value" /}}
{{VAR name=var'default="value"/}}
{{VAR name = var' default = "value" /}}
{{VAR name="var'default="value"/}}
{{VAR name = "var' default = "value" /}}
{{VAR name='var"default="value"/}}
{{VAR name = 'var" default = "value" /}}

{{!--VAR namedefault="value"--}}
{{!-- VAR name default = "value" --}}
{{!--VAR =default="value"--}}
{{!-- VAR = default = "value" --}}
{{!--VAR "var"default="value"--}}
{{!-- VAR "var" default = "value" --}}
{{!--VAR name=default="value"--}}
{{!-- VAR name = default = "value" --}}
{{!--VAR ="var"default="value"--}}
{{!-- VAR = "var" default = "value" --}}
{{!--VAR name=*default="value"--}}         * needs quotes
{{!-- VAR name = * default = "value" --}}   * needs quotes
{{!--VAR name="vardefault="value"--}}
{{!-- VAR name = "var default = "value" --}}
{{!--VAR name='vardefault="value"--}}
{{!-- VAR name = 'var default = "value" --}}
{{!--VAR name=var"default="value"--}}
{{!-- VAR name = var" default = "value" --}}
{{!--VAR name=var'default="value"--}}
{{!-- VAR name = var' default = "value" --}}
{{!--VAR name="var'default="value"--}}
{{!-- VAR name = "var' default = "value" --}}
{{!--VAR name='var"default="value"--}}
{{!-- VAR name = 'var" default = "value" --}}
EOF

cp tmplfile expected

template tmplfile > result 2> /dev/null

check

TEST=5  ########################################

# Testing tags with unsupported/missing/duplicated attribute names,
# which we consider ordinary text

cat << "EOF" > tmplfile
{{LOOP}}
{{LOOP }}
{{LOOP nam = "var"}}
{{LOOP namex = "var"}}
{{LOOP color = "red"}}
{{LOOP name = "var" name = "var"}}
{{LOOP name = "var" name = "var2"}}
{{LOOP name = "var" default = "value"}}
{{LOOP name = "var" fmt = "fmtname"}}
{{LOOP name = "var" value = "testvalue"}}

{{!--LOOP--}}
{{!-- LOOP --}}
{{!--LOOP nam = "var"--}}
{{!--LOOP namex = "var"--}}
{{!--LOOP color = "red"--}}
{{!--LOOP name = "var" name = "var"--}}
{{!--LOOP name = "var" name = "var2"--}}
{{!--LOOP name = "var" default = "value"--}}
{{!--LOOP name = "var" fmt = "fmtname"--}}
{{!--LOOP name = "var" value = "testvalue"--}}

{{INCLUDE}}
{{INCLUDE }}
{{INCLUDE nam = "var"}}
{{INCLUDE namex = "var"}}
{{INCLUDE color = "red"}}
{{INCLUDE name = "var" name = "var"}}
{{INCLUDE name = "var" name = "var2"}}
{{INCLUDE name = "var" default = "value"}}
{{INCLUDE name = "var" fmt = "fmtname"}}
{{INCLUDE name = "var" value = "testvalue"}}

{{INCLUDE/}}
{{INCLUDE /}}
{{INCLUDE nam = "var" /}}
{{INCLUDE namex = "var" /}}
{{INCLUDE color = "red" /}}
{{INCLUDE name = "var" name = "var"/}}
{{INCLUDE name = "var" name = "var2" /}}
{{INCLUDE name = "var" default = "value"/}}
{{INCLUDE name = "var" fmt = "fmtname" /}}
{{INCLUDE name = "var" value = "testvalue" /}}

{{!--INCLUDE--}}
{{!-- INCLUDE --}}
{{!--INCLUDE nam = "var"--}}
{{!--INCLUDE namex = "var"--}}
{{!--INCLUDE color = "red"--}}
{{!--INCLUDE name = "var" name = "var"--}}
{{!--INCLUDE name = "var" name = "var2"--}}
{{!--INCLUDE name = "var" default = "value"--}}
{{!--INCLUDE name = "var" fmt = "fmtname"--}}
{{!--INCLUDE name = "var" value = "testvalue"--}}

{{VAR}}
{{VAR }}
{{VAR nam = "var"}}
{{VAR namex = "var"}}
{{VAR color = "red"}}
{{VAR default = "value"}}
{{VAR fmt = "fmtname"}}
{{VAR default = "value" fmt = "fmtname"}}
{{VAR name = "var" value = "testvalue"}}
{{VAR name = "var" color = "red"}}
{{VAR name = "var" default = "value" fmt = "fmtname" name = "var"}}
{{VAR name = "var" default = "value" fmt = "fmtname" name = "xxx"}}
{{VAR default = "xxx" name = "var" default = "value" fmt = "fmtname"}}
{{VAR fmt = "xxx" name = "var" default = "value" fmt = "fmtname"}}

{{VAR/}}
{{VAR /}}
{{VAR nam = "var" /}}
{{VAR namex = "var" /}}
{{VAR color = "red" /}}
{{VAR default = "value" /}}
{{VAR fmt = "fmtname" /}}
{{VAR default = "value" fmt = "fmtname" /}}
{{VAR name = "var" value = "testvalue"/}}
{{VAR name = "var" color = "red" /}}
{{VAR name = "var" default = "value" fmt = "fmtname" name = "var" /}}
{{VAR name = "var" default = "value" fmt = "fmtname" name = "xxx"/}}
{{VAR default = "xxx" name = "var" default = "value" fmt = "fmtname" /}}
{{VAR fmt = "xxx" name = "var" default = "value" fmt = "fmtname"/}}

{{!--VAR--}}
{{!-- VAR --}}
{{!--VAR nam = "var"--}}
{{!--VAR namex = "var"--}}
{{!--VAR color = "red"--}}
{{!--VAR default = "value"--}}
{{!--VAR fmt = "fmtname"--}}
{{!--VAR default = "value" fmt = "fmtname"--}}
{{!--VAR name = "var" value = "testvalue"--}}
{{!--VAR name = "var" color = "red"--}}
{{!--VAR name = "var" default = "value" fmt = "fmtname" name = "var"--}}
{{!--VAR name = "var" default = "value" fmt = "fmtname" name = "xxx"--}}
{{!--VAR default = "xxx" name = "var" default = "value" fmt = "fmtname"--}}
{{!--VAR fmt = "xxx" name = "var" default = "value" fmt = "fmtname"--}}

{{IF}}
{{IF }}
{{IF nam = "var"}}
{{IF namex = "var"}}
{{IF color = "red"}}
{{IF value = "testvalue"}}
{{IF name = "var" default = "value"}}
{{IF name = "var" fmt = "fmtname"}}
{{IF name = "var" color = "red"}}
{{IF name = "var" value = "testvalue" name = "var"}}
{{IF name = "var" value = "testvalue" name = "xxx"}}
{{IF value = "xxx" name = "var" value = "testvalue"}}

{{!--IF--}}
{{!-- IF --}}
{{!--IF nam = "var"--}}
{{!--IF namex = "var"--}}
{{!--IF color = "red"--}}
{{!--IF value = "testvalue"--}}
{{!--IF name = "var" default = "value"--}}
{{!--IF name = "var" fmt = "fmtname"--}}
{{!--IF name = "var" color = "red"--}}
{{!--IF name = "var" value = "testvalue" name = "var"--}}
{{!--IF name = "var" value = "testvalue" name = "xxx"--}}
{{!--IF value = "xxx" name = "var" value = "testvalue"--}}

{{ELSIF}}
{{ELSIF }}
{{ELSIF nam = "var"}}
{{ELSIF namex = "var"}}
{{ELSIF color = "red"}}
{{ELSIF value = "testvalue"}}
{{ELSIF name = "var" default = "value"}}
{{ELSIF name = "var" fmt = "fmtname"}}
{{ELSIF name = "var" color = "red"}}
{{ELSIF name = "var" value = "testvalue" name = "var"}}
{{ELSIF name = "var" value = "testvalue" name = "xxx"}}
{{ELSIF value = "xxx" name = "var" value = "testvalue"}}

{{ELSIF/}}
{{ELSIF /}}
{{ELSIF nam = "var" /}}
{{ELSIF namex = "var" /}}
{{ELSIF color = "red" /}}
{{ELSIF value = "testvalue"/}}
{{ELSIF name = "var" default = "value"/}}
{{ELSIF name = "var" fmt = "fmtname" /}}
{{ELSIF name = "var" color = "red"/}}
{{ELSIF name = "var" value = "testvalue" name = "var" /}}
{{ELSIF name = "var" value = "testvalue" name = "xxx"/}}
{{ELSIF value = "xxx" name = "var" value = "testvalue" /}}

{{!--ELSIF--}}
{{!-- ELSIF --}}
{{!--ELSIF nam = "var"--}}
{{!--ELSIF namex = "var"--}}
{{!--ELSIF color = "red"--}}
{{!--ELSIF value = "testvalue"--}}
{{!--ELSIF name = "var" default = "value"--}}
{{!--ELSIF name = "var" fmt = "fmtname"--}}
{{!--ELSIF name = "var" color = "red"--}}
{{!--ELSIF name = "var" value = "testvalue" name = "var"--}}
{{!--ELSIF name = "var" value = "testvalue" name = "xxx"--}}
{{!--ELSIF value = "xxx" name = "var" value = "testvalue"--}}

{{ELSE name = "var"}}
{{ELSE color = "red"}}
{{ELSE name = "var" value = "testvalue"}}
{{ELSE name = "var" fmt = "fmtname"}}
{{ELSE name = "var" default = "value"}}

{{ELSE name = "var" /}}
{{ELSE color = "red"/}}
{{ELSE name = "var" value = "testvalue" /}}
{{ELSE name = "var" fmt = "fmtname"/}}
{{ELSE name = "var" default = "value" /}}

{{!--ELSE name = "var"--}}
{{!--ELSE color = "red"--}}
{{!--ELSE name = "var" value = "testvalue"--}}
{{!--ELSE name = "var" fmt = "fmtname"--}}
{{!--ELSE name = "var" default = "value"--}}

{{/IF name = "var"}}
{{/IF color = "red"}}
{{/IF name = "var" value = "testvalue"}}
{{/IF name = "var" fmt = "fmtname"}}
{{/IF name = "var" default = "value"}}

{{!--/IF name = "var"--}}
{{!--/IF color = "red"--}}
{{!--/IF name = "var" value = "testvalue"--}}
{{!--/IF name = "var" fmt = "fmtname"--}}
{{!--/IF name = "var" default = "value"--}}

{{/LOOP name = "var"}}
{{/LOOP color = "red"}}
{{/LOOP name = "var" value = "testvalue"}}
{{/LOOP name = "var" fmt = "fmtname"}}
{{/LOOP name = "var" default = "value"}}

{{!--/LOOP name = "var"--}}
{{!--/LOOP color = "red"--}}
{{!--/LOOP name = "var" value = "testvalue"--}}
{{!--/LOOP name = "var" fmt = "fmtname"--}}
{{!--/LOOP name = "var" default = "value"--}}

{{BREAK lev = 1}}
{{BREAK levelx = 1}}
{{BREAK color = "red"}}
{{BREAK value = "testvalue"}}
{{BREAK level = "1" default = "value"}}
{{BREAK level = "2" fmt = "fmtname"}}
{{BREAK level = 1 name = "var"}}
{{BREAK level = 1 color = "red"}}
{{BREAK level = 1 level = 1}}
{{BREAK name = "var" level = "1" }}

{{BREAK lev = 1/}}
{{BREAK levelx = 1/}}
{{BREAK color = "red"/}}
{{BREAK value = "testvalue"/}}
{{BREAK level = "1" default = "value"/}}
{{BREAK level = "2" fmt = "fmtname"/}}
{{BREAK level = 1 name = "var"/}}
{{BREAK level = 1 color = "red"/}}
{{BREAK level = 1 level = 1/}}
{{BREAK name = "var" level = "1" /}}

{{!-- BREAK lev = 1 --}}
{{!-- BREAK levelx = 1 --}}
{{!-- BREAK color = "red" --}}
{{!-- BREAK value = "testvalue" --}}
{{!-- BREAK level = "1" default = "value" --}}
{{!-- BREAK level = "2" fmt = "fmtname" --}}
{{!-- BREAK level = 1 name = "var" --}}
{{!-- BREAK level = 1 color = "red" --}}
{{!-- BREAK level = 1 level = 1 --}}
{{!-- BREAK name = "var" level = "1"  --}}

{{CONTINUE lev = 1}}
{{CONTINUE levelx = 1}}
{{CONTINUE color = "red"}}
{{CONTINUE value = "testvalue"}}
{{CONTINUE level = "1" default = "value"}}
{{CONTINUE level = "2" fmt = "fmtname"}}
{{CONTINUE level = 1 name = "var"}}
{{CONTINUE level = 1 color = "red"}}
{{CONTINUE level = 1 level = 1}}
{{CONTINUE name = "var" level = "1" }}

{{CONTINUE lev = 1/}}
{{CONTINUE levelx = 1/}}
{{CONTINUE color = "red"/}}
{{CONTINUE value = "testvalue"/}}
{{CONTINUE level = "1" default = "value"/}}
{{CONTINUE level = "2" fmt = "fmtname"/}}
{{CONTINUE level = 1 name = "var"/}}
{{CONTINUE level = 1 color = "red"/}}
{{CONTINUE level = 1 level = 1/}}
{{CONTINUE name = "var" level = "1" /}}

{{!-- CONTINUE lev = 1 --}}
{{!-- CONTINUE levelx = 1 --}}
{{!-- CONTINUE color = "red" --}}
{{!-- CONTINUE value = "testvalue" --}}
{{!-- CONTINUE level = "1" default = "value" --}}
{{!-- CONTINUE level = "2" fmt = "fmtname" --}}
{{!-- CONTINUE level = 1 name = "var" --}}
{{!-- CONTINUE level = 1 color = "red" --}}
{{!-- CONTINUE level = 1 level = 1 --}}
{{!-- CONTINUE name = "var" level = "1"  --}}

EOF

cp tmplfile expected

template tmplfile > result 2> /dev/null

check

TEST=6  ########################################

# Testing tags with illegal white space, which we consider ordinary text

cat << "EOF" > tmplfile

{{ VAR name = "var"}}
{{VARname = "var"}}
{{ VAR name = "var" /}}
{{VARname = "var"/}}
{{ VARname = "var"}}
{{ !--VAR name = "var"--}}
{{! --VAR name = "var"--}}
{{!- -VAR name = "var"--}}
{{!--VAR name = var--}}
{{!--VAR name = "var"- -}}
{{!--VAR name = "var"-- }}
{{!--VARname = "var"--}}
{{!-- VARname = "var"--}}

{{ INCLUDE name = "var"}}
{{INCLUDEname = "var"}}
{{ INCLUDE name = "var" /}}
{{INCLUDEname = "var"/}}
{{ !--INCLUDE name = "var"--}}
{{! --INCLUDE name = "var"--}}
{{!- -INCLUDE name = "var"--}}
{{!--INCLUDE name = "var"- -}}
{{!--INCLUDE name = "var"-- }}
{{ INCLUDEname = "var"}}
{{!--INCLUDEname = "var"--}}
{{!-- INCLUDEname = "var"--}}

{{ LOOP name = "var"}}
{{LOOPname = "var"}}
{{ LOOPname = "var"}}
{{ !--LOOP name = "var"--}}
{{! --LOOP name = "var"--}}
{{!- -LOOP name = "var"--}}
{{!--LOOP name = var--}}
{{!--LOOP name = "var"- -}}
{{!--LOOP name = "var"-- }}
{{!--LOOPname = "var"--}}
{{!-- LOOPname = "var"--}}

{{ IF name = "var"}}
{{IFname = "var"}}
{{ IFname = "var"}}
{{ !--IF name = "var"--}}
{{! --IF name = "var"--}}
{{!- -IF name = "var"--}}
{{!--IF name = var--}}
{{!--IF name = "var"- -}}
{{!--IF name = "var"-- }}
{{!--IFname = "var"--}}
{{!-- IFname = "var"--}}

{{ ELSIF name = "var"}}
{{ELSIFname = "var"}}
{{ ELSIFname = "var"}}
{{ ELSIF name = "var" /}}
{{ELSIFname = "var"/}}
{{ ELSIFname = "var" /}}
{{ !--ELSIF name = "var"--}}
{{! --ELSIF name = "var"--}}
{{!- -ELSIF name = "var"--}}
{{!--ELSIF name = var--}}
{{!--ELSIF name = "var"- -}}
{{!--ELSIF name = "var"-- }}
{{!--ELSIFname = "var"--}}
{{!-- ELSIFname = "var"--}}

{{ ELSE}}
{{ ELSE }}
{{ ELSE/}}
{{ ELSE /}}
{{ !--ELSE--}}
{{! --ELSE--}}
{{!- -ELSE--}}
{{!--ELSE- -}}
{{!--ELSE-- }}

{{ /IF}}
{{ /IF }}
{{/ IF}}
{{/ IF }}
{{ !--/IF--}}
{{! --/IF--}}
{{!- -/IF--}}
{{!--/IF- -}}
{{!--/IF-- }}
{{!--/ IF--}}
{{!-- / IF --}}

{{ /LOOP}}
{{ /LOOP }}
{{/ LOOP}}
{{/ LOOP }}
{{ !--/LOOP--}}
{{! --/LOOP--}}
{{!- -/LOOP--}}
{{!--/LOOP- -}}
{{!--/LOOP-- }}
{{!--/ LOOP--}}
{{!-- / LOOP --}}

{{ BREAK}}
{{ BREAK level=1}}
{{BREAKlevel=1}}
{{ BREAK /}}
{{ BREAK level=1/}}
{{BREAKlevel=1/}}
{{ !--BREAK --}}
{{ !--BREAK level=1 --}}
{{! --BREAK --}}
{{! --BREAK level = "1"--}}
{{!- -BREAK --}}
{{!- -BREAK level = 1 --}}
{{!--BREAK - -}}
{{!--BREAK level = "1"- -}}
{{!--BREAK-- }}
{{!--BREAK level = "1"-- }}
{{!--BREAK level=1--}}
{{!--BREAKlevel=1 --}}
{{!-- BREAKlevel=1 --}}

{{ CONTINUE}}
{{ CONTINUE level=1}}
{{CONTINUElevel=1}}
{{ CONTINUE /}}
{{ CONTINUE level=1/}}
{{CONTINUElevel=1/}}
{{ !--CONTINUE --}}
{{ !--CONTINUE level=1 --}}
{{! --CONTINUE --}}
{{! --CONTINUE level = "1"--}}
{{!- -CONTINUE --}}
{{!- -CONTINUE level = 1 --}}
{{!--CONTINUE - -}}
{{!--CONTINUE level = "1"- -}}
{{!--CONTINUE-- }}
{{!--CONTINUE level = "1"-- }}
{{!--CONTINUE level=1--}}
{{!--CONTINUElevel=1 --}}
{{!-- CONTINUElevel=1 --}}

EOF

cp tmplfile expected

template tmplfile > result 2> /dev/null

check

TEST=7  ########################################

# Testing tags with incorrect delimiters, which we consider ordinary text

cat << "EOF" > tmplfile

{{VAR name = "var"--}}
{{VAR name = "var" --}}
{{!--VAR name = "var"}}
{{!-- VAR name = "var" }}
{{!--VAR name = "var"/}}
{{!-- VAR name = "var" /}}

{{INCLUDE name = "var"--}}
{{INCLUDE name = "var" --}}
{{!--INCLUDE name = "var"}}
{{!-- INCLUDE name = "var" }}
{{!--INCLUDE name = "var"/}}
{{!-- INCLUDE name = "var" /}}

{{LOOP name = "var"/}}
{{LOOP name = "var" /}}
{{LOOP name = "var"--}}
{{LOOP name = "var" --}}
{{!--LOOP name = "var"}}
{{!-- LOOP name = "var" }}

{{IF name = "var"/}}
{{IF name = "var" /}}
{{IF name = "var"--}}
{{IF name = "var" --}}
{{!--IF name = "var"}}
{{!-- IF name = "var" }}

{{ELSIF name = "var"--}}
{{ELSIF name = "var" --}}
{{!--ELSIF name = "var"}}
{{!-- ELSIF name = "var" }}
{{!--ELSIF name = "var"/}}
{{!-- ELSIF name = "var" /}}

{{ELSE--}}
{{ELSE --}}
{{!--ELSE}}
{{!-- ELSE }}
{{!--ELSE/}}
{{!-- ELSE /}}

{{/IF/}}
{{/IF /}}
{{/IF--}}
{{/IF --}}
{{!--/IF}}
{{!-- /IF }}

{{/LOOP/}}
{{/LOOP /}}
{{/LOOP--}}
{{/LOOP --}}
{{!--/LOOP}}
{{!-- /LOOP }}

{{BREAK--}}
{{BREAK --}}
{{!--BREAK}}
{{!-- BREAK }}
{{!--BREAK/}}
{{!-- BREAK /}}
{{BREAK level="2"--}}
{{BREAK level="2" --}}
{{!--BREAK level=2}}
{{!-- BREAK level=2}}
{{!--BREAK level=2 /}}
{{!-- BREAK level=2 /}}

{{CONTINUE--}}
{{CONTINUE --}}
{{!--CONTINUE}}
{{!-- CONTINUE }}
{{!--CONTINUE/}}
{{!-- CONTINUE /}}
{{CONTINUE level="2"--}}
{{CONTINUE level="2" --}}
{{!--CONTINUE level=2}}
{{!-- CONTINUE level=2}}
{{!--CONTINUE level=2 /}}
{{!-- CONTINUE level=2 /}}
EOF

cp tmplfile expected

template tmplfile > result 2> /dev/null

check

TEST=8  ########################################

# Testing VAR tag with just "name =" attribute

cat << "EOF" > tmplfile

X{{VAR name="bogus"}}X
X{{VAR name ="bogus"}}X
X{{VAR name= "bogus"}}X
X{{VAR name="bogus" }}X
X{{VAR name = "bogus" }}X
X{{VAR     name      =      "bogus"    }}X
X{{VAR
  name
  =
  "bogus"
  }}X
X{{VAR name = "bogus"}}{{VAR name = "bogus"}}X
X{{vAr NaMe = "bogus"}}X

X{{VAR name="bogus"/}}X
X{{VAR name ="bogus"/}}X
X{{VAR name= "bogus"/}}X
X{{VAR name="bogus" /}}X
X{{VAR name = "bogus" /}}X
X{{VAR     name      =      "bogus"    /}}X
X{{VAR
  name
  =
  "bogus"
  /}}X
X{{VAR name = "bogus"/}}{{VAR name = "bogus"/}}X
X{{vAr NaMe = "bogus"/}}X

X{{!--VAR name="bogus"--}}X
X{{!-- VAR name="bogus"--}}X
X{{!--VAR name ="bogus"--}}X
X{{!--VAR name= "bogus"--}}X
X{{!--VAR name="bogus" --}}X
X{{!-- VAR name = "bogus" --}}X
X{{!--   VAR     name      =      "bogus"    --}}X
X{{!--
  VAR
  name
  =
  "bogus"
  --}}X
X{{!--VAR name = "bogus"--}}{{!--VAR name = "bogus"--}}X
X{{!--vAr NaMe = "bogus"--}}X

X{{VAR name="var"}}X
X{{VAR name ="var"}}X
X{{VAR name= "var"}}X
X{{VAR name="var" }}X
X{{VAR name = "var" }}X
X{{VAR     name      =      "var"    }}X
X{{VAR
  name
  =
  "var"
  }}X
X{{VAR name = "var"}}{{VAR name = "var"}}X
X{{vAr NaMe = "var"}}X

X{{VAR name="var"/}}X
X{{VAR name ="var"/}}X
X{{VAR name= "var"/}}X
X{{VAR name="var" /}}X
X{{VAR name = "var" /}}X
X{{VAR     name      =      "var"    /}}X
X{{VAR
  name
  =
  "var"
  /}}X
X{{VAR name = "var"/}}{{VAR name = "var"/}}X
X{{vAr NaMe = "var"/}}X

X{{!--VAR name="var"--}}X
X{{!-- VAR name="var"--}}X
X{{!--VAR name ="var"--}}X
X{{!--VAR name= "var"--}}X
X{{!--VAR name="var" --}}X
X{{!-- VAR name = "var" --}}X
X{{!--    VAR     name      =      "var"    --}}X
X{{!--
  VAR
  name
  =
  "var"
  --}}X
X{{!--VAR name = "var"--}}{{!--VAR name = "var"--}}X
X{{!--vAr NaMe = "var"--}}X

X{{VAR name = "var"}}{{VAR name = "bogus"}}X
X{{VAR name = "bogus"}}{{VAR name = "var"}}X

X{{VAR name =
  "This variable has an extremely long, but nevertheless legal, name"}}X

EOF

cat << "EOF" > expected

XX
XX
XX
XX
XX
XX
XX
XX
XX

XX
XX
XX
XX
XX
XX
XX
XX
XX

XX
XX
XX
XX
XX
XX
XX
XX
XX
XX

XtestvalueX
XtestvalueX
XtestvalueX
XtestvalueX
XtestvalueX
XtestvalueX
XtestvalueX
XtestvaluetestvalueX
XtestvalueX

XtestvalueX
XtestvalueX
XtestvalueX
XtestvalueX
XtestvalueX
XtestvalueX
XtestvalueX
XtestvaluetestvalueX
XtestvalueX

XtestvalueX
XtestvalueX
XtestvalueX
XtestvalueX
XtestvalueX
XtestvalueX
XtestvalueX
XtestvalueX
XtestvaluetestvalueX
XtestvalueX

XtestvalueX
XtestvalueX

Xvariable with long nameX

EOF

template tmplfile var testvalue \
  "This variable has an extremely long, but nevertheless legal, name" \
  "variable with long name" > result 2>&1

check

TEST=9  ########################################

# Testing var tag with "default=" attribute

cat << "EOF" > tmplfile

X{{VAR name="bogus"default="DEFAULT"}}X
X{{VAR name ="bogus"default="DEFAULT"}}X
X{{VAR name= "bogus"default="DEFAULT"}}X
X{{VAR name="bogus" default="DEFAULT"}}X
X{{VAR name="bogus"default ="DEFAULT"}}X
X{{VAR name="bogus"default= "DEFAULT"}}X
X{{VAR name="bogus"default="DEFAULT" }}X
X{{VAR   name   =   "bogus"   default   =   "DEFAULT"   }}X
X{{VAR
  name
  =
  "bogus"
  default
  =
  "DEFAULT"
  }}X
X{{VaR nAmE="bogus" DefAUlT="DEFAULT" /}}X
X{{VAR default="DEFAULT" name = "bogus"/}}X

X{{VAR name="bogus"default="DEFAULT"/}}X
X{{VAR name ="bogus"default="DEFAULT"/}}X
X{{VAR name= "bogus"default="DEFAULT"/}}X
X{{VAR name="bogus" default="DEFAULT"/}}X
X{{VAR name="bogus"default ="DEFAULT"/}}X
X{{VAR name="bogus"default= "DEFAULT"/}}X
X{{VAR name="bogus"default="DEFAULT" /}}X
X{{VAR   name   =   "bogus"   default   =   "DEFAULT"   /}}X
X{{VAR
  name
  =
  "bogus"
  default
  =
  "DEFAULT"
  /}}X
X{{VaR nAmE="bogus" DefAUlT="DEFAULT" /}}X
X{{VAR default="DEFAULT" name = "bogus"/}}X

X{{!--VAR name="bogus"default="DEFAULT"--}}X
X{{!-- VAR name="bogus"default="DEFAULT"--}}X
X{{!--VAR name ="bogus"default="DEFAULT"--}}X
X{{!--VAR name= "bogus"default="DEFAULT"--}}X
X{{!--VAR name="bogus" default="DEFAULT"--}}X
X{{!--VAR name="bogus"default ="DEFAULT"--}}X
X{{!--VAR name="bogus"default= "DEFAULT"--}}X
X{{!--VAR name="bogus"default="DEFAULT" --}}X
X{{!--  VAR   name   =   "bogus"   default   =   "DEFAULT"   --}}X
X{{!--
  VAR
  name
  =
  "bogus"
  default
  =
  "DEFAULT"
  --}}X
X{{!--VaR nAmE="bogus" DefAUlT="DEFAULT"--}}X
X{{!--VAR default="DEFAULT" name = "bogus"--}}X

X{{VAR name="var"default="DEFAULT"}}X
X{{VAR name ="var"default="DEFAULT"}}X
X{{VAR name= "var"default="DEFAULT"}}X
X{{VAR name="var" default="DEFAULT"}}X
X{{VAR name="var"default ="DEFAULT"}}X
X{{VAR name="var"default= "DEFAULT"}}X
X{{VAR name="var"default="DEFAULT" }}X
X{{VAR   name   =   "var"   default   =   "DEFAULT"   }}X
X{{VAR
  name
  =
  "var"
  default
  =
  "DEFAULT"
  }}X
X{{VaR nAmE="var" DefAUlT="DEFAULT"}}X
X{{VAR default="DEFAULT" name="var"}}X

X{{VAR name="var"default="DEFAULT"/}}X
X{{VAR name ="var"default="DEFAULT"/}}X
X{{VAR name= "var"default="DEFAULT"/}}X
X{{VAR name="var" default="DEFAULT"/}}X
X{{VAR name="var"default ="DEFAULT"/}}X
X{{VAR name="var"default= "DEFAULT"/}}X
X{{VAR name="var"default="DEFAULT" /}}X
X{{VAR   name   =   "var"   default   =   "DEFAULT"   /}}X
X{{VAR
  name
  =
  "var"
  default
  =
  "DEFAULT"
  /}}X
X{{VaR nAmE="var" DefAUlT="DEFAULT"/}}X
X{{VAR default="DEFAULT" name="var"/}}X

X{{!--VAR name="var"default="DEFAULT"--}}X
X{{!-- VAR name="var"default="DEFAULT"--}}X
X{{!--VAR name ="var"default="DEFAULT"--}}X
X{{!--VAR name= "var"default="DEFAULT"--}}X
X{{!--VAR name="var" default="DEFAULT"--}}X
X{{!--VAR name="var"default ="DEFAULT"--}}X
X{{!--VAR name="var"default= "DEFAULT"--}}X
X{{!--VAR name="var"default="DEFAULT" --}}X
X{{!--  VAR   name   =   "var"   default   =   "DEFAULT"   --}}X
X{{!--
  VAR
  name
  =
  "var"
  default
  =
  "DEFAULT"
  --}}X
X{{!--VaR nAmE="var" DefAUlT="DEFAULT"--}}X
X{{!--VAR default="DEFAULT" name="var"--}}X

EOF

cat << "EOF" > expected

XDEFAULTX
XDEFAULTX
XDEFAULTX
XDEFAULTX
XDEFAULTX
XDEFAULTX
XDEFAULTX
XDEFAULTX
XDEFAULTX
XDEFAULTX
XDEFAULTX

XDEFAULTX
XDEFAULTX
XDEFAULTX
XDEFAULTX
XDEFAULTX
XDEFAULTX
XDEFAULTX
XDEFAULTX
XDEFAULTX
XDEFAULTX
XDEFAULTX

XDEFAULTX
XDEFAULTX
XDEFAULTX
XDEFAULTX
XDEFAULTX
XDEFAULTX
XDEFAULTX
XDEFAULTX
XDEFAULTX
XDEFAULTX
XDEFAULTX
XDEFAULTX

XtestvalueX
XtestvalueX
XtestvalueX
XtestvalueX
XtestvalueX
XtestvalueX
XtestvalueX
XtestvalueX
XtestvalueX
XtestvalueX
XtestvalueX

XtestvalueX
XtestvalueX
XtestvalueX
XtestvalueX
XtestvalueX
XtestvalueX
XtestvalueX
XtestvalueX
XtestvalueX
XtestvalueX
XtestvalueX

XtestvalueX
XtestvalueX
XtestvalueX
XtestvalueX
XtestvalueX
XtestvalueX
XtestvalueX
XtestvalueX
XtestvalueX
XtestvalueX
XtestvalueX
XtestvalueX

EOF

template tmplfile var testvalue > result 2>&1

check

TEST=10  ########################################

# Testing var tag with "fmt=" attribute

cat << "EOF" > tmplfile

X{{VAR name="bogus"fmt="entity"}}X
X{{VAR name ="bogus"fmt="entity"}}X
X{{VAR name= "bogus"fmt="entity"}}X
X{{VAR name="bogus" fmt="entity"}}X
X{{VAR name="bogus"fmt ="entity"}}X
X{{VAR name="bogus"fmt= "entity"}}X
X{{VAR name="bogus"fmt="entity" }}X
X{{VAR   name   =   "bogus"   fmt   =   "entity"   }}X
X{{VAR
  name
  =
  "bogus"
  fmt
  =
  "entity"
  }}X
X{{VaR nAmE="bogus" fMt="entity" }}X
X{{VAR fmt="entity" name = "bogus"}}X

X{{VAR name="bogus"fmt="entity"/}}X
X{{VAR name ="bogus"fmt="entity"/}}X
X{{VAR name= "bogus"fmt="entity"/}}X
X{{VAR name="bogus" fmt="entity"/}}X
X{{VAR name="bogus"fmt ="entity"/}}X
X{{VAR name="bogus"fmt= "entity"/}}X
X{{VAR name="bogus"fmt="entity" /}}X
X{{VAR   name   =   "bogus"   fmt   =   "entity"   /}}X
X{{VAR
  name
  =
  "bogus"
  fmt
  =
  "entity"
  /}}X
X{{VaR nAmE="bogus" fMt="entity" /}}X
X{{VAR fmt="entity" name = "bogus"/}}X

X{{!--VAR name="bogus"fmt="entity"--}}X
X{{!-- VAR name="bogus"fmt="entity"--}}X
X{{!--VAR name ="bogus"fmt="entity"--}}X
X{{!--VAR name= "bogus"fmt="entity"--}}X
X{{!--VAR name="bogus" fmt="entity"--}}X
X{{!--VAR name="bogus"fmt ="entity"--}}X
X{{!--VAR name="bogus"fmt= "entity"--}}X
X{{!--VAR name="bogus"fmt="entity" --}}X
X{{!--  VAR   name   =   "bogus"   fmt   =   "entity"   --}}X
X{{!--
  VAR
  name
  =
  "bogus"
  fmt
  =
  "entity"
  --}}X
X{{!--VaR nAmE="bogus" FmT="entity"--}}X
X{{!--VAR fmt="entity" name = "bogus"--}}X

X{{VAR name="var"fmt="entity"}}X
X{{VAR name ="var"fmt="entity"}}X
X{{VAR name= "var"fmt="entity"}}X
X{{VAR name="var" fmt="entity"}}X
X{{VAR name="var"fmt ="entity"}}X
X{{VAR name="var"fmt= "entity"}}X
X{{VAR name="var"fmt="entity" }}X
X{{VAR   name   =   "var"   fmt   =   "entity"   }}X
X{{VAR
  name
  =
  "var"
  fmt
  =
  "entity"
  }}X
X{{VaR nAmE="var" fmT="entity"}}X
X{{VAR fmt="entity" name="var"}}X

X{{VAR name="var"fmt="entity"/}}X
X{{VAR name ="var"fmt="entity"/}}X
X{{VAR name= "var"fmt="entity"/}}X
X{{VAR name="var" fmt="entity"/}}X
X{{VAR name="var"fmt ="entity"/}}X
X{{VAR name="var"fmt= "entity"/}}X
X{{VAR name="var"fmt="entity" /}}X
X{{VAR   name   =   "var"   fmt   =   "entity"   /}}X
X{{VAR
  name
  =
  "var"
  fmt
  =
  "entity"
  /}}X
X{{VaR nAmE="var" fmT="entity"/}}X
X{{VAR fmt="entity" name="var"/}}X

X{{!--VAR name="var"fmt="entity"--}}X
X{{!-- VAR name="var"fmt="entity"--}}X
X{{!--VAR name ="var"fmt="entity"--}}X
X{{!--VAR name= "var"fmt="entity"--}}X
X{{!--VAR name="var" fmt="entity"--}}X
X{{!--VAR name="var"fmt ="entity"--}}X
X{{!--VAR name="var"fmt= "entity"--}}X
X{{!--VAR name="var"fmt="entity" --}}X
X{{!--  VAR   name   =   "var"   fmt   =   "entity"   --}}X
X{{!--
  VAR
  name
  =
  "var"
  fmt
  =
  "entity"
  --}}X
X{{!--VaR nAmE="var" fMt="entity"--}}X
X{{!--VAR fmt="entity" name="var"--}}X

EOF

cat << "EOF" > expected

XX
XX
XX
XX
XX
XX
XX
XX
XX
XX
XX

XX
XX
XX
XX
XX
XX
XX
XX
XX
XX
XX

XX
XX
XX
XX
XX
XX
XX
XX
XX
XX
XX
XX

X&lt;&quot;test&amp;value&quot;&gt;X
X&lt;&quot;test&amp;value&quot;&gt;X
X&lt;&quot;test&amp;value&quot;&gt;X
X&lt;&quot;test&amp;value&quot;&gt;X
X&lt;&quot;test&amp;value&quot;&gt;X
X&lt;&quot;test&amp;value&quot;&gt;X
X&lt;&quot;test&amp;value&quot;&gt;X
X&lt;&quot;test&amp;value&quot;&gt;X
X&lt;&quot;test&amp;value&quot;&gt;X
X&lt;&quot;test&amp;value&quot;&gt;X
X&lt;&quot;test&amp;value&quot;&gt;X

X&lt;&quot;test&amp;value&quot;&gt;X
X&lt;&quot;test&amp;value&quot;&gt;X
X&lt;&quot;test&amp;value&quot;&gt;X
X&lt;&quot;test&amp;value&quot;&gt;X
X&lt;&quot;test&amp;value&quot;&gt;X
X&lt;&quot;test&amp;value&quot;&gt;X
X&lt;&quot;test&amp;value&quot;&gt;X
X&lt;&quot;test&amp;value&quot;&gt;X
X&lt;&quot;test&amp;value&quot;&gt;X
X&lt;&quot;test&amp;value&quot;&gt;X
X&lt;&quot;test&amp;value&quot;&gt;X

X&lt;&quot;test&amp;value&quot;&gt;X
X&lt;&quot;test&amp;value&quot;&gt;X
X&lt;&quot;test&amp;value&quot;&gt;X
X&lt;&quot;test&amp;value&quot;&gt;X
X&lt;&quot;test&amp;value&quot;&gt;X
X&lt;&quot;test&amp;value&quot;&gt;X
X&lt;&quot;test&amp;value&quot;&gt;X
X&lt;&quot;test&amp;value&quot;&gt;X
X&lt;&quot;test&amp;value&quot;&gt;X
X&lt;&quot;test&amp;value&quot;&gt;X
X&lt;&quot;test&amp;value&quot;&gt;X
X&lt;&quot;test&amp;value&quot;&gt;X

EOF

template tmplfile var '<"test&value">' > result 2>&1

check

TEST=11  ########################################

# Testing VAR with "fmt =" and "default ="

cat << "EOF" > tmplfile

X{{VAR name="var" fmt="entity" default="<<DEFAULT>>"}}X
X{{VAR name="var" default="<<DEFAULT>>" fmt="entity"}}X
X{{VAR default="<<DEFAULT>>" name="var" fmt="entity"}}X
X{{VAR default="<<DEFAULT>>" fmt="entity" name="var"}}X
X{{VAR fmt="entity" name="var" default="<<DEFAULT>>"}}X
X{{VAR fmt="entity" default="<<DEFAULT>>" name="var"}}X

X{{VAR name="var" fmt="entity" default="<<DEFAULT>>"/}}X
X{{VAR name="var" default="<<DEFAULT>>" fmt="entity"/}}X
X{{VAR default="<<DEFAULT>>" name="var" fmt="entity"/}}X
X{{VAR default="<<DEFAULT>>" fmt="entity" name="var"/}}X
X{{VAR fmt="entity" name="var" default="<<DEFAULT>>"/}}X
X{{VAR fmt="entity" default="<<DEFAULT>>" name="var"/}}X

X{{!--VAR name="var" fmt="entity" default="<<DEFAULT>>"--}}X
X{{!--VAR name="var" default="<<DEFAULT>>" fmt="entity"--}}X
X{{!--VAR default="<<DEFAULT>>" name="var" fmt="entity"--}}X
X{{!--VAR default="<<DEFAULT>>" fmt="entity" name="var"--}}X
X{{!--VAR fmt="entity" name="var" default="<<DEFAULT>>"--}}X
X{{!--VAR fmt="entity" default="<<DEFAULT>>" name="var"--}}X

X{{VAR name="bogus" fmt="entity" default="<<DEFAULT>>"}}X
X{{VAR name="bogus" default="<<DEFAULT>>" fmt="entity"}}X
X{{VAR default="<<DEFAULT>>" name="bogus" fmt="entity"}}X
X{{VAR default="<<DEFAULT>>" fmt="entity" name="bogus"}}X
X{{VAR fmt="entity" name="bogus" default="<<DEFAULT>>"}}X
X{{VAR fmt="entity" default="<<DEFAULT>>" name="bogus"}}X

X{{VAR name="bogus" fmt="entity" default="<<DEFAULT>>"/}}X
X{{VAR name="bogus" default="<<DEFAULT>>" fmt="entity"/}}X
X{{VAR default="<<DEFAULT>>" name="bogus" fmt="entity"/}}X
X{{VAR default="<<DEFAULT>>" fmt="entity" name="bogus"/}}X
X{{VAR fmt="entity" name="bogus" default="<<DEFAULT>>"/}}X
X{{VAR fmt="entity" default="<<DEFAULT>>" name="bogus"/}}X

X{{!--VAR name="bogus" fmt="entity" default="<<DEFAULT>>"--}}X
X{{!--VAR name="bogus" default="<<DEFAULT>>" fmt="entity"--}}X
X{{!--VAR default="<<DEFAULT>>" name="bogus" fmt="entity"--}}X
X{{!--VAR default="<<DEFAULT>>" fmt="entity" name="bogus"--}}X
X{{!--VAR fmt="entity" name="bogus" default="<<DEFAULT>>"--}}X
X{{!--VAR fmt="entity" default="<<DEFAULT>>" name="bogus"--}}X

EOF

cat << "EOF" > expected

X&lt;&quot;test&amp;value&quot;&gt;X
X&lt;&quot;test&amp;value&quot;&gt;X
X&lt;&quot;test&amp;value&quot;&gt;X
X&lt;&quot;test&amp;value&quot;&gt;X
X&lt;&quot;test&amp;value&quot;&gt;X
X&lt;&quot;test&amp;value&quot;&gt;X

X&lt;&quot;test&amp;value&quot;&gt;X
X&lt;&quot;test&amp;value&quot;&gt;X
X&lt;&quot;test&amp;value&quot;&gt;X
X&lt;&quot;test&amp;value&quot;&gt;X
X&lt;&quot;test&amp;value&quot;&gt;X
X&lt;&quot;test&amp;value&quot;&gt;X

X&lt;&quot;test&amp;value&quot;&gt;X
X&lt;&quot;test&amp;value&quot;&gt;X
X&lt;&quot;test&amp;value&quot;&gt;X
X&lt;&quot;test&amp;value&quot;&gt;X
X&lt;&quot;test&amp;value&quot;&gt;X
X&lt;&quot;test&amp;value&quot;&gt;X

X&lt;&lt;DEFAULT&gt;&gt;X
X&lt;&lt;DEFAULT&gt;&gt;X
X&lt;&lt;DEFAULT&gt;&gt;X
X&lt;&lt;DEFAULT&gt;&gt;X
X&lt;&lt;DEFAULT&gt;&gt;X
X&lt;&lt;DEFAULT&gt;&gt;X

X&lt;&lt;DEFAULT&gt;&gt;X
X&lt;&lt;DEFAULT&gt;&gt;X
X&lt;&lt;DEFAULT&gt;&gt;X
X&lt;&lt;DEFAULT&gt;&gt;X
X&lt;&lt;DEFAULT&gt;&gt;X
X&lt;&lt;DEFAULT&gt;&gt;X

X&lt;&lt;DEFAULT&gt;&gt;X
X&lt;&lt;DEFAULT&gt;&gt;X
X&lt;&lt;DEFAULT&gt;&gt;X
X&lt;&lt;DEFAULT&gt;&gt;X
X&lt;&lt;DEFAULT&gt;&gt;X
X&lt;&lt;DEFAULT&gt;&gt;X

EOF

template tmplfile var '<"test&value">' > result 2>&1

check

TEST=12  ########################################

# Testing attribute quoting styles with VAR

cat << "EOF" > tmplfile

X{{VAR name="var" fmt="entity" default="DEFAULT"}}X
X{{VAR name='var' fmt='entity' default='DEFAULT'}}X
X{{VAR name=var   fmt=entity   default=DEFAULT}}X
X{{VAR name="var" fmt='entity' default=DEFAULT}}X
X{{VAR name=var   fmt="entity" default='DEFAULT'}}X

EOF

cat << "EOF" > expected

X&lt;&quot;test&amp;value&quot;&gt;X
X&lt;&quot;test&amp;value&quot;&gt;X
X&lt;&quot;test&amp;value&quot;&gt;X
X&lt;&quot;test&amp;value&quot;&gt;X
X&lt;&quot;test&amp;value&quot;&gt;X

EOF

template tmplfile var '<"test&value">' > result 2>&1

check

TEST=13  ########################################

# Testing VAR with undefined format function

cat << "EOF" > tmplfile

{{VAR name = "var" fmt="entity"}}
{{VAR name = "var" fmt="bogus1" /}}
{{VAR fmt="entity" name = "var"}}
{{VAR fmt="bogus2" name = "var"}}
{{!--



VAR



fmt="bogus3"



name="var"



--}}

EOF

cat << "EOF" > expected
Ignoring bad VAR tag (bad "fmt=" attribute) in file "tmplfile" line 3
Ignoring bad VAR tag (bad "fmt=" attribute) in file "tmplfile" line 5
Ignoring bad VAR tag (bad "fmt=" attribute) in file "tmplfile" line 10
EOF

template tmplfile var '<"test&value">' > /dev/null 2> result

check

TEST=14  ########################################

# Testing accepted LOOP tag syntax

cat << "EOF" > tmplfile

X{{LOOP name="loop"}}X{{/LOOP}}X
X{{LOOP name='loop'}}X{{/LOOP}}X
X{{LOOP name=loop}}X{{/LOOP}}X
X{{LOOP   name  =  "loop"  }}X{{/LOOP}}X
X{{LOOP

  name

  =

  "loop"

  }}X{{/LOOP}}X
X{{LoOp NaMe = "loop"}}X{{/LOOP}}X

X{{!--LOOP name="loop"--}}X{{/LOOP}}X
X{{!--LOOP name='loop'--}}X{{/LOOP}}X
X{{!--LOOP name=loop --}}X{{/LOOP}}X
X{{!--   LOOP   name  =  "loop"  --}}X{{/LOOP}}X
X{{!--

  LOOP

  name

  =

  "loop"

  --}}X{{/LOOP}}X
X{{!--LoOp NaMe = "loop"--}}X{{/LOOP}}X

EOF

cat << "EOF" > expected

XXX
XXX
XXX
XXX
XXX
XXX

XXX
XXX
XXX
XXX
XXX
XXX

EOF

template tmplfile loop { var testvalue } > result 2>&1

check

TEST=15  ########################################

# Testing accepted {{/LOOP}} tag syntax

cat << "EOF" > tmplfile

X{{LOOP name=loop}}X{{/LOOP}}X
X{{LOOP name=loop}}X{{/LOOP }}X
X{{LOOP name=loop}}X{{/LOOP   }}X
X{{LOOP name=loop}}X{{/LOOP

}}X
X{{LOOP name=loop}}X{{/LooP}}X

X{{LOOP name=loop}}X{{!--/LOOP--}}X
X{{LOOP name=loop}}X{{!-- /LOOP --}}X
X{{LOOP name=loop}}X{{!--   /LOOP   --}}X
X{{LOOP name=loop}}X{{!--


/LOOP

--}}X
X{{LOOP name=loop}}X{{!--/lOOp--}}X

EOF

cat << "EOF" > expected

XXX
XXX
XXX
XXX
XXX

XXX
XXX
XXX
XXX
XXX

EOF

template tmplfile loop { var testvalue } >result 2>&1

check

TEST=16  ########################################

# Testing accepted INCLUDE tag syntax

cp /dev/null inclfile1

cat << "EOF" > tmplfile

X{{INCLUDE name="inclfile1"}}X
X{{INCLUDE name='inclfile1'}}X
X{{INCLUDE name=inclfile1}}X
X{{INCLUDE   name  =  "inclfile1"  }}X
X{{INCLUDE

  name
  
  =

  "inclfile1"

  }}X
X{{InCluDe NAMe="inclfile1"}}X

X{{INCLUDE name="inclfile1"/}}X
X{{INCLUDE name='inclfile1'/}}X
X{{INCLUDE name=inclfile1/}}X
X{{INCLUDE   name  =  "inclfile1"  /}}X
X{{INCLUDE

  name
  
  =

  "inclfile1"

  /}}X
X{{InCluDe NAMe="inclfile1"/}}X

X{{!--INCLUDE name="inclfile1"--}}X
X{{!--INCLUDE name='inclfile1'--}}X
X{{!--INCLUDE name=inclfile1 --}}X
X{{!--INCLUDE   name  =  "inclfile1"  --}}X
X{{!--

  INCLUDE

  name

  =

  "inclfile1"

  --}}X
X{{!--InClUDe NaMe="inclfile1"--}}X

EOF

cat << "EOF" > expected

XX
XX
XX
XX
XX
XX

XX
XX
XX
XX
XX
XX

XX
XX
XX
XX
XX
XX

EOF

template tmplfile loop { var testvalue } >result 2>&1

check

TEST=17  ########################################

# Testing accepted IF tag syntax

cat << "EOF" > tmplfile

X{{IF name="var"}}X{{/IF}}X
X{{IF name='var'}}X{{/IF}}X
X{{IF name=var}}X{{/IF}}X
X{{IF   name  =  "var"  }}X{{/IF}}X
X{{IF

  name

  =

  "var"

  }}X{{/IF}}X
X{{if NaMe = "var"}}X{{/IF}}X

X{{!--IF name="var"--}}X{{/IF}}X
X{{!--IF name='var'--}}X{{/IF}}X
X{{!--IF name=var --}}X{{/IF}}X
X{{!--   IF   name  =  "var"  --}}X{{/IF}}X
X{{!--

  IF

  name

  =

  "var"

  --}}X{{/IF}}X
X{{!--iF NaMe = "var"--}}X{{/IF}}X

X{{IF name="var" value="testvalue"}}X{{/IF}}X
X{{IF name="var" value='testvalue'}}X{{/IF}}X
X{{IF name="var" value=testvalue}}X{{/IF}}X
X{{IF name=var value=testvalue}}X{{/IF}}X
X{{IF   name  =  "var"  value   =  "testvalue"  }}X{{/IF}}X
X{{IF

  name

  =

  "var"

  value

  =

  "testvalue"

  }}X{{/IF}}X
X{{if NaMe = "var" vAluE="testvalue"}}X{{/IF}}X
X{{IF value="testvalue" name="var"}}X{{/IF}}X

X{{!--IF name="var" value="testvalue"--}}X{{/IF}}X
X{{!--IF name="var" value='testvalue'--}}X{{/IF}}X
X{{!--IF name="var" value=testvalue --}}X{{/IF}}X
X{{!--IF name=var value=testvalue --}}X{{/IF}}X
X{{!--IF   name  =  "var"  value   =  "testvalue"   --}}X{{/IF}}X
X{{!--
  IF

  name

  =

  "var"

  value

  =

  "testvalue"

  --}}X{{/IF}}X
X{{!--if NaMe = "var" vAluE="testvalue"--}}X{{/IF}}X
X{{!--IF value="testvalue" name="var"--}}X{{/IF}}X

EOF

cat << "EOF" > expected

XXX
XXX
XXX
XXX
XXX
XXX

XXX
XXX
XXX
XXX
XXX
XXX

XXX
XXX
XXX
XXX
XXX
XXX
XXX
XXX

XXX
XXX
XXX
XXX
XXX
XXX
XXX
XXX

EOF

template tmplfile var testvalue >result 2>&1

check

TEST=18  ########################################

# Testing accepted ELSIF tag syntax

cat << "EOF" > tmplfile

X{{IF name=x}}X{{ELSIF name="var"}}X{{/IF}}X
X{{IF name=x}}X{{ELSIF name='var'}}X{{/IF}}X
X{{IF name=x}}X{{ELSIF name=var}}X{{/IF}}X
X{{IF name=x}}X{{ELSIF   name  =  "var"  }}X{{/IF}}X
X{{IF name=x}}X{{ELSIF

  name

  =

  "var"

  }}X{{/IF}}X
X{{IF name=x}}X{{ElSif NaMe = "var"}}X{{/IF}}X

X{{IF name=x}}X{{ELSIF name="var"/}}X{{/IF}}X
X{{IF name=x}}X{{ELSIF name='var'/}}X{{/IF}}X
X{{IF name=x}}X{{ELSIF name=var/}}X{{/IF}}X
X{{IF name=x}}X{{ELSIF   name  =  "var"  /}}X{{/IF}}X
X{{IF name=x}}X{{ELSIF

  name

  =

  "var"

  /}}X{{/IF}}X
X{{IF name=x}}X{{ElSif NaMe = "var"/}}X{{/IF}}X

X{{IF name=x}}X{{!--ELSIF name="var"--}}X{{/IF}}X
X{{IF name=x}}X{{!--ELSIF name='var'--}}X{{/IF}}X
X{{IF name=x}}X{{!--ELSIF name=var --}}X{{/IF}}X
X{{IF name=x}}X{{!--   ELSIF   name  =  "var"  --}}X{{/IF}}X
X{{IF name=x}}X{{!--

  ELSIF

  name

  =

  "var"

  --}}X{{/IF}}X
X{{IF name=x}}X{{!--eLSiF NaMe = "var"--}}X{{/IF}}X

X{{IF name=x}}X{{ELSIF name="var" value="testvalue"}}X{{/IF}}X
X{{IF name=x}}X{{ELSIF name="var" value='testvalue'}}X{{/IF}}X
X{{IF name=x}}X{{ELSIF name="var" value=testvalue}}X{{/IF}}X
X{{IF name=x}}X{{ELSIF name=var value=testvalue}}X{{/IF}}X
X{{IF name=x}}X{{ELSIF   name  =  "var"  value   =  "testvalue"  }}X{{/IF}}X
X{{IF name=x}}X{{ELSIF

  name

  =

  "var"

  value

  =

  "testvalue"

  }}X{{/IF}}X
X{{IF name=x}}X{{eLSif NaMe = "var" vAluE="testvalue"}}X{{/IF}}X
X{{IF name=x}}X{{ELSIF value="testvalue" name="var"}}X{{/IF}}X

X{{IF name=x}}X{{ELSIF name="var" value="testvalue"/}}X{{/IF}}X
X{{IF name=x}}X{{ELSIF name="var" value='testvalue'/}}X{{/IF}}X
X{{IF name=x}}X{{ELSIF name="var" value=testvalue/}}X{{/IF}}X
X{{IF name=x}}X{{ELSIF name=var value=testvalue/}}X{{/IF}}X
X{{IF name=x}}X{{ELSIF   name  =  "var"  value   =  "testvalue"  /}}X{{/IF}}X
X{{IF name=x}}X{{ELSIF

  name

  =

  "var"

  value

  =

  "testvalue"

  /}}X{{/IF}}X
X{{IF name=x}}X{{eLSif NaMe = "var" vAluE="testvalue"/}}X{{/IF}}X
X{{IF name=x}}X{{ELSIF value="testvalue" name="var"/}}X{{/IF}}X

X{{IF name=x}}X{{!--ELSIF name="var" value="testvalue"--}}X{{/IF}}X
X{{IF name=x}}X{{!--ELSIF name="var" value='testvalue'--}}X{{/IF}}X
X{{IF name=x}}X{{!--ELSIF name="var" value=testvalue --}}X{{/IF}}X
X{{IF name=x}}X{{!--ELSIF name=var value=testvalue --}}X{{/IF}}X
X{{IF name=x}}X{{!--ELSIF   name  =  "var"  value   =  "testvalue"   --}}X{{/IF}}X
X{{IF name=x}}X{{!--
  ELSIF

  name

  =

  "var"

  value

  =

  "testvalue"

  --}}X{{/IF}}X
X{{IF name=x}}X{{!--ElSif NaMe = "var" vAluE="testvalue"--}}X{{/IF}}X
X{{IF name=x}}X{{!--ELSIF value="testvalue" name="var"--}}X{{/IF}}X

EOF

cat << "EOF" > expected

XXX
XXX
XXX
XXX
XXX
XXX

XXX
XXX
XXX
XXX
XXX
XXX

XXX
XXX
XXX
XXX
XXX
XXX

XXX
XXX
XXX
XXX
XXX
XXX
XXX
XXX

XXX
XXX
XXX
XXX
XXX
XXX
XXX
XXX

XXX
XXX
XXX
XXX
XXX
XXX
XXX
XXX

EOF

template tmplfile var testvalue >result 2>&1

check

TEST=19  ########################################

# Testing accepted {{ELSE}} tag syntax

cat << "EOF" > tmplfile

X{{IF name=x}}X{{ELSE}}X{{/IF}}X
X{{IF name=x}}X{{ELSE }}X{{/IF}}X
X{{IF name=x}}X{{ELSE   }}X{{/IF}}X
X{{IF name=x}}X{{ELSE

}}X{{/IF}}X
X{{IF name=x}}X{{eLSe}}X{{/IF}}X

X{{IF name=x}}X{{ELSE/}}X{{/IF}}X
X{{IF name=x}}X{{ELSE /}}X{{/IF}}X
X{{IF name=x}}X{{ELSE   /}}X{{/IF}}X
X{{IF name=x}}X{{ELSE

/}}X{{/IF}}X
X{{IF name=x}}X{{eLSe/}}X{{/IF}}X

X{{IF name=x}}X{{!--ELSE--}}X{{/IF}}X
X{{IF name=x}}X{{!-- ELSE --}}X{{/IF}}X
X{{IF name=x}}X{{!--   ELSE   --}}X{{/IF}}X
X{{IF name=x}}X{{!--

ELSE

--}}X{{/IF}}X
X{{IF name=x}}X{{!--ElSe--}}X{{/IF}}X

EOF

cat << "EOF" > expected

XXX
XXX
XXX
XXX
XXX

XXX
XXX
XXX
XXX
XXX

XXX
XXX
XXX
XXX
XXX

EOF

template tmplfile var testvalue > result 2>&1

check

TEST=20  ########################################

# Testing accepted {{/IF}} tag syntax

cat << "EOF" > tmplfile

X{{IF name=var}}X{{/IF}}X
X{{IF name=var}}X{{/IF }}X
X{{IF name=var}}X{{/IF   }}X
X{{IF name=var}}X{{/IF

}}X
X{{IF name=var}}X{{/iF}}X

X{{IF name=var}}X{{!--/IF--}}X
X{{IF name=var}}X{{!-- /IF --}}X
X{{IF name=var}}X{{!--   /IF   --}}X
X{{IF name=var}}X{{!--

/IF

--}}X
X{{IF name=var}}X{{!--/If--}}X

EOF

cat << "EOF" > expected

XXX
XXX
XXX
XXX
XXX

XXX
XXX
XXX
XXX
XXX

EOF

template tmplfile var testvalue > result 2>&1

check

TEST=21  ########################################

# Testing setting variable multiple times

cat << "EOF" > tmplfile
var1 = {{var name = "var1"}}
var2 = {{var name = "var2"}}
EOF

cat << "EOF" > expected
var1 = value 4
var2 = value 3
EOF

template tmplfile var1 "value 1" var2 "value 2" var2 "value 3" \
  var1 "value 4" > result 2>&1

check

TEST=22  ########################################

# Testing comments

cat << "EOF" > tmplfile
{{*
 * Let's start
 * off with a
 * comment
 *}}Before comment{{*
  Inside comment
  {{VAR name = "var"}}
  {{/if}}
  {{/loop}}
*}}After comment{{*
another comment *}}
Before comment{{*
  testing three comments in a row
*}}{{*
  second comment
  here *}}{{* and a
  third comment
  here*}}After comment{{*

  And let's finish with a comment
*}}
EOF

cat << "EOF" > expected
Before commentAfter comment
Before commentAfter comment
EOF

template tmplfile var testvalue > result 2>&1

check

TEST=23  ########################################

# Testing nested comments, which do not work

cat << "EOF" > tmplfile
Before outer comment
{{*
  Begin outer comment
  {{VAR name = "var"}}
  Before inner comment
  {{* Inside inner comment *}}
  After inner comment
  End outer comment
*}}
After outer comment
EOF

cat << "EOF" > expected
Before outer comment

  After inner comment
  End outer comment
*}}
After outer comment
EOF

template tmplfile var testvalue > result 2>&1

check

TEST=24  ########################################

# Testing file inclusion

cat << "EOF" > inclfile1
Begin include file 1
{{var name = "var"}}
End include file 1
EOF

cat << "EOF" > inclfile2
Begin include file 2
Including file 1 from file 2
{{include name = "./inclfile1"}}
End include file 2
EOF

cat << "EOF" > tmplfile
Begin template
Including file 1
{{INCLUDE name="inclfile1"}}
Including file 2
{{INCLUDE name = "./inclfile2"}}
End template
EOF

cat << "EOF" > expected
Begin template
Including file 1
Begin include file 1
testvalue
End include file 1

Including file 2
Begin include file 2
Including file 1 from file 2
Begin include file 1
testvalue
End include file 1

End include file 2

End template
EOF

template tmplfile var testvalue > result 2>&1

check

TEST=25  ########################################

# Testing file inclusion with .../

cat << "EOF" > inclfile1
Begin include file 1
{{var name = "var"}}
End include file 1
EOF

cat << "EOF" > inclfile2
Begin include file 2
Including file 1 from file 2
{{include name = ".../inclfile1"}}
End include file 2
EOF

cat << "EOF" > tmplfile
Begin template
Including file 1
{{INCLUDE name=".../inclfile1"}}
Including file 2
{{INCLUDE name = ".../inclfile2"}}
End template
EOF

cat << "EOF" > expected
Begin template
Including file 1
Begin include file 1
testvalue
End include file 1

Including file 2
Begin include file 2
Including file 1 from file 2
Begin include file 1
testvalue
End include file 1

End include file 2

End template
Begin template
Including file 1
Begin include file 1
testvalue
End include file 1

Including file 2
Begin include file 2
Including file 1 from file 2
Begin include file 1
testvalue
End include file 1

End include file 2

End template
EOF

template `pwd`/tmplfile var testvalue > result 2>&1
template tmplfile var testvalue >> result 2>&1

check

TEST=26  ########################################

# Testing direct cyclic file inclusion

cat << "EOF" > tmplfile
Begin template
Including file 1
{{include name = "inclfile1" }}
End template
EOF

cat << "EOF" > inclfile1
Begin include file 1
Including file 1 from file 1
{{INCLUDE name="inclfile1"}}
End include file 1
EOF

cat << "EOF" > expected
Ignoring bad INCLUDE tag (check for include cycle) in file "inclfile1" line 3
EOF

template tmplfile var testvalue > /dev/null 2> result

check

TEST=27  ########################################

# Testing indirect cyclic file inclusion

cat << "EOF" > inclfile1
Begin include file 1
Including file 2 from file 1
{{include name = "inclfile2"}}
End include file 1
EOF

cat << "EOF" > inclfile2
Begin include file 2
Including file 1 from file 2
{{include name = "./inclfile1"}}
End include file 2
EOF

cat << "EOF" > tmplfile
Begin template
Including file 1
{{INCLUDE name="inclfile1"}}
End template
EOF

cat << "EOF" > expected
Ignoring bad INCLUDE tag (check for include cycle) in file "inclfile2" line 3
EOF

template tmplfile var testvalue > /dev/null 2> result

check

TEST=28  ########################################

# Testing include of nonexistent file

cat << "EOF" > tmplfile
Begin template
Including nonexistent file
{{include name = "non existent file"}}
End template
EOF

cat << "EOF" > expected
C Template library: failed to read template from file "non existent file"
EOF

template tmplfile var testvalue > /dev/null 2> result

check

TEST=29  ########################################

# Testing bypassing of bad include

cat << "EOF" > tmplfile
Begin template
{{if name = "bogus"}}
  Including nonexistent file
  {{include name = "non existent file"}}
{{/if}}
End template
EOF

cat << "EOF" > expected
Begin template

End template
EOF

template tmplfile var testvalue > result 2>&1

check

TEST=30  ########################################

# Testing \ escapes

cat << "EOF" > tmplfile
\
\
Begin template
This \ is ordinary
Ordinary \\ double
Ordinary \\\ triple
Here is a continued \
line.
At end of line we should have a single \\
At end of line we should have a double \\\
{{var name = "var"}}\
{{var name = "var"}}\
\
\
\
{{var name = "var"}}\
End template
\
\
\
EOF

cat << "EOF" > expected
Begin template
This \ is ordinary
Ordinary \\ double
Ordinary \\\ triple
Here is a continued line.
At end of line we should have a single \
At end of line we should have a double \\
testvaluetestvaluetestvalueEnd template
EOF

template tmplfile var testvalue > result 2>&1

check

TEST=31  ########################################

# Testing \ escapes resulting in null output

cat << "EOF" > tmplfile
\
\
\
{{var name = "bogus"}}{{*

Inside the comment

*}}\
\
\
EOF

cp /dev/null expected

template tmplfile var testvalue > result 2>&1

check

TEST=32  ########################################

# Testing input that results in no output

printf '{{*
  Inside the comment
  *}}{{var name = "bogus"}}' > tmplfile

cp /dev/null expected

template tmplfile var testvalue > result 2>&1

check

TEST=33  ########################################

# Testing if statement

cat << "EOF" > tmplfile

Testing simple if statement

X{{IF name = "var"}}TRUE{{/IF}}X
X{{IF name = "bogus"}}TRUE{{/IF}}X
X{{IF name = "null"}}TRUE{{/IF}}X
X{{if name = "var" value = ""}}TRUE{{/if}}X
X{{if name = "var" value = "wrong"}}TRUE{{/if}}X
X{{if name = "var" value = "testvalue"}}TRUE{{/if}}X
X{{if value = "testvalue" name = "var"}}TRUE{{/if}}X
X{{if name = "null" value = ""}}TRUE{{/if}}X
X{{if name = "null" value = "wrong"}}TRUE{{/if}}X
X{{if name = "bogus" value = ""}}TRUE{{/if}}X
X{{if name = "bogus" value = "wrong"}}TRUE{{/if}}X
X{{if name = "var"}}{{/if}}X
X{{if name = "bogus"}}{{/if}}X

Testing if with else clause

X{{IF name = "var"}}TRUE{{else}}FALSE{{/if}}X
X{{IF name = "bogus"}}TRUE{{else}}FALSE{{/if}}X
X{{IF name = "null"}}TRUE{{else}}FALSE{{/if}}X
X{{if name = "var" value = ""}}TRUE{{else}}FALSE{{/if}}X
X{{if name = "var" value = "wrong"}}TRUE{{else}}FALSE{{/if}}X
X{{if name = "var" value = "testvalue"}}TRUE{{else}}FALSE{{/if}}X
X{{if value = "testvalue" name = "var"}}TRUE{{else}}FALSE{{/if}}X
X{{if name = "null" value = ""}}TRUE{{else}}FALSE{{/if}}X
X{{if name = "null" value = "wrong"}}TRUE{{else}}FALSE{{/if}}X
X{{if name = "bogus" value = ""}}TRUE{{else}}FALSE{{/if}}X
X{{if name = "bogus" value = "wrong"}}TRUE{{else}}FALSE{{/if}}X
X{{if name = "var"}}{{else}}{{/if}}X
X{{if name = "bogus"}}{{else}}{{/if}}X

Testing if with elseif clauses

X{{IF name = "var"}}
  IF BRANCH
{{ELSIF name = "var" }}
  ELSIF BRANCH 1
{{ELSIF name = "var" value = "testvalue"}}
  ELSIF BRANCH 2
{{ELSE}}
  ELSE BRANCH
{{/IF}}X

X{{IF name = "bogus"}}
  IF BRANCH
{{ELSIF name = "var" }}
  ELSIF BRANCH 1
{{ELSIF name = "var" value = "testvalue"}}
  ELSIF BRANCH 2
{{ELSE}}
  ELSE BRANCH
{{/IF}}X

X{{IF name = "bogus"}}
  IF BRANCH
{{ELSIF name = "var" value = "wrong"}}
  ELSIF BRANCH 1
{{ELSIF value = "testvalue2" name = "var2"}}
  ELSIF BRANCH 2
{{ELSE}}
  ELSE BRANCH
{{/IF}}X

X{{IF name = "bogus"}}
  IF BRANCH
{{ELSIF name = "var" value = "wrong"}}
  ELSIF BRANCH 1
{{ELSIF name = "var2" value = ""}}
  ELSIF BRANCH 2
{{ELSE}}
  ELSE BRANCH
{{/IF}}X

X{{if name = "var"}}{{elsif name = "var2"}}{{else}}{{/if}}X

Testing nested simple if statements

X{{IF name = "var"}}
  Inside IF 1
  X{{IF name = "var2" value = "testvalue2"}}
    Inside IF 2
  {{/if}}X
{{/if}}X

X{{IF name = "bogus"}}
  Inside IF 1
  X{{IF name = "var2" value = "testvalue2"}}
    Inside IF 2
  {{/if}}X
{{/if}}X

Testing nested if with else clauses

X{{IF name = "bogus"}}
  Inside IF BRANCH 1
  X{{IF name = "var" value = "testvalue"}}
    Inside IF BRANCH 2
  {{/else}}
    Inside ELSE BRANCH 2
  {{/if}}X
{{else}}
  Inside ELSE BRANCH 1
  X{{if name = "bogus"}}
    Inside IF BRANCH 3
  {{else}}
    Inside ELSE BRANCH 3
  {{/if}}X
{{/if}}X

X{{IF name = "var"}}
  Inside IF BRANCH 1
  X{{IF name = "var" value = "wrong"}}
    Inside IF BRANCH 2
  {{else}}
    Inside ELSE BRANCH 2
  {{/if}}X
{{else}}
  Inside ELSE BRANCH 1
  X{{if name = "bogus"}}
    Inside IF BRANCH 3
  {{else}}
    Inside ELSE BRANCH 3
  {{/if}}X
{{/if}}X
EOF

cat << "EOF" > expected

Testing simple if statement

XTRUEX
XX
XX
XX
XX
XTRUEX
XTRUEX
XTRUEX
XX
XTRUEX
XX
XX
XX

Testing if with else clause

XTRUEX
XFALSEX
XFALSEX
XFALSEX
XFALSEX
XTRUEX
XTRUEX
XTRUEX
XFALSEX
XTRUEX
XFALSEX
XX
XX

Testing if with elseif clauses

X
  IF BRANCH
X

X
  ELSIF BRANCH 1
X

X
  ELSIF BRANCH 2
X

X
  ELSE BRANCH
X

XX

Testing nested simple if statements

X
  Inside IF 1
  X
    Inside IF 2
  X
X

XX

Testing nested if with else clauses

X
  Inside ELSE BRANCH 1
  X
    Inside ELSE BRANCH 3
  X
X

X
  Inside IF BRANCH 1
  X
    Inside ELSE BRANCH 2
  X
X
EOF

template tmplfile var testvalue var2 testvalue2 null "" > result 2>&1

check

TEST=34  ########################################

# Testing loop statement

cat << "EOF" > tmplfile
Begin template
var1 = {{var name = "var1"}}

X{{loop name = "loop1"}}{{/loop}}X
X{{loop name = "bogus"}}{{/loop}}X

X{{loop name = "loop1"}}
  var1 = {{var name = "var1"}}
  var2 = {{var name = "var2"}}
{{/loop}}X

X{{loop name = "bogus"}}
  var1 = {{var name = "var1"}}
  var2 = {{var name = "var2"}}
{{/loop}}X

X{{loop name = "var1"}}
  var1 = {{var name = "var1"}}
  var2 = {{var name = "var2"}}
{{/loop}}X

X{{loop name = "loop1"}}
  Begin outer loop
  var1 = {{var name = "var1"}}
  var2 = {{var name = "var2"}}
  X{{loop name = "loop1"}}
    Begin inner loop
    var1 = {{var name = "var1"}}
    var2 = {{var name = "var2"}}
    End inner loop
  {{/loop}}X
  End outer loop
{{/loop}}X
End template
EOF

cat << "EOF" > expected
Begin template
var1 = outervalue

XX
XX

X
  var1 = value1
  var2 = value2

  var1 = value3
  var2 = value4

  var1 = value5
  var2 = 

  var1 = outervalue
  var2 = value6
X

XX

XX

X
  Begin outer loop
  var1 = value1
  var2 = value2
  X
    Begin inner loop
    var1 = value1
    var2 = value2
    End inner loop
  
    Begin inner loop
    var1 = value3
    var2 = value4
    End inner loop
  
    Begin inner loop
    var1 = value5
    var2 = 
    End inner loop
  
    Begin inner loop
    var1 = outervalue
    var2 = value6
    End inner loop
  X
  End outer loop

  Begin outer loop
  var1 = value3
  var2 = value4
  X
    Begin inner loop
    var1 = value1
    var2 = value2
    End inner loop
  
    Begin inner loop
    var1 = value3
    var2 = value4
    End inner loop
  
    Begin inner loop
    var1 = value5
    var2 = 
    End inner loop
  
    Begin inner loop
    var1 = outervalue
    var2 = value6
    End inner loop
  X
  End outer loop

  Begin outer loop
  var1 = value5
  var2 = 
  X
    Begin inner loop
    var1 = value1
    var2 = value2
    End inner loop
  
    Begin inner loop
    var1 = value3
    var2 = value4
    End inner loop
  
    Begin inner loop
    var1 = value5
    var2 = 
    End inner loop
  
    Begin inner loop
    var1 = outervalue
    var2 = value6
    End inner loop
  X
  End outer loop

  Begin outer loop
  var1 = outervalue
  var2 = value6
  X
    Begin inner loop
    var1 = value1
    var2 = value2
    End inner loop
  
    Begin inner loop
    var1 = value3
    var2 = value4
    End inner loop
  
    Begin inner loop
    var1 = value5
    var2 = 
    End inner loop
  
    Begin inner loop
    var1 = outervalue
    var2 = value6
    End inner loop
  X
  End outer loop
X
End template
EOF

template tmplfile var1 outervalue \
  loop1 { var1 value1 var2 value2 } { var1 value3 var2 value4 } \
    { var1 value5 } { var2 value6 } > result 2>&1

check

TEST=35  ########################################

# Testing nested loop statements

cat << "EOF" > tmplfile
Begin template
var1 = {{var name = "var1"}}

X{{loop name = "outer"}}
  Begin outer loop
  var1 = {{var name = "var1"}}
  var2 = {{var name = "var2"}}
  X{{loop name = "inner"}}
    Begin inner loop
    var1 = {{var name = "var1"}}
    var2 = {{var name = "var2"}}
    var3 = {{var name = "var3"}}
    End inner loop
  {{/loop}}X
  End outer loop
{{/loop}}X
End template
EOF

cat << "EOF" > expected
Begin template
var1 = outervalue

X
  Begin outer loop
  var1 = val1
  var2 = val2
  X
    Begin inner loop
    var1 = val1
    var2 = val3
    var3 = val4
    End inner loop
  
    Begin inner loop
    var1 = val1
    var2 = val5
    var3 = val6
    End inner loop
  X
  End outer loop

  Begin outer loop
  var1 = val7
  var2 = val8
  X
    Begin inner loop
    var1 = val7
    var2 = val9
    var3 = val10
    End inner loop
  
    Begin inner loop
    var1 = val7
    var2 = val11
    var3 = val12
    End inner loop
  X
  End outer loop

  Begin outer loop
  var1 = val13
  var2 = val14
  X
    Begin inner loop
    var1 = val13
    var2 = val15
    var3 = val16
    End inner loop
  
    Begin inner loop
    var1 = val13
    var2 = val17
    var3 = val18
    End inner loop
  X
  End outer loop

  Begin outer loop
  var1 = val19
  var2 = 
  XX
  End outer loop
X
End template
EOF

template tmplfile var1 outervalue \
  outer \
    { \
      var1 val1 var2 val2 \
      inner \
        { var2 val3 var3 val4 } \
        { var2 val5 var3 val6 } \
    } \
    { \
      var1 val7 var2 val8 \
      inner \
        { var2 val9 var3 val10 } \
        { var2 val11 var3 val12 } \
    } \
    { \
      var1 val13 var2 val14 \
      inner \
        { var2 val15 var3 val16 } \
        { var2 val17 var3 val18 } \
    } \
    { \
      var1 val19 \
    } > result 2>&1

check

TEST=36  ########################################

# Testing include inside of loop

cat << "EOF" > inclfile1
Begin include file
var1 = {{var name = "var1"}}
var2 = {{var name = "var2"}}
End include file
EOF

cat << "EOF" > tmplfile
Begin template
{{loop name = "loop"}}
  Begin loop
  Including file 1
  {{include name = "inclfile1"}}
  End loop
{{/loop}}
End template
EOF

cat << "EOF" > expected
Begin template

  Begin loop
  Including file 1
  Begin include file
var1 = testvalue
var2 = value 1
End include file

  End loop

  Begin loop
  Including file 1
  Begin include file
var1 = testvalue
var2 = value 2
End include file

  End loop

  Begin loop
  Including file 1
  Begin include file
var1 = testvalue
var2 = value 3
End include file

  End loop

End template
EOF

template tmplfile var1 testvalue \
  loop { var2 "value 1" } { var2 "value 2" } { var2 "value 3" } \
  > result 2>&1

check

TEST=37  ########################################

# Testing if and loop nesting

cat << "EOF" > tmplfile

X{{if name = "var"}}{{loop name = "loop"}}{{/loop}}{{/if}}X
X{{if name = "bogus"}}{{loop name = "loop"}}{{/loop}}{{/if}}X
X{{loop name = "loop"}}{{if name = "var"}}{{/if}}{{/loop}}X
X{{loop name = "bogus"}}{{if name = "var"}}{{/if}}{{/loop}}X

X{{if name = "loop"}}
  Inside if 1
  {{loop name = "loop"}}
    Inside loop 1
    {{if name = "bogus"}}
      Inside if 2: bogus = {{var name = "bogus"}}
    {{/if}}
    {{if name = "var2"}}
      Inside if 3: var2 = {{var name = "var2"}}
    {{/if}}
  {{/loop}}
{{/if}}X
X{{if name = "bogus"}}
  Inside if 4
  {{loop name = "loop"}}
    Inside loop 2
    {{if name = "bogus"}}
      Inside if 5: bogus = {{var name = "bogus"}}
    {{/if}}
    {{if name = "var2"}}
      Inside if 6: var2 = {{var name = "var2"}}
    {{/if}}
  {{/loop}}
{{/if}}X
EOF

cat << "EOF" > expected

XX
XX
XX
XX

X
  Inside if 1
  
    Inside loop 1
    
    
      Inside if 3: var2 = value 1
    
  
    Inside loop 1
    
    
      Inside if 3: var2 = value 2
    
  
X
XX
EOF

template tmplfile var testvalue \
  loop { var2 "value 1" } { var2 "value 2" } > result 2>&1

check

TEST=38  ########################################

# Testing break and continue

cat << "EOF" > tmplfile
BEGIN
{{loop name=outer}}\
  BEGIN outer        (CONTINUE 3 comes here)
  o = {{var name=o}}
{{loop name=middle}}\
    BEGIN middle     (CONTINUE 2 comes here)
    m = {{var name=m}}
{{loop name=inner}}\
      BEGIN inner    (CONTINUE 1 comes here)
      i = {{var name=i}}
{{if name=i value=b1}}\
      BREAK 1
{{break}}{{/if}}\
{{if name=i value=b2}}\
      BREAK 2
{{break level=2}}{{/if}}\
{{if name=i value=b3}}\
      BREAK 3
{{break level=3}}{{/if}}\
{{if name=i value=c1}}\
      CONTINUE 1
{{continue}}{{/if}}\
{{if name=i value=c2}}\
      CONTINUE 2
{{continue level=2}}{{/if}}\
{{if name=i value=c3}}\
      CONTINUE 3
{{continue level=3}}{{/if}}\
      END inner
{{/loop}}\
    END middle       (BREAK 1 comes here)
{{/loop}}\
  END outer          (BREAK 2 comes here)
{{/loop}}\
END                  (BREAK 3 comes here)
EOF

cat << "EOF" > expected
BEGIN
  BEGIN outer        (CONTINUE 3 comes here)
  o = o1
    BEGIN middle     (CONTINUE 2 comes here)
    m = m1
      BEGIN inner    (CONTINUE 1 comes here)
      i = c1
      CONTINUE 1
      BEGIN inner    (CONTINUE 1 comes here)
      i = i1
      END inner
    END middle       (BREAK 1 comes here)
    BEGIN middle     (CONTINUE 2 comes here)
    m = m2
    END middle       (BREAK 1 comes here)
  END outer          (BREAK 2 comes here)
  BEGIN outer        (CONTINUE 3 comes here)
  o = o2
  END outer          (BREAK 2 comes here)
  BEGIN outer        (CONTINUE 3 comes here)
  o = o3
    BEGIN middle     (CONTINUE 2 comes here)
    m = m3
      BEGIN inner    (CONTINUE 1 comes here)
      i = b1
      BREAK 1
    END middle       (BREAK 1 comes here)
    BEGIN middle     (CONTINUE 2 comes here)
    m = m4
    END middle       (BREAK 1 comes here)
  END outer          (BREAK 2 comes here)
  BEGIN outer        (CONTINUE 3 comes here)
  o = o4
  END outer          (BREAK 2 comes here)
  BEGIN outer        (CONTINUE 3 comes here)
  o = o5
    BEGIN middle     (CONTINUE 2 comes here)
    m = m5
      BEGIN inner    (CONTINUE 1 comes here)
      i = c2
      CONTINUE 2
    BEGIN middle     (CONTINUE 2 comes here)
    m = m6
    END middle       (BREAK 1 comes here)
  END outer          (BREAK 2 comes here)
  BEGIN outer        (CONTINUE 3 comes here)
  o = o6
  END outer          (BREAK 2 comes here)
  BEGIN outer        (CONTINUE 3 comes here)
  o = o7
    BEGIN middle     (CONTINUE 2 comes here)
    m = m7
      BEGIN inner    (CONTINUE 1 comes here)
      i = b2
      BREAK 2
  END outer          (BREAK 2 comes here)
  BEGIN outer        (CONTINUE 3 comes here)
  o = o8
  END outer          (BREAK 2 comes here)
  BEGIN outer        (CONTINUE 3 comes here)
  o = o9
    BEGIN middle     (CONTINUE 2 comes here)
    m = m9
      BEGIN inner    (CONTINUE 1 comes here)
      i = c3
      CONTINUE 3
  BEGIN outer        (CONTINUE 3 comes here)
  o = o10
  END outer          (BREAK 2 comes here)
  BEGIN outer        (CONTINUE 3 comes here)
  o = o11
    BEGIN middle     (CONTINUE 2 comes here)
    m = m11
      BEGIN inner    (CONTINUE 1 comes here)
      i = b3
      BREAK 3
END                  (BREAK 3 comes here)
EOF

template tmplfile outer \
  { o o1 middle { m m1 inner { i c1 } { i i1 } } { m m2 } } \
  { o o2 } \
  { o o3 middle { m m3 inner { i b1 } { i i2 } } { m m4 } } \
  { o o4 } \
  { o o5 middle { m m5 inner { i c2 } { i i3 } } { m m6 } } \
  { o o6 } \
  { o o7 middle { m m7 inner { i b2 } { i i4 } } { m m8 } } \
  { o o8 } \
  { o o9 middle { m m9 inner { i c3 } { i i5 } } { m m10 } } \
  { o o10 } \
  { o o11 middle { m m11 inner { i b3 } { i i6 } } { m m12 } } \
  { o o12 } \
  { o o13 } > result 2>&1

check

TEST=39  ########################################

# Testing missing statement terminators

cat << "EOF" > tmplfile
{{if name = "var"}}
  Inside if 1
{{elsif name = "var"}}
  Inside elsif 1
{{else}}
  Inside else 1
{{loop name = "loop"}}
  Inside the loop statement
  {{*
{{/loop}} *}}{{* this
comment is not terminated
EOF

cat << "EOF" > expected
"{{*" in file "tmplfile" line 10 has no "*}}"
LOOP tag in file "tmplfile" line 7 has no /LOOP tag
IF tag in file "tmplfile" line 1 has no /IF tag
EOF

template tmplfile var testvalue > /dev/null 2> result

check

TEST=40  ########################################

# Testing missing statement terminators

cat << "EOF" > tmplfile
{{if name = "var"}}
  Inside if 1
  {{loop name = "loop"}}
    Inside loop 1
{{/if}}
{{loop name = "loop"}}
  Inside loop 2
  {{if name = "var"}}
    Inside if 2
{{/loop}}
EOF

cat << "EOF" > expected
LOOP tag in file "tmplfile" line 3 has no /LOOP tag
IF tag in file "tmplfile" line 8 has no /IF tag
EOF

template tmplfile var testvalue > /dev/null 2> result

check

TEST=41  ########################################

# Testing extraneous and misplaced tags

cat << "EOF" > tmplfile
{{if name = "var"}}
  Inside if 1
{{else}}
  Inside else 1
{{elsif name = "var"}}
  Inside misplaced elsif
{{/if}}

{{if name = "var"}}
  Inside if 2
{{elsif name = "var"}}
  Inside elsif 2
{{else}}
  Inside else 2
{{else}}
  Inside misplaced else
{{/if}}

{{elsif name = "var"}}
  Inside elsif 3
{{else}}
  Inside else 3
{{/if}}

{{/loop}}

{{break}}
{{break level=2 /}}
{{continue}}
{{continue level=2/}}

{{loop name="outer"}}
  {{break level = 0}}
  {{break level = 2}}
  {{break level = "non-numeric"}}
  {{continue level = 0}}
  {{continue level = 2}}
  {{continue level = "non-numeric"}}
  {{loop name="inner"}}
    {{break level = 3}}
    {{continue level = 3}}
  {{/loop}}
{{/loop}}

{{*
  Inside comment
*}}
more stuff
*}}
EOF

cat << "EOF" > expected
Unexpected ELSIF tag in file "tmplfile" line 5
Unexpected ELSE tag in file "tmplfile" line 15
Unexpected ELSIF tag in file "tmplfile" line 19
Unexpected ELSE tag in file "tmplfile" line 21
Unexpected /IF tag in file "tmplfile" line 23
Unexpected /LOOP tag in file "tmplfile" line 25
Ignoring bad BREAK tag (not inside a loop) in file "tmplfile" line 27
Ignoring bad BREAK tag (not inside a loop) in file "tmplfile" line 28
Ignoring bad CONTINUE tag (not inside a loop) in file "tmplfile" line 29
Ignoring bad CONTINUE tag (not inside a loop) in file "tmplfile" line 30
Ignoring bad BREAK tag (bad "level=" attribute) in file "tmplfile" line 33
Ignoring bad BREAK tag (bad "level=" attribute) in file "tmplfile" line 34
Ignoring bad BREAK tag (bad "level=" attribute) in file "tmplfile" line 35
Ignoring bad CONTINUE tag (bad "level=" attribute) in file "tmplfile" line 36
Ignoring bad CONTINUE tag (bad "level=" attribute) in file "tmplfile" line 37
Ignoring bad CONTINUE tag (bad "level=" attribute) in file "tmplfile" line 38
Ignoring bad BREAK tag (bad "level=" attribute) in file "tmplfile" line 40
Ignoring bad CONTINUE tag (bad "level=" attribute) in file "tmplfile" line 41
EOF

template tmplfile var testvalue > /dev/null 2> result

check

TEST=42  ########################################

# Testing incorrect statement nesting

cat << "EOF" > tmplfile
{{if name = "var"}}
  Inside  if 1
  {{loop name = "loop"}}
    Inside loop 1
  {{/if}}
{{/loop}}

{{loop name = "loop"}}
  Inside loop 2
  {{if name = "var"}}
    Inside if 2
  {{/loop}}
{{/if}}

{{if name = "var"}}
  Inside if 3
{{elsif name = "bogus"}}
  Inside elsif 1
  {{if name = "var"}}
    Inside if 4
  {{else}}
    Inside else 1
  {{elsif name = "var"}}
    Inside elsif 2
  {{/if}}
{{/if}}
EOF

cat << "EOF" > expected
LOOP tag in file "tmplfile" line 3 has no /LOOP tag
Unexpected /LOOP tag in file "tmplfile" line 6
IF tag in file "tmplfile" line 10 has no /IF tag
Unexpected /IF tag in file "tmplfile" line 13
IF tag in file "tmplfile" line 19 has no /IF tag
Unexpected /IF tag in file "tmplfile" line 26
EOF

template tmplfile var testvalue > /dev/null 2> result

check



TEST=43  ########################################

# Testing incorrect statement nesting

cat << "EOF" > tmplfile
:{{=var1}}:
:{{= var1}}:
:{{= var1 }}:
:{{= var1
}}:
:{{= var2 default="test"}}:
EOF

cat << "EOF" > expected
:hello:
:hello:
:hello:
:hello:
:test:
EOF

template tmplfile var1 'hello' > result 2>&1

check

# clean up

/bin/rm -f expected inclfile1 inclfile2 result tmplfile
