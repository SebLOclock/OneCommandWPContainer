echo "
if( ! define('WP_MEMORY_LIMIT'){
  define('WP_MEMORY_LIMIT', '512M');
}" >> ./wordpress/wp-config.php
echo "La limite mémoire de Wordpress à été redéfinie"
