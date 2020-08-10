#!/usr/bin/python
# TODO Ask a bunch of questions
#   - 
# TODO Build data files: {
#   common.yaml
#   k8s/*
#   inventory.yaml
# }
# Internal Libraries
import os
import sys
import json
import pathlib
import argparse
from subprocess import DEVNULL, STDOUT, check_call

# External Libraries
import yaml
from jinja2 import Environment, FileSystemLoader, Template

# Sets up args
parser = argparse.ArgumentParser(description="Sets up your homelab environment with Bolt")

parser.add_argument('--boltdir', '-b',
    help="Defines your Boltdir. Defaults to 'Boltdir'.",
    default='Boltdir')
parser.add_argument('--debug',
    help="Enabled debug log output.",
    action="store_true", default=False  )

# Parses all of your args.
args = parser.parse_args()

# Definitions
directory = "{}/data".format(args.boltdir)

### Functions

# Create the directory to do everything in.
try:
    os.makedirs(directory + '/', exist_ok = True)
    print("Directory '%s' created successfully" %directory)
except:
    raise

# Questionnaire time!
print("We're going to ask you a few questions to get your environment up and going.")
print("===== KUBERNETES - START =====")
ktDir                           = os.getcwd() + '/' + directory
ktEnvFile                       = ktDir + '/env'
ktOS                            = str(input("Which OS are you deploying to (Default: Ubuntu) : ") or "Ubuntu")
ktVERSION                       = str(input("Which Version of K8s are you deploying (Default: 1.17.6) : ") or "1.17.6")
ktCONTAINER_RUNTIME             = str(input("Which Container Runtime are you using (Default: docker) : ") or "docker")
ktCNI_PROVIDER                  = str(input("Which CNI Provider do you want to deploy (Default: calico) : ") or "calico")
ktEtcdClusterHostname           = str(input("Enter the hostname for your primary K8s node (Default: k8s-primary-1 : ") or "k8s-primary-1")
while True:
    ktEtcdClusterIP             = str(input("Enter the IP address for your primary K8s node : "))
    if not ktEtcdClusterIP:
        print("You must enter an IP")
    else:
        break
ktETCD_INITIAL_CLUSTER          = str(
    input("What ETCD Initial Cluster do you want to use (Default: '{}:{}') : ".format(ktEtcdClusterHostname,ktEtcdClusterIP))
    or
    "{}:{}".format(ktEtcdClusterHostname,ktEtcdClusterIP)
)
ktETCD_IP                       = str('%{::ipaddress_eth1}')
ktKUBE_API_ADVERTISE_ADDRESS    = str('%{::ipaddress_eth1}')
ktINSTALL_DASHBOARD             = str(input("Do you want to install the K8s Dashboard (Default: false) : ") or "false")

file_loader = FileSystemLoader("{}/setup/templates".format(os.getcwd()))
k8s_env = Environment(loader=file_loader)
k8s_template = k8s_env.get_template('env.j2')

# Creates the K8s Environment Files for Hiera
def createK8sEnvFile(
    os,
    version,
    container_runtime,
    cni,
    etcd_initial_cluster,
    etcd_ip,
    k8s_advertise,
    dashboard,
    envFileName
):
    # Render File Output
    output = k8s_template.render(
        OS = os,
        VERSION = version,
        CONTAINER_RUNTIME = container_runtime,
        CNI_PROVIDER = cni,
        ETCD_INITIAL_CLUSTER = etcd_initial_cluster,
        ETCD_IP = etcd_ip,
        KUBE_API_ADVERTISE_ADDRESS = k8s_advertise,
        INSTALL_DASHBOARD = dashboard
    )

    # Try to build the file
    try:
        k8sEnvFile = open(ktEnvFile, 'w')
        k8sEnvFile.writelines(output)
        k8sEnvFile.close()
    except:
        print("The environment file could not be created. Check permissions!")
        sys.exit(1)

# Check if the 'env' file already exists. This WILL be destructive if things already exist!!
checkEnvFile = pathlib.Path(ktEnvFile)
if checkEnvFile.exists():

    while True:
        ans = input("The file already exists; continue? This may be destructive! (y/n) : ")
        if ans not in ['y', 'Y', 'n', 'N']:
            print('Please enter y or n.')
            continue
        if ans == 'y' or ans == 'Y':
            print("Continuing")
            break
        if ans == 'n' or ans == 'N':
            print("Stopping.")
            sys.exit(0)

createK8sEnvFile(os=ktOS, version=ktVERSION, container_runtime=ktCONTAINER_RUNTIME,
    cni=ktCNI_PROVIDER, etcd_initial_cluster=ktETCD_INITIAL_CLUSTER, etcd_ip=ktETCD_IP,
    k8s_advertise=ktKUBE_API_ADVERTISE_ADDRESS, dashboard=ktINSTALL_DASHBOARD,
    envFileName=ktEnvFile)
print("===== KUBERNETES - END =====")

## Run Docker Builder
check_call([
    "/usr/bin/docker", "run", "--rm", "-v", "{}:/mnt".format(ktDir), 
    "--env-file", ktEnvFile, "puppet/kubetool:5.1.0"],
    stdout=DEVNULL, stderr=STDOUT)

# Parse Yaml
osK8sFile = ktDir + "/{}.yaml".format(ktOS)
with open(osK8sFile) as file:
    listOfThings = yaml.load(file, Loader=yaml.FullLoader)

listOfThings.update({
    'kubernetes::kubernetes_package_version':   "{}-00".format(listOfThings['kubernetes::kubernetes_version']),
    'kubernetes::docker_key_source':            'https://download.docker.com/linux/ubuntu/gpg',
    'kubernetes::docker_key_id':                '9DC858229FC7DD38854AE2D88D81803C0EBFCD88',
    'kubernetes::docker_apt_location':          'https://download.docker.com/linux/ubuntu',
    'kubernetes::docker_apt_release':           '%{os.distro.codename}',
    'kubernetes::docker_apt_repos':             'stable',
    'kubernetes::docker_package_name':          'docker-ce',
    'kubernetes::cgroup_driver':                'systemd',
    'kubernetes::docker_version':               '5:19.03.11~3-0~ubuntu-%{os.distro.codename}',
    'kubernetes::kubernetes_apt_location':      'https://packages.cloud.google.com/apt/',
    'kubernetes::kubernetes_apt_release':       'kubernetes-%{os.distro.codename}',
    'kubernetes::cni_pod_cidr':                 '10.32.0.0/12',
    'kubernetes::etcd_version':                 '3.4.0'
})

# If Calico is the CNI provider:
if [ ktCNI_PROVIDER == "calico" ]:
    listOfThings.update({
        'kubernetes::cni_network_provider': 'https://docs.projectcalico.org/manifests/calico.yaml'
    })

listOfCerts = {
    'kubernetes::etcd_ca_crt': listOfThings['kubernetes::etcd_ca_crt'],
    'kubernetes::etcd_ca_key': listOfThings['kubernetes::etcd_ca_key'],
    'kubernetes::etcdclient_crt': listOfThings['kubernetes::etcdclient_crt'],
    'kubernetes::etcdclient_key': listOfThings['kubernetes::etcdclient_key'],
    'kubernetes::kubernetes_ca_crt': listOfThings['kubernetes::kubernetes_ca_crt'],
    'kubernetes::kubernetes_ca_key': listOfThings['kubernetes::kubernetes_ca_key'],
    'kubernetes::kubernetes_front_proxy_ca_crt': listOfThings['kubernetes::kubernetes_front_proxy_ca_crt'],
    'kubernetes::kubernetes_front_proxy_ca_key': listOfThings['kubernetes::kubernetes_front_proxy_ca_key'],
    'kubernetes::sa_key': listOfThings['kubernetes::sa_key'],
    'kubernetes::sa_pub': listOfThings['kubernetes::sa_pub']
}

# Removes the certs from the listOfThings; write them separately.
for i in listOfCerts.keys():
    listOfThings.pop(i)

# try:
with open(osK8sFile, 'w') as file:
    writeThis   = yaml.dump(listOfThings, file, explicit_start=True)

with open(osK8sFile, 'a') as file:
    certs       = yaml.dump(listOfCerts, default_style='|')
    edit1       = certs.replace(': \'', ': |\n  ', len(listOfCerts.keys())).replace('"','')
    file.write(edit1)

# except:
    # print("Something went wrong writing back the file!!")
    # sys.exit(1)

print("Updated the '{}.yaml' file.".format(ktOS))