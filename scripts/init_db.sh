ms="mysql -u$MYSQL_ROOT_USER -p$MYSQL_ROOT_PASSWORD -h$MYSQL_HOST"

YKKSMREADER_DB_NAME=ykksmreader
# YKKSMREADER_DB_PASSWORD=password_ykksmreader

YKKSMIMPORTER_DB_NAME=ykksmimporter
# YKKSMIMPORTER_DB_PASSWORD=ykksmimporter_password

RESULT=`$ms --skip-column-names -e "SHOW DATABASES LIKE 'ykksm'"`
if [ "$RESULT" == "ykksm" ]; then
    echo "Database ykksm exist skipping"
else
	echo "Generating ykksm database"
    echo 'create database ykksm' | $ms
	$ms ykksm < /usr/share/doc/yubikey-ksm/ykksm-db.sql
	
	echo "Granting ykksm access from localhost"
	{
	    echo "CREATE USER '${YKKSMREADER_DB_NAME}'@'localhost';"
	    echo "GRANT SELECT ON ykksm.yubikeys TO '${YKKSMREADER_DB_NAME}'@'localhost';"
	    echo "SET PASSWORD FOR '${YKKSMREADER_DB_NAME}'@'localhost' = PASSWORD('${YKKSM_READER_DB_PASSWORD}');"
	    echo "CREATE USER '${YKKSMIMPORTER_DB_NAME}'@'localhost';"
	    echo "GRANT INSERT ON ykksm.yubikeys TO '${YKKSMIMPORTER_DB_NAME}'@'localhost';"
	    echo "SET PASSWORD FOR '${YKKSMIMPORTER_DB_NAME}'@'localhost' = PASSWORD('${YKKSM_IMPORTER_DB_PASSWORD}');"
	    echo "FLUSH PRIVILEGES;"
	} | $ms

	echo "Granting ykksm access from %"
	{
	    echo "CREATE USER '${YKKSMREADER_DB_NAME}'@'%';"
	    echo "GRANT SELECT ON ykksm.yubikeys TO '${YKKSMREADER_DB_NAME}'@'%';"
	    echo "SET PASSWORD FOR '${YKKSMREADER_DB_NAME}'@'%' = PASSWORD('${YKKSM_READER_DB_PASSWORD}');"
	    echo "CREATE USER '${YKKSMIMPORTER_DB_NAME}'@'%';"
	    echo "GRANT INSERT ON ykksm.yubikeys TO '${YKKSMIMPORTER_DB_NAME}'@'%';"
	    echo "SET PASSWORD FOR '${YKKSMIMPORTER_DB_NAME}'@'%' = PASSWORD('${YKKSM_IMPORTER_DB_PASSWORD}');"
	    echo "FLUSH PRIVILEGES;"
	} | $ms
fi