#!/bin/bash
ver='1.0'




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
    printf "$GREEN"     "[*] sudo hermavpn \$ENDPOINT \$ENTRYPOINT"
    exit 0
else
    # update & upgrade & dist-upgrade
    apt update;apt upgrade -qqy;apt dist-upgrade -qqy;apt autoremove -qqy;apt autoclean

    # init requirements
    apt install -qqy wget curl git net-tools gnupg apt-transport-https mlocate nload htop speedtest-cli
    OS=`uname -m`
    USERS=$(users | awk '{print $1}')
    LAN=$(ifconfig | sed -En 's/127.0.0.1//;s/.*inet (addr:)?(([0-9]*\.){3}[0-9]*).*/\2/p')
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
nohup ./$name &
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
    "name": "simple_multiport_hd_client",
    "nodes": [
        {
            "name": "input",
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
            "next": "halfc"
        },
        {
            "name": "halfc",
            "type": "HalfDuplexClient",
            "next": "output"
        },
        {
            "name": "output",
            "type": "TcpConnector",
            "settings": {
                "nodelay": true,
                "address": "$IP_SUBDOMAIN_ENDPOINT",
                "port": 8080
            }
        }
    ]
}
EOF
    fi
}

endpoint ()
{
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
nohup ./$name &
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
    "name": "simple_multiport_hd_server",
    "nodes": [
        {
            "name": "input",
            "type": "TcpListener",
            "settings": {
                "address": "0.0.0.0",
                "port": 8080,
                "nodelay": true
            },
            "next": "halfs"
        },
        {
            "name": "halfs",
            "type": "HalfDuplexServer",
            "settings": {},
            "next": "port_header"
        },
        {
            "name":"port_header",
            "type": "HeaderServer",
            "settings": {
                "override": "dest_context->port"
            },
            "next": "output"

        },

        {
            "name": "output",
            "type": "TcpConnector",
            "settings": {
                "nodelay": true,
                "address":"127.0.0.1",
                "port":"dest_context->port"
            }
        }
    ]
}
EOF
    fi
}

main ()
{
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
                printf "$GREEN"     "[*] sudo hermavpn \$ENDPOINT \$ENTRYPOINT"
                exit 0
            elif [ -z "$2" ]; then
                printf "$RED"       "[X] The second argument has not Subdomain Entrypoint Server entered."
                printf "$GREEN"     "[*] sudo hermavpn \$ENDPOINT \$ENTRYPOINT"
                exit 0
            fi
            printf "$GREEN"  "[*] Running Endpoint Tunnel..."
            endpoint;;
        "Entrypoint")
            if [ -z "$1" ]; then
                printf "$RED"       "[X] The second argument has not Subdomain Endpoint Server entered."
                printf "$GREEN"     "[*] sudo hermavpn \$ENDPOINT \$ENTRYPOINT"
                exit 0
            elif [ -z "$2" ]; then
                printf "$RED"       "[X] The second argument has not Subdomain Entrypoint Server entered."
                printf "$GREEN"     "[*] sudo hermavpn \$ENDPOINT \$ENTRYPOINT"
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
