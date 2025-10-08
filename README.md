# Anycast DNS with Infoblox NIOS-X and Azure Virtual WAN

This Terraform project automates the deployment of a multi-region Anycast DNS architecture using Infoblox NIOS-X appliances integrated with Azure Virtual WAN.  
It mirrors the reference lab and blog post demonstrating how to build a resilient, scalable DNS fabric with BGP Anycast across multiple Azure regions.

## Overview

The deployment builds the following environment:

- One Azure Virtual WAN  
- Two Virtual WAN hubs (Germany West Central and France Central)  
- Shared Services VNets in each region (hosting NIOS-X appliances)  
- Spoke VNets in each region connected through the hubs  
- Custom route tables for spoke VNets to separate hub vs spoke routing  
- BGP peering between NIOS-X appliances and the virtual hub router  
- Optional NIOS-X VM deployment using Azure Marketplace image

The result is a fully functional Anycast DNS topology using the Anycast IP `10.100.100.10/32`, advertised from NIOS-X appliances in both regions over BGP to Azure Virtual WAN hubs.  
All spokes resolve DNS through the Anycast IP, achieving cross-region resiliency and low latency.

## Architecture

![Architecture](./NIOS-X_and_Azure_vWAN_Anycast.jpeg)

| Region                 | Hub CIDR      | NIOS-X ASN | NIOS-X IPs            | Anycast Prefix      |
|------------------------|--------------|-----------|------------------------|---------------------|
| Germany West Central   | 10.110.0.0/22 | 64581 / 64582 | 10.104.0.4 / 10.104.1.4 | 10.100.100.10/32 |
| France Central         | 10.110.4.0/22 | 64583 / 64584 | 10.108.0.4 / 10.108.1.4 | 10.100.100.10/32 |

## Repository Structure
terraform/
├── main.tf
├── providers.tf
├── variables.tf
├── outputs.tf
├── versions.tf
├── terraform.tfvars # Edit this with your values
├── README.md
└── modules/
├── vwan/
├── vnet/
├── hub-connections/
├── hub-bgp/
└── niosx-vm/

## Prerequisites

- Terraform v1.5 or later  
- Azure CLI authenticated (`az login`)  
- Contributor permissions on the target subscription  
- Optional: Infoblox NIOS-X image available in your Azure Marketplace subscriptions

## Variables

The key variables are defined in `terraform.tfvars`:

```hcl
subscription_id = "<your-subscription-id>"

# Virtual WAN and Hubs
vwan_name          = "vwan_gwc_01"
region1            = "Germany West Central"
region2            = "France Central"
hub1_cidr          = "10.110.0.0/22"
hub2_cidr          = "10.110.4.0/22"

# Anycast & BGP
anycast_ip         = "10.100.100.10/32"
niosx_peers = [
  {
    region   = "Germany West Central"
    peer_ip  = "10.104.0.4"
    peer_asn = 64581
  },
  {
    region   = "Germany West Central"
    peer_ip  = "10.104.1.4"
    peer_asn = 64582
  },
  {
    region   = "France Central"
    peer_ip  = "10.108.0.4"
    peer_asn = 64583
  },
  {
    region   = "France Central"
    peer_ip  = "10.108.1.4"
    peer_asn = 64584
  }
]
```hcl

# Optional NIOS-X VM Deployment
```hcl
deploy_niosx_vms   = false
ssh_public_key     = "~/.ssh/id_rsa.pub"
```hcl

Deployment

```hcl
cd terraform
terraform init
terraform plan
terraform apply
```hcl

Terraform will deploy the entire topology end-to-end, including VNets, hubs, connections, route tables, and BGP peering.

Validation

After the deployment completes, validate that:

The Anycast prefix 10.100.100.10/32 appears in Effective Routes of both hubs and spokes
BGP peering is established under Virtual Hub → BGP Peers
Ping and DNS resolution via Anycast from spoke VMs work successfully

Example test from a spoke VM:

```hcl
ping 10.100.100.10
dig @10.100.100.10 infoblox.com +short
```hcl

Cleanup

To destroy the environment:
```hcl
terraform destroy
```hcl

References

Infoblox Universal DDI Documentation: https://docs.infoblox.com/
Azure Virtual WAN BGP Peering : https://learn.microsoft.com/en-us/azure/virtual-wan/scenario-bgp-peering-hub?utm_source=chatgpt.com
Anycast DNS on Azure Blog: (link to your blog post once published)
