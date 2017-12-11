#!/bin/bash
# Adds list of ip addresses separated by coma to defined security group

IFS=$','
ipList='10.10.10.10,20.20.20.20,30.30.30.30'
groupName='someGroup'

for i in $ipList;
        do echo $i;
        aws ec2 authorize-security-group-ingress --group-name $groupName --protocol tcp --port 22 --cidr ${i}/32
done
