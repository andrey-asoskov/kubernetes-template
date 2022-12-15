# kubernetes-template

Kubernetes Cluster template

## Prerequisites (Tested on)

- Terraform 1.3.3
- kubectl v1.26.0
- Helm v3.10.2
- Helm Chart Testing 3.7.1

## CI/CD status

| Status |
| -------|
| ![Terraform-test GHA Workflow](https://github.com/andrey-asoskov/kubernetes-template/actions/workflows/terraform.yml/badge.svg) |

## Contents

| Path                    | Description                                                              |
|-------------------------|--------------------------------------------------------------------------|
| .github/workflows/      | CI pipelines to test the Terraform config                                |
| Infra/                  | Infra config                                                             |
| K8s_config              |
| .markdownlint.yaml      |
| .pre-commit-config.yaml |
| .yamllint.yaml          |

### Test GHA workflows locally

```commandline
# Test using medium image
act --rm -W ./.github/workflows/terraform.yml -P ubuntu-22.04=ghcr.io/catthehacker/ubuntu:act-22.04

# Test using full image 20.04
act --rm -W ./.github/workflows/terraform.yml -P ubuntu-22.04=catthehacker/ubuntu:full-20.04
```
