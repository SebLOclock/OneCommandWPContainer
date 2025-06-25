# OneCommandWPContainer

🚀 **Script d'installation automatique d'un environnement de développement WordPress complet avec Docker**

Un seul script pour déployer WordPress, MariaDB, phpMyAdmin et Postfix avec gestion complète des emails !

## ✨ Fonctionnalités

### 🐳 **Installation Docker complète**
- Installation automatique de Docker CE et Docker Compose
- Configuration des dépôts officiels Docker
- Ajout de l'utilisateur au groupe Docker
- Activation du service Docker au démarrage

### 🌐 **Environnement WordPress professionnel**
- **WordPress** : Dernière version avec configuration optimisée
- **MariaDB 10** : Base de données avec healthcheck intelligent
- **phpMyAdmin** : Interface d'administration de base de données
- **Postfix** : Serveur de messagerie pour l'envoi d'emails

### 📧 **Gestion avancée des emails**
- **SSMTP** installé automatiquement dans WordPress
- **Configuration automatique** du relais vers Postfix
- **Domaine système** détecté automatiquement
- **Adresse contact@[votre-domaine]** configurée
- **Alternative Gmail** prête à l'emploi pour serveurs cloud

### 🔧 **Configuration optimisée**
- **Noms de conteneurs explicites** (wordpress-dev, wordpress-db, etc.)
- **Volumes persistants** pour les données
- **Healthchecks** pour éviter les erreurs de timing
- **Dépendances intelligentes** entre services
- **Configuration PHP** optimisée (uploads 1GB, etc.)

## 🖥️ Services disponibles

| Service | URL | Description |
|---------|-----|-------------|
| **WordPress** | `http://localhost` | Site WordPress principal |
| **phpMyAdmin** | `http://localhost:8080` | Administration base de données |
| **Base de données** | `localhost:3306` | MariaDB (accès direct) |
| **SMTP** | `localhost:25/587` | Serveur Postfix |

## 📋 Prérequis

- **OS** : Ubuntu/Debian (testé sur serveurs cloud)
- **Droits** : sudo requis
- **Réseau** : Accès internet pour téléchargements
- **Ports** : 80, 3306, 8080, 25, 587 disponibles

## 🚀 Installation

### Installation rapide :
```bash
sudo bash InstallWPContainer.sh
```

### Étapes du script :
1. **Détection du domaine système** automatique
2. **Installation Docker** + Docker Compose
3. **Génération des configurations** (docker-compose.yml, etc.)
4. **Démarrage des conteneurs** avec ordre de dépendance
5. **Configuration SSMTP** en arrière-plan (2-3 minutes)


## 📁 Fichiers générés

```
wordpress/
├── docker-compose.yml              # Configuration principale
├── docker-compose-gmail.yml        # Configuration Gmail alternative  
├── uploads.ini                     # Configuration PHP
└── init-wordpress.sh              # Script d'initialisation SSMTP
```

## 🔧 Gestion des conteneurs

### Commandes utiles :
```bash
cd wordpress

# Voir l'état des conteneurs
docker compose ps

# Voir les logs
docker compose logs
docker compose logs wordpress
docker compose logs postfix

# Redémarrer
docker compose restart

# Arrêter
docker compose down

# Supprimer complètement
docker compose down -v
```

### Noms des conteneurs :
- `wordpress-dev` : Application WordPress
- `wordpress-db` : Base de données MariaDB  
- `wordpress-phpmyadmin` : Interface phpMyAdmin
- `wordpress-postfix` : Serveur de messagerie

## 🐛 Dépannage

### WordPress inaccessible (erreur 403)
```bash
# Vérifier les conteneurs
docker compose ps

# Recréer l'environnement
docker compose down
rm -f docker-compose.yml uploads.ini init-wordpress.sh
cd ..
sudo bash InstallWPContainer.sh
```

### Emails non reçus
1. **Vérifiez les logs Postfix** :
   ```bash
   docker compose logs postfix | grep reject
   ```

2. **Si "Access denied"** → Utilisez la configuration Gmail
3. **Si pas d'erreur** → Vérifiez vos spams

### Base de données inaccessible
```bash
# Vérifiez le healthcheck
docker compose ps
# Si "unhealthy" → attendez ou redémarrez
docker compose restart db
```

## 🌍 Déploiement serveur cloud

Le script est optimisé pour les serveurs cloud (AWS, OVH, DigitalOcean, etc.) :

- ✅ **Détection automatique** du nom de domaine
- ✅ **Configuration réseau** adaptée
- ✅ **Alternative Gmail** pour contournement des restrictions
- ✅ **Healthchecks** pour démarrage fiable

## 📞 Support

En cas de problème :
1. Vérifiez les logs : `docker compose logs`
2. Consultez la section dépannage ci-dessus
3. Recréez l'environnement si nécessaire

---

🎯 **WordPress est accessible immédiatement, emails fonctionnels après 2-3 minutes !**
