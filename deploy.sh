#! /bin/bash

echo
echo "Azure PaloAlto virtual appliance deployment script - 2020 Sebastian Majewski"
echo

while getopts ":l:s:r:" opt; do
    case ${opt} in
    l  ) location=${OPTARG};;
    s  ) subscritpion=${OPTARG};;
    r  ) resource="${OPTARG}" ;;
    \? ) echo 'Usage: deploy [-l location] [-s subscription] [-r resource "net|er|vpn|vm|pa"] site_id'; echo; exit ;;
    esac
done

shift $((${OPTIND} - 1))

site_id="${1:?Missing site_id argument. Usage: deploy [-l location] [-s subscription] [-r resource "net|er|vpn|vm|pa"] site_id}"
site_id=$(echo ${site_id} | tr '/a-z/' '/A-Z/') 
location="${location}"
resource="${resource:-'net|er|vpn|vm|pa'}"

case ${site_id} in
    "LAB1" ) subscription="${subscription:-7f111700-7327-4105-81a6-05e4c7249ffc}";
             er_auth_key="140cc318-b16f-4449-b845-e92def0feea9";
             network_id="1";
             location="${location:-eastus2}" ;;
esac



tag1="Department=IT"
tag2="Project=${site_id} Azure / PaloAlto test project"
tag3="Project Manager=Sebastian Majewski"
output="table"

vm_username="put ur username here"
vm_rsa_key="put ur RSA public key here" 

pa_username="herman"
pa_password="Welcome123"

er_circuit_id="/subscriptions/xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx/resourceGroups/rg_vnet_core_eastus2/providers/Microsoft.Network/expressRouteCircuits/ER_Sprint_EastUS2"

echo "Subscription: $(az account show --subscription ${subscription} | grep name | head -1 | cut -d\" -f4)"
echo "Location:  ${location}"
echo "Site id:  ${site_id}"
echo "Network:  10.${network_id}.0.0/16"
echo "Resource(s): ${resource}"
echo
read -n 1 -s -r -p "Press any key to continue or press CTRL-C to exit..."
echo

echo -e "Setting subscription...\n"
az account set --subscription ${subscription}
echo -e "\n"


function create_resource_group
{
    resource_group="RG_${site_id}_${1}"
    echo -e "Creating resource group RG_${site_id}_${1}...\n"
    az group create --name ${resource_group} \
                    --location ${location} \
                    --tags "${tag1}" "${TAG2}" "${TAG3}" \
                    --output ${output}
    echo -e "\n\n"
}


function deploy_network_template
{
    echo -e "Deploying template ${1}.json to resource group ${resource_group}...\n"
    az deployment group create --resource-group "${resource_group}" \
                               --template-file ${1}.json \
                               --parameters "site_id=${site_id}" "network_id=${network_id}" \
                                            "er_circuit_id=${2}" "er_auth_key=${3}" \
                               --output ${output}
    echo -e "\n\n"
}


function deploy_vm_template
{
    echo -e "Deploying template ${1}.json [ ${2} / ${3} / ${4} ] to resource group ${resource_group}...\n"
    az deployment group create --resource-group "${resource_group}" \
                               --template-file ${1}.json \
                               --parameters "site_id=${site_id}" "network_id=${network_id}" \
                                            "username=${vm_username}" "rsa_key=${vm_rsa_key}" \
                                            "vm_name=${2}" "subnet_name=${3}" "ip_address=${4}" \
                               --output ${output}
    echo -e "\n\n"
}


function deploy_paloalto_template
{
    echo -e "Deploying template ${1}.json to resource group ${resource_group}...\n"
    az deployment group create --resource-group "${resource_group}" \
                               --template-file ${1}.json \
                               --parameters "site_id=${site_id}" "network_id=${network_id}" \
                                            "username=${pa_username}" "password=${pa_password}" \
                               --output ${output}
    echo -e "\n\n"
}


if [[ ${resource} =~ 'net' ]]; then
    echo 'Deploying network...'
    create_resource_group NETWORK
    deploy_network_template routing
    deploy_network_template nsg
    deploy_network_template vnet
fi


if [[ ${resource} =~ 'er' ]]; then
    echo 'Deploying express-route gateway...'
    create_resource_group NETWORK
    deploy_network_template vng_er "${er_circuit_id}" "${er_auth_key}"
fi


if [[ ${resource} =~ 'vpn' ]]; then
    echo 'Deploying vpn gateway...'
    create_resource_group NETWORK
    deploy_network_template vng_vpn
fi


if [[ ${resource} =~ 'vm' ]]; then
    echo 'Deploying virtual machines...'
    create_resource_group NETVM
    deploy_vm_template vm ${site_id}NMS-000-061 NET_10_${network_id}_0_48__28 10.${network_id}.0.61
    deploy_vm_template vm ${site_id}NMS-011-254 NET_10_${network_id}_11_0__24 10.${network_id}.11.254
    deploy_vm_template vm ${site_id}NMS-032-254 NET_10_${network_id}_32_0__24 10.${network_id}.32.254
    deploy_vm_template vm ${site_id}NMS-127-254 NET_10_${network_id}_127_0__24 10.${network_id}.127.254
    deploy_vm_template vm ${site_id}NMS-128-254 NET_10_${network_id}_128_0__24 10.${network_id}.128.254
    deploy_vm_template vm ${site_id}NMS-129-254 NET_10_${network_id}_129_0__24 10.${network_id}.129.254
    deploy_vm_template vm ${site_id}NMS-130-254 NET_10_${network_id}_130_0__24 10.${network_id}.130.254
    deploy_vm_template vm ${site_id}NMS-255-254 NET_10_${network_id}_255_0__24 10.${network_id}.255.254
fi


if [[ ${resource} =~ 'pa' ]]; then
    echo 'Deploying palo alto...'
    echo 'Accepting vm image terms'
    az vm image terms accept --urn paloaltonetworks:vmseries-flex:byol:latest
    create_resource_group PALOALTO
    deploy_paloalto_template pa_1
    deploy_paloalto_template pa_2
fi



