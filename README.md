# Azure PaloAlto Automation Lab

Azure lab configuration used for automatic deployment of PaloAlto virtual firewall appliances in HA mode into the Azure VNet. Automation process uses mix of bash scripting and Azure ARM templates. Each pair (one interface from each node) of PA interfaces is put into separate transit subnet and the actual host deployment subnets are attached to those transit subnets by appropriate configuration of subnet routing tables. Each host subnet has deployed virtual machine in it. Those are being used to test connectivity over the PA firewalls. One virtual machine is also deployed directly into WAN transit subnet to test connectivity from on-prem to the LAB before the traffic hits PAs. All virtual hosts after deployment are reconfigured by Ansible to add lab users and install diagnostic tools like Nmap or IPerf. PaloAlto firewall initial configuration at this point is loaded manually but in future this will be done by PaloAlto Bootstrap process.

### Lab diagram
![AWS lab diagram](https://github.com/ccie18643/Azure-PaloAlto-Automation-Lab/blob/master/pictures/diag01.png)


