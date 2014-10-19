@echo off

set MIN_MEMORY=1G
set MAX_MEMORY=2G

set FORGE=forge-1.7.10-10.13.2.1230-universal.jar
java -Xms%MIN_MEMORY% -Xmx%MAX_MEMORY% -jar %FORGE% nogui

