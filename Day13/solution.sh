# This solution takes you through installation and configuration of iptables
# It blocks all traffic to the Apache server except from the Load Balancer
#!/bin/bash

# Define the IP address of the LBR (Load Balancer Host)
LBR_IP_ADDRESS="172.16.238.12"
APACHE_PORT="8086"

# Check if the script is running with root privileges
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root. Use 'sudo'."
   exit 1
fi

# Step 1: Install iptables and iptables-services
echo "Installing iptables and iptables-services..."
dnf install -y iptables iptables-services

# Check if the installation was successful
if [[ $? -ne 0 ]]; then
    echo "Error: Failed to install iptables packages. Exiting."
    exit 1
fi

# Step 2: Set firewall rules

# First, remove any existing rules for the specified port to prevent duplicates
echo "Clearing existing rules for port ${APACHE_PORT}..."
iptables -F INPUT

# Add the rule to ACCEPT traffic from the LBR
echo "Adding rule to allow traffic from LBR (${LBR_IP_ADDRESS}) on port ${APACHE_PORT}..."
iptables -A INPUT -p tcp --dport ${APACHE_PORT} -s ${LBR_IP_ADDRESS} -j ACCEPT

# Add the rule to DROP all other traffic to the port
echo "Adding rule to drop all other traffic on port ${APACHE_PORT}..."
iptables -A INPUT -p tcp --dport ${APACHE_PORT} -j DROP

# Step 3: Make rules persistent and enable the service

# Save the current rules to the configuration file
echo "Saving current iptables rules..."
service iptables save

# Enable the iptables service to start on boot
echo "Enabling the iptables service to make rules persistent..."
systemctl enable iptables

echo "Firewall configuration complete."
echo "Iptables rules have been set and saved to be persistent across reboots."