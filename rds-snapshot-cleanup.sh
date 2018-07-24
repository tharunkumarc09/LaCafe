#!/bin/bash

date1=$(date --date="1 days ago" +%F)
date2=$(date --date="2 days ago" +%F)
date3=$(date --date="3 days ago" +%F)
echo $date1 $date2 $date3

get_rds() {
        aws rds describe-db-snapshots  --query "DBSnapshots[].[DBSnapshotArn]" --output text
}

remove_rds_using_tags() {
        expire=$(aws rds list-tags-for-resource --resource-name "$1" --query 'TagList[?Key==`expiration`].Value')
        expire=$(echo $expire | cut -c4-)
        expire=${expire:0:-3}
        echo $expire
        if [ "$expire" == "$date1" ]
        then
           echo "matching"
           snapshotid=$(echo "$1" | rev | cut -d':' -f1 | rev)
           echo $snapshotid
           aws rds delete-db-snapshot --db-snapshot-identifier $snapshotid
        else
                echo "Not matching"
        fi
}

for id in $(get_rds)
do
        echo $id
        remove_rds_using_tags $id
        echo ""
done