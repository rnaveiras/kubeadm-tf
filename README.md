# PoC terraform + kubeadm

## Getting Started

```
$ terraform plan -var stage=staging -var key_name=<key-name> -var k8s_token=<kubeadm token>

$ terraform apply -var stage=staging -var key_name=<key-name> -var k8s_token=<kubeadm token>
```
