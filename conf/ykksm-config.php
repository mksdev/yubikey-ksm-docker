<?php
$dbuser = 'ykksmreader';
$dbpass = getenv('YKKSM_READER_DB_PASSWORD');
$basepath = '';
$dbname = 'ykksm';
$dbserver = getenv('MYSQL_HOST');
$dbport = getenv('MYSQL_PORT');
$dbtype = 'mysql';

$db_dsn      = "$dbtype:dbname=$dbname;host=$dbserver;port=$dbport";
$db_username = $dbuser;
$db_password = $dbpass;
$db_options  = array();
$logfacility = LOG_AUTH;
