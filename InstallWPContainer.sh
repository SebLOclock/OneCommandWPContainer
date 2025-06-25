# Author: Sebastien Lemoine
# Date: 2024-09-26
# Description: Ce script permet d'installer un environnement de développement WordPress avec Docker.

# Ajout des dépôts Docker à Apt:
sudo apt-get update
sudo apt-get install -y ca-certificates curl
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
sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# Démarrage et activation de Docker:
sudo systemctl start docker
sudo systemctl enable docker

# Ajout de l'utilisateur courant au groupe Docker:
sudo usermod -aG docker $USER

# Installation de Docker Compose:
sudo apt-get update
sudo apt-get install -y docker-compose-plugin

# Détection du nom de domaine du système:
SYSTEM_DOMAIN=$(hostname -f)
if [ -z "$SYSTEM_DOMAIN" ] || [ "$SYSTEM_DOMAIN" = "localhost" ]; then
    SYSTEM_DOMAIN=$(hostname).local
fi

echo "📧 Utilisation du domaine système : $SYSTEM_DOMAIN"
echo "📧 Adresse email de contact : contact@$SYSTEM_DOMAIN"

# Création du dossier de travail:
mkdir -p wordpress

cd wordpress || exit

# Génération du fichier de configuration pour la gestion des taille de fichier à transmettre au serveur
echo "file_uploads = On
upload_max_filesize = 1024M
post_max_size = 1024M
max_file_uploads = 20
max_execution_time = 600
memory_limit = 256M
max_input_time = 300
" > uploads.ini

# Génération du fichier docker-compose.yml:
# Améliorations apportées:
# - Noms de conteneurs explicites avec le préfixe 'wordpress-'
# - Ajout de Postfix pour la gestion professionnelle des envois de mail
# - Configuration automatique de WordPress pour utiliser Postfix comme serveur SMTP
# - Ajout des dépendances entre conteneurs pour un démarrage ordonné
echo "services:
  wordpress:
    image: wordpress
    container_name: wordpress-dev
    volumes:
      - ./uploads.ini:/usr/local/etc/php/conf.d/uploads.ini
      - ../..:/workspaces:cached
      - ../wordpress:/var/www/html:cached
      - ~/.ssh:/root/.ssh:cached
    environment:
      WORDPRESS_DB_HOST: db
      WORDPRESS_DB_USER: wp_user
      WORDPRESS_DB_PASSWORD: wp_pass
      WORDPRESS_DB_NAME: wordpress
      WORDPRESS_DEBUG: 1
      # Configuration pour l'envoi de mail via Postfix
      WORDPRESS_CONFIG_EXTRA: |
        define('SMTP_HOST', 'postfix');
        define('SMTP_PORT', 587);
        define('SMTP_SECURE', false);
        define('SMTP_AUTH', false);
        define('SMTP_FROM', 'contact@$SYSTEM_DOMAIN');
        define('SMTP_FROMNAME', 'Contact');
    ports:
      - 80:80
    restart: always
    depends_on:
      - db
      - postfix

  db:
    image: mariadb:10
    container_name: wordpress-db
    environment:
      MYSQL_DATABASE: wordpress
      MYSQL_USER: wp_user
      MYSQL_PASSWORD: wp_pass
      MYSQL_RANDOM_ROOT_PASSWORD: '1'
    ports:
      - 3306:3306
    volumes:
      - data:/var/lib/mysql
    restart: always

  phpmyadmin:
    image: phpmyadmin/phpmyadmin
    container_name: wordpress-phpmyadmin
    environment:
      PMA_HOST: db
      PMA_PORT: 3306
    ports:
      - 8080:80
    restart: always
    depends_on:
      - db

  postfix:
    image: catatnight/postfix
    container_name: wordpress-postfix
    environment:
      maildomain: $SYSTEM_DOMAIN
      smtp_user: contact@$SYSTEM_DOMAIN:contact_mail_pass
    ports:
      - 25:25    # Port SMTP standard
      - 587:587  # Port submission SMTP
    volumes:
      - postfix_data:/var/spool/postfix
    restart: always
    
volumes:
  data:
  postfix_data:
" > docker-compose.yml

# Ajouter docker au démarrage de la machine
systemctl enable docker


# Démarrage des conteneurs:
docker compose up -d

echo ""
echo "✅ Installation terminée avec succès !"
echo ""
echo "🌐 Services disponibles :"
echo "   • WordPress : http://localhost"
echo "   • phpMyAdmin : http://localhost:8080"
echo ""
echo "📧 Gestion des emails :"
echo "   Serveur Postfix configuré pour l'envoi d'emails"
echo "   Domaine de messagerie : $SYSTEM_DOMAIN"
echo "   Adresse de contact : contact@$SYSTEM_DOMAIN"
echo "   Ports SMTP : 25 (standard) et 587 (submission)"
echo "   WordPress est automatiquement configuré pour utiliser Postfix"
echo ""
echo "🔧 Noms des conteneurs :"
echo "   • wordpress-dev"
echo "   • wordpress-db" 
echo "   • wordpress-phpmyadmin"
echo "   • wordpress-postfix"
echo ""
