#!/bin/bash
# Este script se puede mapear dentro del contenedor y usar como healthcheck

iptables -L | grep -q "Chain" && ip route | grep -q default