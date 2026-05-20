@description('Location for all resources')
param location string = resourceGroup().location

@description('Base name used to derive resource names')
param baseName string = 'josephfunderburk-iac'

var cosmosAccountName = 'cosmos-${baseName}'
var staticWebAppName = 'swa-${baseName}'
var tableName = 'VisitorCounter'

resource cosmosAccount 'Microsoft.DocumentDB/databaseAccounts@2024-05-15' = {
  name: cosmosAccountName
  location: location
  kind: 'GlobalDocumentDB'
  properties: {
    databaseAccountOfferType: 'Standard'
    capabilities: [
      { name: 'EnableServerless' }
      { name: 'EnableTable' }
    ]
    locations: [
      {
        locationName: location
        failoverPriority: 0
      }
    ]
  }
}

resource cosmosTable 'Microsoft.DocumentDB/databaseAccounts/tables@2024-05-15' = {
  parent: cosmosAccount
  name: tableName
  properties: {
    resource: {
      id: tableName
    }
  }
}

resource staticWebApp 'Microsoft.Web/staticSites@2023-12-01' = {
  name: staticWebAppName
  location: location
  sku: {
    name: 'Free'
    tier: 'Free'
  }
  properties: {
    provider: 'None'
  }
}

output cosmosAccountName string = cosmosAccount.name
output staticWebAppName string = staticWebApp.name
output staticWebAppHostname string = staticWebApp.properties.defaultHostname