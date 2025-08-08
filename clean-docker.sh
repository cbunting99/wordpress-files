#!/usr/bin/env bash
set -euo pipefail

# clean-docker.sh
# Completely remove all Docker entities for a clean install.
# Usage:
#   ./clean-docker.sh --force [--delete-docker-data]
#   --force: proceed with cleanup (required)
#   --delete-docker-data: also delete /var/lib/docker (dangerous; digested data)
#
# Note: Run from an environment where Docker CLI is available (e.g., WSL with Docker Desktop).

# Parse arguments
force_proceed=false
delete_data=false

for arg in "$@"; do
  case "$arg" in
    --force|-f)
      force_proceed=true
      ;;
    --delete-docker-data)
      delete_data=true
      ;;
    *)
      echo "Unknown argument: $arg"
      echo "Usage: ./clean-docker.sh --force [--delete-docker-data]"
      exit 1
      ;;
  esac
done

if [ "$force_proceed" = false ]; then
  echo "This script will remove ALL Docker containers, images, volumes, and networks."
  echo "To proceed, run with --force. Optional --delete-docker-data will remove /var/lib/docker."
  echo "Example: ./clean-docker.sh --force --delete-docker-data"
  exit 0
fi

if ! command -v docker >/dev/null 2>&1; then
  echo "Docker CLI not found in PATH. Ensure Docker is installed and available." >&2
  exit 1
fi

echo "Starting Docker cleanup..."

# 1) Stop all containers (if any)
containers=$(docker ps -aq 2>/dev/null || true)
if [ -n "$containers" ]; then
  echo "Stopping all running containers..."
  docker stop $containers 2>/dev/null || true
else
  echo "No containers to stop."
fi

# 2) Remove all containers (including stopped ones)
all_containers=$(docker ps -aq 2>/dev/null || true)
if [ -n "$all_containers" ]; then
  echo "Removing all containers..."
  docker rm -f $all_containers 2>/dev/null || true
else
  echo "No containers to remove."
fi

# 3) Remove all images
images=$(docker images -aq 2>/dev/null || true)
if [ -n "$images" ]; then
  echo "Removing all images..."
  docker rmi -f $images 2>/dev/null || true
else
  echo "No images to remove."
fi

# 4) Remove all volumes
volumes=$(docker volume ls -q 2>/dev/null || true)
if [ -n "$volumes" ]; then
  echo "Removing all volumes..."
  docker volume rm $volumes 2>/dev/null || true
else
  echo "No volumes to remove."
fi

# 5) Remove all networks (excluding default bridge/host) that are not in use
networks=$(docker network ls -q 2>/dev/null || true)
if [ -n "$networks" ]; then
  echo "Removing custom Docker networks..."
  # Filter out default networks if needed; attempt removal and ignore errors
  for net in $networks; do
    docker network rm "$net" 2>/dev/null || true
  done
else
  echo "No networks to remove."
fi

# 6) Prune system (aggressive cleanup)
echo "Running docker system prune (all, including volumes)..."
docker system prune -a -f --volumes 2>/dev/null || true

# 7) Optional: hard delete Docker data directory
if [ "$delete_data" = true ]; then
  # This is a dangerous operation and requires elevated privileges.
  if [ -d /var/lib/docker ]; then
    echo "Deleting /var/lib/docker (this will remove all Docker data at the filesystem level)."
    sudo rm -rf /var/lib/docker
  else
    echo "/var/lib/docker does not exist; skipping."
  fi
  # Remove docker socket if present (will be recreated)
  if [ -S /var/run/docker.sock ]; then
    echo "Removing /var/run/docker.sock..."
    sudo rm -f /var/run/docker.sock
  fi
fi

echo "Docker cleanup completed."
