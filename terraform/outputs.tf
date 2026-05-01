output "vpc_id" {
  description = "ID of the demo VPC created by Terraform."
  value       = aws_vpc.ansible_demo.id
}

output "public_subnet_id" {
  description = "ID of the demo public subnet used for VM placement."
  value       = aws_subnet.public.id
}

output "instance_profile_name" {
  description = "IAM instance profile attached to demo VMs for SSM reads."
  value       = aws_iam_instance_profile.ec2_ssm_reader.name
}

output "vm_public_ips" {
  description = "Public IPs for the two demo VMs."
  value       = [for vm in aws_instance.vm : vm.public_ip]
}

output "ssh_commands" {
  description = "SSH commands for connecting to each demo VM."
  value = [
    for vm in aws_instance.vm :
    "ssh -i '${var.ssh_private_key_path}' ${var.ssh_user}@${vm.public_ip}"
  ]
}

output "vm_private_ips" {
  description = "Private IPs for the two demo VMs."
  value       = [for vm in aws_instance.vm : vm.private_ip]
}

output "ansible_hosts" {
  description = "Host metadata shaped for dynamic inventory-style consumption."
  value = [
    for idx, vm in aws_instance.vm : {
      name         = "vm-${idx + 1}"
      ansible_host = vm.public_ip
      ansible_user = var.ssh_user
      role         = "java-target"
    }
  ]
}

output "ansible_inventory_lines" {
  description = "Inventory lines with user/key to copy into ansible/inventory.ini."
  value = concat(
    ["[java_targets]"],
    [
      for idx, vm in aws_instance.vm :
      "vm${idx + 1} ansible_host=${vm.public_ip} ansible_user=${var.ssh_user} ansible_ssh_private_key_file=${var.ssh_private_key_path}"
    ]
  )
}
