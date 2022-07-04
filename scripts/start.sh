#!/bin/bash
DESIGNATION_TAG_VALUE="nginx-development"

echo "# Getting targets..."
targets="$(/usr/local/bin/aws --profile nginx ec2 describe-instances --query 'Reservations[].Instances[][].{Instances: InstanceId}' --output text --filters "Name=tag:Designation,Values=${DESIGNATION_TAG_VALUE}" --output=text)"

if [ "$?" -ne 0 ] || [ -z ${targets} ]; then
    echo "Target selection failed."
    exit 1
fi

echo "# $(date) Starting targets..."
/usr/local/bin/aws --profile nginx ec2 start-instances --instance-ids ${targets}

echo "# $(date) Waiting for targets to start..."
/usr/local/bin/aws --profile nginx ec2 wait instance-running --instance-ids ${targets}

echo "# $(date) Waiting for target status to be OK..."
/usr/local/bin/aws --profile nginx ec2 wait instance-status-ok --instance-ids ${targets}

echo "# $(date) Start complete!"
