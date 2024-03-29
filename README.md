# Prepare_VM

## Overview

Prepare_VM is a project designed to streamline the process of setting up a virtual machine for a specific client. By simply entering the client's name, this project prepares a virtual machine with Kali Linux, installs some tools, and performs necessary configurations, utilizing Ansible for automation.

This project was created to make it easy to create an updated Kali Linux VM without using VM cloning and golden images. It will be kept updated based on the needs.

## Features

- Automated setup of Kali Linux on VMware Workstation 16 Pro.
- Installation of various tools and configurations.
- Utilization of Ansible for automation.
- Fast and easy script execution for VM preparation.

## Usage

1. Clone this repository to your local machine.
2. Enable the execution of PowerShell scripts:
   ```powershell
   Set-ExecutionPolicy RemoteSigned
3. Execute the PowerShell script and enter the client's name to initiate the VM setup:
   ```
   .\Prepare_VM.ps1
## Note

This project has been tested only on VMware Workstation 16 Pro.

## Acknowledgments

Special thanks to [IppSec](https://github.com/IppSec) for his repository and Ansible series. Check out his repo [here](https://github.com/IppSec/parrot-build).
