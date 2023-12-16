# SAMBAProject
Cybersecurity project about SAMBA file server

## Usage
- Download the rar file from [link]
- Extract the .rar file. You'll find the VirtualBox .ova file and the Docker image .tar file.

## For VirtualBox (you MUST have VirtualBox installed on your PC!)
- Double click on the .ova file
- Adjust the VM settings depending on your computer
- Start the VM
- Account Passwd: ste123

# ATTENTION! The Vm may be slow because of ClamaV!

## For Docker (you MUST have Docker installed on your PC! You can also use Docker Desktop.)
- Open Docker Desktop and start the Docker Engine
- Open the CLI
- Execute "docker import /path/to/image.tar"
- Execute "docker images" and copy the latest image's ID
- Execute "docke run -it ID /bin/bash"
