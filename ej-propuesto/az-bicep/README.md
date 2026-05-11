# ☁️ Azure — Storage Account + Key Vault con Bicep

**Ejercicio:** Propuesto 02  
**Herramienta:** Azure Bicep  
**Recursos:** Storage Account (Blob), Key Vault

---

## 🎯 Objetivo

Desplegar almacenamiento de objetos y un gestor de secretos en Azure usando Bicep. Al finalizar habrás creado:

- ✅ Una **Storage Account** con un contenedor Blob para ficheros
- ✅ Un **Key Vault** para gestión segura de secretos, claves y certificados

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
  --name deploy-bicep-storage-kv \
  --resource-group <tu-resource-group> \
  --template-file main.bicep \
  --parameters @main.bicepparam
```

### 6 — Ver outputs

```bash
az deployment group show \
  --name deploy-bicep-storage-kv \
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

# Verificar Key Vault
az keyvault show \
  --resource-group <tu-resource-group> \
  --name <nombre-keyvault> \
  --query '{Nombre:name,URI:properties.vaultUri,Estado:properties.provisioningState}'
```

---

## 🧹 Limpieza

```bash
az deployment group delete \
  --name deploy-bicep-storage-kv \
  --resource-group <tu-resource-group>
```

---

## 🔍 Conceptos Clave

| Concepto | Descripción |
|----------|-------------|
| `parent` | Relación jerárquica entre recursos en Bicep (ej. blobService dentro de storageAccount) |
| `enableRbacAuthorization` | Controla el acceso al Key Vault mediante roles de Azure AD en lugar de access policies |
| `enableSoftDelete` | Protege contra eliminaciones accidentales, con retención de 7 días |
| `uniqueString()` | Genera un hash determinista basado en el Resource Group para nombres únicos |
| `subscription().tenantId` | Referencia dinámica al tenant de la suscripción activa |
