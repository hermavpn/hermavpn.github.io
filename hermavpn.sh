#!/bin/bash
ver="2.0"

# color variables
RED="\e[1;31m%s\e[0m\n"
GREEN="\e[1;32m%s\e[0m\n"
YELLOW="\e[1;33m%s\e[0m\n"
BLUE="\e[1;34m%s\e[0m\n"
MAGENTO="\e[1;35m%s\e[0m\n"
CYAN="\e[1;36m%s\e[0m\n"
WHITE="\e[1;37m%s\e[0m\n"

# endpoint variables
ENTRYPOINT="$1"
ENDPOINT="$2"

# root checks 
if [ "$(id -u)" != "0" ];then
    printf "$RED"		"[X] Please run as ROOT..."
    printf "$GREEN"     "[*] sudo hermavpn \$endpoint \$entrypoint"
    exit 0
else
    # update & upgrade & dist-upgrade
    apt update;apt upgrade -y;apt dist-upgrade -y;apt autoremove -y;apt autoclean

    # init requirements
    apt install -y wget curl git net-tools gnupg apt-transport-https nload htop speedtest-cli fail2ban cron iftop zip tcptrack nano dnsutils  
    OS=`uname -m`
    USERS=$(users | awk '{print $1}')
    LAN=$(ifconfig | sed -En 's/127.0.0.1//;s/.*inet (addr:)?(([0-9]*\.){3}[0-9]*).*/\2/p')
    DOM_ONE=$(echo $ENDPOINT | awk -F. '{print $2}')
    DOM_TWO=$(echo $ENTRYPOINT | awk -F. '{print $3}')
    DOMAIN=$(echo "$DOM_ONE.$DOM_TWO")
    IP_ENDPOINT=$(dig -4 +short $ENDPOINT)
    IP_ENTRYPOINT=$(dig -4 +short $ENTRYPOINT)
    INTERFACE=$(ip r | head -1 | cut -d " " -f5)
fi

# unk9vvn logo
logo ()
{
    reset;clear
    printf "$GREEN"   "                            --/osssssssssssso/--                    "
    printf "$GREEN"   "                        -+sss+-+--os.yo:++/.o-/sss+-                "
    printf "$GREEN"   "                     /sy+++-.h.-dd++m+om/s.h.hy/:+oys/              "
    printf "$GREEN"   "                  .sy/// h/h-:d-y:/+-/+-+/-s/sodooh:///ys.          "
    printf "$GREEN"   "                -ys-ss/:y:so-/osssso++++osssso+.oo+/s-:o.sy-        "
    printf "$GREEN"   "              -ys:oossyo/+oyo/:-:.-:.:/.:/-.-:/syo/+/s+:oo:sy-      "
    printf "$GREEN"   "             /d/:-soh/-+ho-.:::--:- .os: -:-.:-/::sy+:+ysso+:d/     "
    printf "$GREEN"   "            sy-..+oo-+h:--:..hy+y/  :s+.  /y/sh..:/-:h+-oyss:.ys    "
    printf "$WHITE"   "           ys :+oo/:d/   .m-yyyo/- - -:   .+oyhy-N.   /d::yosd.sy   "
    printf "$WHITE"   "          oy.++++//d.  ::oNdyo:     .--.     :oyhN+-:  .d//s//y.ys  "
    printf "$WHITE"   "         :m-y+++//d-   dyyy++::-. -.o.-+.- .-::/+hsyd   -d/so+++.m: "
    printf "$WHITE"   "        -d/-/+++.m-  /.ohso- ://:///++++///://:  :odo.+  -m.syoo:/d-"
    printf "$WHITE"   "        :m-+++y:y+   smyms-   -//+/-ohho-/+//-    omsmo   +y s+oy-m:"
    printf "$WHITE"   "        sy:+++y-N-  -.dy+:...-- :: ./hh/. :: --...//hh.:  -N-o+/:-so"
    printf "$WHITE"   "        yo-///s-m   odohd.-.--:/o.-+/::/+-.o/:--.--hd:ho   m-s+++-+y"
    printf "$WHITE"   "        yo::/+o-m   -yNy/:  ...:+s.//:://.s+:...  :/yNs    m-h++++oy"
    printf "$WHITE"   "        oy/hsss-N-  oo:oN-   .-o.:ss:--:ss:.o-.   -My-oo  -N-o+++.so"
    printf "$WHITE"   "        :m :++y:y+   sNMy+: -+/:.--:////:--.:/+- -+hNNs   +y-o++o-m:"
    printf "$WHITE"   "        -d/::+o+.m-  -:/+ho:.       -//-       ./sdo::-  -m-o++++/d-"
    printf "$WHITE"   "         :m-yo++//d- -ommMo//        -:        +oyNhmo- -d//s+++-m: "
    printf "$WHITE"   "          oy /o++//d.  -::/oMss-   -+++s     :yNy+/:   .d//y+---ys  "
    printf "$WHITE"   "           ys--+o++:d/ -/sdmNysNs+/./-//-//hNyyNmmy+- /d-+y--::sy   "
    printf "$RED"     "            sy:..ooo-+h/--.-//odm/hNh--yNh+Ndo//-./:/h+-so+:+/ys    "
    printf "$RED"     "             /d-o.ssy+-+yo:/:/:-:+sho..ohs/-:://::oh+.h//syo-d/     "
    printf "$RED"     "              -ys-oosyss:/oyy//::..-.--.--:/.//syo+-ys//o/.sy-      "
    printf "$RED"     "                -ys.sooh+d-s:+osssysssosssssso:/+/h:/yy/.sy-        "
    printf "$RED"     "                  .sy/:os.h--d/o+-/+:o:/+.+o:d-y+h-o+-+ys.          "
    printf "$RED"     "                     :sy+:+ s//sy-y.-h-m/om:s-y.++/+ys/             "
    printf "$RED"     "                        -+sss+/o/ s--y.s+/:++-+sss+-                "
    printf "$RED"     "                            --/osssssssssssso/--                    "
    printf "$BLUE"    "                                  Unk9vvN                           "
    printf "$YELLOW"  "                             hermavpn.github.io                     "
    printf "$CYAN"    "                               hermavpn "$ver"                      "
    printf "\n\n"
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
        systemctl start $name
        printf "$GREEN"  "[*] Success installing $name"
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
ports = ["80", "443"]
EOF
    fi

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

    exit 0
}

# execute main
main()
{
    # bypass limited
    ip link set dev $INTERFACE mtu 1420

    # resolv fixed
    if ! grep -q "nameserver 8.8.8.8" /etc/resolv.conf; then
        echo "nameserver 8.8.4.4" > /etc/resolv.conf
        echo "nameserver 8.8.8.8" >> /etc/resolv.conf
    fi

    # apt fixed iran
    if grep -q "ir.archive.ubuntu.com" /etc/apt/sources.list; then
        sed -i "s|ir.archive.ubuntu.com|archive.ubuntu.com|g" /etc/apt/sources.list
    fi

    # apt fixed germany
    if grep -q "de.archive.ubuntu.com" /etc/apt/sources.list; then
        sed -i "s|de.archive.ubuntu.com|archive.ubuntu.com|g" /etc/apt/sources.list
    fi

    # Configure DNS with error handling
    if ! grep -q "nameserver 178.22.122.100" /etc/resolv.conf 2>/dev/null; then
        echo -e "nameserver 178.22.122.100\nnameserver 185.51.200.2" > /etc/resolv.conf
        chattr +i /etc/resolv.conf 2>/dev/null
        cat > /etc/hosts << EOF
185.199.108.133 raw.githubusercontent.com
185.125.190.36 archive.ubuntu.com
185.125.190.39 security.ubuntu.com
EOF     
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
        bash /usr/share/$name/$name.sh
    fi

    echo "0 * * * * /usr/share/hermavpn/bandwith.sh" | crontab -
}


arguments()
{
    if [ -z "$1" ]; then
        printf "$RED"       "[X] The Entrypoint Server has not been entered."
        printf "$GREEN"     "[*] sudo hermavpn \$endpoint \$entrypoint"
        exit 1
    elif [ -z "$2" ]; then
        printf "$RED"       "[X] The Endpoint Server has not been entered."
        printf "$GREEN"     "[*] sudo hermavpn \$endpoint \$entrypoint"
        exit 1
    fi
}


logo
main


select opt in "Endpoint" "Entrypoint" Exit
do
    case $opt in
        "Endpoint"|"Entrypoint")
            arguments "$1" "$2"
            printf "$GREEN"  "[*] Running $opt Tunnel..."
            "${opt,,}";;
        "Exit")
            echo "Exiting..."
            break;;
        *) echo "invalid option...";;
    esac
done
