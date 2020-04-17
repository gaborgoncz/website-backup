#!/bin/bash
if [ -z "$1" ]
  then
    echo "No argument supplied"
    exit 1
fi

#root_path="`dirname \"$0\"`"
#echo "$MY_PATH"
#root_path=$PWD

config=$1
source $config
#source $root_path"/backups/"$config".txt"

echo "Name:                "$name
echo "Source Path:         "$source_path
echo "Source SQL host:     "$source_sqlhost
echo "Source SQL username: "$source_sqluser
echo "Source SQL password: "$source_sqlpass
echo "Source SQL database: "$source_database
echo "Temp Path:           "$temp_path
echo "Destination Path:    "$destination_path

backup_date=$(date "+%Y%m%d-%H%M")
backup_path=$destination_path"/"$name
backup_temppath=$temp_path"/"$name
backup_name=$name"_"$backup_date
rclone_config=${config%%.*}"_rclone.conf"

echo "Backup Date:         "$backup_date
echo "Backup Path:         "$backup_path
echo "Backup Temp Path:    "$backup_temppath
echo "rClone Config:       "${config%%.*}"_rclone.conf"
echo "rClone Executable:   "$rclone_exe
echo "Purge Executable:    "$purge_exe
echo "Purge Parameters:    "$purge_exeparm
#mkdir -p $name
mkdir -p $backup_path

rm -f -r $backup_temppath
mkdir -p $backup_temppath

tar -cvpf $backup_temppath"/files.tar" $source_path > $backup_temppath"/files_backup.log"
#echo "mysqldump -h $source_sqlhost -u $source_sqluser -p"$source_sqlpass" $source_database"
mysqldump -h $source_sqlhost -u $source_sqluser -p"$source_sqlpass" $source_database | gzip > $backup_temppath"/database.sql.gz"

zip -rm9j $backup_path"/"$backup_name".zip" $backup_temppath"/"

$purge_exe $purge_exeparm $backup_path

if [ ! -f $rclone_config ]
  then
    echo "No rclone config file"
    exit 1
fi
$rclone_exe --config $rclone_config sync -P local:$backup_path"/" remote_crypt:/$name


exit

#! /bin/bash
TIMESTAMP=$(date +"%F")
BACKUP_DIR=/home/bookclub-englishbitbybit/backups
TEMP_DIR=/tmp

BACKUP_DIR=/temp/My-Backup-$TIMESTAMPMYSQL_USER="your-db-username"
MYSQL=/usr/bin/mysql
MYSQL_PASSWORD="your-db-username-password"
MYSQLDUMP=/usr/bin/mysqldump
DATABASE=your-db-name

mkdir -p "$BACKUP_DIR/mysql"
$MYSQLDUMP --force --opt --user=$MYSQL_USER -p$MYSQL_PASSWORD $DATABASE | gzip > "$BACKUP_DIR/mysql/$DATABASE.gz"

mkdir -p "$BACKUP_DIR/web_dir"
SRCDIR=/var/www/html/
DESTDIR=$BACKUP_DIR/web_dir/
FILENAME=My-WWW-Backup-$TIMESTAMP.tgz
tar --create --gzip --file=$DESTDIR$FILENAME $SRCDIR

tar --create --gzip --file=/backups/My-Backup-$TIMESTAMP.tgz $BACKUP_DIR

rm -rf /temp/*

wait
echo "Backup of DB and Web Directory Complete!"

