output "ec2_key_name" {
  value = data.aws_key_pair.servers_key.key_name
}

output "ec2_key_id" {
  value = data.aws_key_pair.servers_key.id
}

output "ec2_key_fingerprint" {
  value = data.aws_key_pair.servers_key.fingerprint
}

output "k0s_master_server_public_ip" {
  value = module.ec2_instance_k0s_master.public_ip
}

