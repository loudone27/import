#========================================================================================#
#          -                                                                             #
#title              :Generate.ps1                                                        #
#description        :Module for Generate documentum log for logstash                     #
#OS Compatibility   :Windows With Powershell                                             #
#author             :Hertzog Ludovic Amexio Compagny                                     #
#date               :03/09/2018                                                          #
#version            :1.1                                                                 #
#usage              :Must be run as Administrator                                        #
#========================================================================================#

#-----------------------
# Variables Declarations
#-----------------------
$ACTUAL_PATH = pwd
. ./conf/Generate_conf.ps1

#------------------
# Get Computer Name
#------------------

$HOSTNAME = (Get-WmiObject -Class Win32_ComputerSystem -Property Name).Name

#-------------
# Cleaning log
#-------------

function clean_logs()
{
  if((Test-Path -path $QRY_LOG_USRADMIN ))
  {
    rm $QRY_LOG_USRADMIN 2> $null
  }
  
  if((Test-Path -path $QRY_LOG_USRADMIN1 ))
  {
    rm $QRY_LOG_USRADMIN1 2> $null
  }
  
  if((Test-Path -path $QRY_LOG_USRADMIN2 ))
  {
    rm $QRY_LOG_USRADMIN2 2> $null
  }
  
  if((Test-Path -path $QRY_LOG_USRADMIN3 ))
  {
    rm $QRY_LOG_USRADMIN3 2> $null
  }
  
  if((Test-Path -path $QRY_LOG_SESSIONS ))
  {
    rm $QRY_LOG_SESSIONS 2> $null
  }

  if((Test-Path -path $QRY_LOG_SESSIONS1 ))
  {
    rm $QRY_LOG_SESSIONS1 2> $null
  }

  if((Test-Path -path $QRY_LOG_SESSIONS2 ))
  {
    rm $QRY_LOG_SESSIONS2 2> $null
  }

  if((Test-Path -path $QRY_LOG_SESSIONS3 ))
  {
	  rm $QRY_LOG_SESSIONS3 2> $null
  }
  
  if((Test-Path -path $QRY_LOG_SESSIONS4 ))
  {
	  rm $QRY_LOG_SESSIONS4 2> $null
  }
  
  if((Test-Path -path $QRY_LOG_SESSIONS5 ))
  {
	  rm $QRY_LOG_SESSIONS5 2> $null
  }
}

function get_admin_user()
{
  #--------------------------------------------------------
  # execute query for admin user and Generate variable list
  #--------------------------------------------------------
  
  invoke-expression "& `"$IDQL_PATH\idql.exe`" -U$USER_DOCBASE -P$USER_PWD $DOCBASE $QRY_USERADMIN -w30  > $QRY_LOG_USRADMIN" 2> $null
  sleep 5
  if(!(Test-Path -path $QRY_LOG_USRADMIN ))
  {
    Write-Host "Enable to Generate the Sessions Log, Please check the docbase $DOCBASE"
    exit
  }
  
  #------------------------------------------
  # 1er Step remove first unless line in file
  #------------------------------------------
  
  (Get-Content $QRY_LOG_USRADMIN | Select-Object -Skip 13) | Set-Content $QRY_LOG_USRADMIN1
  
  #--------------------------------------------------
  # 2nd Step remove the last Three lines of the Files
  #--------------------------------------------------
  
  $remove = get-content $QRY_LOG_USRADMIN1
  $remove[0..($remove.length-3)] | Set-Content $QRY_LOG_USRADMIN2
  
  #------------------------------------------
  # 3rd Step remove All Double Space in regex
  #------------------------------------------
  
  Get-Content $QRY_LOG_USRADMIN2 | % {$_ -replace '\s\s+', ';'} | Set-Content $QRY_LOG_USRADMIN3

  #------------------------------------------
  # 4rd Step remove last string on each line
  #------------------------------------------
  (Get-Content $QRY_LOG_USRADMIN3) -replace '.$', '' | Set-Content $QRY_LOG_USRADMIN_FINAL

}

function show_session()
{
  
  #----------------------------------------------------
  # execute Show_Sessions and Generate Log for Logstash
  #----------------------------------------------------
  
  invoke-expression "& `"$IDQL_PATH\idql.exe`" -U$USER_DOCBASE -P$USER_PWD $DOCBASE $QRY_SESSIONS -w20  > $QRY_LOG_SESSIONS" 2> $null 
  
  if(!(Test-Path -path $QRY_LOG_SESSIONS ))
  {
    Write-Host "Enable to Generate the Sessions Log, Please check the docbase $DOCBASE"
    exit
  }
  
  #------------------------------------------
  # 1er Step remove first unless line in file
  #------------------------------------------
  
  (Get-Content $QRY_LOG_SESSIONS | Select-Object -Skip 13) | Set-Content $QRY_LOG_SESSIONS1
  
  #-------------------------------------------------------------
  # 2nd Step remove All Double Space en regex and replace by ";"
  #-------------------------------------------------------------
  
  Get-Content $QRY_LOG_SESSIONS1 | % {$_ -replace '\s\s+', ';'} | Set-Content $QRY_LOG_SESSIONS2
  
  #--------------------------------------------------
  # 3rd Step remove the last Three lines of the Files
  #--------------------------------------------------
  
  $remove = get-content $QRY_LOG_SESSIONS2
  $remove[0..($remove.length-3)] | Set-Content $QRY_LOG_SESSIONS3

  #----------------------------------------------------
  # 5th Step add user admin Boolean Flag on every line 
  #----------------------------------------------------
  
  (Get-Content $QRY_LOG_SESSIONS3) -replace '\S+$','$&F;' | Set-Content $QRY_LOG_SESSIONS3
  (Get-Content $QRY_LOG_SESSIONS3) | Set-Content $QRY_LOG_SESSIONS4
  
  #----------------------------------------------------------
  # 6th Step Modify Boolean false to true for only user admin
  #----------------------------------------------------------
  
  $content = Get-Content $QRY_LOG_SESSIONS4
  foreach($line in (Get-Content $QRY_LOG_USRADMIN_FINAL)) {
    $content = $content -replace "($line.*)F;$", '$1T;'
  }
  $content | Set-Content $QRY_LOG_SESSIONS5
  
  #---------------------------------------------------------------------
  # 7th Add docbase_name & Computer_name at the beginning for each lines
  #---------------------------------------------------------------------
  
  $add_docbase = get-content $QRY_LOG_SESSIONS5
  $add_docbase = $add_docbase  | foreach {"$HOSTNAME;$DOCBASE;" + $_ } | Set-Content $QRY_LOG_SESSIONS_FINAL

  #-----------------------------------------------
  # 8th Step remove ";" at the end for each lines
  #-----------------------------------------------

(Get-Content $QRY_LOG_SESSIONS_FINAL) -replace '.$', '' | Set-Content $QRY_LOG_SESSIONS_FINAL

}

#---------------------------------------
# Copy Log session to logstash directory
#---------------------------------------

function copy_file()
{
  cp $QRY_LOG_SESSIONS_FINAL $QRY_LOG_SESSIONS_DEST
}


clean_logs
get_admin_user
show_session
copy_file
clean_logs
