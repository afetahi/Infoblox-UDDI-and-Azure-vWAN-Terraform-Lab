#cloud-config
runcmd:
  - echo "---------------------------------------------------"
  - echo " Infoblox NIOS-X bootstrap starting..."
  - echo "---------------------------------------------------"
  - |
    if [ -n "${join_token}" ]; then
      echo "Join token detected, saving to /var/tmp/join_token.txt"
      printf "%s" "${join_token}" > /var/tmp/join_token.txt
      chmod 600 /var/tmp/join_token.txt
    else
      echo "No join token provided. Register NIOS-X manually."
    fi
  - sysctl -w net.ipv4.ip_forward=1
  - sed -i 's/^#\?net.ipv4.ip_forward=.*/net.ipv4.ip_forward=1/' /etc/sysctl.conf
  - echo "---------------------------------------------------"
  - echo " Next steps (manual): enable DNS, configure Anycast 10.100.100.10/32, set BGP peers."
  - echo "---------------------------------------------------"
