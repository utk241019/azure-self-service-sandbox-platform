targetScope = 'resourceGroup'

@description('Sandbox environment name')
param sandboxName string

@description('Azure region')
param location string = resourceGroup().location

@description('Administrator username')
param adminUsername string

@secure()
@description('Administrator password')
param adminPassword string

//------------------------------------------------
// Storage Account
//------------------------------------------------

resource storageAccount 'Microsoft.Storage/storageAccounts@2023-01-01' = {
  name: '${sandboxName}storageutk'

  location: location

  sku: {
    name: 'Standard_LRS'
  }

  kind: 'StorageV2'

  properties: {}
}

//------------------------------------------------
// Virtual Network
//------------------------------------------------

resource vnet 'Microsoft.Network/virtualNetworks@2023-05-01' = {
  name: '${sandboxName}-vnet'

  location: location

  properties: {
    addressSpace: {
      addressPrefixes: [
        '10.0.0.0/16'
      ]
    }

    subnets: [
      {
        name: 'default'

        properties: {
          addressPrefix: '10.0.1.0/24'
        }
      }
    ]
  }
}

//------------------------------------------------
// Network Security Group
//------------------------------------------------

resource nsg 'Microsoft.Network/networkSecurityGroups@2023-05-01' = {
  name: '${sandboxName}-nsg'

  location: location

  properties: {
    securityRules: [
      {
        name: 'SSH'

        properties: {
          priority: 100

          protocol: 'Tcp'

          access: 'Allow'

          direction: 'Inbound'

          sourceAddressPrefix: '*'

          sourcePortRange: '*'

          destinationAddressPrefix: '*'

          destinationPortRange: '22'
        }
      }
    ]
  }
}

//------------------------------------------------
// Public IP
//------------------------------------------------

resource publicIP 'Microsoft.Network/publicIPAddresses@2023-05-01' = {
  name: '${sandboxName}-pip'

  location: location

  sku: {
    name: 'Standard'
  }

  properties: {
    publicIPAllocationMethod: 'Static'
  }
}

//------------------------------------------------
// Network Interface
//------------------------------------------------

resource nic 'Microsoft.Network/networkInterfaces@2023-05-01' = {
  name: '${sandboxName}-nic'

  location: location

  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig1'

        properties: {
          privateIPAllocationMethod: 'Dynamic'

          subnet: {
            id: vnet.properties.subnets[0].id
          }

          publicIPAddress: {
            id: publicIP.id
          }
        }
      }
    ]

    networkSecurityGroup: {
      id: nsg.id
    }
  }
}

//------------------------------------------------
// Virtual Machine
//------------------------------------------------

resource vm 'Microsoft.Compute/virtualMachines@2024-03-01' = {
  name: '${sandboxName}-vm'

  location: location

  properties: {
    hardwareProfile: {
      vmSize: 'Standard_B2ts_v2'
    }

    osProfile: {
      computerName: sandboxName

      adminUsername: adminUsername

      adminPassword: adminPassword

      linuxConfiguration: {
        disablePasswordAuthentication: false
      }
    }

    storageProfile: {
      imageReference: {
        publisher: 'Canonical'

        offer: '0001-com-ubuntu-server-jammy'

        sku: '22_04-lts'

        version: 'latest'
      }

      osDisk: {
        createOption: 'FromImage'

        managedDisk: {
          storageAccountType: 'Standard_LRS'
        }
      }
    }

    networkProfile: {
      networkInterfaces: [
        {
          id: nic.id
        }
      ]
    }
  }
}

//------------------------------------------------
// Outputs
//------------------------------------------------

output vmName string = vm.name

output storageAccount string = storageAccount.name
