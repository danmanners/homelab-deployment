import os
import yaml
from jinja2 import FileSystemLoader, Template, Environment

# Jinja Template Information
file_loader = FileSystemLoader("{}/setup/templates".format(os.getcwd()))
jinjaLoader = Environment(loader=file_loader)

def createK8sOutputFile(listOfThings,listOfCerts,fileName,inventoryFileName,inventoryFile):
    with open(fileName, 'w') as file:
        yaml.dump(listOfThings, file, explicit_start=True)

    with open(fileName, 'a') as file:
        certs       = yaml.dump(listOfCerts, default_style='|')
        edit1       = certs.replace(': \'', ': |\n  ', len(listOfCerts.keys())).replace('"','')
        file.write(edit1)

    print("Created {}.".format(fileName.rsplit('/', 1)[1]))

    with open(inventoryFileName, 'w') as file:
        file.writelines(inventoryFile)

    print("Created {}.".format(inventoryFileName.rsplit('/', 1)[1]))

def createBoltFile(templateName, outputFileName, **kwargs):
    # Load Template
    template = jinjaLoader.get_template(templateName)
    render = template.render(kwargs)

    # Write Template to Filename
    with open(outputFileName, 'w') as file:
        file.writelines(render)

    # Output Created Filename
    print("Created {}.".format(outputFileName.rsplit('/', 1)[1]))