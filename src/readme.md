# Setup steps

### Add user to match username
For [Cloudflare's certificate-based SSH access](https://developers.cloudflare.com/cloudflare-one/tutorials/ssh-cert-bastion/#configure-the-ssh-client), the username from the identity provider must match the username on the server. If the default username is not the same as the username from the identity provider, add a new user:
```bash
NAME=avirut
sudo adduser $NAME
```
Give the new user `sudo` privileges and copy over the authorized public key:
```bash
sudo usermod -aG sudo $NAME
sudo mkdir /home/$NAME/.ssh
sudo chmod 700 /home/$NAME/.ssh
sudo cp ~/.ssh/authorized_keys /home/$NAME/.ssh/authorized_keys
sudo chown -R $NAME:$NAME /home/$NAME/.ssh
sudo chmod 600 /home/$NAME/.ssh/authorized_keys
```
SSH back in with the new user account.

### Install Docker and Docker Compose
Sourced from DigitalOcean's [Docker](https://archive.ph/Q2Xud) and [Docker Compose](https://archive.ph/vIKVg) tutorials.

Update packages, install some helpful ones, and add the Docker repository.
```bash
# amd64 and arm64 are the two likely options for ARCH based on where you're installing
ARCH="arm64"
sudo apt update
sudo apt install apt-transport-https ca-certificates curl software-properties-common
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo add-apt-repository "deb [arch=${ARCH}] https://download.docker.com/linux/ubuntu focal stable"
```
Verify that your source for Docker is now Docker's repository and not Ubuntu's:
```bash
apt-cache policy docker-ce
```
Install Docker:
```bash
sudo apt install docker-ce
```
Verify Docker is running:
```bash
sudo systemctl status docker
```
Make running Docker commands without specifying `sudo` possible:
```bash
sudo usermod -aG docker ${USER}
su - ${USER}
```
Check [current stable version](https://github.com/docker/compose/releases) of Compose and update accordingly:
```bash
VER="v2.5.0"
sudo curl -L "https://github.com/docker/compose/releases/download/${VER}/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose
```
Verify installation of Docker Compose:
```bash
docker compose --version
```

### Setup networking
You will have to create two Docker networks to get the containers properly linked:
```bash
docker network create cloudflared
docker network create caddy
```

Then, run Docker and Caddy.

##### Short-lived certificates for Cloudflare SSH
Primarily sourced from [Cloudflare docs](https://developers.cloudflare.com/cloudflare-one/tutorials/ssh-cert-bastion).

- From the Cloudflare Zero Trust Dashboard, navigate to `Access/Service Auth`. Under the SSH tab, select your previously created SSH application, and click `Generate certificate`.
- Edit your `sshd` configuration (`sudo nano /etc/ssh/sshd_config`) with the following values:
```
PubkeyAuthentication yes
TrustedUserCAKeys /etc/ssh/ca.pub
```
- Finally, `sudo nano /etc/ssh/ca.pub` and add the public key value you generated on the Cloudflare Zero Trust Dashboard.
- Restart the server (`sudo reboot`).

**The remaining steps are listed in the Cloudflare documentation but do not seem necessary to get this working, nor do they seem like they would make sense without significant modifications.**
- Enter the cloudflared container (`docker exec -it cloudflared sh`).
- To generate an SSH configuration, run:
```bash
cloudflared access ssh-config --hostname ${HOST_HOSTNAME}.${DOMAIN} --short-lived-cert
```
- Copy the output into `sudo nano /root/.ssh/config`.