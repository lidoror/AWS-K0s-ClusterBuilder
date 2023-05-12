!#/bin/bash

terraform -chdir=infra/terraform/jenkins_cluster apply --auto-approve

python Infra/python_script/generate_ansible_inventory.py

export ANSIBLE_HOST_KEY_CHECKING=False

ansible-playbook -i infra/ansible/k0s_cluster/hosts --private-key <path-to-key.pem> infra/ansible/k0s_cluster/worker-agent.yaml

ansible-playbook -i infra/ansible/k0s_cluster/hosts --private-key <path-to-key.pem> infra/ansible/k0s_cluster/cluster-build.yaml