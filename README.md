# El Principito - Sistema de Papelería e Impresiones

![Flutter](https://img.shields.io/badge/Flutter-3.x-blue)
![Firebase](https://img.shields.io/badge/Firebase-Backend-orange)
![Dart](https://img.shields.io/badge/Dart-Language-blue)
![Status](https://img.shields.io/badge/Status-En%20desarrollo-yellow)

Proyecto multiplataforma desarrollado con Flutter y Firebase orientado a la administración y gestión de una papelería.

## Descripción del proyecto

El Principito es una aplicación desarrollada utilizando Flutter como tecnología principal y Firebase como plataforma de servicios en la nube. El proyecto surge con el objetivo de modernizar y facilitar la administración interna de una papelería mediante una solución digital multiplataforma.

El sistema permite gestionar distintas áreas del negocio, incluyendo productos, servicios de impresión, movimientos internos y autenticación de usuarios. Además, se busca ofrecer una interfaz intuitiva, moderna y adaptable tanto para dispositivos móviles como para entornos web.

La aplicación fue diseñada bajo un enfoque responsivo, permitiendo que la experiencia de usuario se adapte automáticamente dependiendo del tamaño de pantalla del dispositivo.

Actualmente el sistema se encuentra en desarrollo activo, incorporando módulos administrativos y funcionalidades enfocadas en mejorar la organización y control operativo de la papelería.

---

# Justificación del proyecto

En muchos pequeños negocios, la administración diaria continúa realizándose de manera manual o mediante herramientas poco integradas, lo que dificulta el control de productos, servicios y movimientos.

El proyecto “El Principito” busca solucionar esta problemática mediante una plataforma centralizada que permita digitalizar procesos importantes dentro de la papelería, mejorando la organización, reduciendo errores y facilitando el acceso a la información.

Además, el uso de tecnologías modernas como Flutter y Firebase permite contar con un sistema escalable, accesible y adaptable a futuras necesidades del negocio.

---

# Objetivos del proyecto

## Objetivo general

Desarrollar un sistema multiplataforma para la gestión de una papelería que permita administrar productos, servicios de impresión, movimientos y usuarios de manera eficiente.

## Objetivos específicos

* Implementar autenticación de usuarios mediante Firebase Authentication.
* Gestionar productos y servicios mediante operaciones CRUD.
* Permitir la administración de archivos e impresiones.
* Registrar movimientos y actividades dentro del sistema.
* Crear una interfaz moderna, adaptable y fácil de usar.
* Integrar servicios en la nube utilizando Firebase.

---

# Tecnologías utilizadas

## Flutter

Framework de desarrollo multiplataforma creado por Google. Se utilizó para construir toda la interfaz visual y la lógica de navegación de la aplicación.

Flutter permite desarrollar una sola base de código compatible con Android, web y otras plataformas, facilitando el mantenimiento y escalabilidad del sistema.

## Dart

Lenguaje de programación utilizado para el desarrollo de toda la lógica de la aplicación.

## Firebase

Plataforma de servicios en la nube desarrollada por Google utilizada como backend principal del sistema.

Firebase proporciona herramientas para autenticación, almacenamiento de datos, analítica y futuras integraciones en tiempo real.

### Firebase Authentication

Utilizado para el inicio de sesión y registro de usuarios.

### Cloud Firestore

Base de datos NoSQL utilizada para almacenar información de usuarios, productos y movimientos.

### Firebase Analytics

Herramienta utilizada para el monitoreo y análisis del comportamiento de la aplicación.

---

# Dependencias utilizadas

| Dependencia        | Función                                  |
| ------------------ | ---------------------------------------- |
| flutter            | Framework principal                      |
| cupertino_icons    | Iconos estilo iOS                        |
| sqflite            | Base de datos SQLite local               |
| path               | Manejo de rutas y directorios            |
| image_picker       | Selección de imágenes desde dispositivo  |
| url_launcher       | Apertura de enlaces externos             |
| printing           | Servicios de impresión                   |
| pdf                | Generación de archivos PDF               |
| file_picker        | Selección de archivos                    |
| pdfx               | Visualización de documentos PDF          |
| firebase_core      | Inicialización de Firebase               |
| firebase_auth      | Autenticación de usuarios                |
| cloud_firestore    | Base de datos en la nube                 |
| shared_preferences | Almacenamiento local de preferencias     |
| device_info_plus   | Obtención de información del dispositivo |
| open_filex         | Apertura de archivos en el dispositivo   |
| path_provider      | Acceso a directorios del sistema         |
| permission_handler | Manejo de permisos                       |
| firebase_analytics | Análisis y métricas de uso               |

---

# Arquitectura del sistema

La arquitectura del proyecto está basada en una estructura modular, separando cada sección funcional en diferentes archivos y componentes para facilitar el mantenimiento y escalabilidad del sistema.

Cada módulo tiene responsabilidades específicas dentro de la aplicación, permitiendo una organización más clara del código y una mejor administración de funcionalidades.

La comunicación entre la aplicación y Firebase se realiza mediante los SDK oficiales de FlutterFire.

El sistema está dividido en distintos módulos funcionales:

## Inicio de sesión

Módulo encargado de autenticar usuarios mediante correo electrónico y contraseña.

## Gestión de productos

Permite registrar, editar, eliminar y visualizar productos disponibles en la papelería.

## Impresiones

Módulo orientado al manejo de archivos PDF e imágenes para impresión.

## Trámites

Sección destinada al manejo de servicios adicionales ofrecidos por la papelería.

## Movimientos

Registro histórico de acciones realizadas dentro del sistema.

---

# Roles de usuario

El sistema contempla tres tipos principales de usuario:

## Jefa

Cuenta con acceso total al sistema y permisos administrativos.

## Trabajador

Puede gestionar productos, impresiones y movimientos.

## Cliente

Puede acceder a funcionalidades limitadas relacionadas con servicios e impresiones.

---

# Base de datos

La aplicación utiliza Cloud Firestore como base de datos principal.

## Colecciones principales

```plaintext
usuarios/
productos/
movimientos/
tramites/
```

## Ejemplo de documento de usuario

```json
{
  "email": "usuario@correo.com",
  "rol": "cliente"
}
```

---

# Requisitos funcionales principales

El sistema contempla funcionalidades básicas y administrativas necesarias para la operación de la papelería.

## Funciones principales

* Inicio de sesión de usuarios.
* Registro de clientes.
* Gestión de productos.
* Manejo de archivos e impresiones.
* Navegación entre módulos.
* Registro de movimientos.
* Administración de servicios.
* Persistencia de datos en la nube.

---

# Configuración del entorno

## Requisitos

* Flutter SDK
* Dart SDK
* Android Studio o Visual Studio Code
* Firebase CLI
* Cuenta de Firebase

---

# Instalación del proyecto

## 1. Clonar repositorio

```bash
git clone <url-del-repositorio>
```

## 2. Entrar al proyecto

```bash
cd principito
```

## 3. Instalar dependencias

```bash
flutter pub get
```

## 4. Ejecutar aplicación

```bash
flutter run
```

---

# Configuración de Firebase

## Inicializar Firebase

La aplicación utiliza `firebase_core` para inicializar Firebase.

## Generar configuración

Se utilizó FlutterFire CLI para generar el archivo:

```plaintext
firebase_options.dart
```

## Comando utilizado

```bash
dart pub global activate flutterfire_cli
flutterfire configure
```

---

# Funcionalidades implementadas

* Inicio de sesión con Firebase.
* Registro de usuarios.
* Navegación mediante pestañas.
* Diseño responsivo.
* Gestión de productos.
* Manejo de archivos PDF.
* Selección y apertura de archivos.
* Almacenamiento en la nube.
* Persistencia local.

---

# Diseño de interfaz

La interfaz fue diseñada tomando en cuenta principios de usabilidad y accesibilidad visual, utilizando una paleta de colores personalizada relacionada con la identidad visual del negocio.

Se implementó una navegación sencilla basada en pestañas y componentes reutilizables para mantener consistencia visual dentro de toda la aplicación.

La aplicación utiliza Material Design y componentes adaptables para dispositivos móviles y web.

Se implementaron:

* Layout responsivo.
* Encabezados personalizados.
* Navegación por pestañas.
* Interfaces dinámicas.
* Fondos personalizados mediante CustomPainter.

---

# Metodología de desarrollo

Para el desarrollo del proyecto se trabajó utilizando control de versiones mediante Git y GitHub, permitiendo el trabajo colaborativo entre ramas y la integración progresiva de funcionalidades.

El proyecto se desarrolla de manera incremental, agregando y probando módulos conforme avanza el sistema.

---

# Estado actual del proyecto

Actualmente el sistema cuenta con:

* Integración con Firebase.
* Sistema de autenticación.
* Estructura de navegación.
* Base de datos en Firestore.
* Módulos principales en desarrollo.
* Diseño visual funcional.

---

# Seguridad y autenticación

El sistema utiliza Firebase Authentication para validar usuarios mediante correo electrónico y contraseña.

Además, se contempla el manejo de roles para restringir funcionalidades dependiendo del tipo de usuario autenticado.

Roles considerados:

* Jefa
* Trabajador
* Cliente

Esto permitirá implementar permisos específicos y mayor control administrativo.

---

# Autores

Proyecto desarrollado para la administración de la papelería “El Principito” por alumnos del Tecnológico de Tepic.

Desarrollado utilizando Flutter y Firebase.
