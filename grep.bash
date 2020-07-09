#!/bin/bash

buildFindCmd='
def join(s, items):	return s.join([i for i in items if i!=""])

import argparse
p = argparse.ArgumentParser()
p.add_argument("--path", default="")
p.add_argument("--args", default="")
p.add_argument("--quote", default="\"")
p.add_argument("--exts", default=[], nargs="*")
p.add_argument("--files", default=[], nargs="*")
p.add_argument("--ignores", default=[], nargs="*")
args = p.parse_args()

ext = join(" -or ", ["-iname {q}*.{s}{q}".format(q=args.quote, s=s) for s in args.exts])
file = join(" -or ", ["-iname {q}{s}{q}".format(q=args.quote, s=s) for s in args.files])
ignore = join(" -and ", ["-not \( -path {q}{s}{q} -prune \)".format(q=args.quote, s=s) for s in args.ignores])

match = join(" -or ", [ext, file])
match = "\( " + match + " \)" if len(match) else ""

limitMatch = join(" -and ", [ignore, match])

print join(" ", ["find", args.path, args.args, limitMatch])
'

function catspreadsheet () {
	handler_ods=ods2csvstdout
	handler_xls=py_xls2txt
	handler_xlsx=xlsx2csv

	filename="$1"
	filenameLower="${filename,,}"
	if [[ $filenameLower == *.ods ]]; then
		$handler_ods "$@"
	elif [[ $filenameLower == *.xlsx ]]; then
		$handler_xlsx "$@" 2>/dev/null
	elif [[ $filenameLower == *.xls ]]; then
		$handler_xls "$@" 2>/dev/null
	else
		echo "No handler defined for $filename" >&2
	fi
}
export -f catspreadsheet

function greptxt () {
	local declare path="$1"; shift;
	local declare fargs="-type f"
	local declare gargs="--no-messages --with-filename --line-number --color=always"
	local declare exts=(md txt log csv)
	local declare files=( )
	local declare ignores=(.git .svn .settings)
	local fcmd="$(python -c "$buildFindCmd" --args "${fargs}" --path "${path}" --exts ${exts[@]} --files ${files[@]} --ignores ${ignores[@]} --quote=\')"
	eval $fcmd | parallel --keep-order --max-procs -1 --max-args 1000 -m grep $gargs $@ {}
}

function grepsrc () {
	local declare path="$1"; shift;
	local declare fargs="-type f"
	local declare gargs="--no-messages --with-filename --line-number --color=always"
	# local declare gargs="--files-with-matches"
	local declare exts=(h c hpp cpp mkdep makefile mak mk config asm inc cmd idl sh bash json xml)
	local declare files=(makefile make.rules)
	local declare ignores=(.git .svn .settings)
	local fcmd="$(python -c "$buildFindCmd" --args "${fargs}" --path "${path}" --exts ${exts[@]} --files ${files[@]} --ignores ${ignores[@]} --quote=\')"
	eval $fcmd | parallel --keep-order --max-procs -1 --max-args 1000 -m grep $gargs $@ {} | perl -pe 's/^(.+?:.+?):(.*)/$1 $2/'
}

function greppdf () {
	local declare path="$1"; shift;
	local declare fargs="-type f"
	local declare gargs="--no-messages --with-filename --line-number --color=always"
	local declare exts=(pdf)
	local declare files=()
	local declare ignores=(.git .svn .settings)
	local fcmd="$(python -c "$buildFindCmd" --args "${fargs}" --path "${path}" --exts ${exts[@]} --files ${files[@]} --ignores ${ignores[@]} --quote=\')"
	eval $fcmd | parallel --keep-order --max-procs -1 --max-args 1 -m "pdftotext -q {} - | grep $gargs --label={} $@ -"
}

function grepdoc () {
	local declare path="$1"; shift;
	local declare fargs="-type f"
	local declare gargs="--no-messages --with-filename --line-number --color=always"
	local declare exts=(doc)
	local declare files=()
	local declare ignores=(.git .svn .settings)
	local fcmd="$(python -c "$buildFindCmd" --args "${fargs}" --path "${path}" --exts ${exts[@]} --files ${files[@]} --ignores ${ignores[@]} --quote=\')"
	eval $fcmd | parallel --keep-order --max-procs -1 --max-args 1 -m "antiword {} | grep $gargs --label={} $@ -"
}

function grepdocx () {
	local declare path="$1"; shift;
	local declare fargs="-type f"
	local declare gargs="--no-messages --with-filename --line-number --color=always"
	local declare exts=(docx)
	local declare files=()
	local declare ignores=(.git .svn .settings)
	local fcmd="$(python -c "$buildFindCmd" --args "${fargs}" --path "${path}" --exts ${exts[@]} --files ${files[@]} --ignores ${ignores[@]} --quote=\')"
	eval $fcmd | parallel --keep-order --max-procs -1 --max-args 1 -m "cat_open_xml.pl {} | grep $gargs --label={} $@ -"
}

function grepmd () {
	local declare path="$1"; shift;
	local declare fargs="-type f"
	local declare gargs="--no-messages --with-filename --line-number --color=always"
	local declare exts=(md markdown)
	local declare files=()
	local declare ignores=(.git .svn .settings)
	local fcmd="$(python -c "$buildFindCmd" --args "${fargs}" --path "${path}" --exts ${exts[@]} --files ${files[@]} --ignores ${ignores[@]} --quote=\')"
	eval $fcmd | parallel --keep-order --max-procs -1 --max-args 1000 -m grep $gargs $@ {}
}

function grepods () {
	local declare path="$1"; shift;
	local declare fargs="-type f"
	local declare gargs="--no-messages --with-filename --color=always"
	local declare exts=(ods)
	local declare files=()
	local declare ignores=(.git .svn .settings)
	local fcmd="$(python -c "$buildFindCmd" --args "${fargs}" --path "${path}" --exts ${exts[@]} --files ${files[@]} --ignores ${ignores[@]} --quote=\')"
	eval $fcmd | parallel --keep-order --max-procs -1 --max-args 1 -m "ods2csvstdout {} | grep $gargs --label={} $@ -"
}

# Find and grep a spreadsheet
function grepss () {
	local declare path="$1"; shift;
	local declare fargs="-type f"
	local declare gargs="--no-messages --with-filename --color=always"
	local declare exts=(ods xls xlsx)
	local declare files=()
	local declare ignores=(.git .svn .settings)
	local fcmd="$(python -c "$buildFindCmd" --args "${fargs}" --path "${path}" --exts ${exts[@]} --files ${files[@]} --ignores ${ignores[@]} --quote=\')"
	eval $fcmd | parallel --keep-order --max-procs -1 --max-args 1 -m "catspreadsheet "{}" | grep $gargs --label={} $@ -"
}

function greppy () {
	local declare path="$1"; shift;
	local declare fargs="-type f"
	local declare gargs="--no-messages --with-filename --line-number --color=always"
	local declare exts=(py)
	local declare files=()
	local declare ignores=(.git .svn .settings)
	local fcmd="$(python -c "$buildFindCmd" --args "${fargs}" --path "${path}" --exts ${exts[@]} --files ${files[@]} --ignores ${ignores[@]} --quote=\')"
	eval $fcmd | parallel --keep-order --max-procs -1 --max-args 1000 -m grep $gargs $@ {}
}

function grepfpga () {
	local declare path="$1"; shift;
	local declare fargs="-type f"
	local declare gargs="--no-messages --with-filename --line-number --color=always"
	local declare exts=(v vhdl vhd)
	local declare files=()
	local declare ignores=(.git .svn .settings)
	local fcmd="$(python -c "$buildFindCmd" --args "${fargs}" --path "${path}" --exts ${exts[@]} --files ${files[@]} --ignores ${ignores[@]} --quote=\')"
	eval $fcmd | parallel --keep-order --max-procs -1 --max-args 1000 -m grep $gargs $@ {}
}
