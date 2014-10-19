#!/usr/bin/env bash

MIN_MEMORY=1G
MAX_MEMORY=2G

FORGE=forge-1.7.10-10.13.2.1230-universal.jar
java -Xms$MIN_MEMORY -Xmx$MAX_MEMORY -jar $FORGE nogui

