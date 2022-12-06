#!/bin/bash

rm terraform.tfstate

tflocal init; tflocal plan; tflocal apply --auto-approve
