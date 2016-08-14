#!/bin/bash

LOGS_DIR=Logs
mkdir -p $LOGS_DIR

SYS_NAME_LOG_DIR=$LOGS_DIR/SysNameLogs
mkdir -p $SYS_NAME_LOG_DIR

CSV=SystemNameLabel.csv
rm -rf $CSV

SYSTEM_LABEL_GETTER_SCRIPT=systemNameLabelgetter.rb
echo "Launching $SYSTEM_LABEL_GETTER_SCRIPT"
ruby $SYSTEM_LABEL_GETTER_SCRIPT $CSV > "$SYS_NAME_LOG_DIR/$(date).log"
echo "Finished making game system CSV"

SCANNER_LOG_DIR=$LOGS_DIR/ScannerLogs
mkdir -p $SCANNER_LOG_DIR

THIS_SCANNER_LOG_DIR="$SCANNER_LOG_DIR/$(date)"
mkdir -p "$THIS_SCANNER_LOG_DIR"

OUTPUT_DIR=Output
INSTANCE_OUTPUT_DIR="$OUTPUT_DIR/$(date)"
mkdir -p $OUTPUT_DIR
mkdir -p "$INSTANCE_OUTPUT_DIR"

echo "Starting process to launch Metacritic scanners"
OLDIFS=$IFS
IFS=,
[ ! -f $CSV ] && { echo "$CSV file not found"; exit 99; }
sed 1d $CSV | while read sysName sysLabel 
do
	echo "Launching $sysLabel"
	nohup ruby scanner.rb $sysLabel "$INSTANCE_OUTPUT_DIR/Games.csv" "$INSTANCE_OUTPUT_DIR/Genres.csv" "$INSTANCE_OUTPUT_DIR/Publishers.csv" "$INSTANCE_OUTPUT_DIR/Critics.csv" > "$THIS_SCANNER_LOG_DIR/$sysLabel.log" 2>&1 &
	sleep 1
done