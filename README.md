# SAMBAProject
Cybersecurity project about SAMBA file server

## Link to resourxes
- https://liveunibo-my.sharepoint.com/:f:/g/personal/leonardo_lembo_studio_unibo_it/ErookCjTtW1HnosbtrrKfe0Bz6jtFwA78xGBVwuXfbJY-Q?e=5b6Okm

## Usage
- Download the rar file from [link]
- Extract the .rar file. You'll find the VirtualBox .ova file and the Docker image .tar file.

## For VirtualBox (you MUST have VirtualBox installed on your PC!)
- Double click on the .ova file
- Adjust the VM settings depending on your computer
- Start the VM
- Account Passwd: secret

# Warning: the VM may be slow because of ClamAV!

## For Docker (you MUST have Docker installed on your PC! You can also use Docker Desktop.)
- Open Docker Desktop and start the Docker Engine
- Open the CLI
- Execute "docker import /path/to/image.tar"
- Execute "docker images" and copy the latest image's ID
- Execute "docker run -it ID /bin/bash"
- Restart slapd, smbd and nslcd by executing the "service *srv* start" command. Be careful to change *srv* with the service that you have to restart.  
