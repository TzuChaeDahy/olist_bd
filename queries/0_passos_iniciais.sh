# Usei o MySQL dentro de um container docker, logo é necessário 
# copiar o arquivo de backup pra dentro do container
docker cp .\olist.sql olist_mysql:/backup.sql

# Rodar o arquivo de backup dentro do terminal MySQL
mysql -u root -p olist < ./backup.sql