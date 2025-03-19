# Mettre à jour la limite de mémoire dans wp-config.php
echo "
if( ! defined('WP_MEMORY_LIMIT') ) {
  define('WP_MEMORY_LIMIT', '512M');
}" >> ./wordpress/wp-config.php

# Mettre à jour les paramètres d'upload dans uploads.ini
echo "
; Activer les uploads de fichiers
file_uploads = On

; Taille maximale d'un fichier téléchargé
upload_max_filesize = 5120M

; Taille maximale des données POST, y compris les fichiers téléchargés
post_max_size = 5120M

; Nombre maximal de fichiers pouvant être téléchargés simultanément
max_file_uploads = 20

; Temps maximum d'exécution d'un script en secondes
max_execution_time = 600
" > /usr/local/etc/php/conf.d/uploads.ini

# Redémarrer le service PHP-FPM pour appliquer les changements (si nécessaire)
# Cette commande peut varier selon la configuration de votre conteneur
# Exemple pour un conteneur utilisant PHP-FPM :
# service php-fpm restart

echo "La limite mémoire de WordPress et les paramètres d'upload ont été redéfinis."
