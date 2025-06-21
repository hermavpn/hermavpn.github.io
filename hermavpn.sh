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

# Fix domain extraction logic
if [[ "$ENDPOINT" =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
    # If ENDPOINT is IP, use ENTRYPOINT for domain
    DOMAIN=$(echo "$ENTRYPOINT" | cut -d. -f2-)
else
    # If ENDPOINT is domain, use it
    DOMAIN=$(echo "$ENDPOINT" | cut -d. -f2-)
fi

IP_ENDPOINT=$(dig -4 +short $ENDPOINT 2>/dev/null | head -1)
IP_ENTRYPOINT=$(dig -4 +short $ENTRYPOINT 2>/dev/null | head -1)
INTERFACE=$(ip r | head -1 | cut -d " " -f5 2>/dev/null)

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
      
      # Download with better error handling
      if ! wget -q https://github.com/Musixal/Backhaul/releases/latest/download/backhaul_linux_amd64.tar.gz -O /tmp/$name.tar.gz; then
          error "Failed to download backhaul"
      fi
      
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

# Function to start backhaul service
start_backhaul()
{
    if systemctl is-active --quiet backhaul; then
        systemctl restart backhaul
        success "Backhaul service restarted"
    else
        systemctl start backhaul
        success "Backhaul service started"
    fi
    
    # Show service status
    sleep 2
    if systemctl is-active --quiet backhaul; then
        success "Backhaul is running successfully"
    else
        warning "Backhaul service failed to start. Check logs with: journalctl -u backhaul"
    fi
}

# TCP
entrypoint_tcp()
{
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
    "80=127.0.0.1:80",
    "443=127.0.0.1:443"
]
EOF
    success "Configuration Success $1"
    start_backhaul
}

# TCP
endpoint_tcp()
{
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
    success "Configuration Success $1"
    start_backhaul
}

# TCPMUX
entrypoint_tcpmux()
{
    cat > /usr/share/backhaul/config.toml << EOF
[server]
bind_addr = "0.0.0.0:8080"
transport = "tcpmux"
token = "00980098" 
keepalive_period = 75
nodelay = true 
heartbeat = 40 
channel_size = 2048
mux_con = 8
mux_version = 1
mux_framesize = 32768 
mux_recievebuffer = 4194304
mux_streambuffer = 65536 
sniffer = false 
sniffer_log = "/usr/share/backhaul/backhaul.json"
log_level = "info"
ports = [
    "80=127.0.0.1:80",
    "443=127.0.0.1:443"
]
EOF
    success "Configuration Success $1"
    start_backhaul
}

# TCPMUX
endpoint_tcpmux()
{
    cat > /usr/share/backhaul/config.toml << EOF
[client]
remote_addr = "$IP_ENTRYPOINT:8080"
transport = "tcpmux"
token = "00980098" 
connection_pool = 8
aggressive_pool = false
keepalive_period = 75
dial_timeout = 10
retry_interval = 3
nodelay = true 
mux_version = 1
mux_framesize = 32768 
mux_recievebuffer = 4194304
mux_streambuffer = 65536 
sniffer = false 
sniffer_log = "/usr/share/backhaul/backhaul.json"
log_level = "info"
EOF
    success "Configuration Success $1"
    start_backhaul
}

# UDP
entrypoint_udp()
{
    cat > /usr/share/backhaul/config.toml << EOF
[server]
bind_addr = "0.0.0.0:8080"
transport = "udp"
token = "00980098"
heartbeat = 20 
channel_size = 2048
sniffer = false
sniffer_log = "/usr/share/backhaul/backhaul.json"
log_level = "info"
ports = [
    "80=127.0.0.1:80",
    "443=127.0.0.1:443"
]
EOF
    success "Configuration Success $1"
    start_backhaul
}

# UDP
endpoint_udp()
{
    cat > /usr/share/backhaul/config.toml << EOF
[client]
remote_addr = "$IP_ENTRYPOINT:8080"
transport = "udp"
token = "your_token" 
connection_pool = 8
aggressive_pool = false
retry_interval = 3
sniffer = false
sniffer_log = "/usr/share/backhaul/backhaul.json"
log_level = "info"
EOF
    success "Configuration Success $1"
    start_backhaul
}

# Websocket
entrypoint_ws()
{
    cat > /usr/share/backhaul/config.toml << EOF
[server]
bind_addr = "0.0.0.0:8080"
transport = "ws"
token = "00980098" 
channel_size = 2048
keepalive_period = 75 
heartbeat = 40
nodelay = true 
sniffer = false 
sniffer_log = "/usr/share/backhaul/backhaul.json"
log_level = "info"
ports = [
    "80=127.0.0.1:80",
    "443=127.0.0.1:443"
]
EOF
    success "Configuration Success $1"
    start_backhaul
}

# Websocket
endpoint_ws()
{
    cat > /usr/share/backhaul/config.toml << EOF
[client]
remote_addr = "$IP_ENTRYPOINT:8080"
transport = "ws"
token = "00980098" 
connection_pool = 8
aggressive_pool = false
keepalive_period = 75 
dial_timeout = 10
retry_interval = 3
nodelay = true 
sniffer = false 
sniffer_log = "/usr/share/backhaul/backhaul.json"
log_level = "info"
EOF
    success "Configuration Success $1"
    start_backhaul
}

# Secure Websocket
entrypoint_wss()
{
    # generate certs
    openssl genpkey -algorithm RSA -out /usr/share/backhaul/server.key -pkeyopt rsa_keygen_bits:2048
    openssl req -new -key /usr/share/backhaul/server.key \
            -out /usr/share/backhaul/server.csr \
            -subj "/C=US/ST=California/L=San Francisco/O=Your Company Name/CN=example.com"

    cat > /usr/share/backhaul/config.toml << EOF
[server]
bind_addr = "0.0.0.0:8080"
transport = "wss"
token = "your_token" 
channel_size = 2048
keepalive_period = 75 
nodelay = true 
tls_cert = "/usr/share/backhaul/server.crt"      
tls_key = "/usr/share/backhaul//server.key"
sniffer = false
sniffer_log = "/usr/share/backhaul/backhaul.json"
log_level = "info"
ports = [
    "80=127.0.0.1:80",
    "443=127.0.0.1:443"
]
EOF
    success "Configuration Success $1"
    start_backhaul
}

# Secure Websocket
endpoint_wss()
{
    cat > /usr/share/backhaul/config.toml << EOF
[client]
remote_addr = "$IP_ENTRYPOINT:8080"
transport = "wss"
token = "00980098" 
connection_pool = 8
aggressive_pool = false
keepalive_period = 75
dial_timeout = 10
retry_interval = 3  
nodelay = true 
sniffer = false 
sniffer_log = "/usr/share/backhaul/backhaul.json"
log_level = "info"
EOF
    success "Configuration Success $1"
    start_backhaul
}

# Websocket MUX
entrypoint_wsmux()
{
    cat > /usr/share/backhaul/config.toml << EOF
[server]
bind_addr = "0.0.0.0:8080"
transport = "wsmux"
token = "00980098" 
keepalive_period = 75
nodelay = true 
heartbeat = 40 
channel_size = 2048
mux_con = 8
mux_version = 1
mux_framesize = 32768 
mux_recievebuffer = 4194304
mux_streambuffer = 65536 
sniffer = false
sniffer_log = "/usr/share/backhaul/backhaul.json"
log_level = "info"
ports = [
    "80=127.0.0.1:80",
    "443=127.0.0.1:443"
]
EOF
    success "Configuration Success $1"
    start_backhaul
}

# Websocket MUX
endpoint_wsmux()
{
    cat > /usr/share/backhaul/config.toml << EOF
[client]
remote_addr = "$IP_ENTRYPOINT:8080"
transport = "wsmux"
token = "00980098" 
connection_pool = 8
aggressive_pool = false
keepalive_period = 75
dial_timeout = 10
nodelay = true
retry_interval = 3
mux_version = 1
mux_framesize = 32768 
mux_recievebuffer = 4194304
mux_streambuffer = 65536 
sniffer = false
sniffer_log = "/usr/share/backhaul/backhaul.json"
log_level = "info"
EOF
    success "Configuration Success $1"
    start_backhaul
}

# Secure Websocket MUX
entrypoint_wssmux()
{
    # generate certs
    openssl genpkey -algorithm RSA -out /usr/share/backhaul/server.key -pkeyopt rsa_keygen_bits:2048
    openssl req -new -key /usr/share/backhaul/server.key \
            -out /usr/share/backhaul/server.csr \
            -subj "/C=US/ST=California/L=San Francisco/O=Your Company Name/CN=example.com"

    cat > /usr/share/backhaul/config.toml << EOF
[server]
bind_addr = "0.0.0.0:8080"
transport = "wssmux"
token = "00980098" 
keepalive_period = 75
nodelay = true 
heartbeat = 40 
channel_size = 2048
mux_con = 8
mux_version = 1
mux_framesize = 32768 
mux_recievebuffer = 4194304
mux_streambuffer = 65536 
tls_cert = "/usr/share/backhaul/server.crt"      
tls_key = "/usr/share/backhaul/server.key"
sniffer = false 
sniffer_log = "/usr/share/backhaul/backhaul.json"
log_level = "info"
ports = [
    "80=127.0.0.1:80",
    "443=127.0.0.1:443"
]
EOF
    success "Configuration Success $1"
    start_backhaul
}

# Secure Websocket MUX
endpoint_wssmux()
{
    cat > /usr/share/backhaul/config.toml << EOF
[client]
remote_addr = "$IP_ENTRYPOINT:8080"
transport = "wssmux"
token = "00980098" 
keepalive_period = 75
dial_timeout = 10
nodelay = true
retry_interval = 3
connection_pool = 8
aggressive_pool = false
mux_version = 1
mux_framesize = 32768 
mux_recievebuffer = 4194304
mux_streambuffer = 65536  
sniffer = false
sniffer_log = "/usr/share/backhaul/backhaul.json"
log_level = "info"
EOF
    success "Configuration Success $1"
    start_backhaul
}

# Function to select tunneling protocol
select_protocol()
{
    local service_type=$1
    info "Select Tunneling Protocol for $service_type"
    select protocol_opt in "TCP" "TCPMUX" "UDP" "WS" "WSS" "WSMUX" "WSSMUX" "Back to Main Menu"
    do
        case $protocol_opt in
            "TCP")
                if [ "$service_type" = "endpoint" ]; then
                    endpoint_tcp "$service_type"
                elif [ "$service_type" = "entrypoint" ]; then
                    entrypoint_tcp "$service_type"
                fi
                break;;
            "TCPMUX")
                if [ "$service_type" = "endpoint" ]; then
                    endpoint_tcpmux "$service_type"
                elif [ "$service_type" = "entrypoint" ]; then
                    entrypoint_tcpmux "$service_type"
                fi
                break;;
            "UDP")
                if [ "$service_type" = "endpoint" ]; then
                    endpoint_udp "$service_type"
                elif [ "$service_type" = "entrypoint" ]; then
                    entrypoint_udp "$service_type"
                fi
                break;;
            "WS")
                if [ "$service_type" = "endpoint" ]; then
                    endpoint_ws "$service_type"
                elif [ "$service_type" = "entrypoint" ]; then
                    entrypoint_ws "$service_type"
                fi
                break;;
            "WSS")
                if [ "$service_type" = "endpoint" ]; then
                    endpoint_wss "$service_type"
                elif [ "$service_type" = "entrypoint" ]; then
                    entrypoint_wss "$service_type"
                fi
                break;;
            "WSMUX")
                if [ "$service_type" = "endpoint" ]; then
                    endpoint_wsmux "$service_type"
                elif [ "$service_type" = "entrypoint" ]; then
                    entrypoint_wsmux "$service_type"
                fi
                break;;
            "WSSMUX")
                if [ "$service_type" = "endpoint" ]; then
                    endpoint_wssmux "$service_type"
                elif [ "$service_type" = "entrypoint" ]; then
                    entrypoint_wssmux "$service_type"
                fi
                break;;
            "Back to Main Menu")
                break;;
            *) error "Invalid option: $REPLY. Please choose a valid protocol.";;
        esac
    done
}

# entrypoint server
entrypoint()
{
    # Initialize hostname
    if ! grep -q "entrypoint" /etc/hostname; then
        echo "entrypoint" > /etc/hostname
        hostname entrypoint
    fi

    # install backhaul
    backhaul
}

# endpoint server
endpoint()
{
    # Initialize hostname
    if ! grep -q "endpoint" /etc/hostname; then
        echo "endpoint" > /etc/hostname
        hostname endpoint
    fi

    # install backhaul
    backhaul
}

# execute main
main()
{
    # bypass limited (with error handling)
    if [ -n "$INTERFACE" ]; then
        ip link set dev $INTERFACE mtu 1420 2>/dev/null || warning "Failed to set MTU"
    fi

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

    # Install dependencies with better error handling (added bc)
    apt_dependencies=(
        "net-tools" "wget" "curl" "git" "jq" "unzip" "zip" "gnupg" "apt-transport-https" "openssl"
        "nload" "htop" "speedtest-cli" "fail2ban" "cron" "iftop" "tcptrack" "nano" "dnsutils" "bc"
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
        systemctl start fail2ban 2>/dev/null
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
        # Fixed filename: bandwidth.sh (not bandwith.sh)
        cat > /usr/share/$name/bandwidth.sh << 'EOF'
#!/bin/bash
# Define the minimum acceptable bandwidth in Mbps
MIN_BANDWIDTH=10
# Run the speed test and parse the download speed
if command -v speedtest-cli >/dev/null 2>&1; then
    DOWNLOAD_SPEED=$(timeout 60 speedtest-cli --simple 2>/dev/null | grep 'Download' | awk '{print $2}')
    
    # Check if we got a valid result and if speed is below threshold
    # Use awk instead of bc for better compatibility
    if [[ -n "$DOWNLOAD_SPEED" ]] && awk "BEGIN {exit !($DOWNLOAD_SPEED < $MIN_BANDWIDTH)}"; then
        logger "Bandwidth ($DOWNLOAD_SPEED Mbps) below threshold ($MIN_BANDWIDTH Mbps), rebooting..."
        /sbin/reboot
    fi
fi
EOF
        chmod +x /usr/share/$name/bandwidth.sh
        (crontab -l 2>/dev/null; echo "0 * * * * /usr/share/$name/bandwidth.sh") | crontab -
        success "Success installing $name"
    elif [ "$(curl -s https://raw.githubusercontent.com/hermavpn/hermavpn.github.io/main/version 2>/dev/null)" != "$ver" ]; then
        local name="hermavpn"
        curl -s -o /usr/share/$name/$name.sh https://raw.githubusercontent.com/hermavpn/hermavpn.github.io/main/hermavpn.sh
        chmod 755 /usr/share/$name/*
        cat > /usr/bin/$name << EOF
#!/bin/bash
cd /usr/share/$name;bash $name.sh "\$@"
EOF
        chmod +x /usr/bin/$name
        # Fixed filename: bandwidth.sh (not bandwith.sh)
        cat > /usr/share/$name/bandwidth.sh << 'EOF'
#!/bin/bash
# Define the minimum acceptable bandwidth in Mbps
MIN_BANDWIDTH=10
# Run the speed test and parse the download speed
if command -v speedtest-cli >/dev/null 2>&1; then
    DOWNLOAD_SPEED=$(timeout 60 speedtest-cli --simple 2>/dev/null | grep 'Download' | awk '{print $2}')
    
    # Check if we got a valid result and if speed is below threshold
    # Use awk instead of bc for better compatibility
    if [[ -n "$DOWNLOAD_SPEED" ]] && awk "BEGIN {exit !($DOWNLOAD_SPEED < $MIN_BANDWIDTH)}"; then
        logger "Bandwidth ($DOWNLOAD_SPEED Mbps) below threshold ($MIN_BANDWIDTH Mbps), rebooting..."
        /sbin/reboot
    fi
fi
EOF
        chmod +x /usr/share/$name/bandwidth.sh
        (crontab -l 2>/dev/null; echo "0 * * * * /usr/share/$name/bandwidth.sh") | crontab -
        success "Success updating $name"
        bash /usr/share/$name/$name.sh
    fi
}

# Check arguments
arguments()
{
    if [ -z "$1" ]; then
        error "sudo hermavpn $endpoint $entrypoint"
    elif [ -z "$2" ]; then
        error "sudo hermavpn $endpoint $entrypoint"
    fi
}

main_menu()
{
    select opt in "Setup" "Endpoint" "Entrypoint" "Exit"
    do
        case $opt in
            "Setup")
                # main is now called unconditionally at the beginning of the script
                ;;
            "Endpoint")
                arguments "$1" "$2"
                info "Running Endpoint service..."
                endpoint # Call the endpoint function
                select_protocol "endpoint" # Pass the service type to select_protocol
                ;;
            "Entrypoint")
                arguments "$1" "$2"
                info "Running Entrypoint service..."
                entrypoint # Call the entrypoint function
                select_protocol "entrypoint" # Pass the service type to select_protocol
                ;;
            "Exit")
                error "Exiting..."
                break;;
            *) echo "invalid option...";;
        esac
    done
}

main
logo

main_menu "$ENTRYPOINT" "$ENDPOINT"
