# Terraform

Initialize backend

```sh
export pg_pass=""
terraform init -backend-config="conn_str=postgres://terraform:$pg_pass@pg01.hlab.no/terraform"
```

Add required variables to a file ending in `.auto.tfvars`

```
vsphere_server = ""
vsphere_password = ""
```

Mikrotik variables

```
mikrotik_user = ""
mikrotik_password = ""
```
