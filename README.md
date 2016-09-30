# PoC terraform + kubeadm

## Getting Started

```
$ KUBEADM_TOKEN=$(go run token.go | awk -F': ' '{print $2}')

$ terraform plan -var stage=staging -var key_name=id_rsa -var k8s_token=$KUBEADM_TOKEN

$ terraform apply -var stage=staging -var key_name=id_rsa -var k8s_token=$KUBEADM_TOKEN
```
