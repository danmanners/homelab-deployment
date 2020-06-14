# Homelab Deployment
All of the code to make sure that my homelab can be deployed simply and easily.

This project leverages [Puppet Bolt](https://puppet.com/docs/bolt/latest/bolt.html) to deploy all of the VMs and then provision them.

# What hardware components are necessary for a deployment like this?

I am running a single Proxmox 6.2 node for my hypervisor. My hardware specs are:

```yaml
Hardware:
    CPU: "Intel i7-7700 (4c8t, 3.6 - 4.2GHz)"
    RAM: "64GB (4x 16GB DDR4-2400)"
    Storage:
        - Disk1: "256GB M.2 SSD Western Digital Blue"
          Alias: "hypervisor"
        - Disk2: "500GB M.2 SSD Crucial"
          Alias: "fivehundo"
        - Disk3: "1TB M.2 NVME Western Digital Blue"
          Alias: "nvmestor"
        - Disk4: "2TB SATA 7200rpm Seagate 3.5"
          Alias: "slowboat"
```

# What software will I need for this?

I'm assuming that you're going to be running *nix in some form or fashion. My primary personal development rig is running Windows 10 Pro with WSL2 running Ubuntu 20.04. That being said, 100% of this can be done with Mac OS, as my daily work driver is just that with all of the following tooling.

You'll need the following software packages/libraries:

* Favorite flavor of *nix
* [kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl/)
* [Puppet Bolt](https://puppet.com/docs/bolt/latest/bolt_installing.html)
* [hiera-eyaml](https://packages.ubuntu.com/search?keywords=hiera-eyaml)


Additionally, you'll _want_ to install the following software for various purposes:

* [jq](https://stedolan.github.io/jq/) - Easier JSON parsing
* [Puppet Agent](https://puppet.com/docs/puppet/latest/install_agents.html) - Lets you test Facter locally.

# What will the network architecture actually look like?

For my environment, I want to make sure that I can safely deploy and redeploy everything I'm doing without having to manually type any commands. Simple(ish) goal.

Additionally, I have previously run my homelab as the home network, which justifiably annoyed my wife when I'd make breaking changes. This time around, I'm running everything double NAT'd because it'll limit the amount of damage I can cause 😉.

In order to manage this, the hypervisor will have two networks:
- Bridged network with my home network, or 'WAN.'
- Bridged network that does not leave the hypervisor, or 'LAN.'

Here's a simple diagram of what this should all look like:

```
+-----------------+
|                 |
|   Cable Modem   |
|                 |
+--------+--------+
         |
         |
         |
         v
+--------+--------+    +----------------+
|                 |    |                |
|   Home Router   +--->+   Everything   |
|                 |    |     Normal     |
+------------+----+    |                |
             |         +----------------+
             |
+------------|--------------------------+
|            |                          |
| Hypervisor |                          |
|            v                          |
+------------+---+     +---------------++
||               |     |               ||
||  VM's on the  |     |               ||
||  Home Subnet  |     |               ||
||               |     |  VM's on the  ||
||               |     |    homelab    ||
||               |     |     subnet    ||
|| +-----^-----+ |     |               ||
|| Router&Proxy+------>|               ||
|| +-----------+ |     |               ||
||               |     |               ||
|----------------+     +---------------+|
+---------------------------------------+
```

The "Router&Proxy" virtual machine (further referred to as `pmxrouter`) is a simple Ubuntu VM with two ethernet interfaces; WAN and LAN. It will ultimately be provisioned with iptables, NGINX and BIRD Internet Routing Daemon ([an amusingly recursive name](https://bird.network.cz/)). The subnetting looks like this:

### Router Interface Settings

| Description  | Interface Name  | IP Address | Gateway | Subnet Mask|
|-|-|-|-|-|
| WAN | eth0 | 10.45.0.11 | 10.45.0.1 | 255.255.255.0 |
| LAN | eth1 | 10.99.0.1  | **n/a** | 255.255.255.0 |

All virtual machines on the LAN (10.99.0.0/24 network) have their gateways set to the `pmxrouter` (10.99.0.1) host, and all traffic is masqueraded with iptables outbound. DNS is currently proxied up to my primary home router, though eventually the plan is to switch to something that can be easily deployed and managed by Puppet Bolt.

In order for communications between my development station and the virtual machines on the homelab subnet, I am leveraging the `pmxrouter` as a Proxyjump (or bastion) host. 

# Recommended GenericCloud Images

While you can absolutely create your own [Cloud-Init](https://cloudinit.readthedocs.io/en/latest/) enabled images on your hypervisor, I recommend downloading and using the following Official GenericCloud Image:

- [Ubuntu Bionic 18.04 Image](https://cloud-images.ubuntu.com/bionic/current/bionic-server-cloudimg-amd64.img)
  - [Installation Instructions can be found here](https://pve.proxmox.com/wiki/Cloud-Init_Support#_preparing_cloud_init_templates)

The reason I recommend using this image is that you can simply:

1. Add your ssh-keys to the Cloud-Init template image
0. Set your default network settings
0. Clone the image
0. Expand the volume
0. Launch the image

Within ~30s you have a fully functional Linux VM!

# Inventory File

The Inventory file includes all of the virtual hosts to provision, and does so by leveraging Proxyjump/Bastion through the `pmxrouter` host. The hosts are grouped in such a way that allows easy reference to any number of services.

# What is Hiera/Hiera-Eyaml and how is it being used?

[Hiera-Eyaml](https://puppet.com/blog/encrypt-your-data-using-hiera-eyaml/) is a quick and safe way to encrypt and store your secret and private information with a self-signed PKCS7 keypair. Once encrypted, it's effectively safe to commit to source control (so long as you never accidentally commit the keypair 😉)! So long as you have the keys in the correct spot on the system that is running the Bolt plan, it will automatically decrypt and use the Hiera values as if they were unencrypted.

# Right Before Deploying Everything

Make sure that you've created 10 Virtual Machines, ensuring their system settings are appropriate:

|**#**| **Name** | **vCPU Count** \||\| **Memory (GiB)** \||\| **HDD Size (GB)** | **NIC 1 IP** | **NIC 2 IP**
|-|:-:|:-:|:-:|:-:|:-:|:-:|
|01|pmxrouter|2|2|20|10.45.0.11/24|10.99.0.1/24|
|02|k8s-primary|4|4|40|10.45.0.20/24|n/a|
|03|k8s-worker1|2|4|40|10.45.0.21/24|n/a|
|04|k8s-worker2|2|4|40|10.45.0.22/24|n/a|
|05|k8s-worker3|2|4|40|10.45.0.23/24|n/a|
|06|gitlab-25|4|8|80|10.45.0.25/24|n/a|
|07|docker-31|1|1|40|10.45.0.31/24|n/a|
|08|docker-32|1|1|40|10.45.0.31/24|n/a|
|09|docker-33|1|1|40|10.45.0.31/24|n/a|
|10|docker-34|1|1|40|10.45.0.31/24|n/a|

Once you have verified those settings, make sure that you turn all the machines on and wait 3-5 minutes for them to turn on and provision.

# Time to Deploy the Entire Project

Provisoning the entire project is as simple as running a few commands:

```bash
# Stage One - Initialization
➜ bolt plan run deploy_applications::qemu_guest_agent
➜ bolt plan run deploy_applications::docker_install

# Stage Two - Router Config
➜ bolt plan run deploy_router::router_config
➜ bolt plan run deploy_router::bird

# Stage Three - Gitlab and CI/CD Runners
➜ bolt plan run deploy_applications::gitlab_ce
➜ bolt plan run deploy_applications::gitlab_runner

# Stage Four - Kubernetes!
➜ bolt plan run deploy_k8s::init_master
➜ bolt plan run deploy_k8s::init_workers

# Stage Five - Make it all reachable
➜ bolt plan run deploy_router::nginx
```

### Why aren't all of the plans in the project on the list above?
Some of them are just for my homelab environment, like `deploy_applications::unifi_controller`, and others should never _**ever**_ be run unless you have an extrordinary need, like `deploy_k8s::nuke_it_all`. 

# Post Deployment Requirements
Once Kubernetes has been deployed, you'll be able to run a command like this to get the correct Kubernetes config file:

```bash
➜ mkdir -p ~/.kube

➜ ssh -J ubuntu@pmxrouter.danmanners.io ubuntu@10.99.0.20 \
  -t 'sudo cat /etc/kubernetes/admin.conf' > ~/.kube/config
```

Once you have the file locally, you'll need to apply a kubernetes manifest and run one additional command to finish the [MetalLB](https://metallb.universe.tf/installation/) deployment:


```bash
➜ kubectl apply \
  -f kubernetes/manifests/metallb/metallb-config.yaml

➜ kubectl create secret generic \
  -n metallb-system memberlist \
  --from-literal=secretkey="$(openssl rand -base64 128)"
```

Now, if you run `kubectl get pods --all-namespaces`, you should have a response which looks like this:

```
➜ kubectl get pods --all-namespaces
NAMESPACE        NAME                                       READY   STATUS    RESTARTS   AGE
kube-system      calico-kube-controllers-77d6cbc65f-qfb7s   1/1     Running   1          116m
kube-system      calico-node-c5wq8                          1/1     Running   1          85m
kube-system      calico-node-chdxv                          1/1     Running   1          85m
kube-system      calico-node-k99z4                          1/1     Running   1          85m
kube-system      calico-node-xhfrv                          1/1     Running   1          85m
kube-system      coredns-6955765f44-qgg7b                   1/1     Running   1          116m
kube-system      coredns-6955765f44-wj75m                   1/1     Running   1          116m
kube-system      kube-apiserver-k8s-primary                 1/1     Running   1          116m
kube-system      kube-controller-manager-k8s-primary        1/1     Running   1          116m
kube-system      kube-proxy-6t72z                           1/1     Running   1          112m
kube-system      kube-proxy-b2rcn                           1/1     Running   1          112m
kube-system      kube-proxy-csv4x                           1/1     Running   1          113m
kube-system      kube-proxy-qrd5v                           1/1     Running   1          116m
kube-system      kube-scheduler-k8s-primary                 1/1     Running   1          116m
kube-system      kubernetes-dashboard-7c54d59f66-xkgnd      1/1     Running   1          116m
metallb-system   controller-5c9894b5cd-9njqs                1/1     Running   1          94m
metallb-system   speaker-4fjtl                              1/1     Running   0          94m
metallb-system   speaker-9htm9                              1/1     Running   0          94m
metallb-system   speaker-nsv2x                              1/1     Running   0          94m
metallb-system   speaker-p8rgw                              1/1     Running   0          94m
```

# Questions? Concerns?

Please feel free to open an issue if you have any questions or concerns, or email me at [me@danmanners.com](mailto:me@danmanners.com)!
