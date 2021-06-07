# 18F Concourse task Docker image

This repo contains the pipeline and resources for building a custom Docker image to run [Concourse](http://concourse.ci/) tasks.

## Using local Terraform providers

Adding providers to source locally for tasks using them in Terraform will have to be download and add them via the [`./concourse-tasks/scripts/build.sh`] script. Provider builds will need to be downloaded and added to the `$HOME/.terraform-providers/local/providers/` directory with the following path structure `.../<PROVIDER NAME>/<VERSION>/<PLATFORM>/<PROVIDER BUILD>`.  The only local provider installed is [`terraform-provider-credhub v0.13.3`](https://github.com/orange-cloudfoundry/terraform-provider-credhub) at `$HOME/.terraform-providers/local/providers/credhub/0.13.3/linux_amd64/terraform-provider-credhub`.

For the Terraform CLI config to install and use the local providers, the `~/.terraformrc` file points the the above directory.

ie.
```tf
provider_installation {
  filesystem_mirror {
    path    = "~/.terraform-providers/"
    include = ["local/providers/*"]
  }
  direct {
    exclude = ["local/providers/*"]
  }
}
```

To consume the local provider when using Terraform, reference the following example for credhub.

ie.
```tf
terraform {
  required_version = ">= 0.14"
  required_providers {
    credhub = {
      version = "0.13.3"
      source  = "local/providers/credhub"
    }
  }
}
```
