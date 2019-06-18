#!/bin/bash
# SCRIPT to download (and compress) accesslogs from S3 (bucket: YOUR_BUCKET_NAME)
# USAGE: <script.sh> StartDate (format: YYYY-MM-DD) FinalDate (format: YYYY-MM-DD)
# Sample: <script.sh> 2019-06-15 2019-06-19
# It will download logs from S3 bucket, compress a single file for each day and 
# remove log single files, reamining only a compressed file for every day.

S3_CONFIG_PATH="/etc/s3cfg-configfile"
REMOTE_PATH="s3://your_bucket"
LOCAL_PATH_PRO="/mnt/logs/"
StartDate="$1"
FinalDate="$2"

# No variables values, no job (life sucks!)
if [ -z "$StartDate" ] && [ -z "$FinalDate" ]; then
   echo "ERROR - No values informed. Please retry with, at least, an initial date."
   exit 1
fi

# We do not have a final date, so we want just one day logs
if [ -z "$FinalDate" ]; then
   s3cmd -c $S3_CONFIG_PATH get --skip-existing $REMOTE_PATH/$StartDate* $LOCAL_PATH_PRO
   cd $LOCAL_PATH_PRO
   tar -czf S3Logs_$StartDate.tar.gz $StartDate*
   chmod 755 S3Logs_$StartDate.tar.gz
   rm -f $StartDate*
   echo "Log file available at: $LOCAL_PATH_PRO filename: S3Logs_$StartDate.tar.gz"
   exit 0
else
# We've got an initial date and final date (range between dates)     

   # Basic error control (final date older than initial date ~ inverted dates) 
   date1=$(date -d $StartDate +%s)
   date2=$(date -d $FinalDate +%s)

   if [[ "$date1" > "$date2" ]]; then
      echo "IMPORTANT NOTICE !!! - Your final date is older than your Initial date"
      echo "Let's rotate these values ;)"

      # Re-assign values fecha1 <-> fecha2
      StartDate=$2
      FinalDate=$1

      # Date Iteration
      starts=$(date -d $StartDate "+%Y-%m-%d")
      ends=$(date -d $FinalDate "+%Y-%m-%d")

      while [[ $starts < $ends ]] || [[ $starts = $ends ]]
      do
        s3cmd -c $S3_CONFIG_PATH get --skip-existing $REMOTE_PATH/$starts* $LOCAL_PATH_PRO
        Current_Day=$(date -d $date1 "+%Y-%m-%d")
        cd $LOCAL_PATH_PRO
        tar -czf S3Logs_$Current_Day.tar.gz $Current_Day*
        chmod 755 S3Logs_$Current_Day.tar.gz
        rm -f $Current_Day*
        echo "Log file available  at: $LOCAL_PATH_PRO filename: S3Logs_$starts.tar.gz"
        starts=$(date -d"$date1 + 1 day" +"%Y-%m-%d")        
      done
      exit 0
   else
      # Date Iteration
      starts=$(date -d $StartDate "+%Y-%m-%d")
      ends=$(date -d $FinalDate "+%Y-%m-%d")

      while [[ $starts < $ends ]] || [[ $starts = $ends ]]
      do
        s3cmd -c $S3_CONFIG_PATH get --skip-existing $REMOTE_PATH/$starts* $LOCAL_PATH_PRO
        Current_Day=$(date -d $date1 "+%Y-%m-%d")
        cd $LOCAL_PATH_PRO
        tar -czf S3Logs_$Current_Day.tar.gz $Current_Day*
        chmod 755 S3Logs_$Current_Day.tar.gz
        rm -f $Current_Day*
        echo "Log file available at: $LOCAL_PATH_PRO filename: S3Logs_$starts.tar.gz"
        starts=$(date -d"$date1 + 1 day" +"%Y-%m-%d")
      done
      exit 0
   fi
fi
exit 0
