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
import argparse

# External Libraries
import yaml
from jinja2 import Environment, FileSystemLoader, Template

# Sets up args
parser = argparse.ArgumentParser(description="Sets up your homelab environment with Bolt")

parser.add_argument('--boltdir', '-b',
    help="Defines your Boltdir. Defaults to 'Boltdir'.",
    default='Boltdir')

# Parses all of your args.
args = parser.parse_args()

directory = "{}/data".format(args.boltdir)

# Create the directory to do everything in.
try:
    os.makedirs(directory + '/', exist_ok = True)
    print("Directory '%s' created successfully" %directory)
except:
    raise

# Questionnaire time!
print("We're going to ask you a few questions to get your environment up and going.")
print("===== KUBERNETES - START =====")
ktDir                           = os.getcwd()+'/'+directory
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
output = k8s_template.render(
    ktOS = ktOS,
    ktVERSION = ktVERSION,
    ktCONTAINER_RUNTIME = ktCONTAINER_RUNTIME,
    ktCNI_PROVIDER = ktCNI_PROVIDER,
    ktETCD_INITIAL_CLUSTER = ktETCD_INITIAL_CLUSTER,
    ktETCD_IP = ktETCD_IP,
    ktKUBE_API_ADVERTISE_ADDRESS = ktKUBE_API_ADVERTISE_ADDRESS,
    ktINSTALL_DASHBOARD = ktINSTALL_DASHBOARD
)

try:
    k8sEnvFile = open("{}/env".format(ktDir), 'w')
    k8sEnvFile.writelines(output)
    k8sEnvFile.close
    print("Environment File Created!")
except:
    print("The environment file could not be created. Check permissions!")
    sys.exit(1)

print("===== KUBERNETES - END =====")

## Run Docker Builder
# os.system("docker run --rm -v {}:/mnt puppet/kubetool:5.1.0".format(ktDir))