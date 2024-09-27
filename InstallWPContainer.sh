# Author: Sebastien Lemoine
# Date: 2024-09-26
# Description: Ce script permet d'installer un environnement de développement WordPress avec Docker.

# Ajout des dépôts Docker à Apt:
sudo apt-get update
sudo apt-get install ca-certificates curl
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

# Add the repository to Apt sources:
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update

# Installation de Docker:
sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# Démarrage et activation de Docker:
sudo systemctl start docker
sudo systemctl enable docker

# Ajout de l'utilisateur courant au groupe Docker:
sudo usermod -aG docker $USER

# Installation de Docker Compose:
sudo apt-get update
sudo apt-get install docker-compose-plugin

# Création du dossier de travail:
mkdir -p wordpress

cd wordpress

# Génération du fichier docker-compose.yml:
echo "services:
  devcontainer:
    image: wordpress
    volumes:
      - ../..:/workspaces:cached
      - ../wordpress:/var/www/html:cached
      - ~/.ssh:/root/.ssh:cached
    environment:
      WORDPRESS_DB_HOST: db
      WORDPRESS_DB_USER: wp_user
      WORDPRESS_DB_PASSWORD: wp_pass
      WORDPRESS_DB_NAME: wordpress
      WORDPRESS_DEBUG: 1
    ports:
      - 80:80

  db:
    image: mariadb:10
    environment:
      MYSQL_DATABASE: wordpress
      MYSQL_USER: wp_user
      MYSQL_PASSWORD: wp_pass
      MYSQL_RANDOM_ROOT_PASSWORD: '1'
    ports:
      - 3306:3306
    volumes:
      - data:/var/lib/mysql

  phpmyadmin:
    image: phpmyadmin/phpmyadmin
    environment:
      PMA_HOST: db
      PMA_PORT: 3306
    ports:
      - 8080:80
    
volumes:
  data:
" > docker-compose.yml


# Démarrage des conteneurs:
docker-compose up -d