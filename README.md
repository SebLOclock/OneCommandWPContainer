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
- **Détection intelligente du domaine** (serveurs cloud .eddi.xyz → .eddi.cloud)
- **Adresse contact@[votre-domaine]** configurée automatiquement
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

## 🔍 Détection intelligente du domaine

Le script détecte automatiquement votre domaine et l'adapte pour les serveurs cloud :

**Exemples de conversion automatique** :
- `hostname -f` : `sebloclock-server.cloud.eddi.xyz.local` 
- **→ Converti en** : `sebloclock-server.eddi.cloud`
- **→ Emails depuis** : `contact@sebloclock-server.eddi.cloud`

**Compatibilité** :
- ✅ **Serveurs locaux** : `monserveur.local`
- ✅ **Serveurs cloud** : Conversion automatique des domaines internes
- ✅ **Domaines personnalisés** : Préservés tels quels

## 🚀 Installation

### Installation rapide :
```bash
sudo bash InstallWPContainer.sh
```

**Affichage simplifié** :
```
🎉 Installation WordPress terminée !

🌐 Accès aux services :
   • WordPress    : http://localhost
   • phpMyAdmin   : http://localhost:8080

📧 Configuration email :
   • Domaine      : sebloclock-server.eddi.cloud
   • Expéditeur   : contact@sebloclock-server.eddi.cloud
   • Serveur SMTP : Postfix (ports 25/587)

⏳ WordPress est accessible immédiatement
⚠️  Emails opérationnels dans 2-3 minutes
```

### Étapes du script :
1. **Détection intelligente du domaine** (conversion automatique serveurs cloud)
2. **Installation Docker** + Docker Compose
3. **Génération des configurations** (docker-compose.yml, etc.)
4. **Démarrage des conteneurs** avec ordre de dépendance
5. **Configuration SSMTP** en arrière-plan (2-3 minutes)

## 📧 Configuration des emails

### 🟢 **Mode automatique (par défaut)**
Les emails sont envoyés directement via Postfix avec le domaine détecté :
- ✅ **Adresse automatique** : `contact@[votre-domaine-détecté]`
- ✅ **Configuration SSMTP** : Automatique via relais Postfix
- ⚠️ Peut être bloqué sur certains hébergeurs cloud (port 25)

### 🔵 **Mode Gmail (serveurs cloud)**
Si les emails ne fonctionnent pas, utilisez Gmail comme relais :

1. **Préparez Gmail** : Validation 2 étapes + mot de passe d'application
2. **Éditez** : `cd wordpress && nano docker-compose-gmail.yml`  
3. **Activez** : `cp docker-compose-gmail.yml docker-compose.yml && docker compose up -d`

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
1. **Vérifiez la détection du domaine** :
   ```bash
   # Le script affiche le domaine détecté
   # Si incorrect, modifiez manuellement docker-compose.yml
   ```

2. **Vérifiez les logs Postfix** :
   ```bash
   docker compose logs postfix | grep reject
   ```

3. **Si "Access denied"** → Utilisez la configuration Gmail
4. **Si pas d'erreur** → Vérifiez vos spams

### Base de données inaccessible
```bash
# Vérifiez le healthcheck
docker compose ps
# Si "unhealthy" → attendez ou redémarrez
docker compose restart db
```

## 🌍 Déploiement serveur cloud

Le script est optimisé pour les serveurs cloud (AWS, OVH, DigitalOcean, etc.) :

- ✅ **Détection intelligente** du domaine public (conversion .eddi.xyz → .eddi.cloud)
- ✅ **Configuration réseau** adaptée aux environnements cloud
- ✅ **Alternative Gmail** pour contournement des restrictions SMTP
- ✅ **Healthchecks** pour démarrage fiable
- ✅ **Messages simplifiés** pour un retour d'information clair

**Nouveauté** : Le script reconnaît automatiquement les serveurs cloud et adapte la configuration email pour une compatibilité maximale.

## 📞 Support

En cas de problème :
1. Vérifiez les logs : `docker compose logs`
2. Consultez la section dépannage ci-dessus
3. Recréez l'environnement si nécessaire

---

🎯 **WordPress est accessible immédiatement, emails fonctionnels après 2-3 minutes !**
