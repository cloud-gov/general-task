# General Concourse Task

A general-purpose [Concourse](http://concourse-ci.org/) task containing a variety of build systems and CLI tools.

Formerly named `cg-deploy-concourse-docker-image`.

## Using local Terraform providers 

Adding providers to source locally for tasks using them in Terraform will have to be download and add them via the [`scripts/build.sh`] script. Provider builds will need to be downloaded and added to the `$HOME/.terraform-providers/local/providers/` directory with the following path structure `.../<PROVIDER NAME>/<VERSION>/<PLATFORM>/<PROVIDER BUILD>`.

For the Terraform CLI config to install and use the local providers, the `~/.terraformrc` file points the the above directory:

```tf
# ~/.terraformrc
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

To consume the local provider when using Terraform, reference the following example for `a-local-provider`.

```tf
terraform {
  required_version = ">= 0.14"
  required_providers {
    a-local-provider = {
      version = "0.13.3"
      source  = "local/providers/a-local-provider"
    }
  }
}
```
