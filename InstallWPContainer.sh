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
SYSTEM_HOSTNAME=$(hostname)
SYSTEM_DOMAIN=$(hostname -f)

# Si le domaine complet n'est pas disponible ou si c'est localhost, on crée un domaine local
if [ -z "$SYSTEM_DOMAIN" ] || [ "$SYSTEM_DOMAIN" = "localhost" ] || [ "$SYSTEM_DOMAIN" = "$SYSTEM_HOSTNAME" ]; then
    SYSTEM_DOMAIN="${SYSTEM_HOSTNAME}.local"
fi

echo "📧 Utilisation du domaine système : $SYSTEM_DOMAIN"
echo "📧 Adresse email de contact : contact@$SYSTEM_DOMAIN"

# Création du dossier de travail:
mkdir -p wordpress

cd wordpress || exit

# Génération du fichier de configuration PHP pour uploads et SMTP
echo "file_uploads = On
upload_max_filesize = 1024M
post_max_size = 1024M
max_file_uploads = 20
max_execution_time = 600
memory_limit = 256M
max_input_time = 300

; Configuration SMTP pour Postfix
SMTP = postfix
smtp_port = 587
sendmail_from = contact@${SYSTEM_DOMAIN}
sendmail_path = \"/usr/sbin/sendmail -t -i -f contact@${SYSTEM_DOMAIN}\"
" > uploads.ini

# Génération du script d'initialisation qui préserve WordPress
cat > init-wordpress.sh << INIT_EOF
#!/bin/bash
# Script qui préserve l'entrypoint WordPress original et ajoute SSMTP

# D'abord, on laisse WordPress s'installer normalement
/usr/local/bin/docker-entrypoint.sh apache2-foreground &
APACHE_PID=\$!

# On attend qu'Apache soit démarré
sleep 10

# Installation de SSMTP en arrière-plan
export DEBIAN_FRONTEND=noninteractive
apt-get update -qq >/dev/null 2>&1
apt-get install -y -qq ssmtp >/dev/null 2>&1

# Configuration ssmtp pour relayer vers Postfix
cat > /etc/ssmtp/ssmtp.conf << 'SSMTP_EOF'
root=contact@${SYSTEM_DOMAIN}
mailhub=postfix:587
hostname=${SYSTEM_DOMAIN}
FromLineOverride=YES
SSMTP_EOF

# Lien symbolique pour sendmail
ln -sf /usr/sbin/ssmtp /usr/sbin/sendmail

# On rejoint le processus Apache
wait \$APACHE_PID
INIT_EOF

chmod +x init-wordpress.sh

# Génération du fichier docker-compose.yml:
# Améliorations apportées:
# - Noms de conteneurs explicites avec le préfixe 'wordpress-'
# - Ajout de Postfix pour la gestion professionnelle des envois de mail
# - Installation automatique de sendmail dans WordPress avec relais vers Postfix
# - Configuration PHP pour l'envoi d'emails via contact@[domaine_système]
# - Ajout des dépendances entre conteneurs pour un démarrage ordonné
# - Healthcheck pour MariaDB pour éviter les problèmes de timing de connexion
# - WordPress attend que la base soit complètement prête avant de démarrer
cat > docker-compose.yml << EOF
services:
  wordpress:
    image: wordpress
    container_name: wordpress-dev
    command: ["/init-wordpress.sh"]
    volumes:
      - ./uploads.ini:/usr/local/etc/php/conf.d/uploads.ini
      - ./init-wordpress.sh:/init-wordpress.sh:ro
      - ~/.ssh:/root/.ssh:cached
    environment:
      WORDPRESS_DB_HOST: db
      WORDPRESS_DB_USER: wp_user
      WORDPRESS_DB_PASSWORD: wp_pass
      WORDPRESS_DB_NAME: wordpress
      WORDPRESS_DEBUG: 1
    ports:
      - 80:80
    restart: always
    depends_on:
      db:
        condition: service_healthy
      postfix:
        condition: service_started

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
    healthcheck:
      test: ["CMD", "healthcheck.sh", "--connect", "--innodb_initialized"]
      timeout: 20s
      retries: 10

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
      db:
        condition: service_healthy

  postfix:
    image: boky/postfix
    container_name: wordpress-postfix
    environment:
      HOSTNAME: ${SYSTEM_DOMAIN}
      ALLOWED_SENDER_DOMAINS: ${SYSTEM_DOMAIN}
      RELAYHOST_USERNAME: contact@${SYSTEM_DOMAIN}
      RELAYHOST_PASSWORD: contact_mail_pass
    ports:
      - 25:25    # Port SMTP standard
      - 587:587  # Port submission SMTP
    volumes:
      - postfix_data:/var/spool/postfix
    restart: always
    
volumes:
  data:
  postfix_data:
EOF

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
echo "   SSMTP installé dans WordPress et configuré pour relayer vers Postfix"
echo "   WordPress peut maintenant envoyer des emails automatiquement (plus rapide)"
echo ""
echo "🔧 Noms des conteneurs :"
echo "   • wordpress-dev"
echo "   • wordpress-db" 
echo "   • wordpress-phpmyadmin"
echo "   • wordpress-postfix"
echo ""
echo "⚡ Améliorations du démarrage :"
echo "   • Healthcheck MariaDB pour éviter les erreurs de timing"
echo "   • WordPress attend que la base soit complètement prête"
echo "   • Démarrage ordonné et fiable des services"
echo ""
