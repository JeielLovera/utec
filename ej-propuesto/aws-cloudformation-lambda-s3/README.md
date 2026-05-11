# ☁️ AWS — Lambda + S3 con CloudFormation

**Ejercicio:** Propuesto 02  
**Herramienta:** AWS CloudFormation  
**Recursos:** AWS Lambda, Amazon S3, IAM Role

---

## 🎯 Objetivo

Aprovisionar una función Lambda con acceso a un bucket S3 usando CloudFormation. Al finalizar habrás creado:

- ✅ Un **bucket S3** con versionado habilitado y acceso público bloqueado
- ✅ Un **IAM Role** con permisos mínimos para que Lambda acceda al bucket
- ✅ Una **función Lambda** (Python 3.12) que puede listar y escribir objetos en S3

---

## 📁 Archivos

| Archivo | Descripción |
|---------|-------------|
| `template.yaml` | Plantilla CloudFormation principal |
| `parameters.json` | Parámetros del despliegue |

---

## 🚀 Despliegue

### 1 — Editar parámetros

Reemplaza `<student_name>` en `parameters.json` con tu nombre único:

```json
{
  "ParameterKey": "UniqueSuffix",
  "ParameterValue": "tu-nombre"
}
```

### 2 — Validar

```bash
aws cloudformation validate-template \
  --template-body file://template.yaml \
  --region us-west-2
```

### 3 — Previsualizar

```bash
aws cloudformation create-change-set \
  --stack-name lab-lambda-s3-tu-nombre \
  --change-set-name preview-inicial \
  --template-body file://template.yaml \
  --parameters file://parameters.json \
  --capabilities CAPABILITY_NAMED_IAM \
  --change-set-type CREATE \
  --region us-west-2

aws cloudformation describe-change-set \
  --stack-name lab-lambda-s3-tu-nombre \
  --change-set-name preview-inicial \
  --query 'Changes[*].ResourceChange.{Accion:Action,Tipo:ResourceType,ID:LogicalResourceId}' \
  --output table \
  --region us-west-2
```

### 4 — Desplegar

```bash
aws cloudformation create-stack \
  --stack-name lab-lambda-s3-tu-nombre \
  --template-body file://template.yaml \
  --parameters file://parameters.json \
  --capabilities CAPABILITY_NAMED_IAM \
  --region us-west-2
```

### 5 — Monitorear

```bash
aws cloudformation wait stack-create-complete \
  --stack-name lab-lambda-s3-tu-nombre \
  --region us-west-2

aws cloudformation describe-stacks \
  --stack-name lab-lambda-s3-tu-nombre \
  --query 'Stacks[0].Outputs[*].{Clave:OutputKey,Valor:OutputValue}' \
  --output table \
  --region us-west-2
```

---

## ✅ Verificación

```bash
# Verificar el bucket S3
aws s3 ls | grep lab-lambda-s3

# Invocar la Lambda con acción "list"
aws lambda invoke \
  --function-name lab-lambda-tu-nombre \
  --payload '{"action": "list"}' \
  --cli-binary-format raw-in-base64-out \
  response.json \
  --region us-west-2

cat response.json

# Invocar la Lambda para escribir un objeto en S3
aws lambda invoke \
  --function-name lab-lambda-tu-nombre \
  --payload '{"action": "write", "key": "prueba.txt", "content": "Hola desde Lambda!"}' \
  --cli-binary-format raw-in-base64-out \
  response.json \
  --region us-west-2

cat response.json
```

---

## 🧹 Limpieza

```bash
# Vaciar el bucket antes de eliminar el stack
aws s3 rm s3://lab-lambda-s3-tu-nombre-<account-id>-us-west-2 --recursive

# Eliminar el stack
aws cloudformation delete-stack \
  --stack-name lab-lambda-s3-tu-nombre \
  --region us-west-2

aws cloudformation wait stack-delete-complete \
  --stack-name lab-lambda-s3-tu-nombre \
  --region us-west-2
```

> ⚠️ El bucket S3 debe estar vacío antes de eliminar el stack.

---

## 🔍 Conceptos Clave

| Concepto | Descripción |
|----------|-------------|
| `CAPABILITY_NAMED_IAM` | Requerido cuando la plantilla crea recursos IAM con nombres explícitos |
| `ZipFile` | Permite incluir código Lambda inline en la plantilla (hasta 4KB) |
| `!GetAtt` | Obtiene un atributo de un recurso (ej. ARN del bucket) |
| `!Sub` | Interpolación de strings con variables y referencias |
| Principio de mínimo privilegio | El IAM Role solo otorga los permisos S3 necesarios |
