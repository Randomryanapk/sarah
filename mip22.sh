#!/bin/bash
__version__="1.5"

## DEFAULT HOST & PORT 
HOST='127.0.0.1'
PORT='8090'

# Define colors
GREEN="\033[32m"
WHITE="\033[37m"
RESET="\033[0m"

# Function to print banner in green
green_echo() {
    local str="$1"
    echo -e "${GREEN}${str}${RESET}"
}

# Define the banner function
banner() {
    green_echo "========================================"
    green_echo "███████╗ █████╗ ██████╗  █████╗ ██╗  ██╗"
    green_echo "██╔════╝██╔══██╗██╔══██╗██╔══██╗██║  ██║"
    green_echo "███████╗███████║██████╔╝███████║███████║"
    green_echo "╚════██║██╔══██║██╔══██╗██╔══██║██╔══██║"
    green_echo "███████║██║  ██║██║  ██║██║  ██║██║  ██║"
    green_echo "╚══════╝╚═╝  ╚═╝╚═╝  ╚═╝╚═╝  ╚═╝╚═╝  ╚═╝"
    green_echo "========================================"
    green_echo "+++---PROJECT-SARAH-FOR-TERMUX---+++"
    green_echo "========================================"
}

## Directories
BASE_DIR=$(realpath "$(dirname "$BASH_SOURCE")")
WEBROOT_DIR="${BASE_DIR}/your_site"

# Function to set up the webroot directory
setup_webroot() {
    if [[ ! -d "${WEBROOT_DIR}" ]]; then
        mkdir -p "${WEBROOT_DIR}"
        echo -e "\n[+] Created webroot directory: ${WEBROOT_DIR}"
    fi

    if [[ -d "${WEBROOT_DIR}" ]]; then
        rm -rf "${WEBROOT_DIR}/*"
        echo -e "\n[+] Cleaned up existing webroot directory."
    fi
}

# Reset terminal colors
reset_color() {
    tput sgr0   # reset attributes
    tput op     # reset color
    return
}

# Function to kill already running processes
kill_pid() {
    local processes="php cloudflared"
    for process in ${processes}; do
        local pids=$(pidof ${process})
        if [[ -n "${pids}" ]]; then
            echo "Killing ${process} processes with PIDs: ${pids}"
            killall ${process} > /dev/null 2>&1
        fi
    done
}

# Install dependencies
dependencies() {
    echo -e "\n[+] Installing required packages..."
    pkgs=(php curl unzip wget)
    for pkg in "${pkgs[@]}"; do
        if ! command -v $pkg >/dev/null 2>&1; then
            echo -e "\n[+] Installing package: $pkg"
            pkg install "$pkg" -y
        else
            echo -e "\n[+] $pkg is already installed."
        fi
    done
}

# Download Cloudflared
install_cloudflared() {
    if [[ -e ".server/cloudflared" ]]; then
        echo -e "\n[+] Cloudflared already installed."
    else
        echo -e "\n[+] Installing Cloudflared..."
        arch=$(uname -m)
        if [[ "$arch" == "aarch64" ]]; then
            wget -O cloudflared 'https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-arm64'
        elif [[ "$arch" == *"arm"* ]]; then
            wget -O cloudflared 'https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-arm'
        elif [[ "$arch" == "x86_64" ]]; then
            wget -O cloudflared 'https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64'
        else
            wget -O cloudflared 'https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-386'
        fi
        chmod +x cloudflared
        mv cloudflared .server/cloudflared
    fi
}

## Setup website and start PHP server
setup_site() {
    setup_webroot
    echo -e "\n[ - ] Setting up server..."
    echo -ne "\n[ - ] Starting PHP server..."
    cd "${WEBROOT_DIR}" && php -S "$HOST":"$PORT" > /dev/null 2>&1 &
}

## Start Cloudflared
start_cloudflared() { 
    echo -e "\n[ - ] Initializing... ( http://$HOST:$PORT )"
    { sleep 1; setup_site; }
    echo -ne "\n[ - ] Launching Cloudflared tunnel..."
    ./server/cloudflared tunnel -url "$HOST":"$PORT" > /dev/null 2>&1 &
    sleep 8
    cldflr_url=$(curl -s http://127.0.0.1:4040/api/tunnels | grep -oP '(?<=https://)[^"]+')
    echo -e "\n[ - ] Server running at: https://$cldflr_url"
}

## Exit message
msg_exit() {
    { clear; banner; echo; }
    echo -e "${GREEN} Thank you for using this tool. Have a good day.${RESET}\n"
    { reset_color; exit 0; }
}

## Main Menu
main_menu() {
    { clear; banner; echo; }
    cat <<- EOF
         THIS PROJECT WAS MADE STRICTLY FOR EDUCATION...  
EOF
    
    read -p "[ - ] Continue? Y/N : " REPLY

    case $REPLY in 
        Y | y)
            start_cloudflared;;
        0 | 00 )
            msg_exit;;
        *)
            echo -ne "\n[!] Invalid Option, Try Again..."
            { sleep 1; main_menu; };;
    esac
}

## Main
kill_pid
dependencies
install_cloudflared
main_menu
