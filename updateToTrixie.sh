#!/bin/bash
# Script to upgrade Debian 12 (bookworm) to Debian 13 (trixie)

set -e

echo "Starting upgrade from Debian 12 (bookworm) to Debian 13 (trixie)"

# Ensure running as root
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root." 
   exit 1
fi

# Step 1: Update & upgrade current system
echo "Updating and upgrading current system..."
apt update && apt upgrade -y

# Step 2: Replace sources.list entries
echo "Updating /etc/apt/sources.list to use 'trixie'..."

cp /etc/apt/sources.list /etc/apt/sources.list.bak

sed -i 's/bookworm/trixie/g' /etc/apt/sources.list

# Step 3: Update any bookworm references in sources.list.d/
echo "Updating sources.list.d/ entries..."
if [ -d /etc/apt/sources.list.d ]; then
  find /etc/apt/sources.list.d -type f -exec sed -i 's/bookworm/trixie/g' {} +
fi

# Step 4: Update & upgrade to trixie
echo "Updating package lists for trixie..."
apt update

echo "Performing full upgrade to Debian 13 (trixie)..."
apt upgrade -y
apt dist-upgrade -y

# Step 5: Optionally, remove obsolete packages
echo "Removing obsolete packages..."
apt autoremove -y

echo "Debian upgrade to trixie complete!"
echo "It is recommended to reboot your system now."

# End of script
