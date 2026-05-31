#!/usr/bin/env bash
# deploy.sh — deploy bien-species-shinyapp from any working directory.
# Run: bash /path/to/BIEN-SpeciesShinyApp/deploy.sh
set -euo pipefail
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
echo "Deploying from: $DIR"
Rscript -e "rsconnect::deployApp(appDir='${DIR}', appName='bien-species-shinyapp', forceUpdate=TRUE)"
