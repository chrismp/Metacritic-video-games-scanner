#!/bin/bash

rm -rf *.csv
rm -rf Logs/*.log

LOGS_DIR=Logs
mkdir -p $LOGS_DIR

export PAGES=`ruby pageNumGetter.rb`
PAGE_NUMBER=0
DIVIDER=2

while [[ $PAGE_NUMBER -lt $PAGES ]]; do
	nohup ruby scanner.rb $PAGE_NUMBER > "$LOGS_DIR/$PAGE_NUMBER.log" 2>&1 &
	PAGE_NUMBER=$[$PAGE_NUMBER+$DIVIDER]
done
