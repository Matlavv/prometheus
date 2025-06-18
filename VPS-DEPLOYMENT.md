# 🚀 Déploiement Prometheus/Grafana sur VPS

## Configuration VPS

**IP du VPS:** `180.149.196.68`
**URLs d'accès:**

- Prometheus: http://180.149.196.68/prometheus/
- Grafana: http://180.149.196.68/grafana/

## 📋 Prérequis

1. **Traefik** doit être en cours d'exécution
2. **Réseau Docker** `traefik` doit exister
3. **Votre API backend** doit exposer des métriques sur le port 3001

## 🔧 Installation

### 1. Transférer les fichiers sur le VPS

```bash
# Depuis votre machine locale
scp -r prometheus/ user@180.149.196.68:~/monitoring/
```

### 2. Se connecter au VPS et déployer

```bash
ssh user@180.149.196.68
cd ~/monitoring
./deploy.sh
```

## 🔐 Sécurité

### Changer le mot de passe Grafana

Avant le déploiement, modifiez le fichier `.env` :

```bash
nano .env
# Changez GRAFANA_ADMIN_PASSWORD=VotreMotDePasseSecurise123!
```

### Configuration firewall (recommandé)

```bash
# Ouvrir uniquement les ports nécessaires
sudo ufw allow 80/tcp
sudo ufw allow 22/tcp
sudo ufw enable
```

## 📊 Configuration du monitoring

### Ajouter d'autres services à monitorer

Modifiez `prometheus/prometheus.yaml` :

```yaml
scrape_configs:
  # Votre configuration existante...

  - job_name: 'autre-service'
    static_configs:
      - targets: ['IP:PORT']
```

### Créer de nouveaux dashboards

1. Accédez à Grafana: http://180.149.196.68/grafana/
2. Créez votre dashboard
3. Exportez en JSON
4. Placez dans `grafana/dashboards/`
5. Redémarrez: `docker-compose restart grafana`

## 🛠️ Maintenance

### Voir les logs

```bash
# Logs de tous les services
docker-compose logs

# Logs spécifiques
docker-compose logs prometheus
docker-compose logs grafana
```

### Redémarrer les services

```bash
docker-compose restart
```

### Sauvegarder les données

```bash
# Sauvegarde des volumes
docker run --rm -v prometheus-monitoring_grafana-data:/data -v $(pwd):/backup alpine tar czf /backup/grafana-backup.tar.gz -C /data .
docker run --rm -v prometheus-monitoring_prometheus-data:/data -v $(pwd):/backup alpine tar czf /backup/prometheus-backup.tar.gz -C /data .
```

## 🔍 Dépannage

### Prometheus n'arrive pas à scraper votre API

1. Vérifiez que votre API expose bien `/metrics`
2. Testez manuellement: `curl http://180.149.196.68:3001/metrics`
3. Vérifiez les logs: `docker-compose logs prometheus`

### Grafana ne se charge pas

1. Vérifiez Traefik: `docker logs traefik`
2. Vérifiez les routes: http://180.149.196.68:8080 (dashboard Traefik)
3. Vérifiez les logs Grafana: `docker-compose logs grafana`

### Erreur de réseau Docker

```bash
# Recréer le réseau monitoring
docker-compose down
docker network prune
docker-compose up -d
```

## 📈 Optimisations

### Pour un environnement de production

1. **HTTPS** : Configurez Let's Encrypt avec Traefik
2. **Authentification** : Ajoutez un middleware d'auth à Traefik
3. **Backup automatique** : Configurez des sauvegardes régulières
4. **Monitoring avancé** : Ajoutez Alertmanager pour les alertes

### Exemples de métriques personnalisées

```javascript
// Dans votre API Node.js
const client = require('prom-client');

// Métrique custom
const customMetric = new client.Gauge({
  name: 'my_custom_metric',
  help: 'Description de ma métrique',
});

// Dans vos routes
customMetric.set(42);
```
