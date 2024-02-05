#!/bin/bash
SG_ID=$(aws ec2 describe-security-groups --filters Name=tag:aws:eks:cluster-name,Values=tukktukk-prod-infra --query 'SecurityGroups[*].GroupId' --output text)
echo "{\"sg_id\":\"$SG_ID\"}"