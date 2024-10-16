#!/bin/bash

# Change to the directory of the script
cd "$(dirname "$0")"

# Check if warp is installed
if [ ! -f "warp" ]; then
    echo "Downloading warp..."
    wget -O "warp" "https://raw.githubusercontent.com/Json-Script/IPTest/refs/heads/main/Need/pre/warp"
    if [ $? -ne 0 ]; then
        echo "Failed to download warp"
        read -p "Press any key to exit..." -n1 -s
        exit 1
    fi
    chmod +x warp
fi

echo ":::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::"
echo "::                                                                 ::"
echo "::                Welcome to the Termux WARP Startup               ::"
echo "::                This program is provided for scan Warp IP        ::"
echo "::                github.com/Json-Script                           ::"
echo "::                                                                 ::"
echo ":::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::"
echo ""

# Main menu
while true; do
    echo "1. Preferred IPV4"
    echo "2. Preferred IPV6"
    echo "0. Exit"
    read -p "Please select an option (default 1): " menu
    menu=${menu:-1}

    case $menu in
        0) exit ;;
        1)
            title="CF Preferred WARP IP"
            ipv4=("162.159.192.0/24" "162.159.193.0/24" "162.159.195.0/24" "188.114.96.0/24" "188.114.97.0/24" "188.114.98.0/24" "188.114.99.0/24")
            getv4
            ;;
        2)
            title="CF Preferred WARP IP"
            ipv6=("2606:4700:d0::/48" "2606:4700:d1::/48")
            getv6
            ;;
        *) echo "Invalid option, please try again." ;;
    esac
done

getv4() {
    local n=0
    while true; do
        for ip in "${ipv4[@]}"; do
            random_ip[$RANDOM%100]="$ip"
        done
        for ip in "${random_ip[@]}"; do
            if [ -z "${anycastip[$ip]}" ]; then
                anycastip[$ip]="anycastip"
                ((n++))
            fi
            if [ "$n" -eq 100 ]; then
                getip
                break
            fi
        done
    done
}

getv6() {
    local n=0
    while true; do
        for ip in "${ipv6[@]}"; do
            random_ip[$RANDOM%100]="$ip"
        done
        for ip in "${random_ip[@]}"; do
            if [ -z "${anycastip[$ip]}" ]; then
                anycastip[$ip]="anycastip"
                ((n++))
            fi
            if [ "$n" -eq 100 ]; then
                getip
                break
            fi
        done
    done
}

getip() {
    rm -f ip.txt
    for ip in "${!anycastip[@]}"; do
        echo "$ip" >> ip.txt
    done
    ./warp
    while IFS=',' read -r endpoint loss delay; do
        echo "Best IP:Port $endpoint"
        echo "Packet loss $loss Average delay $delay"
        break
    done < <(tail -n +2 result.csv)
    rm -f ip.txt
    read -p "Press any key to exit..." -n1 -s
    exit
}