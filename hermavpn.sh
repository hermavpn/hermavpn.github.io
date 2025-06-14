#!/bin/bash
ver="2.0"


RED="\e[1;31m%s\e[0m\n"
GREEN="\e[1;32m%s\e[0m\n"
YELLOW="\e[1;33m%s\e[0m\n"
BLUE="\e[1;34m%s\e[0m\n"
MAGENTO="\e[1;35m%s\e[0m\n"
CYAN="\e[1;36m%s\e[0m\n"
WHITE="\e[1;37m%s\e[0m\n"
ENTRYPOINT="$1"
ENDPOINT="$2"


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


waterwall()
{
    local name="waterwall"
    if [ ! -d "/usr/share/$name" ]; then
        wget https://github.com/radkesvat/WaterWall/releases/latest/download/Waterwall-linux-64.zip -O /tmp/$name.zip
        unzip /tmp/$name.zip -d /usr/share/$name;rm -f /tmp/$name.zip
        chmod 755 /usr/share/$name/*
        ln -fs /usr/share/$name/Waterwall /usr/bin/$name
        chmod +x /usr/bin/$name
        cat > /etc/$name.local << EOF
#!/bin/bash
cd /usr/share/waterwall
exec ./Waterwall
EOF
        chmod +x /etc/$name.local
        cat > /usr/lib/systemd/system/$name.service << EOF
[Unit]
Description=WaterWall Tunneling
After=network.target syslog.target nss-lookup.target
Wants=network-online.target

[Service]
Type=exec
ExecStart=/etc/$name.local
ExecReload=/bin/kill -HUP \$MAINPID
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
        printf "$GREEN"  "[*] Success installing $name"
    fi
}


entrypoint()
{
    # Initialize hostname
    if ! grep -q "entrypoint" /etc/hostname; then
        echo "entrypoint" > /etc/hostname
    fi

    # install waterwall
    waterwall

    if [ ! -f "/usr/share/waterwall/core.json" ]; then
        cat > /usr/share/waterwall/core.json << EOF
{
  "log": {
    "path": "log/",
    "core": {
      "loglevel": "DEBUG",
      "file": "core.log",
      "console": true
    },
    "network": {
      "loglevel": "DEBUG",
      "file": "network.log",
      "console": true
    },
    "dns": {
      "loglevel": "SILENT",
      "file": "dns.log",
      "console": false
    }
  },
  "dns": {},
  "misc": {
    "workers": 0,
    "ram-profile": "server",
    "libs-path": "libs/"
  },
  "configs": ["config.json"]
}
EOF
    fi

    if [ ! -f "/usr/share/waterwall/config.json" ]; then
        cat > /usr/share/waterwall/config.json << EOF
{
  "name": "reverse_reality_grpc_server_multiport",
  "nodes": [
    {
      "name": "users_inbound",
      "type": "TcpListener",
      "settings": {
        "address": "0.0.0.0",
        "port": [443, 65535],
        "nodelay": true
      },
      "next": "header"
    },
    {
      "name": "header",
      "type": "HeaderClient",
      "settings": {
        "data": "src_context->port"
      },
      "next": "bridge2"
    },
    {
      "name": "bridge2",
      "type": "Bridge",
      "settings": {
        "pair": "bridge1"
      }
    },
    {
      "name": "bridge1",
      "type": "Bridge",
      "settings": {
        "pair": "bridge2"
      }
    },
    {
      "name": "reverse_server",
      "type": "ReverseServer",
      "settings": {},
      "next": "bridge1"
    },
    {
      "name": "pbserver",
      "type": "ProtoBufServer",
      "settings": {},
      "next": "reverse_server"
    },
    {
      "name": "h2server",
      "type": "Http2Server",
      "settings": {},
      "next": "pbserver"
    },
    {
      "name": "reality_server",
      "type": "RealityServer",
      "settings": {
        "destination": "reality_dest",
        "password": "passwd"
      },
      "next": "h2server"
    },
    {
      "name": "kharej_inbound",
      "type": "TcpListener",
      "settings": {
        "address": "0.0.0.0",
        "port": 443,
        "nodelay": true,
        "whitelist": ["$IP_ENDPOINT/32"]
      },
      "next": "reality_server"
    },
    {
      "name": "reality_dest",
      "type": "TcpConnector",
      "settings": {
        "nodelay": true,
        "address": "element.snapp.ir",
        "port": 443
      }
    }
  ]
}
EOF
    fi
    exit 0
}


endpoint ()
{
    # Initialize hostname
    if ! grep -q "endpoint" /etc/hostname; then
        echo "endpoint" > /etc/hostname
    fi

    # install waterwall
    waterwall

    if [ ! -f "/usr/share/waterwall/core.json" ]; then
        cat > /usr/share/waterwall/core.json << EOF
{
  "log": {
    "path": "log/",
    "core": {
      "loglevel": "DEBUG",
      "file": "core.log",
      "console": true
    },
    "network": {
      "loglevel": "DEBUG",
      "file": "network.log",
      "console": true
    },
    "dns": {
      "loglevel": "SILENT",
      "file": "dns.log",
      "console": false
    }
  },
  "dns": {},
  "misc": {
    "workers": 0,
    "ram-profile": "server",
    "libs-path": "libs/"
  },
  "configs": ["config.json"]
}
EOF
    fi

    if [ ! -f "/usr/share/waterwall/config.json" ]; then
        cat > /usr/share/waterwall/config.json << EOF
{
  "name": "reverse_reality_grpc_client_multiport",
  "nodes": [
    {
      "name": "outbound_to_core",
      "type": "TcpConnector",
      "settings": {
        "nodelay": true,
        "address": "127.0.0.1",
        "port": "dest_context->port"
      }
    },
    {
      "name": "header",
      "type": "HeaderServer",
      "settings": {
        "override": "dest_context->port"
      },
      "next": "outbound_to_core"
    },
    {
      "name": "bridge1",
      "type": "Bridge",
      "settings": {
        "pair": "bridge2"
      },
      "next": "header"
    },
    {
      "name": "bridge2",
      "type": "Bridge",
      "settings": {
        "pair": "bridge1"
      },
      "next": "reverse_client"
    },
    {
      "name": "reverse_client",
      "type": "ReverseClient",
      "settings": {
        "minimum-unused": 8
      },
      "next": "pbclient"
    },
    {
      "name": "pbclient",
      "type": "ProtoBufClient",
      "settings": {},
      "next": "h2client"
    },
    {
      "name": "h2client",
      "type": "Http2Client",
      "settings": {
        "host": "element.snapp.ir",
        "port": 443,
        "path": "/",
        "content-type": "application/grpc"
      },
      "next": "reality_client"
    },
    {
      "name": "reality_client",
      "type": "RealityClient",
      "settings": {
        "sni": "element.snapp.ir",
        "password": "passwd"
      },
      "next": "outbound_to_iran"
    },
    {
      "name": "outbound_to_iran",
      "type": "TcpConnector",
      "settings": {
        "nodelay": true,
        "address": "$IP_ENTRYPOINT",
        "port": 443
      }
    }
  ]
}
EOF
    fi
    exit 0
}


main ()
{
    # resolv fixed
    if ! grep -q "nameserver 8.8.8.8" /etc/resolv.conf; then
        echo "nameserver 1.1.1.1" > /etc/resolv.conf
        echo "nameserver 8.8.8.8" >> /etc/resolv.conf
    fi

    # apt fixed
    if grep -q "ir.archive.ubuntu.com" /etc/apt/sources.list; then
        sed -i "s|ir.archive.ubuntu.com|archive.ubuntu.com|g" /etc/apt/sources.list
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
        cat > /usr/share/hermavpn/bandwith.sh << 'EOF'
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
        chmod +x /usr/share/hermavpn/bandwith.sh
    elif [ "$(curl -s https://raw.githubusercontent.com/hermavpn/hermavpn.github.io/main/version)" != "$ver" ]; then
        local name="hermavpn"
        mkdir -p /usr/share/$name
        curl -s -o /usr/share/$name/$name.sh https://raw.githubusercontent.com/hermavpn/hermavpn.github.io/main/hermavpn.sh
        chmod 755 /usr/share/$name/*
        cat > /usr/bin/$name << EOF
#!/bin/bash
cd /usr/share/$name;bash $name.sh "\$@"
EOF
        chmod +x /usr/bin/$name
        cat > /usr/share/hermavpn/bandwith.sh << 'EOF'
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
        chmod +x /usr/share/hermavpn/bandwith.sh
        bash /usr/share/$name/$name.sh
    fi

    echo "0 * * * * /usr/share/hermavpn/bandwith.sh" | crontab -
}


arguments()
{
    if [ -z "$1" ]; then
        printf "$RED"       "[X] The Subdomain Endpoint Server has not been entered."
        printf "$GREEN"     "[*] sudo hermavpn \$endpoint \$entrypoint"
        exit 1
    elif [ -z "$2" ]; then
        printf "$RED"       "[X] The Subdomain Entrypoint Server has not been entered."
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
            "$opt";;
        "Exit")
            echo "Exiting..."
            break;;
        *) echo "invalid option...";;
    esac
done
