#!/bin/sh

# This script will compress and move old data files older than certain days
# Change the arguments below

nofdays=120
sourcedir='/data2/db7/'
logfile='/tmp/tablescompressed-db7-comcastprod_staging.log'
tmpdir='/tmp'
#Below are the most important parameters
DB='comcastprod_staging'
MYSQL="mysql --socket=/var/lib/mysql/db7.sock $DB -A  -BCe"

# Split the master query into multiple small tables
$MYSQL "DROP TABLE if exists old_staging_tables; CREATE TABLE old_staging_tables SELECT distinct tablename, LAST_MODIFIED_DATE from N_DATA_LISTS where type in ('DATA_FILE','TMP','STAGING') AND LAST_MODIFIED_DATE < date_sub(now(),INTERVAL $nofdays DAY)"

$MYSQL " DROP TABLE IF EXISTS is_tablelist; CREATE TABLE is_tablelist select TABLE_NAME from INFORMATION_SCHEMA.TABLES where TABLE_SCHEMA = '$DB'; CREATE INDEX ix1 on is_tablelist(table_name)"

$MYSQL "SELECT a.tablename from old_staging_tables a, is_tablelist b WHERE a.tablename=b.table_name"> $tmpdir/tablelist-$DB.txt

touch $logfile

while read table
do
        echo "Compressing the files $table.* ..." >> $logfile
        echo "/bin/gzip $sourcedir/$DB/$table.*" >> $logfile
        /bin/gzip $sourcedir/$DB/$table.*
        echo "Compress completed for $table " >> $logfile
done < $tmpdir/tablelist-$DB.txt

