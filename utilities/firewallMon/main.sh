#!/bin/bash
chmod +x /utilities/firewallMon/firewall.sh
chmod +x /utilities/firewallMon/iptableslog.sh

/utilities/firewallMon/firewall.sh &
/utilities/firewallMon/iptableslog.sh &

echo "Tareas de monitoreo inicializadas"