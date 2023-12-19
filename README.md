# Deception Component Generator
Cybersecurity project about SAMBA file server

## Link to resources
- https://liveunibo-my.sharepoint.com/:f:/g/personal/leonardo_lembo_studio_unibo_it/ErookCjTtW1HnosbtrrKfe0Bz6jtFwA78xGBVwuXfbJY-Q?e=5b6Okm

# Usage
- Download the rar files from the link above.

## For VirtualBox (you MUST have VirtualBox installed on your PC!)
- Double click on the .ova file
- Adjust the VM settings depending on your computer
- Start the VM
- Account Passwd: secret
- Path Scripts generazione utenti/gruppi: /home/admin/ScriptCyb/*

## Warning: the VM may be slow because of ClamAV!

## For Docker (you MUST have Docker installed on your PC! You can also use Docker Desktop.)
- Open Docker Desktop and start the Docker Engine
- Open the CLI
- Execute "docker import /path/to/image.tar"
- Execute "docker images" and copy the latest image's <ID>
- Execute "docker run --hostname <HOSTNAME> -it <ID> /bin/bash"
# The hostname must be the same as the one used when configuring the docker container
- Start slapd, smbd and nslcd by executing the "service *srv* start" command. Be careful to change *srv* with the service that you have to start.
