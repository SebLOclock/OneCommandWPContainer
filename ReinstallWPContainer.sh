# Suppression des conteneurs:
cd /home/student/wordpress
docker compose down
# Suppression des fichiers:
rm -rf /home/student/OneCommandWPContainer/wordpress
rm -rf /home/student/OneCommandWPContainer/uploads.ini

# Docker rm
docker rm $(docker ps -a -q) -f

sh ./InstallWPContainer.sh
