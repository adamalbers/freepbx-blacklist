#!/bin/bash

# Get currented blacklisted IPs.
currentBlacklist=$(/usr/sbin/fwconsole firewall list blacklist | /bin/grep -oE '((25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)')

# Clear current blacklist.
/usr/sbin/fwconsole firewall del blacklist $currentBlacklist

# Get IPs bashing against server
# Search for IPs that had "wrong password" more than 30 times.
ipToBan=$(/bin/grep -oE '(failed for).*(Wrong password)' /var/log/asterisk/full | /bin/grep -oE '((25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?):' | /bin/grep -oE '((25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)' | /bin/sort -n | /usr/bin/uniq -c | /bin/awk '$1 > 30 {print;}' | /bin/grep -oE '((25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)')

# Now add the IPs that "failed to authenticate" more than 30 times.
ipToBan="$ipToBan $(/bin/grep -oE '((25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?).*(failed to authenticate)' /var/log/asterisk/full | /bin/sort -n | /usr/bin/uniq -c | /bin/awk '$1 > 30 {print;}' | /bin/grep -oE '((25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)')"

# Blacklist IPs.
/usr/sbin/fwconsole firewall add blacklist $ipToBan

exit 0
