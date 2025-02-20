docker cp .\olist.sql olist_mysql:/backup.sql

mysql -u root -p olist < ./backup.sql