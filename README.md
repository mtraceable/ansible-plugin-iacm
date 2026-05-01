# IaCM Ansible + Terraform Sample

This sample creates a VPC and 2 AWS VMs with Terraform, then installs Java using an Ansible playbook.

## Project layout

- `terraform/`: Infrastructure provisioning (VPC + public subnet + 2 EC2 instances + SSH security group)
- `ansible/`: Playbook to install Java and verify installation

## Why requirements were adjusted

Based on Harness IaCM + Ansible guidance, this sample includes a few necessary clarifications:

1. **Cloud target specified as AWS EC2**  
   "Create 2 VMs" was underspecified, so this sample picks AWS EC2 to make Terraform runnable.

2. **Runtime inputs added as variables**  
   AMI, SSH key pair, region, and availability zone are required inputs. Network CIDRs are configurable with defaults.

3. **SSH reachability made explicit**  
   Harness docs require delegate/container network access to hosts (typically SSH 22), so Terraform creates a security group with SSH ingress CIDR input.

4. **Dynamic-inventory-friendly outputs added**  
   Terraform outputs include host metadata (`ansible_hosts`) so IaCM dynamic inventory usage is easier.

5. **OS-aware Java install logic**  
   Playbook supports Debian and RHEL families and installs the latest available JDK package from repo channels.

## Quick start (local)

1. Copy and edit vars:
   - `cp terraform/terraform.tfvars.example terraform/terraform.tfvars`
2. Provision:
   - `cd terraform`
   - `terraform init`
   - `terraform apply`
3. Run Ansible (static inventory example):
   - `cd ../ansible`
   - `cp inventory.ini.example inventory.ini`
   - update host IPs to Terraform output values (or use `terraform output ansible_inventory_lines`)
   - `ansible-playbook -i inventory.ini install_java.yml`

SSH authentication notes:
- Set `ssh_user` in `terraform/terraform.tfvars` to match your AMI (`ec2-user` for Amazon Linux, `ubuntu` for Ubuntu).
- Ensure your inventory includes `ansible_ssh_private_key_file=/path/to/key.pem`.

## Harness alignment notes

- Keep playbook in Git (`ansible/install_java.yml`) and register it in Harness IaCM Playbooks.
- Use Terraform workspace outputs for a dynamic inventory in IaCM Inventories.
- In a pipeline, add `IACMAnsiblePlugin` with `command: run`, then select your playbook and inventory.
- Ensure the delegate network can reach targets via SSH.

## Documentation

- [Harness IaCM Ansible Overview](https://developer.harness.io/docs/infra-as-code-management/configuration-management/ansible/overview)
- [Harness IaCM Ansible Get Started](https://developer.harness.io/docs/infra-as-code-management/configuration-management/ansible/get-started/)
