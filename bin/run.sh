#!/bin/bash
# run.sh

COMMAND="bundle exec bin/family_tree "
PROC=( 'dot ' 'ccomps -x | dot | gvpack -array3 | neato ')
# DISPLAY=(' ' '| display')

pr=0 
disp=0

usage()
{

cat <<FIN
  run.sh [options] input_file

    -h  Shows help and exit
    -d  Opens graphic display
    -n  Rearranges dot output to compact graphic
        Needs -d display option

    run.sh depends on graphviz. Please install it on 
    your system if you still don't have it.

FIN

      exit 1

}

while getopts ":dnh" opt; do
  case $opt in
    h)
      usage
      ;;
    d)
      disp=1
      ;;
    n)
      pr=1
      ;;
  esac
done

shift $(($OPTIND-1))

if [ $# -eq "0" ]; then
  usage
fi

FINAL="$COMMAND $1" 
if [ $disp -eq "1" ]; then
    FINAL="$COMMAND $1 | ${PROC[pr]}"
fi

echo "Executing: $FINAL"

if [ $disp -eq "1" ]; then
    eval `echo "$FINAL"` | display
else
    eval `echo "$FINAL"`
fi
