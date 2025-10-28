#!/usr/bin/env sh

set -o errexit
set -o nounset

usage ()
{
    echo "Usage: ${0##*/} <interface_name> <interface_address> <netmask>"
    echo "Example: ${0##*/} lo:0 192.168.1.100 255.255.255.0"
    exit 1
}

# Check if all 3 parameters are provided
if [ $# -ne 3 ]; then
  usage
fi

interface_name="$1"
interface_address="$2"
netmask="$3"

echo "Setting up interface: ${interface_name}"
echo "Address: ${interface_address}"
echo "Netmask: ${netmask}"

# Show current ifconfig
echo "Current ifconfig:"
ifconfig

# Check if interface already exists
if ifconfig | grep -q "^${interface_name}"; then
  echo "Interface ${interface_name} already exists"
  
  # Get current address
  current_address=$(ifconfig "${interface_name}" 2>/dev/null | grep 'inet ' | awk '{print $2}' | head -1)
  
  if [ -n "${current_address}" ]; then
    echo "Current address: ${current_address}"
    
    if [ "${current_address}" = "${interface_address}" ]; then
      echo "Interface ${interface_name} already has the correct address ${interface_address}"
    else
      echo "Removing old address ${current_address} and setting new address ${interface_address}"
      
      # Remove old address
      ifconfig "${interface_name}" del "${current_address}" 2>/dev/null || true
      
      # Add new address with netmask
      ifconfig "${interface_name}" "${interface_address}" netmask "${netmask}" 2>/dev/null || {
        echo "Failed to configure interface ${interface_name} with ifconfig, trying with ip command"
        ip addr add "${interface_address}/${netmask}" dev lo label "${interface_name}" 2>/dev/null || {
          echo "Error: Unable to configure interface ${interface_name}"
          exit 1
        }
      }
      echo "Successfully configured interface ${interface_name}"
    fi
  else
    echo "Interface ${interface_name} exists but has no address, configuring..."
    ifconfig "${interface_name}" "${interface_address}" netmask "${netmask}" 2>/dev/null || {
      echo "Failed to configure interface ${interface_name} with ifconfig, trying with ip command"
      ip addr add "${interface_address}/${netmask}" dev lo label "${interface_name}" 2>/dev/null || {
        echo "Error: Unable to configure interface ${interface_name}"
        exit 1
      }
    }
    echo "Successfully configured interface ${interface_name}"
  fi
else
  echo "Interface ${interface_name} does not exist, creating..."
  
  # Try ifconfig first
  ifconfig lo:0 "${interface_address}" netmask "${netmask}" 2>/dev/null || {
    echo "ifconfig failed, trying with ip command"
    ip addr add "${interface_address}/${netmask}" dev lo label "${interface_name}" 2>/dev/null || {
      echo "Error: Unable to create interface ${interface_name}"
      exit 1
    }
  }
  echo "Successfully created interface ${interface_name}"
fi

# Show final ifconfig
echo "Final ifconfig:"
ifconfig

# Keep container running
echo "Interface configured. Container will keep running..."
tail -f /dev/null