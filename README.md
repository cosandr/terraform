# Terraform

Gopass must be setup.

Initialize backend

```sh
terraform init -backend-config="conn_str=postgres://terraform:$(gopass show -o terraform/pg_pass)@pg01.hlab.no/terraform"
```
