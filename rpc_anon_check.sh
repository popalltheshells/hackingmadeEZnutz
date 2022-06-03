#!/bin/bash
#twitter: @popalltheshells
a=0
while [ $a -le 254 ]
do
   echo "trying" $a
   #get list of anonymous RPC access from a subnet. Change the IP manually tho -- too lazy to make this script asks for inputs.
   rpcclient -U '' -N 10.0.0.$a 2>&1
   #get list of anonymous RPC access to enumerate domain users
   #rpcclient -U '' -N 10.0.0.$a -c enumdomusers 2>&1
   ((a++))
done
