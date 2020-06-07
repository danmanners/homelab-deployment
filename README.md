# Homelab Deployment
All of the code to make sure that my homelab can be deployed simply and easily.

This project leverages [Puppet Bolt](https://puppet.com/docs/bolt/latest/bolt.html) to deploy all of the VMs and then provision them.

# What components are necessary for a deployment like this?

I am running a single Proxmox 6.2 node for my hypervisor. My hardware is as follows:

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

# What will the network architecture actually look like?

For my environment, I want to make sure that I can run safely deploy and redeploy everything I'm doing without having to manually type any commands.

Additionally, I have previously run my homelab as the home network, which justifiably annoyed my wife when I'd make breaking changes. This time around, I'm running everything double NAT'd because it'll make sure I don't cause unnecessary issues 😉.

In order to manage this, the hypervisor will have two networks:
- Bridged network with my home network
- Bridged network that does not leave the hypervisor

The one VM where everything will communicate through is the "`pmxrouter`" host. This VM has two ethernet interfaces, one on each subnet, and runs iptables and NGINX. Any and all services that should be accessible to either the home subnet (`10.45.0.0/24`) or the outside world will be proxied through that one VM host. All clients on the homelab subnet (`10.99.0.0/24`) have their gateways set to `10.99.0.1`. When clients attempt to reach out to the outside world, `pmxrouter` masquerades all traffic with iptables from the homelab subnet to the home network subnet.Once the applications have been deployed, the router will be significantly more locked down.

Here's a simple-ish diagram of sort of what this all looks like:

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

In order for communications between my development station and the virtual machines on the homelab subnet, I am leveraging the `pmxrouter` as a Proxyjump (or bastion) host. This means that all SSH sessions are established through the router.

# Recommended GenericCloud Images

While you can absolutely create your own [Cloud-Init](https://cloudinit.readthedocs.io/en/latest/) enabled images on your hypervisor, I recommend downloading and using the following Official GenericCloud Images:

- [CentOS 8 Cloud Images](https://cloud.centos.org/centos/8/x86_64/images/)
- [Ubuntu Bionic 18.04 Image](https://cloud-images.ubuntu.com/bionic/current/bionic-server-cloudimg-amd64.img)
  - [Installation Instructions can be found here](https://pve.proxmox.com/wiki/Cloud-Init_Support#_preparing_cloud_init_templates)

The reason I recommend using these images is that you can simply:
0. Add your ssh-keys to the template
0. Set your default network settings
0. Clone the image
0. Expand the volume
0. Launch the image

Within ~30s you have a fully functional Linux VM!

# Inventory File

The Inventory file includes all of the hosts to deploy code to, and does so through the `pmxrouter` host as a Proxyjump/Bastion host.

