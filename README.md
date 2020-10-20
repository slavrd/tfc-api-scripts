# TFC API Scripts

A collection of various scripts for interacting with the TFC API.

## Contents

List of contents and short description of the scripts

* `tf_cli_trigger_rins.sh` - triggers a set number of Terraform Cloud runs via the Terraform CLI. For each run the script will:
  * Create a directory. 
  * Copy the contents of a provided source directory into it. It is assumed that the contents are Terraform Configuration
  * Execute `terraform init` using a partial backend config to set up the `remote backend`. The Terraform configuration must still contain a `remote` backend stanza.
    
    ```HCL
    terraform {
        backend "remote" {}
    }
    ```
  * Execute `terraform apply`.

* `workspace_delete.sh` - uses the Terraform Cloud API to delete **all** workspaces that **contain** a provided string in their names.
