# Terraform

Initialize backend

```sh
export pg_pass=""
terraform init -backend-config="conn_str=postgres://terraform:$pg_pass@pg01.vm.local/terraform"
```

## Avoid replacement when template was changed

```sh
terraform state pull > terraform.tfstate
sed -i 's/<old template_uuid>/<new template_uuid>/g' terraform.tfstate
terraform state push -force terraform.tfstate
```
