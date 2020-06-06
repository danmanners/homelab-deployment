# This plan will configure the Proxmox Router.
# This is the ONLY host that will not be a GenericCloud Cent7 Image.
plan deploy_dhcp::router_config(
  TargetSpec $subnet_mask,
  TargetSpec $subnet_address,
) {
  # Prep the server
  apply_prep('bastion')
}
