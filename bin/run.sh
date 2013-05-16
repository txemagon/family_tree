#!/bin/bash
# run.sh

bundle exec bin/family_tree $1 | ccomps -x | dot | gvpack -array3 | neato | display
