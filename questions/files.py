import yaml

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