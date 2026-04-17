#!/bin/bash

# ezlinux - by roxzitywolf
# the ultimate cachyos setup script

RED='\033[0;31m'
BRED='\033[1;31m'
DARKRED='\033[2;31m'
WHITE='\033[1;37m'
GRAY='\033[0;37m'
DIM='\033[2m'
BOLD='\033[1m'
RESET='\033[0m'
BLINK='\033[5m'
BG_RED='\033[41m'
BG_BLACK='\033[40m'

clear

echo -e "${BRED}"
cat << 'EOF'
 ███████╗███████╗██╗     ██╗███╗   ██╗██╗   ██╗██╗  ██╗
 ██╔════╝╚══███╔╝██║     ██║████╗  ██║██║   ██║╚██╗██╔╝
 █████╗    ███╔╝ ██║     ██║██╔██╗ ██║██║   ██║ ╚███╔╝ 
 ██╔══╝   ███╔╝  ██║     ██║██║╚██╗██║██║   ██║ ██╔██╗ 
 ███████╗███████╗███████╗██║██║ ╚████║╚██████╔╝██╔╝ ██╗
 ╚══════╝╚══════╝╚══════╝╚═╝╚═╝  ╚═══╝ ╚═════╝ ╚═╝  ╚═╝
EOF
echo -e "${RESET}"
echo -e "${RED}▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓${RESET}"
echo -e "${WHITE}           the ultimate cachyos performance setup           ${RESET}"
echo -e "${DARKRED}                     by roxzitywolf                        ${RESET}"
echo -e "${RED}▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓${RESET}"
echo ""

sleep 1

# ── spinner ──────────────────────────────────────────────────────────
spinner() {
    local pid=$1
    local msg=$2
    local spinstr='⣾⣽⣻⢿⡿⣟⣯⣷'
    while kill -0 "$pid" 2>/dev/null; do
        for i in $(seq 0 7); do
            char="${spinstr:$i:1}"
            echo -ne "\r${RED}  ${char} ${WHITE}${msg}${RESET}   "
            sleep 0.1
        done
    done
    echo -ne "\r${BRED}  ✔ ${WHITE}${msg}${RESET}            \n"
}

# ── section header ────────────────────────────────────────────────────
section() {
    echo ""
    echo -e "${RED}┌─────────────────────────────────────────────────────────┐${RESET}"
    echo -e "${RED}│${BRED}  ⚡ ${WHITE}${1}${RED}$(printf '%*s' $((54 - ${#1})) '')│${RESET}"
    echo -e "${RED}└─────────────────────────────────────────────────────────┘${RESET}"
    echo ""
}

# ── done message ──────────────────────────────────────────────────────
done_msg() {
    echo -e "  ${BRED}✔ ${GRAY}${1}${RESET}"
}

# ── error ─────────────────────────────────────────────────────────────
err_msg() {
    echo -e "  ${RED}✘ ${WHITE}${1} failed — skipping${RESET}"
}

# ── run with spinner ──────────────────────────────────────────────────
run() {
    local msg=$1
    shift
    ("$@" &>/dev/null) &
    local pid=$!
    spinner $pid "$msg"
    wait $pid
    local code=$?
    if [ $code -ne 0 ]; then
        err_msg "$msg"
    fi
    return $code
}

# ── check root ────────────────────────────────────────────────────────
if [ "$EUID" -eq 0 ]; then
    echo -e "${BRED}  ✘ don't run as root bro 💀${RESET}"
    exit 1
fi

echo -e "${RED}  ►${WHITE} initializing ezlinux...${RESET}"
sleep 0.5
echo -e "${RED}  ►${WHITE} detecting system...${RESET}"
sleep 0.5

DISTRO=$(cat /etc/os-release | grep "^NAME" | cut -d'"' -f2)
KERNEL=$(uname -r)
CPU=$(grep "model name" /proc/cpuinfo | head -1 | cut -d':' -f2 | xargs)
RAM=$(free -h | awk '/^Mem:/{print $2}')

echo ""
echo -e "${RED}╔═══════════════════════════════════════════════════════════╗${RESET}"
echo -e "${RED}║${WHITE}  system info                                              ${RED}║${RESET}"
echo -e "${RED}╠═══════════════════════════════════════════════════════════╣${RESET}"
echo -e "${RED}║${GRAY}  distro  ${WHITE}» ${BRED}${DISTRO}$(printf '%*s' $((41 - ${#DISTRO})) '')${RED}║${RESET}"
echo -e "${RED}║${GRAY}  kernel  ${WHITE}» ${BRED}${KERNEL}$(printf '%*s' $((41 - ${#KERNEL})) '')${RED}║${RESET}"
echo -e "${RED}║${GRAY}  cpu     ${WHITE}» ${BRED}${CPU:0:40}$(printf '%*s' $((41 - ${#CPU} > 0 ? 41 - ${#CPU} : 1)) '')${RED}║${RESET}"
echo -e "${RED}║${GRAY}  ram     ${WHITE}» ${BRED}${RAM}$(printf '%*s' $((41 - ${#RAM})) '')${RED}║${RESET}"
echo -e "${RED}╚═══════════════════════════════════════════════════════════╝${RESET}"
echo ""

echo -e "${WHITE}  press ${BRED}ENTER${WHITE} to begin the demon setup or ${BRED}CTRL+C${WHITE} to bail 💀${RESET}"
read -r

# ════════════════════════════════════════════════════════════════════
section "STEP 1 — SYSTEM UPDATE"
# ════════════════════════════════════════════════════════════════════

run "updating system packages" sudo pacman -Syu --noconfirm
done_msg "system updated"

# install paru if not present
if ! command -v paru &>/dev/null; then
    run "installing paru (AUR helper)" bash -c "
        cd /tmp &&
        git clone https://aur.archlinux.org/paru.git &&
        cd paru &&
        makepkg -si --noconfirm
    "
    done_msg "paru installed"
else
    done_msg "paru already installed"
fi

# ════════════════════════════════════════════════════════════════════
section "STEP 2 — GAMING SETUP"
# ════════════════════════════════════════════════════════════════════

GAMING_PKGS=(
    steam
    gamemode
    lib32-gamemode
    mangohud
    lib32-mangohud
    lutris
    wine
    wine-mono
    winetricks
    heroic-games-launcher-bin
    proton-ge-custom-bin
    gamescope
    goverlay
)

for pkg in "${GAMING_PKGS[@]}"; do
    run "installing $pkg" paru -S --noconfirm "$pkg"
done

# enable gamemode
run "enabling gamemode service" systemctl --user enable gamemoded
done_msg "gaming stack installed"

# ════════════════════════════════════════════════════════════════════
section "STEP 3 — PERFORMANCE TWEAKS"
# ════════════════════════════════════════════════════════════════════

# cpu governor
run "setting cpu governor to performance" bash -c "
    echo performance | sudo tee /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor
"

# vm tweaks
run "applying vm tweaks" bash -c "
    echo 'vm.swappiness=10' | sudo tee -a /etc/sysctl.d/99-ezlinux.conf
    echo 'vm.vfs_cache_pressure=50' | sudo tee -a /etc/sysctl.d/99-ezlinux.conf
    echo 'vm.dirty_ratio=6' | sudo tee -a /etc/sysctl.d/99-ezlinux.conf
    echo 'vm.dirty_background_ratio=3' | sudo tee -a /etc/sysctl.d/99-ezlinux.conf
    sudo sysctl -p /etc/sysctl.d/99-ezlinux.conf
"

# ananicy-cpp for process priority
run "installing ananicy-cpp" paru -S --noconfirm ananicy-cpp
run "enabling ananicy-cpp" sudo systemctl enable --now ananicy-cpp

# irqbalance
run "installing irqbalance" sudo pacman -S --noconfirm irqbalance
run "enabling irqbalance" sudo systemctl enable --now irqbalance

# preload
run "installing preload" paru -S --noconfirm preload
run "enabling preload" sudo systemctl enable --now preload

# zram
run "setting up zram" bash -c "
    sudo pacman -S --noconfirm zram-generator
    echo '[zram0]' | sudo tee /etc/systemd/zram-generator.conf
    echo 'zram-size = ram / 2' | sudo tee -a /etc/systemd/zram-generator.conf
    echo 'compression-algorithm = zstd' | sudo tee -a /etc/systemd/zram-generator.conf
"

# io scheduler tweak
run "setting io scheduler to mq-deadline" bash -c "
    echo 'ACTION==\"add|change\", KERNEL==\"sd[a-z]*|nvme[0-9]*\", ATTR{queue/scheduler}=\"mq-deadline\"' | sudo tee /etc/udev/rules.d/60-ioschedulers.rules
"

done_msg "performance tweaks applied"

# ════════════════════════════════════════════════════════════════════
section "STEP 4 — VISUAL THEMES"
# ════════════════════════════════════════════════════════════════════

THEME_PKGS=(
    kvantum
    qt5ct
    lightly-qt
    tela-circle-icon-theme-git
    catppuccin-gtk-theme-mocha
    bibata-cursor-theme
)

for pkg in "${THEME_PKGS[@]}"; do
    run "installing $pkg" paru -S --noconfirm "$pkg"
done

# gtk config
run "applying gtk dark theme" bash -c "
    mkdir -p ~/.config/gtk-3.0
    cat > ~/.config/gtk-3.0/settings.ini << 'GTKEOF'
[Settings]
gtk-theme-name=catppuccin-mocha-red-standard+default
gtk-icon-theme-name=Tela-circle-dark
gtk-cursor-theme-name=Bibata-Modern-Classic
gtk-font-name=Inter 11
gtk-application-prefer-dark-theme=1
GTKEOF
"

done_msg "themes installed"

# ════════════════════════════════════════════════════════════════════
section "STEP 5 — KALI VM SETUP"
# ════════════════════════════════════════════════════════════════════

VIRT_PKGS=(
    virt-manager
    qemu-full
    libvirt
    edk2-ovmf
    dnsmasq
    bridge-utils
    vde2
)

for pkg in "${VIRT_PKGS[@]}"; do
    run "installing $pkg" sudo pacman -S --noconfirm "$pkg"
done

run "enabling libvirtd" sudo systemctl enable --now libvirtd
run "adding user to libvirt group" sudo usermod -aG libvirt "$USER"
run "enabling default network" sudo virsh net-autostart default

done_msg "VM stack ready — open virt-manager and create a new VM with kali iso"

# ════════════════════════════════════════════════════════════════════
section "STEP 6 — EXTRA GOODIES"
# ════════════════════════════════════════════════════════════════════

EXTRA_PKGS=(
    btop
    fastfetch
    timeshift
    fish
    starship
    ripgrep
    fd
    bat
    eza
    fzf
    zoxide
)

for pkg in "${EXTRA_PKGS[@]}"; do
    run "installing $pkg" paru -S --noconfirm "$pkg"
done

# fastfetch config
run "setting up fastfetch config" bash -c "
    mkdir -p ~/.config/fastfetch
    fastfetch --gen-config
"

# fish shell setup
run "setting fish as default shell" bash -c "
    echo /usr/bin/fish | sudo tee -a /etc/shells
    chsh -s /usr/bin/fish
"

done_msg "extra tools installed"

# ════════════════════════════════════════════════════════════════════
# DONE
# ════════════════════════════════════════════════════════════════════

echo ""
echo -e "${RED}▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓${RESET}"
echo -e "${BRED}"
cat << 'EOF'
    ██████╗  ██████╗ ███╗   ██╗███████╗██╗██╗
    ██╔══██╗██╔═══██╗████╗  ██║██╔════╝██║██║
    ██║  ██║██║   ██║██╔██╗ ██║█████╗  ██║██║
    ██║  ██║██║   ██║██║╚██╗██║██╔══╝  ╚═╝╚═╝
    ██████╔╝╚██████╔╝██║ ╚████║███████╗██╗██╗
    ╚═════╝  ╚═════╝ ╚═╝  ╚═══╝╚══════╝╚═╝╚═╝
EOF
echo -e "${RESET}"
echo -e "${RED}▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓${RESET}"
echo ""
echo -e "${WHITE}  your system is now a demon 😈${RESET}"
echo -e "${GRAY}  reboot to apply all changes${RESET}"
echo ""
echo -e "${RED}  ►${WHITE} github  ${GRAY}» ${RED}github.com/roxzitywolf/ezlinux${RESET}"
echo ""
echo -e "${DIM}  ezlinux by roxzitywolf — go touch grass now${RESET}"
echo ""
