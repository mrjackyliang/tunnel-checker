# tunnelCheck
# ============

# Settings
IP_CHECK=http://ipinfo.io/ip
PORT_FORWARD=

# Script Starts
if [ ! -x "$(command -v nmap)" ] && [ "$PORT_FORWARD" != "" ]; then
	echo "Installing nmap ..."
	apt-get -qq update
	apt-get -qq install nmap
fi

VPN_ADDR=`ip -4 addr show tun0 | grep -oP '(?<=inet\s)\d+(\.\d+){3}'`
VPN_RESP=`curl -sS --interface tun0 $IP_CHECK`

if [ "$PORT_FORWARD" != "" ]; then
  nc -z $VPN_ADDR $PORT_FORWARD
  RESULT=$?
  if [ $RESULT - eq 0 ]; then 
    VPN_PORT="open"; 
  else 
    VPN_PORT="closed"; 
  fi; 
else 
  VPN_PORT="not set"; 
fi

echo "Interface IP is "$VPN_ADDR
echo "API Query IP is "$VPN_RESP
echo "Network Port is "$VPN_PORT

if [ "$VPN_ADDR" != "$VPN_RESP" ] || [ "$VPN_PORT" = "closed" ]; then
    echo "Killing OpenVPN"
	pkill -SIGINT openvpn
else
	echo "VPN is already working!"
fi

exit 0
