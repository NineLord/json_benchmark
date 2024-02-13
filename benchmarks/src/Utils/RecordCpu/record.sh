#!/bin/bash

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

filePath="$1"
numberOfCores="$2"

if [ -z "$numberOfCores" ]; then
    numberOfCores="4"
fi
let "intNumberOfCores = $numberOfCores * 100"

if [ -z "$filePath" ]; then
    echo "First argument has to be path to csv file"
    exit 0
fi

rm -rf "$filePath"
echo -en "CPU Average:,,CPU Maximum:,,CPU Minimum:,\nCPU Average (out of $intNumberOfCores%):,,CPU Maximum (out of $intNumberOfCores%):,,CPU Minimum (out of $intNumberOfCores%):,\nRAM Average (MB):,,RAM Maximum (MB):,,RAM Minimum (MB):,\nSwp Average (MB):,,Swp Maximum (MB):,,Swp Minimum (MB):,\n,\n" > "$filePath"
for ((index=1; index<="${numberOfCores}"; index++)); do
    echo -en "Core ${index}," >> "$filePath"
done
echo -e "Sum Cores,Avg Cores,RAM Used (MB),Total RAM,Swp Used (MB),Total Swp," >> "$filePath"

echo "Starting to run!"
while true; do
    echo | htop -u nobody -C | head -c -10 | tail -c +10 | "${SCRIPT_DIR}/pipeIntoMe.js" "$numberOfCores" >> "$filePath" || break
done
exit 0
