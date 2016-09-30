# PoC terraform + kubeadm

A small proof of concept for automate the bootstrap of a kubernetes cluster with Terraform and kubeadm

## Getting Started

```shell
# Generate the token required by kubeadm
$ KUBEADM_TOKEN=$(go run token.go)

# Check what operations are going to be run on AWS
$ terraform plan -var k8s_token=$KUBEADM_TOKEN

# Apply the terraform configuration
$ terraform apply -var k8s_token=$KUBEADM_TOKEN
```

For tear down:

```shell
$ terraform destroy -var k8s_token=$KUBEADM_TOKEN
```

After the terraform plan has been executed successful, you can `ssh` to the control plane node:

```shell
ssh $(terraform output |grep 'control_plane.public_ip' | cut -d'=' -f2) -lubuntu

```

Then inside the control plane, you can see how the rest of the nodes join the Kubernets cluster. If the command fails or is missing, don't worry, just wait a bit, probably means that the control plane is still provisioning.

```
sudo kubectl get nodes -w
```

You should see something like this, after a few minutes, where the node as join the control plane.

```
sudo kubectl get nodes
NAME            STATUS    AGE
ip-10-1-1-37    Ready     2m
ip-10-1-3-119   Ready     13s
```

After this, you can visit the http://kubernetes.io/docs/user-guide/, to learn more.

## What do you need

- [Terraform](https://www.terraform.io) v0.7 or higher
- AWS API credentials thought the `AWS_PROFILE` environment variable. [See here](https://www.terraform.io/docs/providers/aws/index.html) environment variables and shared credentials file sections
- Go 1.5 or higher

#### Mac OS, you can install all the dependencies as follow:

```
brew install terraform awscli go
```

#### GNU/Linux, you can find help to install all the dependencies in the following links:

- https://golang.org/doc/install
- https://www.terraform.io/downloads.html

## Description

This will create:

- a new VPC at AWS `eu-west-1` using with 3 public subnets, one for each availability zone.
- an instance to hold the Kubernetes control plane.
- an autoscaler group to hold the nodes (by default just 1 node).

All instances are setup with docker and kubeadm using cloud init.

## Configuration

- `key_name`: Needs the name of a SSH public/private key inside your ~/.ssh. This public key will be uploaded to AWS during the terraform execution. By default `id_rsa`
- `stage`: Name that is attached to may of the resources created at AWS. By default `staging`. You can uses this name to setup different AWS VPC
- `k8s_token`: Kubeadm token needs for the nodes to join the Kubernetes cluster. The token needs to generated ahead and provide as a seed to the control plane and nodes inside the autoscaler group.
- `nodes_num`: Number of nodes inside the AWS autoscaler group, by default 1. You can provide the number of nodes wanted. e.g. `terraform apply -var 'nodes_num="3"'`

## Notes

- Currently, is only support the `eu-west-1` because the way that aws subnets are handle. You can see more at `vpc.tf`. Support other AWS regions will be a straightforward change.

- The Kubernetes cluster is bootstrap without a specify cloud provider, even `kubeadm` allow the option, there is a open issue where the `control-manager` cannot connect to the AWS API because the container doesn't have TLS certificates. https://github.com/kubernetes/kubernetes/pull/33681

- Do not provide access to the control plane outside the AWS VPC.

## Acknowledgements

* Thanks to the authors of kubeadm and [its getting started guide](http://kubernetes.io/docs/getting-started-guides/kubeadm/)

