#!/bin/bash
ver='1.1'




RED='\e[1;31m%s\e[0m\n'
GREEN='\e[1;32m%s\e[0m\n'
YELLOW='\e[1;33m%s\e[0m\n'
BLUE='\e[1;34m%s\e[0m\n'
MAGENTO='\e[1;35m%s\e[0m\n'
CYAN='\e[1;36m%s\e[0m\n'
WHITE='\e[1;37m%s\e[0m\n'
SUBDOMAIN_ENTRYPOINT=$1
SUBDOMAIN_ENDPOINT=$2




if [ "$(id -u)" != "0" ];then
    printf "$RED"		"[X] Please run as ROOT..."
    printf "$GREEN"     "[*] sudo hermavpn \$Endpoint \$Entrypoint"
    exit 0
else
    # update & upgrade & dist-upgrade
    apt update;apt upgrade -qqy;apt dist-upgrade -qqy;apt autoremove -qqy;apt autoclean

    # init requirements
    apt install -qqy wget curl git net-tools gnupg apt-transport-https mlocate nload htop speedtest-cli fail2ban cron iftop zip tcptrack certbot ssh nano dnsutils 
    OS=`uname -m`
    USERS=$(users | awk '{print $1}')
    LAN=$(ifconfig | sed -En 's/127.0.0.1//;s/.*inet (addr:)?(([0-9]*\.){3}[0-9]*).*/\2/p')
    DOM_ONE=$(echo $SUBDOMAIN_ENDPOINT | awk -F. '{print $2}')
    DOM_TWO=$(echo $SUBDOMAIN_ENDPOINT | awk -F. '{print $3}')
    DOMAIN=$(echo "$DOM_ONE.$DOM_TWO")
    IP_SUBDOMAIN_ENDPOINT=$(dig -4 +short $SUBDOMAIN_ENDPOINT)
    IP_SUBDOMAIN_ENTRYPOINT=$(dig -4 +short $SUBDOMAIN_ENTRYPOINT)
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


entrypoint ()
{
    # Initialize hostname
    if ! grep -q "entrypoint" /etc/hostname; then
        echo "entrypoint" > /etc/hostname
    fi

    # install waterwall
    if [ ! -d "/usr/share/waterwall" ]; then
        local name="waterwall"
        wget https://github.com/radkesvat/WaterWall/releases/latest/download/Waterwall-linux-64.zip -O /tmp/$name.zip
        unzip /tmp/$name.zip -d /usr/share/$name;rm -f /tmp/$name.zip
        chmod 755 /usr/share/$name/*
        ln -fs /usr/share/$name/Waterwall /usr/bin/$name
        chmod +x /usr/bin/$name
        cat > /etc/$name.local << EOF
#!/bin/bash
cd /usr/share/$name;nohup ./Waterwall &
exit 0
EOF
        chmod +x /etc/$name.local
        cat > /usr/lib/systemd/system/$name.service << EOF
[Unit]
Description=WaterWall Tunneling
After=network.target
After=syslog.target
After=nss-lookup.target

[Install]
WantedBy=multi-user.target
Alias=$name.target

[Service]
Type=forking
ExecStart=/etc/$name.local
ExecStop=pkill $name
Restart=on-failure
RestartSec=10
RemainAfterExit=yes
EOF
        systemctl daemon-reload
        systemctl enable $name;systemctl start $name
        printf "$GREEN"  "[*] Success installing $name"
    fi

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
    "configs": [
        "config.json"
    ]
}
EOF
    fi

    if [ ! -f "/usr/share/waterwall/config.json" ]; then
        cat > /usr/share/waterwall/config.json << EOF
{
    "name": "config_reverse_tls_grpc_multiport_hd_iran",
    "nodes": [
        {
            "name": "inbound_users",
            "type": "TcpListener",
            "settings": {
                "address": "0.0.0.0",
                "port": [23,65535],
                "nodelay": true
            },
            "next": "port_header"
        },
        {
            "name": "port_header",
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
            "name": "halfs",
            "type": "HalfDuplexServer",
            "settings": {},
            "next": "reverse_server"
        },
        {
            "name": "grpc_server",
            "type": "ProtoBufServer",
            "settings": {},
            "next": "halfs"
        },
        {
            "name": "h2server",
            "type": "Http2Server",
            "settings": {},
            "next": "grpc_server"
        },
        {
            "name": "sslserver",
            "type": "OpenSSLServer",
            "settings": {
                "cert-file": "/usr/share/hermavpn/fullchain.pem",
                "key-file": "/usr/share/hermavpn/privkey.pem",
                "alpns": [
                    {
                        "value": "h2",
                        "next": "node->next"
                    },
                    {
                        "value": "http/1.1",
                        "next": "node->next"
                    }
                ],
                "fallbackintencedelay": 0
            },
            "next": "h2server"
        },
        {
            "name": "inbound_cloudflare",
            "type": "TcpListener",
            "settings": {
                "address": "0.0.0.0",
                "port": 443,
                "nodelay": true,
                "whitelist": [
                    "173.245.48.0/20",
                    "103.21.244.0/22",
                    "103.22.200.0/22",
                    "103.31.4.0/22",
                    "141.101.64.0/18",
                    "108.162.192.0/18",
                    "190.93.240.0/20",
                    "188.114.96.0/20",
                    "197.234.240.0/22",
                    "198.41.128.0/17",
                    "162.158.0.0/15",
                    "104.16.0.0/13",
                    "104.24.0.0/14",
                    "172.64.0.0/13",
                    "131.0.72.0/22",
                    "2400:cb00::/32",
                    "2606:4700::/32",
                    "2803:f800::/32",
                    "2405:b500::/32",
                    "2405:8100::/32",
                    "2a06:98c0::/29",
                    "2c0f:f248::/32"
                ]
            },
            "next": "sslserver"
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
    if ! grep -q "entrypoint" /etc/hostname; then
        echo "entrypoint" > /etc/hostname
    fi

    # install waterwall
    if [ ! -d "/usr/share/waterwall" ]; then
        local name="waterwall"
        wget https://github.com/radkesvat/WaterWall/releases/latest/download/Waterwall-linux-64.zip -O /tmp/$name.zip
        unzip /tmp/$name.zip -d /usr/share/$name;rm -f /tmp/$name.zip
        chmod 755 /usr/share/$name/*
        ln -fs /usr/share/$name/Waterwall /usr/bin/$name
        chmod +x /usr/bin/$name
        cat > /etc/$name.local << EOF
#!/bin/bash
cd /usr/share/$name;nohup ./Waterwall &
exit 0
EOF
        chmod +x /etc/$name.local
        cat > /usr/lib/systemd/system/$name.service << EOF
[Unit]
Description=WaterWall Tunneling
After=network.target
After=syslog.target
After=nss-lookup.target

[Install]
WantedBy=multi-user.target
Alias=$name.target

[Service]
Type=forking
ExecStart=/etc/$name.local
ExecStop=pkill $name
Restart=on-failure
RestartSec=10
RemainAfterExit=yes
EOF
        systemctl daemon-reload
        systemctl enable $name;systemctl start $name
        printf "$GREEN"  "[*] Success installing $name"
    fi

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
    "configs": [
        "config.json"
    ]
}
EOF
    fi

    if [ ! -f "/usr/share/waterwall/config.json" ]; then
        cat > /usr/share/waterwall/config.json << EOF
{
    "name": "config_reverse_tls_grpc_multiport_hd_kharej",
    "nodes": [
        {
            "name": "core_outbound",
            "type": "TcpConnector",
            "settings": {
                "nodelay": true,
                "address": "127.0.0.1",
                "port": 443
            }
        },
        {
            "name": "port_header",
            "type": "HeaderServer",
            "settings": {
                "override": "dest_context->port"
            },
            "next": "core_outbound"
        },
        {
            "name": "bridge1",
            "type": "Bridge",
            "settings": {
                "pair": "bridge2"
            },
            "next": "port_header"
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
            },
            "next": "halfc"
        },
        {
            "name": "halfc",
            "type": "HalfDuplexClient",
            "settings": {},
            "next": "grpc_client"
        },
        {
            "name": "grpc_client",
            "type": "ProtoBufClient",
            "settings": {},
            "next": "h2client"
        },
        {
            "name": "h2client",
            "type": "Http2Client",
            "settings": {
                "host": "cdn.$DOMAIN",
                "port": 443,
                "path": "/service",
                "content-type": "application/grpc"
            },
            "next": "sslclient"
        },
        {
            "name": "sslclient",
            "type": "OpenSSLClient",
            "settings": {
                "sni": "cdn.$DOMAIN",
                "verify": true,
                "alpn": "h2"
            },
            "next": "iran_outbound"
        },
        {
            "name": "iran_outbound",
            "type": "TcpConnector",
            "settings": {
                "nodelay": true,
                "address": "cdn.$DOMAIN",
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
    # Set Time Zone
    timedatectl set-timezone Asia/Tehran

    # resolv fixed
    if ! grep -q "nameserver 8.8.8.8" /etc/resolv.conf; then
        echo "nameserver 1.1.1.1" > /etc/resolv.conf
        echo "nameserver 8.8.8.8" >> /etc/resolv.conf
    fi

    # apt fixed
    if grep -q "ir.archive.ubuntu.com" /etc/apt/sources.list; then
        sed -i "s|ir.archive.ubuntu.com|archive.ubuntu.com|g" /etc/apt/sources.list
    fi

    # Initialize SSH root Login
    if ! grep -q "prohibit-password" /etc/ssh/sshd_config; then
        sed -i "s|#PermitRootLogin prohibit-password|PermitRootLogin yes|g" /etc/ssh/sshd_config
        service ssh restart;service sshd restart
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
        systemctl enable fail2ban;systemctl start fail2ban
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
        cat > /usr/share/hermavpn/bandwith.sh << EOF
#!/bin/bash

# Define the minimum acceptable bandwidth in Mbps
MIN_BANDWIDTH=10

# Run the speed test and parse the download speed
DOWNLOAD_SPEED=\$(speedtest-cli --simple | grep 'Download' | awk '{print \$2}')

# Check if the download speed is less than the minimum bandwidth
if (( \$(echo "\$DOWNLOAD_SPEED < \$MIN_BANDWIDTH" | bc -l) )); then
    sudo reboot
fi
EOF
        chmod +x /usr/share/hermavpn/bandwith.sh
        echo "0 * * * * /usr/share/hermavpn/bandwith.sh" | crontab -
    elif [ "$(curl -s https://raw.githubusercontent.com/hermavpn/hermavpn.github.io/main/version)" != $ver ]; then
        local name="hermavpn"
        mkdir -p /usr/share/$name
        curl -s -o /usr/share/$name/$name.sh https://raw.githubusercontent.com/hermavpn/hermavpn.github.io/main/hermavpn.sh
        chmod 755 /usr/share/$name/*
        cat > /usr/bin/$name << EOF
#!/bin/bash
cd /usr/share/$name;bash $name.sh "\$@"
EOF
        chmod +x /usr/bin/$name
        cat > /usr/share/hermavpn/bandwith.sh << EOF
#!/bin/bash

# Define the minimum acceptable bandwidth in Mbps
MIN_BANDWIDTH=10

# Run the speed test and parse the download speed
DOWNLOAD_SPEED=\$(speedtest-cli --simple | grep 'Download' | awk '{print \$2}')

# Check if the download speed is less than the minimum bandwidth
if (( \$(echo "\$DOWNLOAD_SPEED < \$MIN_BANDWIDTH" | bc -l) )); then
    sudo reboot
fi
EOF
        chmod +x /usr/share/hermavpn/bandwith.sh
        echo "0 * * * * /usr/share/hermavpn/bandwith.sh" | tab -
        bash /usr/share/$name/$name.sh
    fi
}


main
logo


select opt in "Endpoint" "Entrypoint" Exit
do
    case $opt in
        "Endpoint")
            if [ -z "$1" ]; then
                printf "$RED"       "[X] The second argument has not Subdomain Endpoint Server entered."
                printf "$GREEN"     "[*] sudo hermavpn \$Endpoint \$Entrypoint"
                exit 0
            elif [ -z "$2" ]; then
                printf "$RED"       "[X] The second argument has not Subdomain Entrypoint Server entered."
                printf "$GREEN"     "[*] sudo hermavpn \$Endpoint \$Entrypoint"
                exit 0
            fi
            printf "$GREEN"  "[*] Running Endpoint Tunnel..."
            endpoint;;
        "Entrypoint")
            if [ -z "$1" ]; then
                printf "$RED"       "[X] The second argument has not Subdomain Endpoint Server entered."
                printf "$GREEN"     "[*] sudo hermavpn \$Endpoint \$Entrypoint"
                exit 0
            elif [ -z "$2" ]; then
                printf "$RED"       "[X] The second argument has not Subdomain Entrypoint Server entered."
                printf "$GREEN"     "[*] sudo hermavpn \$Endpoint \$Entrypoint"
                exit 0
            fi
            printf "$GREEN"  "[*] Running Entrypoint Tunnel..."
            entrypoint;;
        "Exit")
            echo "Exiting..."
            break;;
        *) echo "invalid option...";;
    esac
done
