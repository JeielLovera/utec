@description('Nombre del entorno (lab, dev o prod)')
@allowed(['lab', 'dev', 'prod'])
param environmentName string = 'lab'

@description('Región de Azure para todos los recursos')
param location string = resourceGroup().location

@description('SKU de la Storage Account')
@allowed(['Standard_LRS', 'Standard_GRS', 'Standard_ZRS'])
param storageAccountSku string = 'Standard_LRS'

@description('Sufijo único para evitar conflictos de nombres (ej. nombre-del-alumno)')
param uniqueSuffix string

@description('Throughput de Cosmos DB en RU/s (400 mínimo)')
@minValue(400)
@maxValue(4000)
param cosmosThroughput int = 400

// --- Nombres de recursos ---
var storageAccountName = toLower('st${uniqueSuffix}${uniqueString(resourceGroup().id)}')
var cosmosAccountName = 'cosmos-${uniqueSuffix}-${environmentName}'
var cosmosDatabaseName = 'db-${environmentName}'
var cosmosContainerName = 'items'

var tags = {
  Environment: environmentName
  Proyecto: 'NativeIaC'
}

// =============================================================
// Storage Account — almacenamiento de objetos/ficheros
// =============================================================
resource storageAccount 'Microsoft.Storage/storageAccounts@2023-01-01' = {
  name: storageAccountName
  location: location
  tags: tags
  sku: {
    name: storageAccountSku
  }
  kind: 'StorageV2'
  properties: {
    supportsHttpsTrafficOnly: true
    minimumTlsVersion: 'TLS1_2'
    allowBlobPublicAccess: false
    accessTier: 'Hot'
  }
}

// Blob service y contenedor para ficheros
resource blobService 'Microsoft.Storage/storageAccounts/blobServices@2023-01-01' = {
  parent: storageAccount
  name: 'default'
}

resource blobContainer 'Microsoft.Storage/storageAccounts/blobServices/containers@2023-01-01' = {
  parent: blobService
  name: 'ficheros'
  properties: {
    publicAccess: 'None'
  }
}

// =============================================================
// Cosmos DB — base de datos no relacional (NoSQL)
// =============================================================
resource cosmosAccount 'Microsoft.DocumentDB/databaseAccounts@2024-02-15-preview' = {
  name: cosmosAccountName
  location: location
  tags: tags
  kind: 'GlobalDocumentDB'
  properties: {
    databaseAccountOfferType: 'Standard'
    consistencyPolicy: {
      defaultConsistencyLevel: 'Session'
    }
    locations: [
      {
        locationName: location
        failoverPriority: 0
        isZoneRedundant: false
      }
    ]
    enableFreeTier: true
    capabilities: [
      {
        name: 'EnableServerless'
      }
    ]
  }
}

resource cosmosDatabase 'Microsoft.DocumentDB/databaseAccounts/sqlDatabases@2024-02-15-preview' = {
  parent: cosmosAccount
  name: cosmosDatabaseName
  properties: {
    resource: {
      id: cosmosDatabaseName
    }
  }
}

resource cosmosContainer 'Microsoft.DocumentDB/databaseAccounts/sqlDatabases/containers@2024-02-15-preview' = {
  parent: cosmosDatabase
  name: cosmosContainerName
  properties: {
    resource: {
      id: cosmosContainerName
      partitionKey: {
        paths: ['/id']
        kind: 'Hash'
      }
      indexingPolicy: {
        indexingMode: 'consistent'
        automatic: true
      }
    }
  }
}

// =============================================================
// Outputs
// =============================================================
output storageAccountName string = storageAccount.name
output storageAccountId string = storageAccount.id
output blobContainerName string = blobContainer.name

output cosmosAccountName string = cosmosAccount.name
output cosmosAccountId string = cosmosAccount.id
output cosmosDatabaseName string = cosmosDatabase.name
output cosmosEndpoint string = cosmosAccount.properties.documentEndpoint
