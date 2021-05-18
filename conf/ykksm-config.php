<?php
$dbuser = getenv('YKKSM_READER_DB_USER_NAME');
$dbpass = getenv('YKKSM_READER_DB_USER_PASSWORD');
$basepath = '';
$dbname = getenv('YKKSM_DB_NAME');
$dbserver = getenv('MYSQL_HOST');
$dbport = getenv('MYSQL_PORT');
$dbtype = 'mysql';

$db_dsn      = "$dbtype:dbname=$dbname;host=$dbserver;port=$dbport";
$db_username = $dbuser;
$db_password = $dbpass;
$db_options  = array();
$logfacility = LOG_AUTH;
