#!/bin/bash

REPO=$REPO
BRANCH=main

seed_configs(){
  echo "Seeding Configs..."
  mkdir -p /app/config/
  cp /config/services.yaml /app/config/services.yaml
  cp /config/settings.yaml /app/config/settings.yaml
}

seed_icons(){
  echo "Seeding Icons..."
  mkdir -p /app/public/icons
  wget -O /app/public/icons/supermicro-ipmi.png https://raw.githubusercontent.com/$REPO/$BRANCH/misc/homepage/files/icons/supermicro-ipmi.png
  wget -O /app/public/icons/kiali.png https://raw.githubusercontent.com/$REPO/$BRANCH/misc/homepage/files/icons/kiali.png
}

seed_images(){
  echo "Seeding Images..."
  mkdir -p /app/public/images
  wget -O /app/public/images/background.jpg https://raw.githubusercontent.com/$REPO/$BRANCH/misc/homepage/files/images/background.jpg
  wget -O /app/public/images/favicon.png https://raw.githubusercontent.com/$REPO/$BRANCH/misc/homepage/files/images/favicon.png
}

main(){
  seed_configs
  seed_icons
  seed_images
}

main "$@"