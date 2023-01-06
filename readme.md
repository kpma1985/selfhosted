# Hosts
### Auth + VPN + Reverse proxy
The first host, which must have a static IP, runs authentication and a VPN behind a reverse proxy, along with routing traffic to other notes. Currently, Authentik is used for authentication, Headscale is used for the VPN, and Caddy is used to reverse proxy. To set up this host, follow the steps below.
1. Initial setup
1. Restic setup (w/ cronjobs for `backup.sh` and `remove-old.sh`)
1. Run containers (Caddy and Authentik must be the first and second, respectively)
    1. Caddy (use caddy-front here)
        - run `docker network create caddy` before bringing the container up
    1. Authentik
        - after bringing up authentik, create a user for yourself and another for `servers`
        - create a `headscalars` group and add any users that should be able to access the `headscale` server
        - create an OIDC provider, then create an application for `headscale` using that provider
    1. Headscale
        - update the `.env` file with the OIDC provider and application details, as well as the domain name and other details
    1. Static-file-server
    1. Uptime Kuma
1. Tailscale setup

### Worker nodes
Subsequently, as many nodes as desired can be added, with or without static IPs. To set up a worker node, follow the steps below.
1. Initial setup
1. Restic setup (w/ cronjobs for `backup.sh` *only*)
1. Tailscale setup
1. Run containers
    1. Caddy (use caddy-back here)
        - run `docker network create caddy` before bringing the container up
    1. Currently, any subsequent containers spun up on a worker node will be automatically reverse proxied to by that node's instance of Caddy. However, for the traffic to reach the worker node in the first place, the relevant subdomain must be directed to that particular node in the Caddyfile of the first host (VPS w/ static IP that's gating all traffic). Another downside is that TLS terminates at the VPS, and further traffic, which occurs over the headscale network, is not encrypted. A couple solutions to this are:
        -  described [here](https://caddy.community/t/caddy-reverse-proxy-nextcloud-collabora-vaultwarden-with-local-https/12052), have the former Caddy serve as a CA and create a certificate for each worker node, then have each worker node serve as a reverse proxy for its own containers, essentially serving as a second TLS
        - use Caddy-l4 to proxy TCP traffic directly to the worker node, bypassing the first host entirely. This is likely optimal, and should be much easier once l4 is further developed and allows access via Caddyfile. Nevertheless, since this whole thing needs to be automated anyways, it may be worth it to just see if I can do it now. 
    1. Since TLS terminated at the VPS node, everything beyond needs to be explicitly specified as http. 
        - This means that on the worker node, caddy labels should be specified as:
        ```
        http://<subdomain>.<domain> {
            reverse_proxy http://<container>:<port>
        }
        ```
        which translates to container labels of
        ```
        labels:
          caddy: http://sub.${DOMAIN}
          caddy.reverse_proxy: "{{upstreams http 80}}"
        ```
        - And on the VPS node, this would be added as:
        ```
        sub.{$DOMAIN} {
            reverse_proxy http://<worker node tailnet IP>
        }
        directly to the Caddyfile
    1. TODO: automate the hard part of this process

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

Set the timezone as appropriate:
```bash
sudo timedatectl set-timezone America/Chicago
timedatectl
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
- 2376/tcp

Both above and below, we can open hosts only to the tailnet IP range, i.e., `100.64.0.0/10`.  

Then, on all swarm hosts, use `firewalld` to edit `iptables`:
```bash
sudo apt install firewalld
sudo systemctl enable firewalld

sudo firewall-cmd --permanent --zone=public --add-port=2377/tcp
sudo firewall-cmd --permanent --zone=public --add-port=7946/tcp
sudo firewall-cmd --permanent --zone=public --add-port=7946/udp
sudo firewall-cmd --permanent --zone=public --add-port=4789/udp
sudo firewall-cmd --permanent --zone=public --add-port=2376/udp
sudo firewall-cmd --reload
```

Next, initialize the swarm:
```bash
docker swarm init --advertise-addr <tailnet IP>
```

Finally, add the other hosts to the swarm:
```bash
docker swarm join-token worker # get the token from the swarm manager
```
Run the command printed above on other hosts, adding in `--advertise-addr <tailnet IP>`.

Create a Docker overlay network for the swarm:
```bash
docker network create --driver overlay --attachable --subnet
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
