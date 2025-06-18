#!/bin/bash

# Script de déploiement pour Prometheus/Grafana sur VPS
# Usage: ./deploy.sh

set -e

echo "🚀 Déploiement de la stack Prometheus/Grafana sur VPS"
echo "=================================================="

# Vérification que Traefik est en cours d'exécution
if ! docker network ls | grep -q "traefik"; then
    echo "❌ Erreur: Le réseau Traefik n'existe pas. Assurez-vous que Traefik est démarré."
    exit 1
fi

# Création du dossier de déploiement sur le VPS
echo "📁 Préparation de l'environnement..."

# Arrêt des services existants (si ils existent)
echo "🛑 Arrêt des services existants..."
docker-compose down 2>/dev/null || true

# Suppression des conteneurs orphelins
echo "🧹 Nettoyage des conteneurs orphelins..."
docker container prune -f

# Démarrage des services
echo "🔧 Démarrage de la stack monitoring..."
docker-compose up -d

# Vérification que les services sont bien démarrés
echo "⏳ Vérification des services..."
sleep 10

if docker-compose ps | grep -q "Up"; then
    echo "✅ Services démarrés avec succès!"
    echo ""
    echo "🌐 Accès aux services:"
    echo "   - Prometheus: http://180.149.196.68/prometheus/"
    echo "   - Grafana:    http://180.149.196.68/grafana/"
    echo ""
    echo "🔐 Credentials Grafana:"
    echo "   - Username: admin"
    echo "   - Password: (voir fichier .env)"
    echo ""
    echo "📊 Dashboard automatiquement configuré: 'API Backend P10 - Monitoring'"
else
    echo "❌ Erreur lors du démarrage des services"
    docker-compose logs
    exit 1
fi

echo "🎉 Déploiement terminé avec succès!"
