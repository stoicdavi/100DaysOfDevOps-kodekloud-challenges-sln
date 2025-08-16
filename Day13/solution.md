# Apache Service Not Reachable on Port 5004 - Solution Summary

## Problem
- Monitoring tool reported Apache service unreachable on port 5004 at stapp01
- Initial symptoms: "Address already in use" error when trying to start Apache

## Root Cause Analysis
1. **Service Conflict**: Sendmail was occupying port 5004, preventing Apache from binding to it
2. **Firewall Rules**: Missing iptables rules to allow external access to port 5004

## Solution Steps

### 1. Access the Application Server
```bash
ssh tony@stapp01  # or ssh tony@172.16.238.10
```

### 2. Identify Port Conflict
```bash
sudo netstat -tlnp  # Found sendmail on port 5004
```

### 3. Resolve Service Conflict
```bash
sudo systemctl stop sendmail
sudo systemctl disable sendmail
```

### 4. Start and Verify Apache Service
```bash
sudo systemctl start httpd
sudo systemctl enable httpd
sudo systemctl status httpd
sudo netstat -tlnp | grep :5004  # Confirm Apache on port 5004
```

### 5. Configure Firewall Rules
```bash
sudo iptables -I INPUT -p tcp --dport 5004 -j ACCEPT
sudo iptables-save > /etc/sysconfig/iptables
sudo iptables -L -n | grep 5004  # Verify rules
```

### 6. Test Connectivity
```bash
# Local test
curl http://localhost:5004

# Remote test from jump host
curl http://stapp01:5004
```

## Key Lessons
- Always check for port conflicts using `netstat -tlnp`
- Don't forget firewall rules for external connectivity
- Test both locally and remotely to confirm full functionality
