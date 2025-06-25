#!/bin/bash

git pull

# Suppression des conteneurs:
cd wordpress || exit
docker compose down -v

# Suppression des fichiers:
rm -rf uploads.ini
rm -rf docker-compose.yml

# Nettoyage des conteneurs Docker
docker system prune -f

# Réinstallation
sh ../InstallWPContainer.sh
