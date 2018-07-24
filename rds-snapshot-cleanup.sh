#!/bin/bash

date=$(date +%F)
# date2=$(date --date="2 days ago" +%F)
# date3=$(date --date="3 days ago" +%F)
echo $date

get_rds() {
        aws rds describe-db-snapshots --snapshot-type manual --query "DBSnapshots[].[DBSnapshotArn]" --output text
}

remove_rds_using_tags() {
        expire=$(aws rds list-tags-for-resource --resource-name "$1" --query 'TagList[?Key==`expiration`].Value')
        if [[ ! -z $expire ]]
        then
                expire=$(echo $expire | cut -c4-)
                echo $expire
                expire=${expire:0:-3}
                echo $expire
                        if [ "$expire" == "$date" ]
                        then
                                echo "Expiration date matching the current date.. Proceeding with Purging"
                                snapshotid=$(echo "$1" | rev | cut -d':' -f1 | rev)
                                echo $snapshotid
                                #   aws rds delete-db-snapshot --db-snapshot-identifier $snapshotid
                        else
                                echo "Expiration date not matching the current date"
                        fi
        else
                echo "No expiration tag for the snapshot"
        fi

}

for id in $(get_rds)
do
        echo $id
        remove_rds_using_tags $id
        echo ""
done
