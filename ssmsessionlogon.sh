#!/bin/sh

INSTANCEID=$(curl http://169.254.169.254/latest/meta-data/instance-id -s)
for f in /var/lib/amazon/ssm/$INSTANCEID/document/state/current/*
do
  SESSIONPID=$(cat $f | jq '.DocumentInformation.ProcInfo.Pid')
  if [[ "$SESSIONPID" == "$1" ]]; then
    SESSIONID=$(cat $f | jq -r '.DocumentInformation.MessageID')
    break;
  fi
done
FULLUSERNAME="${SESSIONID%-*}"
PARTUSERNAME="${FULLUSERNAME%@*}"
useradd $PARTUSERNAME &> /dev/null
su - $PARTUSERNAME