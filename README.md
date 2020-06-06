# Homelab Deployment
All of the code to make sure that my homelab can be deployed simply and easily.

This project leverages [Puppet Bolt](https://puppet.com/docs/bolt/latest/bolt.html) to deploy all of the VMs and then provision them.

# Inventory File

The Inventory file should include all of the hosts to deploy code to and will do so through a bastion/proxyjump host.