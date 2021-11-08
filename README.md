# Terraform

Initialize backend

```sh
export pg_pass=""
terraform init -backend-config="conn_str=postgres://terraform:$pg_pass@pg01.vm.local/terraform"
```
