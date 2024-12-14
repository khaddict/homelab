#!/bin/bash

RED="\033[0;31m"
GREEN="\033[0;32m"
YELLOW="\033[1;33m"
CYAN="\033[0;36m"
RESET="\033[0m"

echo -e "This script needs the following secrets to be set up in Vault:
  - argocd_dashboard_password
  - traefik_dashboard_secret

Vault URL: ${CYAN}https://vault.homelab.lan:8200/ui/vault/secrets/kv/kv/kubernetes${RESET}"

read -p "Already done? (yes/no) " RESPONSE

if [[ $RESPONSE == "yes" ]]; then
    # Check for kubectl
    if which kubectl &> /dev/null; then
        echo -e "${GREEN}✔ kubectl is installed.${RESET}"
    else
        echo -e "${RED}✘ kubectl is not installed.${RESET}"
        echo -e "Please install it: ${CYAN}https://kubernetes.io/docs/tasks/tools/install-kubectl-linux/${RESET}"
        exit 1
    fi

    # Check for helm
    if which helm &> /dev/null; then
        echo -e "${GREEN}✔ helm is installed.${RESET}"
    else
        echo -e "${RED}✘ helm is not installed.${RESET}"
        echo -e "Please install it: ${CYAN}https://helm.sh/docs/intro/install/${RESET}"
        exit 1
    fi

    # Install metallb
    /usr/bin/bash /root/scripts/01_metallb.sh
    if [[ $? -ne 0 ]]; then
        echo -e "${RED}✘ Metallb installation failed. Exiting.${RESET}"
        exit 1
    else
        echo -e "${GREEN}✔ Metallb installation succeeded.${RESET}"
    fi

    # Install traefik
    /usr/bin/bash /root/scripts/02_traefik.sh
    if [[ $? -ne 0 ]]; then
        echo -e "${RED}✘ Traefik installation failed. Exiting.${RESET}"
        exit 1
    else
        echo -e "${GREEN}✔ Traefik installation succeeded.${RESET}"
    fi

    # Install tools
    /usr/bin/bash /root/scripts/03_tools.sh
    if [[ $? -ne 0 ]]; then
        echo -e "${RED}✘ Tools installation failed. Exiting.${RESET}"
        exit 1
    else
        echo -e "${GREEN}✔ Tools installation succeeded.${RESET}"
    fi

    # Install argocd
    /usr/bin/bash /root/scripts/04_argocd.sh
    if [[ $? -ne 0 ]]; then
        echo -e "${RED}✘ ArgoCD installation failed. Exiting.${RESET}"
        exit 1
    else
        echo -e "${GREEN}✔ ArgoCD installation succeeded.${RESET}"
    fi

    # Install khaddict.com
    /usr/bin/bash /root/scripts/05_khaddict.sh
    if [[ $? -ne 0 ]]; then
        echo -e "${RED}✘ Khaddict.com installation failed. Exiting.${RESET}"
        exit 1
    else
        echo -e "${GREEN}✔ Khaddict.com installation succeeded.${RESET}"
    fi

else
    echo -e "${RED}Please complete the Vault setup before proceeding.${RESET}"
    exit 1
fi
