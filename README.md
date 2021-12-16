# Terraform

Initialize backend

```sh
export pg_pass=""
terraform init -backend-config="conn_str=postgres://terraform:$pg_pass@pg01.vm.local/terraform"
```

Add required variables to a file ending in `.auto.tfvars`

```
vsphere_server = ""
vsphere_password = ""
```
