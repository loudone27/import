#========================================================================================#
#          -                                                                             #
#title              :Generate_conf                                                       #
#description        :Configuration file for Generate documentum log for logstash         #
#OS Compatibility   :Windows With Powershell                                             #
#author             :Hertzog Ludovic Amexio Compagny                                     #
#date               :03/09/2018                                                          #
#version            :1.1                                                                 #
#usage              :Must be in the conf folder                                          #
#========================================================================================#

#-----------------------
# Variables Declarations
#-----------------------

$DOCBASE="dctm04"
$USER_DOCBASE="dmadmin"
$USER_PWD="Password01"
$ACTUAL_PATH = pwd
$IDQL_PATH="D:\Apps\Documentum\product\7.3\bin"
$DEST_PATH="D:\logs\Logstash"
$QRY_SESSIONS="-R$ACTUAL_PATH\queries_files\qry_session_list.txt"					#Please Keep "-R" before the path
$QRY_USERADMIN="-R$ACTUAL_PATH\queries_files\qry_admin_user.txt"					#Please Keep "-R" before the path
$QRY_LOG_SESSIONS="$ACTUAL_PATH\logs_temp\session_logstash.log"

$QRY_LOG_USRADMIN="$ACTUAL_PATH\logs_temp\list_usradmin.log"
$QRY_LOG_USRADMIN1="$ACTUAL_PATH\logs_temp\list_usradmin1.log"
$QRY_LOG_USRADMIN2="$ACTUAL_PATH\logs_temp\list_usradmin2.log"
$QRY_LOG_USRADMIN3="$ACTUAL_PATH\logs_temp\list_usradmin3.log"
$QRY_LOG_USRADMIN_FINAL="$ACTUAL_PATH\logs_temp\list_usradmin_final.log"

$QRY_LOG_SESSIONS1="$ACTUAL_PATH\logs_temp\session_logstash1.log"
$QRY_LOG_SESSIONS2="$ACTUAL_PATH\logs_temp\session_logstash2.log"
$QRY_LOG_SESSIONS3="$ACTUAL_PATH\logs_temp\session_logstash3.log"
$QRY_LOG_SESSIONS4="$ACTUAL_PATH\logs_temp\session_logstash4.log"
$QRY_LOG_SESSIONS5="$ACTUAL_PATH\logs_temp\session_logstash5.log"
$QRY_LOG_SESSIONS_FINAL="$ACTUAL_PATH\logs_temp\session_logstash_final.log"
$QRY_LOG_SESSIONS_DEST="$DEST_PATH\session_logstash_final.log"
