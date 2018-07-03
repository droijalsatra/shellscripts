
#!/bin/bash

# Destination path
cd /tmp/backups_wiki

# Dump database
mongodump --host localhost --db wiki --port 27017 --out backup_wiki_`date +%Y%m%d`

# (in order to restore upload backup to destination path, uncompress it and launch: mongorestore --host localhost --port 27017 /tmp/backups_wiki/<file_uncompressed_to_restore>)

# Delete all files EXCEPT last 10 (most recent ones, disk IS NOT FREE, buddies)
ls -t /tmp/backups_wiki/ | tail -n +11 | xargs -I {} rm {}

# Compress and send by email
tar -czf backup_wiki_`date +%Y%m%d`.gz backup_wiki_`date +%Y%m%d` | uuencode backup_wiki_`date +%Y%m%d`.gz | mail -r AtrapaBackupeador -s "Backup de la Wiki de Sistemas" daniel.roijals@atrapalo.com xavier.rodriguez@atrapalo.com ivo.sandoval@atrapalo.com
