# ☁️ Azure — Storage Account + Cosmos DB con Bicep

**Ejercicio:** Propuesto 02  
**Herramienta:** Azure Bicep  
**Recursos:** Storage Account (Blob), Cosmos DB (NoSQL)

---

## 🎯 Objetivo

Desplegar almacenamiento de objetos y una base de datos no relacional en Azure usando Bicep. Al finalizar habrás creado:

- ✅ Una **Storage Account** con un contenedor Blob para ficheros
- ✅ Una cuenta **Cosmos DB** (API SQL/NoSQL) en modo serverless con una base de datos y un contenedor

---

## 📁 Archivos

| Archivo | Descripción |
|---------|-------------|
| `main.bicep` | Plantilla Bicep principal |
| `main.bicepparam` | Parámetros del despliegue |

---

## 🚀 Despliegue

### 1 — Verificar el Resource Group

```bash
az group show --name <tu-resource-group>
```

### 2 — Editar parámetros

Reemplaza `<student_name>` en `main.bicepparam` con tu nombre único.

### 3 — Validar

```bash
az deployment group validate \
  --resource-group <tu-resource-group> \
  --template-file main.bicep \
  --parameters @main.bicepparam
```

### 4 — Previsualizar

```bash
az deployment group what-if \
  --resource-group <tu-resource-group> \
  --template-file main.bicep \
  --parameters @main.bicepparam
```

### 5 — Desplegar

```bash
az deployment group create \
  --name deploy-bicep-storage-cosmos \
  --resource-group <tu-resource-group> \
  --template-file main.bicep \
  --parameters @main.bicepparam
```

### 6 — Ver outputs

```bash
az deployment group show \
  --name deploy-bicep-storage-cosmos \
  --resource-group <tu-resource-group> \
  --query properties.outputs \
  --output table
```

---

## ✅ Verificación

```bash
# Listar recursos del Resource Group
az resource list \
  --resource-group <tu-resource-group> \
  --query '[*].{Nombre:name,Tipo:type}' \
  --output table

# Verificar Storage Account
az storage account show \
  --resource-group <tu-resource-group> \
  --name <nombre-storage> \
  --query '{Nombre:name,SKU:sku.name,Estado:provisioningState}'

# Verificar Cosmos DB
az cosmosdb show \
  --resource-group <tu-resource-group> \
  --name <nombre-cosmos> \
  --query '{Nombre:name,Endpoint:documentEndpoint,Estado:provisioningState}'
```

---

## 🧹 Limpieza

```bash
az deployment group delete \
  --name deploy-bicep-storage-cosmos \
  --resource-group <tu-resource-group>
```

---

## 🔍 Conceptos Clave

| Concepto | Descripción |
|----------|-------------|
| `parent` | Relación jerárquica entre recursos en Bicep (ej. blobService dentro de storageAccount) |
| Cosmos DB serverless | Modo de facturación por operación, ideal para cargas variables o laboratorios |
| Partition key | Campo usado para distribuir datos en Cosmos DB, aquí `/id` |
| `uniqueString()` | Genera un hash determinista basado en el Resource Group para nombres únicos |
| Free Tier | Cosmos DB ofrece un nivel gratuito (1 cuenta por suscripción) |

> ⚠️ Cosmos DB Free Tier solo está disponible en una cuenta por suscripción. Si ya tienes una cuenta con Free Tier activo, cambia `enableFreeTier` a `false` en `main.bicep`.
