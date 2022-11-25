#!/usr/bin/env bash

cd components/SingleHost/VPC
terraform apply

cd components/SingleHost/CP
terraform apply

cd components/SingleHost/Worker
terraform apply
