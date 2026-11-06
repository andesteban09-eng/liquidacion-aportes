# Liquidación de Aportes

Aplicación móvil desarrollada con **Flutter y Dart**, conectada a una API REST construida con **Node.js y Express**, que utiliza **PostgreSQL** para calcular, registrar y consultar liquidaciones de aportes al sistema de seguridad social.

El proyecto implementa una arquitectura cliente-servidor: Flutter gestiona la interfaz y las solicitudes HTTP, mientras que Express procesa los cálculos y administra la persistencia de la información en PostgreSQL.

## Características principales

- Cálculo de aportes a salud, pensión y riesgos laborales (ARL).
- Selección del nivel de riesgo ARL mediante tarifas consultadas desde la base de datos.
- Validación del sueldo ingresado.
- Aplicación de un ingreso base de cotización (IBC) mínimo definido en la lógica del proyecto.
- Registro de liquidaciones en PostgreSQL.
- Consulta del historial de liquidaciones.
- Visualización del detalle de cada liquidación.
- Formateo de valores monetarios en pesos colombianos (COP).

## Tecnologías utilizadas

| Componente | Tecnologías |
|---|---|
| Aplicación móvil | Flutter, Dart |
| Comunicación | HTTP, JSON |
| Backend | Node.js, Express |
| Base de datos | PostgreSQL |
| Acceso a datos | node-postgres (`pg`) |
| Variables de entorno | dotenv |

### Dependencias principales

**Frontend**
- `http`: comunicación con la API REST.
- `intl`: formato de fechas y valores monetarios.

**Backend**
- `express`: creación y administración de rutas HTTP.
- `pg`: conexión y consultas a PostgreSQL.
- `dotenv`: gestión de variables de entorno.

## Arquitectura del proyecto

La aplicación sigue una arquitectura cliente-servidor en tres componentes:

1. **Frontend (Flutter):** recibe los datos del usuario, realiza validaciones de entrada, consume los endpoints y presenta los resultados.
2. **Backend (Express):** recibe las solicitudes HTTP, ejecuta la lógica de cálculo y realiza las operaciones sobre la base de datos.
3. **Base de datos (PostgreSQL):** almacena las tarifas ARL y las liquidaciones registradas.

Flujo general:

```text
┌──────────────────────────────┐
│       Flutter / Dart         │
│                              │
│  - Calcular aportes          │
│  - Consultar historial       │
│  - Ver detalle               │
└──────────────┬───────────────┘
               │
               │ HTTP / JSON
               ▼
┌──────────────────────────────┐
│       Node.js / Express      │
│                              │
│  - API REST                  │
│  - Validaciones              │
│  - Lógica de cálculo         │
│  - Consultas SQL             │
└──────────────┬───────────────┘
               │
               │ node-postgres
               ▼
┌──────────────────────────────┐
│          PostgreSQL          │
│                              │
│  - liquidacion               │
│  - tarifaArl                 │
└──────────────────────────────┘
```

## Reglas de cálculo

El backend recibe el sueldo mensual y el identificador de la tarifa ARL seleccionada. A partir de estos datos realiza los siguientes cálculos:

| Concepto | Regla implementada |
|---|---|
| IBC | 40 % del sueldo mensual |
| IBC mínimo | $1.750.000 COP |
| Salud | 12,5 % del IBC |
| Pensión | 16 % del IBC |
| ARL | IBC multiplicado por el porcentaje de la tarifa seleccionada |
| Total | Salud + Pensión + ARL |

El IBC utilizado corresponde al 40 % del sueldo, siempre que no sea inferior al mínimo definido en el código.

### Tarifas ARL

Las siguientes tarifas se insertan inicialmente mediante el script SQL:

| Nivel de riesgo | Porcentaje |
|---|---:|
| I | 0,522 % |
| II | 1,044 % |
| III | 2,436 % |
| IV | 4,350 % |
| V | 6,960 % |

Los porcentajes se almacenan en formato decimal en PostgreSQL.

> **Nota:** los porcentajes y el IBC mínimo corresponden a los parámetros implementados para este ejercicio académico. No deben interpretarse como una calculadora de cumplimiento normativo ni como asesoría legal o financiera.

## Modelo de datos

La base de datos utiliza dos tablas relacionadas:

### Tabla `tarifaArl`

Almacena los niveles de riesgo y sus porcentajes correspondientes.

| Campo | Descripción |
|---|---|
| id | Identificador único (PK) |
| nivelArl | Nivel de riesgo |
| porcentaje | Porcentaje de cotización |
| descripcion | Descripción opcional |

### Tabla `liquidacion`

Almacena los resultados de las liquidaciones realizadas.

| Campo | Descripción |
|---|---|
| id | Identificador único (PK) |
| ibc | Ingreso base de cotización |
| salud | Aporte a salud |
| pension | Aporte a pensión |
| arl | Aporte a riesgos laborales |
| total | Total de aportes |
| descripcion | Descripción opcional |
| fecha_creacion | Fecha de registro |
| tarifaArl_id | Referencia a la tarifa ARL (FK) |

### Relación

Una tarifa ARL puede estar asociada a múltiples liquidaciones. Cada liquidación registrada referencia una tarifa mediante la clave foránea `tarifaArl_id`.

## API REST

La API se ejecuta por defecto en el puerto `3000`.

| Método | Endpoint | Descripción |
|---|---|---|
| GET | `/arl` | Consulta los niveles y tarifas ARL. |
| POST | `/liquidaciones` | Calcula y registra una liquidación. |
| GET | `/liquidaciones` | Consulta el historial de liquidaciones. |
| GET | `/liquidaciones/:id` | Consulta una liquidación específica. |

### Crear una liquidación

**POST** `/liquidaciones`

Cuerpo de la solicitud:

```json
{
  "sueldo": 3000000,
  "tarifaArl_id": 1
}
```

El backend calcula los aportes, consulta el porcentaje ARL correspondiente y almacena el resultado en PostgreSQL.

Respuesta exitosa: `201 Created`.

### Consultar tarifas ARL

**GET** `/arl`

Devuelve los registros disponibles en la tabla `tarifaArl`.

### Consultar historial

**GET** `/liquidaciones`

Devuelve las liquidaciones registradas, incluyendo el nivel y el porcentaje de riesgo ARL asociados.

Los resultados se ordenan por fecha de creación descendente.

### Consultar detalle

**GET** `/liquidaciones/:id`

Devuelve la información de una liquidación específica junto con los datos de su tarifa ARL.

Si el registro no existe, responde con `404 Not Found`.

## Estructura del repositorio

```text
liquidacion-aportes/
│
├── .github/
├── .gitignore
│
├── backend/
│   ├── db-script/
│   │   └── script_liquidacion.sql
│   ├── img/
│   ├── public/
│   ├── .env.example
│   ├── app.js
│   ├── conexion.js
│   ├── package.json
│   └── package-lock.json
│
└── frontend/
    ├── lib/
    │   ├── models/
    │   ├── screens/
    │   └── services/
    ├── android/
    ├── ios/
    ├── web/
    ├── windows/
    ├── pubspec.yaml
    └── pubspec.lock
```

## Instalación y ejecución

### Requisitos previos

- Git.
- Node.js y npm.
- PostgreSQL.
- Flutter SDK y Dart.
- Un emulador Android o dispositivo compatible para ejecutar la aplicación.

### 1. Clonar el repositorio

```bash
git clone https://github.com/andesteban09-eng/liquidacion-aportes.git
cd liquidacion-aportes
```

### 2. Configurar la base de datos

Crear una base de datos PostgreSQL llamada:

```sql
CREATE DATABASE dbLiquidacion;
```

Desde la raíz del repositorio, ejecutar el script SQL:

```powershell
psql -h localhost -p 5432 -U postgres -d dbLiquidacion -f ".\backend\db-script\script_liquidacion.sql"
```

El script crea las tablas, establece la relación entre ellas y registra las cinco tarifas ARL iniciales.

### 3. Configurar y ejecutar el backend

Ingresar al directorio:

```bash
cd backend
```

Instalar las dependencias:

```bash
npm install
```

Crear el archivo `.env` a partir del ejemplo:

```powershell
Copy-Item .env.example .env
```

Configurar las credenciales de conexión a PostgreSQL:

```env
DB_USER=postgres
DB_HOST=localhost
DB_DATABASE=dbLiquidacion
DB_PASSWORD=tu_contraseña
DB_PORT=5432
```

Iniciar el servidor:

```bash
npm start
```

El backend estará disponible en:

```text
http://localhost:3000
```

### 4. Configurar y ejecutar Flutter

Desde la raíz del repositorio:

```bash
cd frontend
```

Obtener las dependencias:

```bash
flutter pub get
```

Ejecutar la aplicación:

```bash
flutter run
```

### Configuración de conexión desde Android

La aplicación utiliza actualmente:

```text
http://10.0.2.2:3000
```

Esta dirección permite que el emulador Android acceda al servidor que se ejecuta en el equipo anfitrión.

Si se utiliza un dispositivo físico, será necesario reemplazar esa dirección por la dirección IP local del equipo donde se ejecuta el backend y permitir las conexiones de red correspondientes.

## Consideraciones

- El archivo `.env` contiene credenciales locales y no debe publicarse en el repositorio.
- El archivo `.env.example` proporciona la estructura de las variables necesarias para configurar el backend.
- Las carpetas de dependencias y los archivos generados por Flutter se excluyen mediante `.gitignore`.
- El proyecto tiene fines académicos y demostrativos; no está diseñado para sustituir herramientas oficiales de liquidación ni para realizar cálculos normativos certificados.

## Autor

**Andersson Peña**

Desarrollado como proyecto práctico para fortalecer conocimientos en desarrollo de aplicaciones móviles, construcción de API REST, integración de sistemas y gestión de bases de datos relacionales.

---

**Repositorio:** [andesteban09-eng/liquidacion-aportes](https://github.com/andesteban09-eng/liquidacion-aportes)