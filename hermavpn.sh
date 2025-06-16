#!/bin/bash
ver="2.0"

# Color definitions
readonly GREEN="\033[32m"
readonly WHITE="\033[37m"
readonly RED="\033[31m"
readonly BLUE="\033[34m"
readonly YELLOW="\033[33m"
readonly CYAN="\033[36m"
readonly MAGENTA="\033[35m"
readonly RESET="\033[0m"

# Message display functions
error()
{
    echo -e "${RED}[-] Error: $1${RESET}" >&2
    exit 1
}

success()
{
    echo -e "${GREEN}[+] $1${RESET}"
}

warning()
{
    echo -e "${YELLOW}[!] $1${RESET}"
}

info()
{
    echo -e "${BLUE}[*] $1${RESET}"
}

# endpoint variables
ENTRYPOINT="$1"
ENDPOINT="$2"

# root checks 
if [ "$(id -u)" != "0" ];then
    error "sudo hermavpn \$endpoint \$entrypoint"
else
    # install ifconfig
    apt -qq update
    apt install -qy net-tools
fi

# global variables
OS=`uname -m`
USERS=$(users | awk '{print $1}')
LAN=$(ifconfig | sed -En 's/127.0.0.1//;s/.*inet (addr:)?(([0-9]*\.){3}[0-9]*).*/\2/p')
DOM_ONE=$(echo $ENDPOINT | awk -F. '{print $2}')
DOM_TWO=$(echo $ENTRYPOINT | awk -F. '{print $3}')
DOMAIN=$(echo "$DOM_ONE.$DOM_TWO")
IP_ENDPOINT=$(dig -4 +short $ENDPOINT)
IP_ENTRYPOINT=$(dig -4 +short $ENTRYPOINT)
INTERFACE=$(ip r | head -1 | cut -d " " -f5)

# Display ASCII art logo
logo()
{
    reset
    clear
    echo -e  "${GREEN}                            --/osssssssssssso/--                    "
    echo -e  "${GREEN}                        -+sss+-+--os.yo:++/.o-/sss+-                "
    echo -e  "${GREEN}                     /sy+++-.h.-dd++m+om/s.h.hy/:+oys/              "
    echo -e  "${GREEN}                  .sy/// h/h-:d-y:/+-/+-+/-s/sodooh:///ys.          "
    echo -e  "${GREEN}                -ys-ss/:y:so-/osssso++++osssso+.oo+/s-:o.sy-        "
    echo -e  "${GREEN}              -ys:oossyo/+oyo/:-:.-:.:/.:/-.-:/syo/+/s+:oo:sy-      "
    echo -e  "${GREEN}             /d/:-soh/-+ho-.:::--:- .os: -:-.:-/::sy+:+ysso+:d/     "
    echo -e  "${GREEN}            sy-..+oo-+h:--:..hy+y/  :s+.  /y/sh..:/-:h+-oyss:.ys    "
    echo -e  "${WHITE}           ys :+oo/:d/   .m-yyyo/- - -:   .+oyhy-N.   /d::yosd.sy   "
    echo -e  "${WHITE}          oy.++++//d.  ::oNdyo:     .--.     :oyhN+-:  .d//s//y.ys  "
    echo -e  "${WHITE}         :m-y+++//d-   dyyy++::-. -.o.-+.- .-::/+hsyd   -d/so+++.m: "
    echo -e  "${WHITE}        -d/-/+++.m-  /.ohso- ://:///++++///://:  :odo.+  -m.syoo:/d-"
    echo -e  "${WHITE}        :m-+++y:y+   smyms-   -//+/-ohho-/+//-    omsmo   +y s+oy-m:"
    echo -e  "${WHITE}        sy:+++y-N-  -.dy+:...-- :: ./hh/. :: --...//hh.:  -N-o+/:-so"
    echo -e  "${WHITE}        yo-///s-m   odohd.-.--:/o.-+/::/+-.o/:--.--hd:ho   m-s+++-+y"
    echo -e  "${WHITE}        yo::/+o-m   -yNy/:  ...:+s.//:://.s+:...  :/yNs    m-h++++oy"
    echo -e  "${WHITE}        oy/hsss-N-  oo:oN-   .-o.:ss:--:ss:.o-.   -My-oo  -N-o+++.so"
    echo -e  "${WHITE}        :m :++y:y+   sNMy+: -+/:.--:////:--.:/+- -+hNNs   +y-o++o-m:"
    echo -e  "${WHITE}        -d/::+o+.m-  -:/+ho:.       -//-       ./sdo::-  -m-o++++/d-"
    echo -e  "${WHITE}         :m-yo++//d- -ommMo//        -:        +oyNhmo- -d//s+++-m: "
    echo -e  "${WHITE}          oy /o++//d.  -::/oMss-   -+++s     :yNy+/:   .d//y+---ys  "
    echo -e  "${WHITE}           ys--+o++:d/ -/sdmNysNs+/./-//-//hNyyNmmy+- /d-+y--::sy   "
    echo -e    "${RED}            sy:..ooo-+h/--.-//odm/hNh--yNh+Ndo//-./:/h+-so+:+/ys    "
    echo -e    "${RED}             /d-o.ssy+-+yo:/:/:-:+sho..ohs/-:://::oh+.h//syo-d/     "
    echo -e    "${RED}              -ys-oosyss:/oyy//::..-.--.--:/.//syo+-ys//o/.sy-      "
    echo -e    "${RED}                -ys.sooh+d-s:+osssysssosssssso:/+/h:/yy/.sy-        "
    echo -e    "${RED}                  .sy/:os.h--d/o+-/+:o:/+.+o:d-y+h-o+-+ys.          "
    echo -e    "${RED}                     :sy+:+ s//sy-y.-h-m/om:s-y.++/+ys/             "
    echo -e    "${RED}                        -+sss+/o/ s--y.s+/:++-+sss+-                "
    echo -e    "${RED}                            --/osssssssssssso/--                    "
    echo -e   "${BLUE}                                  Unk9vvN                           "
    echo -e "${YELLOW}                         https://hermavpn.github.io                 "
    echo -e   "${CYAN}                                HermaVPN "$ver"                     "
    echo -e "\n"
}

# install backhaul
backhaul()
{
    if [ ! -d "/usr/share/backhaul" ]; then
      local name="backhaul"
      mkdir -p /usr/share/$name
      wget https://github.com/Musixal/Backhaul/releases/latest/download/backhaul_linux_amd64.tar.gz -O /tmp/$name.tar.gz
      tar -xzf /tmp/$name.tar.gz -C /usr/share/$name
      chmod 755 /usr/share/$name/*
      ln -fs /usr/share/$name/backhaul /usr/bin/$name
      chmod +x /usr/bin/$name
      cat > /etc/$name.local << EOF
#!/bin/bash
cd /usr/share/$name
exec ./$name -c config.toml
EOF
      chmod +x /etc/$name.local
      cat > /usr/lib/systemd/system/$name.service << EOF
[Unit]
Description=$name Tunneling
After=network.target syslog.target nss-lookup.target
Wants=network-online.target

[Service]
Type=exec
ExecStart=/etc/$name.local
ExecReload=/bin/pkill $name
KillMode=mixed
Restart=on-failure
RestartSec=10
User=root
Group=root

[Install]
WantedBy=multi-user.target
EOF
        systemctl daemon-reload
        systemctl enable $name
        success "Success installing $name"
    fi
}

# entrypoint server
entrypoint()
{
    # Initialize hostname
    if ! grep -q "entrypoint" /etc/hostname; then
        echo "entrypoint" > /etc/hostname
    fi

    # install backhaul
    backhaul

    if [ ! -f "/usr/share/backhaul/config.toml" ]; then
        cat > /usr/share/backhaul/config.toml << EOF
[server]
bind_addr = "0.0.0.0:8080"
transport = "tcp"
accept_udp = false 
token = "00980098"
keepalive_period = 75  
nodelay = true 
heartbeat = 40 
channel_size = 2048
sniffer = false 
sniffer_log = "/usr/share/backhaul/backhaul.json"
log_level = "info"
ports = [
    "80=127.0.0.1:80",     # HTTP traffic
    "443=127.0.0.1:443"    # HTTPS/VLESS traffic
]
EOF
    fi

    success "entrypoint success config"
    exit 0
}

# endpoint server
endpoint()
{
    # Initialize hostname
    if ! grep -q "endpoint" /etc/hostname; then
        echo "endpoint" > /etc/hostname
    fi

    # install backhaul
    backhaul

    if [ ! -f "/usr/share/backhaul/config.toml" ]; then
        cat > /usr/share/backhaul/config.toml << EOF
[client]
remote_addr = "$IP_ENTRYPOINT:8080"
transport = "tcp"
token = "00980098"
connection_pool = 8
aggressive_pool = false
keepalive_period = 75
dial_timeout = 10
nodelay = true
retry_interval = 3
sniffer = false
sniffer_log = "/usr/share/backhaul/backhaul.json"
log_level = "info"
EOF
    fi

    success "endpoint success config"
    exit 0
}

# execute main
main()
{
    # bypass limited
    ip link set dev $INTERFACE mtu 1420

    # apt fixed iran
    if grep -q "ir.archive.ubuntu.com" /etc/apt/sources.list; then
        sed -i "s|ir.archive.ubuntu.com|archive.ubuntu.com|g" /etc/apt/sources.list
        success "fixing apt iran"
    fi

    # apt fixed germany
    if grep -q "de.archive.ubuntu.com" /etc/apt/sources.list; then
        sed -i "s|de.archive.ubuntu.com|archive.ubuntu.com|g" /etc/apt/sources.list
        success "fixing apt germany"
    fi

    # Configure DNS with error handling
    if ! grep -q "nameserver 178.22.122.100" /etc/resolv.conf; then
        echo -e "nameserver 178.22.122.100\nnameserver 185.51.200.2" > /etc/resolv.conf
        chattr +i /etc/resolv.conf 2>/dev/null
        success "setting nameserver shecan.ir"
    fi

    # Configure DNS with error handling
    if ! grep -q "185.199.108.133" /etc/hosts; then
        cat > /etc/hosts << EOF
185.199.108.133 raw.githubusercontent.com
185.125.190.36 archive.ubuntu.com
185.125.190.39 security.ubuntu.com
EOF
        success "setting host shecan.ir"
    fi

    # Install dependencies with better error handling
    apt_dependencies=(
        "net-tools" "wget" "curl" "git" "jq" "unzip" "zip" "gnupg" "apt-transport-https"
        "nload" "htop" "speedtest-cli" "fail2ban" "cron" "iftop" "tcptrack" "nano" "dnsutils"
    )

    # Check and install missing dependencies with improved checking
    missing_dependencies=()
    for dep in "${apt_dependencies[@]}"; do
        # Check if package is installed using dpkg-query
        if ! dpkg-query -W -f='${Status}' "$dep" 2>/dev/null | grep -q "installed"; then
            # Double check if command exists in PATH
            if ! command -v "$dep" &>/dev/null; then
                missing_dependencies+=("$dep")
            fi
        fi
    done

    if (( ${#missing_dependencies[@]} > 0 )); then
        info "Installing missing packages: ${missing_dependencies[*]}"
        if ! apt install -y "${missing_dependencies[@]}"; then
            warning "Failed to install some packages - continuing with available tools"
        fi
    fi

    # Initialize fail2ban
    if [ ! -f "/etc/fail2ban/jail.local" ]; then
        cat > /etc/fail2ban/jail.local << EOF
[sshd]
enabled = true
port = ssh
filter = sshd
logpath = /var/log/auth.log
maxretry = 10
findtime = 60m
bantime = 60m
ignoreip = 127.0.0.1/8 ::1
EOF
        systemctl daemon-reload
        systemctl enable fail2ban
        success "Success installing fail2ban"
    fi

    # install hermavpn
    if [ ! -d "/usr/share/hermavpn" ]; then
        local name="hermavpn"
        mkdir -p /usr/share/$name
        curl -s -o /usr/share/$name/$name.sh https://raw.githubusercontent.com/hermavpn/hermavpn.github.io/main/hermavpn.sh
        chmod 755 /usr/share/$name/*
        cat > /usr/bin/$name << EOF
#!/bin/bash
cd /usr/share/$name;bash $name.sh "\$@"
EOF
        chmod +x /usr/bin/$name
        cat > /usr/share/$name/bandwith.sh << 'EOF'
#!/bin/bash
# Define the minimum acceptable bandwidth in Mbps
MIN_BANDWIDTH=10
# Run the speed test and parse the download speed
if command -v speedtest-cli >/dev/null 2>&1; then
    DOWNLOAD_SPEED=$(timeout 60 speedtest-cli --simple 2>/dev/null | grep 'Download' | awk '{print $2}')
    
    # Check if we got a valid result and if speed is below threshold
    if [[ -n "$DOWNLOAD_SPEED" ]] && (( $(echo "$DOWNLOAD_SPEED < $MIN_BANDWIDTH" | bc -l 2>/dev/null || echo 0) )); then
        logger "Bandwidth ($DOWNLOAD_SPEED Mbps) below threshold ($MIN_BANDWIDTH Mbps), rebooting..."
        /sbin/reboot
    fi
fi
EOF
        chmod +x /usr/share/$name/bandwith.sh
        (crontab -l 2>/dev/null; echo "0 * * * * /usr/share/$name/bandwidth.sh") | crontab -
        success "Success installing $name"
    elif [ "$(curl -s https://raw.githubusercontent.com/hermavpn/hermavpn.github.io/main/version)" != "$ver" ]; then
        local name="hermavpn"
        curl -s -o /usr/share/$name/$name.sh https://raw.githubusercontent.com/hermavpn/hermavpn.github.io/main/hermavpn.sh
        chmod 755 /usr/share/$name/*
        cat > /usr/bin/$name << EOF
#!/bin/bash
cd /usr/share/$name;bash $name.sh "\$@"
EOF
        chmod +x /usr/bin/$name
        cat > /usr/share/$name/bandwith.sh << 'EOF'
#!/bin/bash
# Define the minimum acceptable bandwidth in Mbps
MIN_BANDWIDTH=10
# Run the speed test and parse the download speed
if command -v speedtest-cli >/dev/null 2>&1; then
    DOWNLOAD_SPEED=$(timeout 60 speedtest-cli --simple 2>/dev/null | grep 'Download' | awk '{print $2}')
    
    # Check if we got a valid result and if speed is below threshold
    if [[ -n "$DOWNLOAD_SPEED" ]] && (( $(echo "$DOWNLOAD_SPEED < $MIN_BANDWIDTH" | bc -l 2>/dev/null || echo 0) )); then
        logger "Bandwidth ($DOWNLOAD_SPEED Mbps) below threshold ($MIN_BANDWIDTH Mbps), rebooting..."
        /sbin/reboot
    fi
fi
EOF
        chmod +x /usr/share/$name/bandwith.sh
        (crontab -l 2>/dev/null; echo "0 * * * * /usr/share/$name/bandwidth.sh") | crontab -
        success "Success updating $name"
        bash /usr/share/$name/$name.sh
    fi
}


arguments()
{
    if [ -z "$1" ]; then
        error "sudo hermavpn \$endpoint \$entrypoint"
        exit 1
    elif [ -z "$2" ]; then
        error "sudo hermavpn \$endpoint \$entrypoint"
    fi
}


logo
main


select opt in "Endpoint" "Entrypoint" Exit
do
    case $opt in
        "Endpoint"|"Entrypoint")
            arguments "$1" "$2"
            info "Running $opt Tunnel..."
            "${opt,,}";;
        "Exit")
            error "Exiting..."
            break;;
        *) echo "invalid option...";;
    esac
done
