# Hosts
### Auth + VPN
The first host, which must have a static IP, runs authentication and a VPN behind a reverse proxy. Currently, Authentik is used for authentication, Headscale is used for the VPN, and Caddy is used to reverse proxy. To set up this host, follow the steps below.
1. Initial setup
1. Run containers (order matters)
    1. Caddy
        - run `docker network create caddy` before bringing the container up
    1. Authentik
        - after bringing up authentik, create a user for yourself and another for `servers`
        - create a `headscalars` group and add any users that should be able to access the `headscale` server
        - create an OIDC provider, then create an application for `headscale` using that provider
    1. Headscale
        - update the `.env` file with the OIDC provider and application details, as well as the domain name and other details

### Swarm manager
The second host, which also needs a static IP, manages a Docker swarm over a tailnet, and reverse proxies traffic to all subsequent hosts. To set up this host, follow the steps below.
1. Initial setup
1. Tailscale setup
1. Swarm setup
    - Figure out the tailnet IPs of the swarm manager by running the following command on the server running `headscale`. 
    ```bash
    docker exec headscale headscale node ls
    ```
    - Based off of the [official tutorial](https://docs.docker.com/network/network-tutorial-overlay/#use-an-overlay-network-for-standalone-containers): run the following command on the swarm manager to initialize the swarm, advertising the tailnet IP of the swarm manager.
    ```bash
    docker swarm init --advertise-addr <tailnet IP of swarm manager>
    ```
    - Create an overlay network for the swarm with the following command.
    ```bash
    docker network create --driver=overlay --attachable caddy
    ```
    
1. Run containers
    1. Caddy
    1. Static-file-server

### Worker nodes
Subsequently, as many nodes as desired can be added, with or without static IPs. To set up a worker node, follow the steps below.
1. Initial setup
1. Tailscale setup
1. Join swarm
    - Get the tailnet IP of the node you want to join by running the following command on the server running `headscale`. 
    ```bash
    docker exec headscale headscale node ls
    ```
    - From the swarm manager node, get the join token by running the following command.
    ```bash
    docker swarm join-token worker
    ```
    - Append `advertise-addr <tailnet IP of swarm worker>` to the end of the join command, and run it on the swarm worker node.
    - The `caddy` swarm overlay network should now be available on the swarm worker node.
1. Run containers

# Steps
### Initial setup
If on a VPS with an automatically created user, you can optionally pick a new username as desired:
```bash
export NAME=avirut
```

Next, create a new user with the same username as the automatically created user, add it to the `sudo` group, and copy over the SSH keys from the automatically created user:
```bash
sudo adduser $NAME
sudo usermod -aG sudo $NAME
sudo mkdir /home/$NAME/.ssh
sudo chmod 700 /home/$NAME/.ssh
sudo cp ~/.ssh/authorized_keys /home/$NAME/.ssh/authorized_keys
sudo chown -R $NAME:$NAME /home/$NAME/.ssh
sudo chmod 600 /home/$NAME/.ssh/authorized_keys
```

Finally, SSH in with the new username and delete the automatically created user:
```bash
sudo deluser --remove-home <automatically created user>
```

Next, install Docker by following the [official instructions](https://docs.docker.com/engine/install/ubuntu/#install-using-the-repository).

Complete the suggested post-installation steps:
```bash
sudo groupadd docker
sudo usermod -aG docker $USER
newgrp docker
```

Test docker by running the hello-world container:
```bash
docker run hello-world
```
### Tailscale setup
Download and install Tailscale from the [official website](https://tailscale.com/download).
Login with:
```bash
sudo tailscale up --login-server https://hs.${DOMAIN}
```
Complete the printed steps to authorize the device.

### Swarm setup
For Docker swarm to work, certain ports must be open on all hosts. First, ensure that any swarm hosts with managed network ingress rules (e.g., on Oracle Cloud) have the appropriate ports open through the web GUI. These ports are:
- 2377/tcp
- 7946/tcp
- 7946/udp
- 4789/udp

Then, on all swarm hosts, use `firewalld` to edit `iptables`:
```bash
sudo apt install firewalld
sudo systemctl enable firewalld

sudo firewall-cmd --permanent --zone=public --add-port=2377/tcp
sudo firewall-cmd --permanent --zone=public --add-port=7946/tcp
sudo firewall-cmd --permanent --zone=public --add-port=7946/udp
sudo firewall-cmd --permanent --zone=public --add-port=4789/udp
sudo firewall-cmd --reload
```

# Debugging
### Docker swarm networking
If you see an error that looks like:
```
docker: Error response from daemon: error creating external connectivity network: Failed to Setup IP tables: Unable to enable SKIP DNAT rule:  (iptables failed: iptables --wait -t nat -I DOCKER -i docker_gwbridge -j RETURN: iptables: No chain/target/match by that name.
```
Then, try restarting Docker:
```bash
sudo systemctl restart docker
```
