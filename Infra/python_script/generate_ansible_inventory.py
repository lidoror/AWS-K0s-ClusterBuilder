# opening the terraform local file that generate the inventory data
import json

with open('infra/terraform/jenkins_cluster/instances_ip', 'r') as read_terraform_inventory:
    terraform_inventory = json.loads(read_terraform_inventory.read())

# creating two vars that represent the nodes type in the inventory
master_node = terraform_inventory.get('k0s_master')

worker_node = terraform_inventory.get('nodes')

master_list: list = []
node_list: list = []

if type(master_node) == list:
    for index, host in enumerate(master_node):
        master_list.append(f'\nmaster{index} ansible_host={host} ansible_user=ec2-user ansible_port=22')
else:
    master_list.append(f'\nmaster0 ansible_host={master_node} ansible_user=ec2-user ansible_port=22')


if type(worker_node) == list:
    for index, node in enumerate(worker_node):
        node_list.append(f'\nnode{index} ansible_host={node} ansible_user=ec2-user ansible_port=22')
else:
    node_list.append(f'\nnode0 ansible_host={worker_node} ansible_user=ec2-user ansible_port=22')


with open('infra/ansible/k0s_cluster/hosts', 'w') as hosts:
    hosts.write('[master]' + ''.join(master_list) + '\n[nodes]' + ''.join(node_list))
