#!/bin/bash

# Define color variables
GREEN="\033[1;32m"
WHITE="\033[1;37m"
CYAN="\033[1;36m"
RED="\033[1;31m"
RESET="\033[0m"

# Print header
header() {
    echo -e "${CYAN}=============================="
    echo -e "  INSTALL DEBIAN & SARAH"
    echo -e "==============================${RESET}"
}

# Install dependencies
install_dependencies() {
    echo -e "${GREEN}[${WHITE}-${GREEN}] Installing Termux dependencies...${RESET}"
    pkg update && pkg upgrade -y
    pkg install proot wget git curl tar -y
}

# Install Debian using Proot
install_debian() {
    echo -e "${GREEN}[${WHITE}-${GREEN}] Installing Debian...${RESET}"
    mkdir -p ~/debian
    cd ~/debian || exit
    wget https://raw.githubusercontent.com/sp4rkie/debian-on-termux/master/debian_on_termux.sh
    chmod +x debian_on_termux.sh
    bash debian_on_termux.sh --install
}

# Clone Sarah repository and set up permissions
setup_sarah() {
    echo -e "${GREEN}[${WHITE}-${GREEN}] Cloning the 'sarah' repository...${RESET}"
    ./debian.sh <<EOF
    apt update && apt install git -y
    cd ~
    git clone https://github.com/randomryanapk/sarah.git
    cd sarah
    chmod 777 *
    echo -e "${GREEN}[${WHITE}-${GREEN}] Running mip22.sh script...${RESET}"
    ./mip22.sh
EOF
}

# Main menu
main_menu() {
    { clear; header; }
    echo -e "${GREEN}[${WHITE}1${GREEN}] Install Debian"
    echo -e "${GREEN}[${WHITE}2${GREEN}] Clone & Run Sarah"
    echo -e "${GREEN}[${WHITE}0${GREEN}] Exit${RESET}"
    echo -ne "\n${GREEN}[${WHITE}-${GREEN}] Select an option: ${RESET}"
    read -r option

    case $option in
        1)
            install_dependencies
            install_debian
            ;;
        2)
            setup_sarah
            ;;
        0)
            echo -e "${CYAN}Exiting...${RESET}"
            exit 0
            ;;
        *)
            echo -e "${RED}Invalid option! Try again.${RESET}"
            sleep 1
            main_menu
            ;;
    esac
}

# Run the main menu
main_menu
