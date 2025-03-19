# Suppression des conteneurs:
cd /home/$(whoami)/wordpress
docker compose down
# Suppression des fichiers:
rm -rf /home/$(whoami)/OneCommandWPContainer/wordpress
rm -rf /home/$(whoami)/OneCommandWPContainer/uploads.ini

# Docker rm
docker rm $(docker ps -a -q) -f

sh ./InstallWPContainer.sh