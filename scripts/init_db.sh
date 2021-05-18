ms="mysql -u$MYSQL_ROOT_USER -p$MYSQL_ROOT_PASSWORD -h$MYSQL_HOST"

RESULT=`$ms --skip-column-names -e "SHOW DATABASES LIKE '${YKKSM_DB_NAME}'"`
if [ "$RESULT" == "${YKKSM_DB_NAME}" ]; then
    echo "Database ${YKKSM_DB_NAME} exist skipping"
else
	echo "Generating ${YKKSM_DB_NAME} database"
    echo "create database ${YKKSM_DB_NAME}" | $ms
	$ms ${YKKSM_DB_NAME} < /usr/share/doc/yubikey-ksm/ykksm-db.sql
	
	echo "Granting ${YKKSM_DB_NAME} access from localhost"
	{
	    echo "CREATE USER '${YKKSM_READER_DB_USER_NAME}'@'localhost';"
	    echo "GRANT SELECT ON ${YKKSM_DB_NAME}.yubikeys TO '${YKKSM_READER_DB_USER_NAME}'@'localhost';"
	    echo "SET PASSWORD FOR '${YKKSM_READER_DB_USER_NAME}'@'localhost' = PASSWORD('${YKKSM_READER_DB_USER_PASSWORD}');"
	    echo "CREATE USER '${YKKSM_IMPORTER_DB_USER_NAME}'@'localhost';"
	    echo "GRANT INSERT ON ${YKKSM_DB_NAME}.yubikeys TO '${YKKSM_IMPORTER_DB_USER_NAME}'@'localhost';"
	    echo "SET PASSWORD FOR '${YKKSM_IMPORTER_DB_USER_NAME}'@'localhost' = PASSWORD('${YKKSM_IMPORTER_DB_USER_PASSWORD}');"
	    echo "FLUSH PRIVILEGES;"
	} | $ms

	echo "Granting ${YKKSM_DB_NAME} access from %"
	{
	    echo "CREATE USER '${YKKSM_READER_DB_USER_NAME}'@'%';"
	    echo "GRANT SELECT ON ${YKKSM_DB_NAME}.yubikeys TO '${YKKSM_READER_DB_USER_NAME}'@'%';"
	    echo "SET PASSWORD FOR '${YKKSM_READER_DB_USER_NAME}'@'%' = PASSWORD('${YKKSM_READER_DB_USER_PASSWORD}');"
	    echo "CREATE USER '${YKKSM_IMPORTER_DB_USER_NAME}'@'%';"
	    echo "GRANT INSERT ON ${YKKSM_DB_NAME}.yubikeys TO '${YKKSM_IMPORTER_DB_USER_NAME}'@'%';"
	    echo "SET PASSWORD FOR '${YKKSM_IMPORTER_DB_USER_NAME}'@'%' = PASSWORD('${YKKSM_IMPORTER_DB_USER_PASSWORD}');"
	    echo "FLUSH PRIVILEGES;"
	} | $ms
fi