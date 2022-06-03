#!/bin/bash
#medium: popalltheshells.medium.com
#twitter: @popalltheshells
a=0
while [ $a -le 254 ]
do
   #Check for anonymous SMB access to the following shares. populate the Username and Password if you have domain cred to see if they have access to the sha>
   #sample for domain user: smbclient //10.x.x.$a/IPC$ U "username"%"password" 2>&1
   #otherwise anonymous checks will be done.

   echo "trying" $a
   smbclient //10.x.x.$a/IPC$ U " "%" " 2>&1
   smbclient //10.240.20.$a/C$ U " "%" " 2>&1
   smbclient //10.x.x.$a/Public U " "%" " 2>&1
   smbclient //10.240.20.$a/Admin$ U " "%" " 2>&1

   ((a++))
done
