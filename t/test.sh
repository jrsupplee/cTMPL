#! /bin/sh

PATH=..:/bin:/usr/bin

# Regression tests for the template library
# Usage: ./test.sh [ -r ]
# The -r option causes the script to edit itself and renumber
# the tests in case any are added or removed.

# renumber the tests in this script

check () {
    if diff -c expected$1.txt result$1.txt; then
        echo "Test $TEST success"
    else
        echo "Test $TEST failure"
    fi
}

test "X$1" = X-r && renumber

TEST=NoTags  ########################################

# Testing null input

template NoTags.tmpl > NoTags.rslt 2>&1

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
{{LOOP *}}      * needs quotes
{{LOOP name = * }}   * needs quotes
{{LOOP var}}
{{LOOP name = var }}
{{LOOP var}}
{{LOOP name = var }}
{{LOOP var"}}
{{LOOP name = var" }}
{{LOOP var'}}
{{LOOP name = var' }}
{{LOOP name="var'}}
{{LOOP name = "var' }}
{{LOOP name='var"}}
{{LOOP name = 'var" }}

{{!--LOOP --}}
{{!-- LOOP --}}
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
{{!--LOOP var--}}
{{!-- LOOP name = var --}}
{{!--LOOP var--}}
{{!-- LOOP name = var --}}
{{!--LOOP var"--}}
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
{{VAR default="value"var}}
{{VAR default = value" var }}
{{VAR default=value"name='var}}
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
{{VAR default="value"var/}}
{{VAR default = value" var /}}
{{VAR default=value"name='var/}}
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
{{!--VAR default="value"var--}}
{{!-- VAR default = value" var --}}
{{!--VAR default=value"name='var--}}
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
{{VAR vardefault=value"}}
{{VAR var default = value" }}
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
{{VAR vardefault=value"/}}
{{VAR var default = value" /}}
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
{{!--VAR vardefault=value"--}}
{{!-- VAR var default = value" --}}
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
{{LOOP var var}}
{{LOOP var var2}}
{{LOOP var default = "value"}}
{{LOOP var fmt = "fmtname"}}
{{LOOP var value = "testvalue"}}

{{!--LOOP--}}
{{!-- LOOP --}}
{{!--LOOP nam = "var"--}}
{{!--LOOP namex = "var"--}}
{{!--LOOP color = "red"--}}
{{!--LOOP var var--}}
{{!--LOOP var var2--}}
{{!--LOOP var default = "value"--}}
{{!--LOOP var fmt = "fmtname"--}}
{{!--LOOP var value = "testvalue"--}}

{{INCLUDE}}
{{INCLUDE }}
{{INCLUDE nam = "var"}}
{{INCLUDE namex = "var"}}
{{INCLUDE color = "red"}}
{{INCLUDE var var}}
{{INCLUDE var var2}}
{{INCLUDE var default = "value"}}
{{INCLUDE var fmt = "fmtname"}}
{{INCLUDE var value = "testvalue"}}

{{INCLUDE/}}
{{INCLUDE /}}
{{INCLUDE var /}}
{{INCLUDE var /}}
{{INCLUDE color = "red" /}}
{{INCLUDE var /}}
{{INCLUDE var var2 /}}
{{INCLUDE var default = "value"/}}
{{INCLUDE var fmt = "fmtname" /}}
{{INCLUDE var value = "testvalue" /}}

{{!--INCLUDE--}}
{{!-- INCLUDE --}}
{{!--INCLUDE nam = "var"--}}
{{!--INCLUDE namex = "var"--}}
{{!--INCLUDE color = "red"--}}
{{!--INCLUDE var var--}}
{{!--INCLUDE var var2--}}
{{!--INCLUDE var default = "value"--}}
{{!--INCLUDE var fmt = "fmtname"--}}
{{!--INCLUDE var value = "testvalue"--}}

{{VAR}}
{{VAR }}
{{VAR nam = "var"}}
{{VAR namex = "var"}}
{{VAR color = "red"}}
{{VAR default = "value"}}
{{VAR fmt = "fmtname"}}
{{VAR default = "value" fmt = "fmtname"}}
{{VAR var value = "testvalue"}}
{{VAR var color = "red"}}
{{VAR var default = "value" fmt = "fmtname" var}}
{{VAR var default = "value" fmt = "fmtname" xxx}}
{{VAR default = "xxx" var default = "value" fmt = "fmtname"}}
{{VAR fmt = "xxx" var default = "value" fmt = "fmtname"}}

{{VAR/}}
{{VAR /}}
{{VAR nam = "var" /}}
{{VAR namex = "var" /}}
{{VAR color = "red" /}}
{{VAR default = "value" /}}
{{VAR fmt = "fmtname" /}}
{{VAR default = "value" fmt = "fmtname" /}}
{{VAR var value = "testvalue"/}}
{{VAR var color = "red" /}}
{{VAR var default = "value" fmt = "fmtname" var /}}
{{VAR var default = "value" fmt = "fmtname" xxx/}}
{{VAR default = "xxx" var default = "value" fmt = "fmtname" /}}
{{VAR fmt = "xxx" var default = "value" fmt = "fmtname"/}}

{{!--VAR--}}
{{!-- VAR --}}
{{!--VAR nam = "var"--}}
{{!--VAR namex = "var"--}}
{{!--VAR color = "red"--}}
{{!--VAR default = "value"--}}
{{!--VAR fmt = "fmtname"--}}
{{!--VAR default = "value" fmt = "fmtname"--}}
{{!--VAR var value = "testvalue"--}}
{{!--VAR var color = "red"--}}
{{!--VAR var default = "value" fmt = "fmtname" var--}}
{{!--VAR var default = "value" fmt = "fmtname" xxx--}}
{{!--VAR default = "xxx" var default = "value" fmt = "fmtname"--}}
{{!--VAR fmt = "xxx" var default = "value" fmt = "fmtname"--}}

{{IF}}
{{IF }}
{{IF nam = "var"}}
{{IF namex = "var"}}
{{IF color = "red"}}
{{IF == "testvalue"}}
{{IF var default = "value"}}
{{IF var fmt = "fmtname"}}
{{IF var color = "red"}}
{{IF var == "testvalue" var}}
{{IF var == "testvalue" xxx}}
{{IF == "xxx" var == "testvalue"}}

{{!--IF--}}
{{!-- IF --}}
{{!--IF nam = "var"--}}
{{!--IF namex = "var"--}}
{{!--IF color = "red"--}}
{{!--IF == "testvalue"--}}
{{!--IF var default = "value"--}}
{{!--IF var fmt = "fmtname"--}}
{{!--IF var color = "red"--}}
{{!--IF var == "testvalue" var--}}
{{!--IF var == "testvalue" xxx--}}
{{!--IF == "xxx" var == "testvalue"--}}

{{ELSIF}}
{{ELSIF }}
{{ELSIF nam = "var"}}
{{ELSIF namex = "var"}}
{{ELSIF color = "red"}}
{{ELSIF == "testvalue"}}
{{ELSIF var default = "value"}}
{{ELSIF var fmt = "fmtname"}}
{{ELSIF var color = "red"}}
{{ELSIF var == "testvalue" var}}
{{ELSIF var == "testvalue" xxx}}
{{ELSIF == "xxx" var == "testvalue"}}

{{ELSIF/}}
{{ELSIF /}}
{{ELSIF nam = "var" /}}
{{ELSIF namex = "var" /}}
{{ELSIF color = "red" /}}
{{ELSIF == "testvalue"/}}
{{ELSIF var default = "value"/}}
{{ELSIF var fmt = "fmtname" /}}
{{ELSIF var color = "red"/}}
{{ELSIF var == "testvalue" var /}}
{{ELSIF var == "testvalue" xxx/}}
{{ELSIF == "xxx" var == "testvalue" /}}

{{!--ELSIF--}}
{{!-- ELSIF --}}
{{!--ELSIF nam = "var"--}}
{{!--ELSIF namex = "var"--}}
{{!--ELSIF color = "red"--}}
{{!--ELSIF == "testvalue"--}}
{{!--ELSIF var default = "value"--}}
{{!--ELSIF var fmt = "fmtname"--}}
{{!--ELSIF var color = "red"--}}
{{!--ELSIF var == "testvalue" var--}}
{{!--ELSIF var == "testvalue" xxx--}}
{{!--ELSIF == "xxx" var == "testvalue"--}}

{{ELSE var}}
{{ELSE color = "red"}}
{{ELSE var == "testvalue"}}
{{ELSE var fmt = "fmtname"}}
{{ELSE var default = "value"}}

{{ELSE var /}}
{{ELSE color = "red"/}}
{{ELSE var == "testvalue" /}}
{{ELSE var fmt = "fmtname"/}}
{{ELSE var default = "value" /}}

{{!--ELSE var--}}
{{!--ELSE color = "red"--}}
{{!--ELSE var == "testvalue"--}}
{{!--ELSE var fmt = "fmtname"--}}
{{!--ELSE var default = "value"--}}

{{ENDIF var}}
{{ENDIF color = "red"}}
{{ENDIF var == "testvalue"}}
{{ENDIF var fmt = "fmtname"}}
{{ENDIF var default = "value"}}

{{!--ENDIF var--}}
{{!--ENDIF color = "red"--}}
{{!--ENDIF var == "testvalue"--}}
{{!--ENDIF var fmt = "fmtname"--}}
{{!--ENDIF var default = "value"--}}

{{ENDLOOP var}}
{{ENDLOOP color = "red"}}
{{ENDLOOP var value = "testvalue"}}
{{ENDLOOP var fmt = "fmtname"}}
{{ENDLOOP var default = "value"}}

{{!--ENDLOOP var--}}
{{!--ENDLOOP color = "red"--}}
{{!--ENDLOOP var value = "testvalue"--}}
{{!--ENDLOOP var fmt = "fmtname"--}}
{{!--ENDLOOP var default = "value"--}}

{{BREAK lev = 1}}
{{BREAK levelx = 1}}
{{BREAK color = "red"}}
{{BREAK value = "testvalue"}}
{{BREAK level = "1" default = "value"}}
{{BREAK level = "2" fmt = "fmtname"}}
{{BREAK level = 1 var}}
{{BREAK level = 1 color = "red"}}
{{BREAK level = 1 level = 1}}
{{BREAK var level = "1" }}

{{BREAK lev = 1/}}
{{BREAK levelx = 1/}}
{{BREAK color = "red"/}}
{{BREAK value = "testvalue"/}}
{{BREAK level = "1" default = "value"/}}
{{BREAK level = "2" fmt = "fmtname"/}}
{{BREAK level = 1 var/}}
{{BREAK level = 1 color = "red"/}}
{{BREAK level = 1 level = 1/}}
{{BREAK var level = "1" /}}

{{!-- BREAK lev = 1 --}}
{{!-- BREAK levelx = 1 --}}
{{!-- BREAK color = "red" --}}
{{!-- BREAK value = "testvalue" --}}
{{!-- BREAK level = "1" default = "value" --}}
{{!-- BREAK level = "2" fmt = "fmtname" --}}
{{!-- BREAK level = 1 var --}}
{{!-- BREAK level = 1 color = "red" --}}
{{!-- BREAK level = 1 level = 1 --}}
{{!-- BREAK var level = "1"  --}}

{{CONTINUE lev = 1}}
{{CONTINUE levelx = 1}}
{{CONTINUE color = "red"}}
{{CONTINUE value = "testvalue"}}
{{CONTINUE level = "1" default = "value"}}
{{CONTINUE level = "2" fmt = "fmtname"}}
{{CONTINUE level = 1 var}}
{{CONTINUE level = 1 color = "red"}}
{{CONTINUE level = 1 level = 1}}
{{CONTINUE var level = "1" }}

{{CONTINUE lev = 1/}}
{{CONTINUE levelx = 1/}}
{{CONTINUE color = "red"/}}
{{CONTINUE value = "testvalue"/}}
{{CONTINUE level = "1" default = "value"/}}
{{CONTINUE level = "2" fmt = "fmtname"/}}
{{CONTINUE level = 1 var/}}
{{CONTINUE level = 1 color = "red"/}}
{{CONTINUE level = 1 level = 1/}}
{{CONTINUE var level = "1" /}}

{{!-- CONTINUE lev = 1 --}}
{{!-- CONTINUE levelx = 1 --}}
{{!-- CONTINUE color = "red" --}}
{{!-- CONTINUE value = "testvalue" --}}
{{!-- CONTINUE level = "1" default = "value" --}}
{{!-- CONTINUE level = "2" fmt = "fmtname" --}}
{{!-- CONTINUE level = 1 var --}}
{{!-- CONTINUE level = 1 color = "red" --}}
{{!-- CONTINUE level = 1 level = 1 --}}
{{!-- CONTINUE var level = "1"  --}}

EOF

cp tmplfile expected

template tmplfile > result 2> /dev/null

check

TEST=6  ########################################

# Testing tags with illegal white space, which we consider ordinary text

cat << "EOF" > tmplfile

{{ VAR var}}
{{VARvar}}
{{ VAR var /}}
{{VARvar/}}
{{ VARvar}}
{{ !--VAR var--}}
{{! --VAR var--}}
{{!- -VAR var--}}
{{!--VAR name = var--}}
{{!--VAR var- -}}
{{!--VAR var-- }}
{{!--VARvar--}}
{{!-- VARvar--}}

{{ INCLUDE var}}
{{INCLUDEvar}}
{{ INCLUDE var /}}
{{INCLUDEvar/}}
{{ !--INCLUDE var--}}
{{! --INCLUDE var--}}
{{!- -INCLUDE var--}}
{{!--INCLUDE var- -}}
{{!--INCLUDE var-- }}
{{ INCLUDEvar}}
{{!--INCLUDEvar--}}
{{!-- INCLUDEvar--}}

{{ LOOP var}}
{{LOOPvar}}
{{ LOOPvar}}
{{ !--LOOP var--}}
{{! --LOOP var--}}
{{!- -LOOP var--}}
{{!--LOOP name = var--}}
{{!--LOOP var- -}}
{{!--LOOP var-- }}
{{!--LOOPvar--}}
{{!-- LOOPvar--}}

{{ IF var}}
{{IFvar}}
{{ IFvar}}
{{ !--IF var--}}
{{! --IF var--}}
{{!- -IF var--}}
{{!--IF name = var--}}
{{!--IF var- -}}
{{!--IF var-- }}
{{!--IFvar--}}
{{!-- IFvar--}}

{{ ELSIF var}}
{{ELSIFvar}}
{{ ELSIFvar}}
{{ ELSIF var /}}
{{ELSIFvar/}}
{{ ELSIFvar /}}
{{ !--ELSIF var--}}
{{! --ELSIF var--}}
{{!- -ELSIF var--}}
{{!--ELSIF name = var--}}
{{!--ELSIF var- -}}
{{!--ELSIF var-- }}
{{!--ELSIFvar--}}
{{!-- ELSIFvar--}}

{{ ELSE}}
{{ ELSE }}
{{ ELSE/}}
{{ ELSE /}}
{{ !--ELSE--}}
{{! --ELSE--}}
{{!- -ELSE--}}
{{!--ELSE- -}}
{{!--ELSE-- }}

{{ ENDIF}}
{{ ENDIF }}
{{/ IF}}
{{/ IF }}
{{ !--ENDIF--}}
{{! --ENDIF--}}
{{!- -ENDIF--}}
{{!--ENDIF- -}}
{{!--ENDIF-- }}
{{!--/ IF--}}
{{!-- / IF --}}

{{ ENDLOOP}}
{{ ENDLOOP }}
{{/ LOOP}}
{{/ LOOP }}
{{ !--ENDLOOP--}}
{{! --ENDLOOP--}}
{{!- -ENDLOOP--}}
{{!--ENDLOOP- -}}
{{!--ENDLOOP-- }}
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

{{VAR var--}}
{{VAR var --}}
{{!--VAR var}}
{{!-- VAR var }}
{{!--VAR var/}}
{{!-- VAR var /}}

{{INCLUDE var--}}
{{INCLUDE var --}}
{{!--INCLUDE var}}
{{!-- INCLUDE var }}
{{!--INCLUDE var/}}
{{!-- INCLUDE var /}}

{{LOOP var/}}
{{LOOP var /}}
{{LOOP var--}}
{{LOOP var --}}
{{!--LOOP var}}
{{!-- LOOP var }}

{{IF var/}}
{{IF var /}}
{{IF var--}}
{{IF var --}}
{{!--IF var}}
{{!-- IF var }}

{{ELSIF var--}}
{{ELSIF var --}}
{{!--ELSIF var}}
{{!-- ELSIF var }}
{{!--ELSIF var/}}
{{!-- ELSIF var /}}

{{ELSE--}}
{{ELSE --}}
{{!--ELSE}}
{{!-- ELSE }}
{{!--ELSE/}}
{{!-- ELSE /}}

{{ENDIF/}}
{{ENDIF /}}
{{ENDIF--}}
{{ENDIF --}}
{{!--ENDIF}}
{{!-- ENDIF }}

{{ENDLOOP/}}
{{ENDLOOP /}}
{{ENDLOOP--}}
{{ENDLOOP --}}
{{!--ENDLOOP}}
{{!-- ENDLOOP }}

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

# Testing VAR tag with just " attribute

cat << EOF" > tmplfile

X{{VAR bogus}}X
X{{VAR bogus}}X
X{{VAR bogus}}X
X{{VAR bogus }}X
X{{VAR bogus }}X
X{{VAR     bogus    }}X
X{{VAR
  bogus
  }}X
X{{VAR bogus}}{{VAR bogus}}X
X{{vAr bogus}}X

X{{VAR bogus/}}X
X{{VAR bogus/}}X
X{{VAR bogus/}}X
X{{VAR bogus /}}X
X{{VAR bogus /}}X
X{{VAR     bogus    /}}X
X{{VAR
  bogus
  /}}X
X{{VAR bogus/}}{{VAR bogus/}}X
X{{vAr bogus/}}X

X{{!--VAR bogus--}}X
X{{!-- VAR bogus--}}X
X{{!--VAR bogus--}}X
X{{!--VAR bogus--}}X
X{{!--VAR bogus --}}X
X{{!-- VAR bogus --}}X
X{{!--   VAR     bogus    --}}X
X{{!--
  VAR
  bogus
  --}}X
X{{!--VAR bogus--}}{{!--VAR bogus--}}X
X{{!--vAr bogus--}}X

X{{VAR var}}X
X{{VAR var}}X
X{{VAR var}}X
X{{VAR var }}X
X{{VAR var }}X
X{{VAR     var    }}X
X{{VAR
  var
  }}X
X{{VAR var}}{{VAR var}}X
X{{vAr var}}X

X{{VAR var/}}X
X{{VAR var/}}X
X{{VAR var/}}X
X{{VAR var /}}X
X{{VAR var /}}X
X{{VAR     var    /}}X
X{{VAR
  var
  /}}X
X{{VAR var/}}{{VAR var/}}X
X{{vAr var/}}X

X{{!--VAR var--}}X
X{{!-- VAR var--}}X
X{{!--VAR var--}}X
X{{!--VAR var--}}X
X{{!--VAR var --}}X
X{{!-- VAR var --}}X
X{{!--    VAR     var    --}}X
X{{!--
  VAR
  var
  --}}X
X{{!--VAR var--}}{{!--VAR var--}}X
X{{!--vAr var--}}X

X{{VAR var}}{{VAR bogus}}X
X{{VAR bogus}}{{VAR var}}X

X{{VAR This variable has an extremely long, but nevertheless legal, name}}X

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

X{{VAR bogusdefault="DEFAULT"}}X
X{{VAR bogusdefault="DEFAULT"}}X
X{{VAR bogusdefault="DEFAULT"}}X
X{{VAR bogus default="DEFAULT"}}X
X{{VAR bogusdefault ="DEFAULT"}}X
X{{VAR bogusdefault= "DEFAULT"}}X
X{{VAR bogusdefault="DEFAULT" }}X
X{{VAR   bogus   default   =   "DEFAULT"   }}X
X{{VAR
  bogus
  default
  =
  "DEFAULT"
  }}X
X{{VaR bogus DefAUlT="DEFAULT" /}}X
X{{VAR default="DEFAULT" bogus/}}X

X{{VAR bogusdefault="DEFAULT"/}}X
X{{VAR bogusdefault="DEFAULT"/}}X
X{{VAR bogusdefault="DEFAULT"/}}X
X{{VAR bogus default="DEFAULT"/}}X
X{{VAR bogusdefault ="DEFAULT"/}}X
X{{VAR bogusdefault= "DEFAULT"/}}X
X{{VAR bogusdefault="DEFAULT" /}}X
X{{VAR   bogus   default   =   "DEFAULT"   /}}X
X{{VAR
  bogus
  default
  =
  "DEFAULT"
  /}}X
X{{VaR bogus DefAUlT="DEFAULT" /}}X
X{{VAR default="DEFAULT" bogus/}}X

X{{!--VAR bogusdefault="DEFAULT"--}}X
X{{!-- VAR bogusdefault="DEFAULT"--}}X
X{{!--VAR bogusdefault="DEFAULT"--}}X
X{{!--VAR bogusdefault="DEFAULT"--}}X
X{{!--VAR bogus default="DEFAULT"--}}X
X{{!--VAR bogusdefault ="DEFAULT"--}}X
X{{!--VAR bogusdefault= "DEFAULT"--}}X
X{{!--VAR bogusdefault="DEFAULT" --}}X
X{{!--  VAR   bogus   default   =   "DEFAULT"   --}}X
X{{!--
  VAR
  bogus
  default
  =
  "DEFAULT"
  --}}X
X{{!--VaR bogus DefAUlT="DEFAULT"--}}X
X{{!--VAR default="DEFAULT" bogus--}}X

X{{VAR vardefault="DEFAULT"}}X
X{{VAR vardefault="DEFAULT"}}X
X{{VAR vardefault="DEFAULT"}}X
X{{VAR var default="DEFAULT"}}X
X{{VAR vardefault ="DEFAULT"}}X
X{{VAR vardefault= "DEFAULT"}}X
X{{VAR vardefault="DEFAULT" }}X
X{{VAR   var   default   =   "DEFAULT"   }}X
X{{VAR
  var
  default
  =
  "DEFAULT"
  }}X
X{{VaR var DefAUlT="DEFAULT"}}X
X{{VAR default="DEFAULT" var}}X

X{{VAR vardefault="DEFAULT"/}}X
X{{VAR vardefault="DEFAULT"/}}X
X{{VAR vardefault="DEFAULT"/}}X
X{{VAR var default="DEFAULT"/}}X
X{{VAR vardefault ="DEFAULT"/}}X
X{{VAR vardefault= "DEFAULT"/}}X
X{{VAR vardefault="DEFAULT" /}}X
X{{VAR   var   default   =   "DEFAULT"   /}}X
X{{VAR
  var
  default
  =
  "DEFAULT"
  /}}X
X{{VaR var DefAUlT="DEFAULT"/}}X
X{{VAR default="DEFAULT" var/}}X

X{{!--VAR vardefault="DEFAULT"--}}X
X{{!-- VAR vardefault="DEFAULT"--}}X
X{{!--VAR vardefault="DEFAULT"--}}X
X{{!--VAR vardefault="DEFAULT"--}}X
X{{!--VAR var default="DEFAULT"--}}X
X{{!--VAR vardefault ="DEFAULT"--}}X
X{{!--VAR vardefault= "DEFAULT"--}}X
X{{!--VAR vardefault="DEFAULT" --}}X
X{{!--  VAR   var   default   =   "DEFAULT"   --}}X
X{{!--
  VAR
  var
  default
  =
  "DEFAULT"
  --}}X
X{{!--VaR var DefAUlT="DEFAULT"--}}X
X{{!--VAR default="DEFAULT" var--}}X

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

X{{VAR bogusfmt="entity"}}X
X{{VAR bogusfmt="entity"}}X
X{{VAR bogusfmt="entity"}}X
X{{VAR bogus fmt="entity"}}X
X{{VAR bogusfmt ="entity"}}X
X{{VAR bogusfmt= "entity"}}X
X{{VAR bogusfmt="entity" }}X
X{{VAR   bogus   fmt   =   "entity"   }}X
X{{VAR
  bogus
  fmt
  =
  "entity"
  }}X
X{{VaR bogus fMt="entity" }}X
X{{VAR fmt="entity" bogus}}X

X{{VAR bogusfmt="entity"/}}X
X{{VAR bogusfmt="entity"/}}X
X{{VAR bogusfmt="entity"/}}X
X{{VAR bogus fmt="entity"/}}X
X{{VAR bogusfmt ="entity"/}}X
X{{VAR bogusfmt= "entity"/}}X
X{{VAR bogusfmt="entity" /}}X
X{{VAR   bogus   fmt   =   "entity"   /}}X
X{{VAR
  bogus
  fmt
  =
  "entity"
  /}}X
X{{VaR bogus fMt="entity" /}}X
X{{VAR fmt="entity" bogus/}}X

X{{!--VAR bogusfmt="entity"--}}X
X{{!-- VAR bogusfmt="entity"--}}X
X{{!--VAR bogusfmt="entity"--}}X
X{{!--VAR bogusfmt="entity"--}}X
X{{!--VAR bogus fmt="entity"--}}X
X{{!--VAR bogusfmt ="entity"--}}X
X{{!--VAR bogusfmt= "entity"--}}X
X{{!--VAR bogusfmt="entity" --}}X
X{{!--  VAR   bogus   fmt   =   "entity"   --}}X
X{{!--
  VAR
  bogus
  fmt
  =
  "entity"
  --}}X
X{{!--VaR bogus FmT="entity"--}}X
X{{!--VAR fmt="entity" bogus--}}X

X{{VAR varfmt="entity"}}X
X{{VAR varfmt="entity"}}X
X{{VAR varfmt="entity"}}X
X{{VAR var fmt="entity"}}X
X{{VAR varfmt ="entity"}}X
X{{VAR varfmt= "entity"}}X
X{{VAR varfmt="entity" }}X
X{{VAR   var   fmt   =   "entity"   }}X
X{{VAR
  var
  fmt
  =
  "entity"
  }}X
X{{VaR var fmT="entity"}}X
X{{VAR fmt="entity" var}}X

X{{VAR varfmt="entity"/}}X
X{{VAR varfmt="entity"/}}X
X{{VAR varfmt="entity"/}}X
X{{VAR var fmt="entity"/}}X
X{{VAR varfmt ="entity"/}}X
X{{VAR varfmt= "entity"/}}X
X{{VAR varfmt="entity" /}}X
X{{VAR   var   fmt   =   "entity"   /}}X
X{{VAR
  var
  fmt
  =
  "entity"
  /}}X
X{{VaR var fmT="entity"/}}X
X{{VAR fmt="entity" var/}}X

X{{!--VAR varfmt="entity"--}}X
X{{!-- VAR varfmt="entity"--}}X
X{{!--VAR varfmt="entity"--}}X
X{{!--VAR varfmt="entity"--}}X
X{{!--VAR var fmt="entity"--}}X
X{{!--VAR varfmt ="entity"--}}X
X{{!--VAR varfmt= "entity"--}}X
X{{!--VAR varfmt="entity" --}}X
X{{!--  VAR   var   fmt   =   "entity"   --}}X
X{{!--
  VAR
  var
  fmt
  =
  "entity"
  --}}X
X{{!--VaR var fMt="entity"--}}X
X{{!--VAR fmt="entity" var--}}X

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

X{{VAR var fmt="entity" default="<<DEFAULT>>"}}X
X{{VAR var default="<<DEFAULT>>" fmt="entity"}}X
X{{VAR var default="<<DEFAULT>>" fmt="entity"}}X
X{{VAR var default="<<DEFAULT>>" fmt="entity"}}X
X{{VAR var fmt="entity" default="<<DEFAULT>>"}}X
X{{VAR fmt="entity" default="<<DEFAULT>>" var}}X

X{{VAR var fmt="entity" default="<<DEFAULT>>"/}}X
X{{VAR var default="<<DEFAULT>>" fmt="entity"/}}X
X{{VAR default="<<DEFAULT>>" var fmt="entity"/}}X
X{{VAR default="<<DEFAULT>>" fmt="entity" var/}}X
X{{VAR fmt="entity" var default="<<DEFAULT>>"/}}X
X{{VAR fmt="entity" default="<<DEFAULT>>" var/}}X

X{{!--VAR var fmt="entity" default="<<DEFAULT>>"--}}X
X{{!--VAR var default="<<DEFAULT>>" fmt="entity"--}}X
X{{!--VAR default="<<DEFAULT>>" var fmt="entity"--}}X
X{{!--VAR default="<<DEFAULT>>" fmt="entity" var--}}X
X{{!--VAR fmt="entity" var default="<<DEFAULT>>"--}}X
X{{!--VAR fmt="entity" default="<<DEFAULT>>" var--}}X

X{{VAR bogus fmt="entity" default="<<DEFAULT>>"}}X
X{{VAR bogus default="<<DEFAULT>>" fmt="entity"}}X
X{{VAR default="<<DEFAULT>>" bogus fmt="entity"}}X
X{{VAR default="<<DEFAULT>>" fmt="entity" bogus}}X
X{{VAR fmt="entity" bogus default="<<DEFAULT>>"}}X
X{{VAR fmt="entity" default="<<DEFAULT>>" bogus}}X

X{{VAR bogus fmt="entity" default="<<DEFAULT>>"/}}X
X{{VAR bogus default="<<DEFAULT>>" fmt="entity"/}}X
X{{VAR default="<<DEFAULT>>" bogus fmt="entity"/}}X
X{{VAR default="<<DEFAULT>>" fmt="entity" bogus/}}X
X{{VAR fmt="entity" bogus default="<<DEFAULT>>"/}}X
X{{VAR fmt="entity" default="<<DEFAULT>>" bogus/}}X

X{{!--VAR bogus fmt="entity" default="<<DEFAULT>>"--}}X
X{{!--VAR bogus default="<<DEFAULT>>" fmt="entity"--}}X
X{{!--VAR default="<<DEFAULT>>" bogus fmt="entity"--}}X
X{{!--VAR default="<<DEFAULT>>" fmt="entity" bogus--}}X
X{{!--VAR fmt="entity" bogus default="<<DEFAULT>>"--}}X
X{{!--VAR fmt="entity" default="<<DEFAULT>>" bogus--}}X

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

X{{VAR var fmt="entity" default="DEFAULT"}}X
X{{VAR var fmt='entity' default='DEFAULT'}}X
X{{VAR var   fmt=entity   default=DEFAULT}}X
X{{VAR var fmt='entity' default=DEFAULT}}X
X{{VAR var   fmt="entity" default='DEFAULT'}}X

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

{{VAR var fmt="entity"}}
{{VAR var fmt="bogus1" /}}
{{VAR var fmt="entity" }}
{{VAR var fmt="bogus2"}}
{{!--



VAR var



fmt="bogus3"







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

X{{LOOP loop}}X{{ENDLOOP}}X
X{{LOOP loop}}X{{ENDLOOP}}X
X{{LOOP loop}}X{{ENDLOOP}}X
X{{LOOP   loop  }}X{{ENDLOOP}}X
X{{LOOP

  loop

  }}X{{ENDLOOP}}X
X{{LoOp loop}}X{{ENDLOOP}}X

X{{!--LOOP loop--}}X{{ENDLOOP}}X
X{{!--LOOP loop--}}X{{ENDLOOP}}X
X{{!--LOOP loop --}}X{{ENDLOOP}}X
X{{!--   LOOP   loop  --}}X{{ENDLOOP}}X
X{{!--

  LOOP

  loop

  --}}X{{ENDLOOP}}X
X{{!--LoOp loop--}}X{{ENDLOOP}}X

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

# Testing accepted {{ENDLOOP}} tag syntax

cat << "EOF" > tmplfile

X{{LOOP loop}}X{{ENDLOOP}}X
X{{LOOP loop}}X{{ENDLOOP }}X
X{{LOOP loop}}X{{ENDLOOP   }}X
X{{LOOP loop}}X{{ENDLOOP

}}X
X{{LOOP loop}}X{{ENDLOOP}}X

X{{LOOP loop}}X{{!--ENDLOOP--}}X
X{{LOOP loop}}X{{!-- ENDLOOP --}}X
X{{LOOP loop}}X{{!--   ENDLOOP   --}}X
X{{LOOP loop}}X{{!--


ENDLOOP

--}}X
X{{LOOP loop}}X{{!--ENDLOOP--}}X

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

X{{INCLUDE inclfile1}}X
X{{INCLUDE inclfile1}}X
X{{INCLUDE inclfile1}}X
X{{INCLUDE   inclfile1  }}X
X{{INCLUDE

  inclfile1

  }}X
X{{InCluDe inclfile1}}X

X{{INCLUDE inclfile1/}}X
X{{INCLUDE inclfile1/}}X
X{{INCLUDE inclfile1/}}X
X{{INCLUDE   inclfile1  /}}X
X{{INCLUDE

  inclfile1

  /}}X
X{{InCluDe inclfile1/}}X

X{{!--INCLUDE inclfile1--}}X
X{{!--INCLUDE inclfile1--}}X
X{{!--INCLUDE inclfile1 --}}X
X{{!--INCLUDE   inclfile1  --}}X
X{{!--

  INCLUDE

  inclfile1

  --}}X
X{{!--InClUDe inclfile1--}}X

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

X{{IF var}}X{{ENDIF}}X
X{{IF var}}X{{ENDIF}}X
X{{IF var}}X{{ENDIF}}X
X{{IF   var  }}X{{ENDIF}}X
X{{IF

  var

  }}X{{ENDIF}}X
X{{IF var}}X{{ENDIF}}X

X{{!--IF var--}}X{{ENDIF}}X
X{{!--IF var--}}X{{ENDIF}}X
X{{!--IF var --}}X{{ENDIF}}X
X{{!--   IF   var  --}}X{{ENDIF}}X
X{{!--

  IF

  var

  --}}X{{ENDIF}}X
X{{!--iF var--}}X{{ENDIF}}X

X{{IF var =="testvalue"}}X{{ENDIF}}X
X{{IF var == 'testvalue'}}X{{ENDIF}}X
X{{IF var ==testvalue}}X{{ENDIF}}X
X{{IF var ==testvalue}}X{{ENDIF}}X
X{{IF   var  ==  "testvalue"  }}X{{ENDIF}}X
X{{IF

  var

  ==

  "testvalue"

  }}X{{ENDIF}}X
X{{IF var =="testvalue"}}X{{ENDIF}}X
X{{IF var=="testvalue"}}X{{ENDIF}}X

X{{!--IF var =="testvalue"--}}X{{ENDIF}}X
X{{!--IF var =='testvalue'--}}X{{ENDIF}}X
X{{!--IF var ==testvalue --}}X{{ENDIF}}X
X{{!--IF var ==testvalue --}}X{{ENDIF}}X
X{{!--IF   var  ==  "testvalue"   --}}X{{ENDIF}}X
X{{!--
  IF

  var

  ==

  "testvalue"

  --}}X{{ENDIF}}X
X{{!--if var =="testvalue"--}}X{{ENDIF}}X
X{{!--IF var =="testvalue"--}}X{{ENDIF}}X

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

X{{IF x}}X{{ELSIF var}}X{{ENDIF}}X
X{{IF x}}X{{ELSIF var}}X{{ENDIF}}X
X{{IF x}}X{{ELSIF var}}X{{ENDIF}}X
X{{IF x}}X{{ELSIF   var  }}X{{ENDIF}}X
X{{IF x}}X{{ELSIF

  var

  }}X{{ENDIF}}X
X{{IF x}}X{{ElSif var}}X{{ENDIF}}X

X{{IF x}}X{{ELSIF var/}}X{{ENDIF}}X
X{{IF x}}X{{ELSIF var/}}X{{ENDIF}}X
X{{IF x}}X{{ELSIF var/}}X{{ENDIF}}X
X{{IF x}}X{{ELSIF   var  /}}X{{ENDIF}}X
X{{IF x}}X{{ELSIF

  var

  /}}X{{ENDIF}}X
X{{IF x}}X{{ElSif var/}}X{{ENDIF}}X

X{{IF x}}X{{!--ELSIF var--}}X{{ENDIF}}X
X{{IF x}}X{{!--ELSIF var--}}X{{ENDIF}}X
X{{IF x}}X{{!--ELSIF var --}}X{{ENDIF}}X
X{{IF x}}X{{!--   ELSIF   var  --}}X{{ENDIF}}X
X{{IF x}}X{{!--

  ELSIF

  var

  --}}X{{ENDIF}}X
X{{IF x}}X{{!--eLSiF var--}}X{{ENDIF}}X

X{{IF x}}X{{ELSIF var =="testvalue"}}X{{ENDIF}}X
X{{IF x}}X{{ELSIF var =='testvalue'}}X{{ENDIF}}X
X{{IF x}}X{{ELSIF var ==testvalue}}X{{ENDIF}}X
X{{IF x}}X{{ELSIF var ==testvalue}}X{{ENDIF}}X
X{{IF x}}X{{ELSIF   var  ==  "testvalue"  }}X{{ENDIF}}X
X{{IF x}}X{{ELSIF

  var

  ==

  "testvalue"

  }}X{{ENDIF}}X
X{{IF x}}X{{eLSif var =="testvalue"}}X{{ENDIF}}X
X{{IF x}}X{{ELSIF var =="testvalue"}}X{{ENDIF}}X

X{{IF x}}X{{ELSIF var =="testvalue"/}}X{{ENDIF}}X
X{{IF x}}X{{ELSIF var =='testvalue'/}}X{{ENDIF}}X
X{{IF x}}X{{ELSIF var ==testvalue/}}X{{ENDIF}}X
X{{IF x}}X{{ELSIF var ==testvalue/}}X{{ENDIF}}X
X{{IF x}}X{{ELSIF   var  ==  "testvalue"  /}}X{{ENDIF}}X
X{{IF x}}X{{ELSIF

  var

  ==

  "testvalue"

  /}}X{{ENDIF}}X
X{{IF x}}X{{eLSif var =="testvalue"/}}X{{ENDIF}}X
X{{IF x}}X{{ELSIF var =="testvalue" /}}X{{ENDIF}}X

X{{IF x}}X{{!--ELSIF var =="testvalue"--}}X{{ENDIF}}X
X{{IF x}}X{{!--ELSIF var --}}X{{ENDIF}}X
X{{IF x}}X{{!--ELSIF var ==testvalue --}}X{{ENDIF}}X
X{{IF x}}X{{!--ELSIF var ==testvalue --}}X{{ENDIF}}X
X{{IF x}}X{{!--ELSIF   var  ==  "testvalue"   --}}X{{ENDIF}}X
X{{IF x}}X{{!--
  ELSIF

  var

  ==

  "testvalue"

  --}}X{{ENDIF}}X
X{{IF x}}X{{!--ElSif var =="testvalue"--}}X{{ENDIF}}X
X{{IF x}}X{{!--ELSIF var =="testvalue"--}}X{{ENDIF}}X

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

X{{IF x}}X{{ELSE}}X{{ENDIF}}X
X{{IF x}}X{{ELSE }}X{{ENDIF}}X
X{{IF x}}X{{ELSE   }}X{{ENDIF}}X
X{{IF x}}X{{ELSE

}}X{{ENDIF}}X
X{{IF x}}X{{eLSe}}X{{ENDIF}}X

X{{IF x}}X{{ELSE/}}X{{ENDIF}}X
X{{IF x}}X{{ELSE /}}X{{ENDIF}}X
X{{IF x}}X{{ELSE   /}}X{{ENDIF}}X
X{{IF x}}X{{ELSE

/}}X{{ENDIF}}X
X{{IF x}}X{{eLSe/}}X{{ENDIF}}X

X{{IF x}}X{{!--ELSE--}}X{{ENDIF}}X
X{{IF x}}X{{!-- ELSE --}}X{{ENDIF}}X
X{{IF x}}X{{!--   ELSE   --}}X{{ENDIF}}X
X{{IF x}}X{{!--

ELSE

--}}X{{ENDIF}}X
X{{IF x}}X{{!--ElSe--}}X{{ENDIF}}X

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

# Testing accepted {{ENDIF}} tag syntax

cat << "EOF" > tmplfile

X{{IF var}}X{{ENDIF}}X
X{{IF var}}X{{ENDIF }}X
X{{IF var}}X{{ENDIF   }}X
X{{IF var}}X{{ENDIF

}}X
X{{IF var}}X{{ENDIF}}X

X{{IF var}}X{{!--ENDIF--}}X
X{{IF var}}X{{!-- ENDIF --}}X
X{{IF var}}X{{!--   ENDIF   --}}X
X{{IF var}}X{{!--

ENDIF

--}}X
X{{IF var}}X{{!--ENDIF--}}X

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
var1 = {{var var1}}
var2 = {{var var2}}
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
  {{VAR var}}
  {{ENDIF}}
  {{ENDLOOP}}
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
  {{VAR var}}
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
{{var var}}
End include file 1
EOF

cat << "EOF" > inclfile2
Begin include file 2
Including file 1 from file 2
{{include ./inclfile1}}
End include file 2
EOF

cat << "EOF" > tmplfile
Begin template
Including file 1
{{INCLUDE inclfile1}}
Including file 2
{{INCLUDE ./inclfile2}}
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
{{var var}}
End include file 1
EOF

cat << "EOF" > inclfile2
Begin include file 2
Including file 1 from file 2
{{include .../inclfile1}}
End include file 2
EOF

cat << "EOF" > tmplfile
Begin template
Including file 1
{{INCLUDE .../inclfile1}}
Including file 2
{{INCLUDE .../inclfile2}}
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
{{include inclfile1 }}
End template
EOF

cat << "EOF" > inclfile1
Begin include file 1
Including file 1 from file 1
{{INCLUDE inclfile1}}
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
{{include inclfile2}}
End include file 1
EOF

cat << "EOF" > inclfile2
Begin include file 2
Including file 1 from file 2
{{include ./inclfile1}}
End include file 2
EOF

cat << "EOF" > tmplfile
Begin template
Including file 1
{{INCLUDE inclfile1}}
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
{{include non existent file}}
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
{{IF bogus}}
  Including nonexistent file
  {{include non existent file}}
{{ENDIF}}
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
{{var var}}\
{{var var}}\
\
\
\
{{var var}}\
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
{{var bogus}}{{*

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
  *}}{{var bogus}}' > tmplfile

cp /dev/null expected

template tmplfile var testvalue > result 2>&1

check

TEST=33  ########################################

# Testing if statement

cat << "EOF" > tmplfile

Testing simple if statement

X{{IF var}}TRUE{{ENDIF}}X
X{{IF bogus}}TRUE{{ENDIF}}X
X{{IF null}}TRUE{{ENDIF}}X
X{{IF var == ""}}TRUE{{ENDIF}}X
X{{IF var == "wrong"}}TRUE{{ENDIF}}X
X{{IF var == "testvalue"}}TRUE{{ENDIF}}X
X{{if var == "testvalue"}}TRUE{{ENDIF}}X
X{{IF null == ""}}TRUE{{ENDIF}}X
X{{IF null == "wrong"}}TRUE{{ENDIF}}X
X{{IF bogus == ""}}TRUE{{ENDIF}}X
X{{IF bogus == "wrong"}}TRUE{{ENDIF}}X
X{{IF var}}{{ENDIF}}X
X{{IF bogus}}{{ENDIF}}X

Testing if with else clause

X{{IF var}}TRUE{{else}}FALSE{{ENDIF}}X
X{{IF bogus}}TRUE{{else}}FALSE{{ENDIF}}X
X{{IF null}}TRUE{{else}}FALSE{{ENDIF}}X
X{{IF var == ""}}TRUE{{else}}FALSE{{ENDIF}}X
X{{IF var == "wrong"}}TRUE{{else}}FALSE{{ENDIF}}X
X{{IF var == "testvalue"}}TRUE{{else}}FALSE{{ENDIF}}X
X{{if var == "testvalue"}}TRUE{{else}}FALSE{{ENDIF}}X
X{{IF null == ""}}TRUE{{else}}FALSE{{ENDIF}}X
X{{IF null == "wrong"}}TRUE{{else}}FALSE{{ENDIF}}X
X{{IF bogus == ""}}TRUE{{else}}FALSE{{ENDIF}}X
X{{IF bogus == "wrong"}}TRUE{{else}}FALSE{{ENDIF}}X
X{{IF var}}{{else}}{{ENDIF}}X
X{{IF bogus}}{{else}}{{ENDIF}}X

Testing if with elseif clauses

X{{IF var}}
  IF BRANCH
{{ELSIF var }}
  ELSIF BRANCH 1
{{ELSIF var == "testvalue"}}
  ELSIF BRANCH 2
{{ELSE}}
  ELSE BRANCH
{{ENDIF}}X

X{{IF bogus}}
  IF BRANCH
{{ELSIF var }}
  ELSIF BRANCH 1
{{ELSIF var == "testvalue"}}
  ELSIF BRANCH 2
{{ELSE}}
  ELSE BRANCH
{{ENDIF}}X

X{{IF bogus}}
  IF BRANCH
{{ELSIF var == "wrong"}}
  ELSIF BRANCH 1
{{ELSIF var2 == "testvalue2"}}
  ELSIF BRANCH 2
{{ELSE}}
  ELSE BRANCH
{{ENDIF}}X

X{{IF bogus}}
  IF BRANCH
{{ELSIF var == "wrong"}}
  ELSIF BRANCH 1
{{ELSIF var2 == ""}}
  ELSIF BRANCH 2
{{ELSE}}
  ELSE BRANCH
{{ENDIF}}X

X{{IF var}}{{elsif var2}}{{else}}{{ENDIF}}X

Testing nested simple if statements

X{{IF var}}
  Inside IF 1
  X{{IF var2 == "testvalue2"}}
    Inside IF 2
  {{ENDIF}}X
{{ENDIF}}X

X{{IF bogus}}
  Inside IF 1
  X{{IF var2 == "testvalue2"}}
    Inside IF 2
  {{ENDIF}}X
{{ENDIF}}X

Testing nested if with else clauses

X{{IF bogus}}
  Inside IF BRANCH 1
  X{{IF var == "testvalue"}}
    Inside IF BRANCH 2
  {{/else}}
    Inside ELSE BRANCH 2
  {{ENDIF}}X
{{else}}
  Inside ELSE BRANCH 1
  X{{IF bogus}}
    Inside IF BRANCH 3
  {{else}}
    Inside ELSE BRANCH 3
  {{ENDIF}}X
{{ENDIF}}X

X{{IF var}}
  Inside IF BRANCH 1
  X{{IF var == "wrong"}}
    Inside IF BRANCH 2
  {{else}}
    Inside ELSE BRANCH 2
  {{ENDIF}}X
{{else}}
  Inside ELSE BRANCH 1
  X{{IF bogus}}
    Inside IF BRANCH 3
  {{else}}
    Inside ELSE BRANCH 3
  {{ENDIF}}X
{{ENDIF}}X
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
XX
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
XFALSEX
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
var1 = {{var var1}}

X{{loop loop1}}{{ENDLOOP}}X
X{{loop bogus}}{{ENDLOOP}}X

X{{loop loop1}}
  var1 = {{var var1}}
  var2 = {{var var2}}
{{ENDLOOP}}X

X{{loop bogus}}
  var1 = {{var var1}}
  var2 = {{var var2}}
{{ENDLOOP}}X

X{{loop var1}}
  var1 = {{var var1}}
  var2 = {{var var2}}
{{ENDLOOP}}X

X{{loop loop1}}
  Begin outer loop
  var1 = {{var var1}}
  var2 = {{var var2}}
  X{{loop loop1}}
    Begin inner loop
    var1 = {{var var1}}
    var2 = {{var var2}}
    End inner loop
  {{ENDLOOP}}X
  End outer loop
{{ENDLOOP}}X
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
var1 = {{var var1}}

X{{loop outer}}
  Begin outer loop
  var1 = {{var var1}}
  var2 = {{var var2}}
  X{{loop inner}}
    Begin inner loop
    var1 = {{var var1}}
    var2 = {{var var2}}
    var3 = {{var var3}}
    End inner loop
  {{ENDLOOP}}X
  End outer loop
{{ENDLOOP}}X
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
var1 = {{var var1}}
var2 = {{var var2}}
End include file
EOF

cat << "EOF" > tmplfile
Begin template
{{loop loop}}
  Begin loop
  Including file 1
  {{include inclfile1}}
  End loop
{{ENDLOOP}}
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

X{{IF var}}{{loop loop}}{{ENDLOOP}}{{ENDIF}}X
X{{IF bogus}}{{loop loop}}{{ENDLOOP}}{{ENDIF}}X
X{{loop loop}}{{IF var}}{{ENDIF}}{{ENDLOOP}}X
X{{loop bogus}}{{IF var}}{{ENDIF}}{{ENDLOOP}}X

X{{IF loop}}
  Inside if 1
  {{loop loop}}
    Inside loop 1
    {{IF bogus}}
      Inside if 2: bogus = {{var bogus}}
    {{ENDIF}}
    {{IF var2}}
      Inside if 3: var2 = {{var var2}}
    {{ENDIF}}
  {{ENDLOOP}}
{{ENDIF}}X
X{{IF bogus}}
  Inside if 4
  {{loop loop}}
    Inside loop 2
    {{IF bogus}}
      Inside if 5: bogus = {{var bogus}}
    {{ENDIF}}
    {{IF var2}}
      Inside if 6: var2 = {{var var2}}
    {{ENDIF}}
  {{ENDLOOP}}
{{ENDIF}}X
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
{{loop outer}}\
  BEGIN outer        (CONTINUE 3 comes here)
  o = {{var o}}
{{loop middle}}\
    BEGIN middle     (CONTINUE 2 comes here)
    m = {{var m}}
{{loop inner}}\
      BEGIN inner    (CONTINUE 1 comes here)
      i = {{var i}}
{{if i ==b1}}\
      BREAK 1
{{break}}{{ENDIF}}\
{{if i ==b2}}\
      BREAK 2
{{break level=2}}{{ENDIF}}\
{{if i ==b3}}\
      BREAK 3
{{break level=3}}{{ENDIF}}\
{{if i ==c1}}\
      CONTINUE 1
{{continue}}{{ENDIF}}\
{{if i ==c2}}\
      CONTINUE 2
{{continue level=2}}{{ENDIF}}\
{{if i ==c3}}\
      CONTINUE 3
{{continue level=3}}{{ENDIF}}\
      END inner
{{ENDLOOP}}\
    END middle       (BREAK 1 comes here)
{{ENDLOOP}}\
  END outer          (BREAK 2 comes here)
{{ENDLOOP}}\
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
{{IF var}}
  Inside if 1
{{elsif var}}
  Inside elsif 1
{{else}}
  Inside else 1
{{loop loop}}
  Inside the loop statement
  {{*
{{ENDLOOP}} *}}{{* this
comment is not terminated
EOF

cat << "EOF" > expected
"{{*" in file "tmplfile" line 10 has no "*}}"
LOOP tag in file "tmplfile" line 7 has no ENDLOOP tag
IF tag in file "tmplfile" line 1 has no ENDIF tag
EOF

template tmplfile var testvalue > /dev/null 2> result

check

TEST=40  ########################################

# Testing missing statement terminators

cat << "EOF" > tmplfile
{{IF var}}
  Inside if 1
  {{loop loop}}
    Inside loop 1
{{ENDIF}}
{{loop loop}}
  Inside loop 2
  {{IF var}}
    Inside if 2
{{ENDLOOP}}
EOF

cat << "EOF" > expected
LOOP tag in file "tmplfile" line 3 has no ENDLOOP tag
IF tag in file "tmplfile" line 8 has no ENDIF tag
EOF

template tmplfile var testvalue > /dev/null 2> result

check

TEST=41  ########################################

# Testing extraneous and misplaced tags

cat << "EOF" > tmplfile
{{IF var}}
  Inside if 1
{{else}}
  Inside else 1
{{elsif var}}
  Inside misplaced elsif
{{ENDIF}}

{{IF var}}
  Inside if 2
{{elsif var}}
  Inside elsif 2
{{else}}
  Inside else 2
{{else}}
  Inside misplaced else
{{ENDIF}}

{{elsif var}}
  Inside elsif 3
{{else}}
  Inside else 3
{{ENDIF}}

{{ENDLOOP}}

{{break}}
{{break level=2 /}}
{{continue}}
{{continue level=2/}}

{{loop outer}}
  {{break level = 0}}
  {{break level = 2}}
  {{break level = "non-numeric"}}
  {{continue level = 0}}
  {{continue level = 2}}
  {{continue level = "non-numeric"}}
  {{loop inner}}
    {{break level = 3}}
    {{continue level = 3}}
  {{ENDLOOP}}
{{ENDLOOP}}

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
Unexpected ENDIF tag in file "tmplfile" line 23
Unexpected ENDLOOP tag in file "tmplfile" line 25
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
{{IF var}}
  Inside  if 1
  {{loop loop}}
    Inside loop 1
  {{ENDIF}}
{{ENDLOOP}}

{{loop loop}}
  Inside loop 2
  {{IF var}}
    Inside if 2
  {{ENDLOOP}}
{{ENDIF}}

{{IF var}}
  Inside if 3
{{elsif bogus}}
  Inside elsif 1
  {{IF var}}
    Inside if 4
  {{else}}
    Inside else 1
  {{elsif var}}
    Inside elsif 2
  {{ENDIF}}
{{ENDIF}}
EOF

cat << "EOF" > expected
LOOP tag in file "tmplfile" line 3 has no ENDLOOP tag
Unexpected ENDLOOP tag in file "tmplfile" line 6
IF tag in file "tmplfile" line 10 has no ENDIF tag
Unexpected ENDIF tag in file "tmplfile" line 13
IF tag in file "tmplfile" line 19 has no ENDIF tag
Unexpected ENDIF tag in file "tmplfile" line 26
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
