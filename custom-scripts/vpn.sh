#!/bin/zsh

# Function to display script usage
display_usage() {
	echo "Usage: vpn [options]"
	echo "Options:"
	echo "  help	Display this help message"
	echo "  c	Connect to IIMJobs & Hirist VPNs"
	echo "  d	Diconnect from IIMJobs & Hirist VPNs"
	echo "  h	Connect to Hirist VPN"
	echo "  i	Connect to IIMJobs VPN"
	echo "  g	Connect to Global VPN"
	echo "  r	Refresh VPN connections"
	# Add other options and their descriptions here
}

if [ $# -eq 0 ]; then
	echo "Missing option"
	display_usage
	exit 1
elif [ $# -gt 1 ]; then
	echo "Extra options not acceptable"
	display_usage
	exit 1
fi

option=$1

# Function to connect to IIMJobs & Hirist VPNs
connect() {
	# Connect
	echo "-----------------------------------------------------------------------------"

	echo "Connecting to Hirist VPN...\n"
	openvpn3 session-start --config-path /net/openvpn/v3/configuration/80930f3exc44ax4876xbf1ax8bc0946f78c6
	if [ $? -gt 0 ]; then
		openvpn3 session-start --config-path /net/openvpn/v3/configuration/80930f3exc44ax4876xbf1ax8bc0946f78c6
	fi

	echo "\nConnecting to Global VPN...\n"
	openvpn3 session-start --config-path /net/openvpn/v3/configuration/d9e58a57x9d41x450axb72cxa403467e9c6a

	echo "\nConnecting to IIMJobs VPN...\n"
	oathtool -b --totp MLYYSJBLOTTDSXD6 | xclip -selection clipboard && openvpn3 session-start --config-path /net/openvpn/v3/configuration/0fb59471x4cd3x427exb27bxdd6f19587353
	echo "Connected\n"

	echo "-----------------------------------------------------------------------------"
}

# Function to disconnect from IIMJobs & Hirist VPNs
disconnect() {
	# Disconnect
	session_paths=($(openvpn3 sessions-list | grep -i 'path' | awk '{print $2}'))
	config_names=($(openvpn3 sessions-list | grep -i 'config name' | awk '{print $3}'))
	number_of_sessions=${#session_paths[@]}
	if [ "$number_of_sessions" -gt 0 ]; then
		echo "Number of sessions = $number_of_sessions"
		echo "-----------------------------------------------------------------------------"
		for ind in $(seq 1 $number_of_sessions); do
			session=${session_paths[ind]}
			config_name=${config_names[ind]}

			if echo "$config_name" | grep -q "iimjobs"; then
				echo "Disconnecting IIMJobs VPN"
			elif echo "$config_name" | grep -q "hirist"; then
				echo "Disconnecting Hirist VPN"
			elif echo "$config_name" | grep -q "global"; then
				echo "Disconnectiong Global VPN"
			fi

			openvpn3 session-manage -D --session-path $session
		done
		echo "-----------------------------------------------------------------------------"
	fi
}

case $option in
help)
	# Help
	display_usage
	exit 0
	;;
c)
	connect
	;;
d)
	disconnect
	;;
l)
	# List
	openvpn3 sessions-list
	;;
i)
	# Connect to IIMJobs VPN
	echo "\nConnecting to IIMJobs VPN...\n"
	oathtool -b --totp MLYYSJBLOTTDSXD6 | xclip -selection clipboard && openvpn3 session-start --config-path /net/openvpn/v3/configuration/0fb59471x4cd3x427exb27bxdd6f19587353
	if [ $? -gt 0 ]; then
		oathtool -b --totp MLYYSJBLOTTDSXD6 | xclip -selection clipboard && openvpn3 session-start --config-path /net/openvpn/v3/configuration/0fb59471x4cd3x427exb27bxdd6f19587353
	fi
	echo "Connected\n"
	;;
h)
	# Connect to Hirist VPN
	echo "Connecting to Hirist VPN...\n"
	openvpn3 session-start --config-path /net/openvpn/v3/configuration/80930f3exc44ax4876xbf1ax8bc0946f78c6
	if [ $? -gt 0 ]; then
		openvpn3 session-start --config-path /net/openvpn/v3/configuration/80930f3exc44ax4876xbf1ax8bc0946f78c6
	fi
	;;
g)
	# Connect to Global VPN
	echo "Connecting to Global VPN...\n"
	openvpn3 session-start --config-path /net/openvpn/v3/configuration/d9e58a57x9d41x450axb72cxa403467e9c6a
	if [ $? -gt 0 ]; then
		openvpn3 session-start --config-path /net/openvpn/v3/configuration/d9e58a57x9d41x450axb72cxa403467e9c6a
	fi
	;;
r)
	# Refresh VPN connections
	disconnect
	connect
	;;
esac
