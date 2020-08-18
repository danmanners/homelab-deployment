import yaml
import os, sys, glob, ipaddress
from pathlib import Path
from jinja2 import Environment, FileSystemLoader, Template

def getUserSshKeys():
    # Identify the user's home directory
    userSshDir = "{}/.ssh".format(Path.home())
    # List of all Files in the Directory
    allFiles = glob.glob(userSshDir + '/*', recursive=True)
    # Empty List
    userSshKeys = []
    # For each file,
    for f in allFiles:
        # Open the file as read only
        with open(f, 'r') as l:
            # If the first 5 characters match '-----':
            if l.readline(5) == '-----':
                # Add them to the userSshKeys List.
                userSshKeys.append(f.rsplit('/', 1)[1])

    # Return the list of SSH Keys
    return userSshKeys, userSshDir

def inventoryQuestions(kubePrimary):
    print("===== INVENTORY - START =====")

    sshUsername = str(input("Which username do you want to SSH to the K8s Nodes with (Default: 'ubuntu'): ") or 'ubuntu')

    # Evaluate and query the list of SSH Keys
    sshKeys, sshDir = getUserSshKeys()
    if sshKeys is not []:
        while True:
            num = 1
            for i in sshKeys:
                print("{}) {}".format(num,i))
                num += 1
            
            sshKeySelection = str(input("Type the name of the SSH key above to be used to SSH to K8s Nodes, or press enter to use '{}': ".format(sshKeys[0])))
            if not sshKeySelection:
                sshKeySelection = sshKeys[0]
                break
            else:
                if sshKeySelection in sshKeys:
                    break
                else:
                    print("The key '{}' doesn't appear valid. Please try again.".format(sshKeySelection))
    else:
        print("No SSH keys could be found in {}.".format(sshDir))
        
    # Create the list of kubeNodes
    kubeNodes = []
    while True:
        if len(kubeNodes) == 0:
            node = input("Enter the IP address for your first k8s node: ")
        else:
            node = input("Enter an IP address for another node, or just press enter: ")
            if not node:
                break
        try:
            ipaddress.ip_address(node)
            kubeNodes.append(node)
        except:
            print("It doesn't appear that {} is a valid IP address.".format(node))

    print("===== INVENTORY -  END  =====")

    file_loader = FileSystemLoader("{}/setup/templates".format(os.getcwd()))
    invEnv = Environment(loader=file_loader)
    template = invEnv.get_template('inventory.yaml.j2')
    render = template.render(
        kubeNodes = kubeNodes,
        sshUsername = sshUsername,
        sshKeySelection = sshKeySelection,
        kubePrimary = kubePrimary
    )

    return render