#!/bin/bash

OPTION=$1
VALUE=$2
LOGFILE=./logs/logs.log

tar -xf logs.tar.bz2 || { echo "Error occurred while extracting" $$ rm -rf $(pwd)/logs && exit 1; }

case $OPTION in
 "--user-agent")
    if [ -z "$VALUE" ]; then
        echo "You need to provide argument for --user-agent option. --user-agent <parameter>"
        rm -rf $(pwd)/logs && exit 1
    fi
    printf "%-30s %-30s %s\n"  "ADDRESS" "COUNT" "USER-AGENT" > Parsed_User_Agent_Log.txt
    paste -d ' ' <(grep -oP 'client_ip: "\K[^"]+' $LOGFILE) <(grep -oP 'user_agent: "\K[^"]+' $LOGFILE) | \
    grep $VALUE | uniq -c | \
    awk '{  concat = $3; 
            for (i=4; i<=NF; i++) 
            concat = concat " " $i; 
            printf "%-30s %-30s %s\n", $2, $1, concat 
        }' >> Parsed_User_Agent_Log.txt
;;
 "--method")
    printf "%-30s %-30s %s\n" "ADDRESS" "METHOD" "COUNT" > Parsed_Method_Log.txt
    paste -d ' ' <(grep -oP 'client_ip: "\K[^"]+' $LOGFILE) <(grep -oP 'method: "\K[^"]+' $LOGFILE) | \
    sort | uniq -c | awk '{ printf "%-30s %-30s %d\n", $2, $3, $1 }' >> Parsed_Method_Log.txt

;;
 *)
    printf "%-30s %s\n" "ADDRESS" "REQUESTS" > Parsed_Requests_Log.txt
    awk -F'client_ip:' '{ gsub(/"/, "", $2); print $2 }' $LOGFILE | sort | uniq -c | sort -n | \
    awk '{ printf "%-30s %s\n", $2, $1 }' >> Parsed_Requests_Log.txt
;;
esac

rm -rf $(pwd)/logs
