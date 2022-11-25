# Azure PaloAlto Automation Lab

### Simple Azure lab
<br>

Azure lab configuration used for automatic deployment of Palo Alto virtual firewall appliances in HA mode into the Azure VNet. The automation process uses a mix of bash scripting and Azure ARM templates. Each pair (one interface from each node) of PA interfaces is put into a separate transit subnet. The actual host deployment subnets are attached to those transit subnets by the appropriate configuration of subnet routing tables. Each host subnet has deployed a virtual machine in it. Those are being used to test connectivity over the PA firewalls. One virtual machine is also deployed directly into the WAN transit subnet to test connectivity from on-prem to the LAB before the traffic hits PAs. Ansible reconfigures all virtual hosts after deployment to add lab users and install diagnostic tools like Nmap or IPerf. PaloAlto firewall initial configuration is loaded manually, but in the future, this will be done by the PaloAlto Bootstrap process.

### Lab diagram
![Azure lab diagram](https://github.com/ccie18643/Azure-PaloAlto-Automation-Lab/blob/main/pictures/diag01.jpg)


