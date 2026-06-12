# Terraform

Gopass must be setup.

Initialize backend

```sh
source env.sh
terraform init
```

When updating lock file, use:
```sh
terraform providers lock -platform=linux_amd64 -platform=darwin_arm64
```
