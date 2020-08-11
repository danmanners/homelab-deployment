#!/usr/bin/python
# TODO Build data files:
# TODO   - common.yaml
# TODO   - inventory.yaml
#      }
# Internal Libraries
import os
import argparse
from subprocess import DEVNULL, STDOUT, check_call

# External Libraries
import yaml

from questions.k8s import k8sQuestion, buildKubePrimaryFile
from questions.inventory import inventoryQuestions
from questions.files import createK8sOutputFile

# Sets up args
parser = argparse.ArgumentParser(description="Sets up your homelab environment with Bolt")
parser.add_argument('--boltdir', '-b',
    help="Defines your Boltdir. Defaults to 'Boltdir'.",
    default='Boltdir')
parser.add_argument('--debug',
    help="Enabled debug log output.",
    action="store_true", default=False)

# Parses all of your args.
args = parser.parse_args()

# Definitions
directory = "{}/data".format(args.boltdir)
inventoryFileName = "{}/inventory.yaml".format(args.boltdir)

# Create the directory to do everything in.
try:
    os.makedirs(directory + '/', exist_ok = True)
except:
    raise

# Questionnaire time!
print("We're going to ask you a few questions to get your environment up and going.")

# Functions
## K8s Questions
ktDir, ktEnvFile, ktOS, ktCNI_PROVIDER, etcdClusterHostname, kubePrimary = k8sQuestion(directory=directory)

## Inventory Questions
inventoryFile = inventoryQuestions(kubePrimary)

## Run Docker Builder
check_call([
    "/usr/bin/docker", "run", "--rm", "-v", "{}:/mnt".format(ktDir), 
    "--env-file", ktEnvFile, "puppet/kubetool:5.1.0"],
    stdout=DEVNULL, stderr=STDOUT)

# Generate the list of Values, list of Certs, and the filename 
listOfThings, listOfCerts, k8sFile = buildKubePrimaryFile(ktDir, ktOS, ktCNI_PROVIDER, etcdClusterHostname)

# Create the k8s Output File
createK8sOutputFile(listOfThings, listOfCerts, k8sFile, inventoryFileName, inventoryFile)
