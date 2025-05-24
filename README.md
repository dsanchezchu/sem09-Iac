# Infraestructura como Código (IaC) para Jenkins con Docker Cloud

## Introducción y Propósito

Este proyecto implementa un entorno Jenkins optimizado utilizando principios de Infraestructura como Código (IaC). Proporciona una configuración automatizada y ligera de Jenkins que incluye:

- **Controlador Jenkins**: El servidor principal que gestiona los procesos CI/CD
- **Docker-in-Docker (DinD)**: Un servicio Docker que permite crear contenedores dinámicamente
- **Docker Cloud**: Integración que permite a Jenkins crear agentes dinámicamente como contenedores Docker
- **Configuración como Código**: Toda la configuración de Jenkins definida como código (JCasC)

El propósito de este proyecto es:
1. Demostrar una configuración moderna de Jenkins con agentes dinámicos
2. Proporcionar un entorno de CI/CD ligero para desarrollo y pruebas
3. Facilitar el despliegue rápido mediante código de infraestructura
4. Mostrar las mejores prácticas de configuración como código

## Componentes del Sistema

### 1. Controlador Jenkins

El Controlador Jenkins sirve como interfaz principal de gestión para el entorno CI/CD.

**Especificaciones técnicas:**
- **Imagen Base**: `jenkins/jenkins:lts` (versión LTS estable)
- **Nombre del Contenedor**: `jenkins-controller`
- **Puertos Expuestos**:
  - `8080`: Interfaz web
  - `50000`: Comunicación con agentes
- **Configuración Automatizada**: 
  - Asistente de configuración inicial omitido
  - Configuración aplicada mediante JCasC (Jenkins Configuration as Code)
- **Plugins Preinstalados**:
  - workflow-aggregator (soporte para Pipeline)
  - git (integración con Git)
  - configuration-as-code (soporte para JCasC)
  - generic-webhook-trigger (soporte para webhooks)
  - docker-plugin (integración con Docker Cloud)
- **Almacenamiento Persistente**:
  - Directorio home de Jenkins almacenado en un volumen Docker (`jenkins_home`)
  - Configuración JCasC montada desde el host
- **Monitoreo de Salud**:
  - Comprobaciones regulares de salud (cada 30s)
  - Reinicio automático en caso de fallo

### 2. Docker-in-Docker (DinD)

El servicio Docker-in-Docker permite ejecutar contenedores Docker dentro de un contenedor.

**Especificaciones técnicas:**
- **Imagen Base**: `docker:24.0.8-dind` (Docker-in-Docker)
- **Nombre del Contenedor**: `docker-dind`
- **Modo**: Privilegiado (requerido para DinD)
- **Certificados TLS**: Configurados para comunicación segura
- **Volúmenes**:
  - Certificados Docker (para autenticación segura)
  - Datos Docker (para almacenar imágenes y contenedores)

### 3. Docker Cloud

La integración con Docker Cloud permite a Jenkins crear agentes de forma dinámica como contenedores Docker.

**Especificaciones:**
- **Conexión**: A través de la API Docker en el servicio DinD
- **Plantillas de Contenedores**: Configuración predefinida para crear agentes
- **Imagen de Agente**: `jenkins/agent:latest`
- **Capacidad**: Hasta 10 instancias de agentes concurrentes
- **Estrategia de Retención**: Agentes eliminados después de 10 minutos de inactividad

### 4. Configuración como Código (JCasC)

Todo el sistema Jenkins se configura mediante archivos YAML, sin intervención manual.

**Configuración:**
- **Seguridad**: Usuario administrador y estrategia de autorización
- **Sistema**: Configuración básica del sistema Jenkins
- **Nube**: Configuración de Docker Cloud y plantillas de agentes
- **Herramientas**: Configuración de Git y otras herramientas

## Requisitos del Sistema

Para ejecutar esta infraestructura, necesitarás:

- **Docker Engine**: versión 20.10.0 o superior
- **Docker Compose**: versión 2.0.0 o superior
- **Sistema Operativo**: Linux, Windows o macOS con Docker instalado
- **Recursos Recomendados**:
  - 4GB RAM mínimo (para DinD)
  - 20GB espacio en disco
  - 2 núcleos CPU

## Instalación y Uso

### Pasos de Despliegue

1. Clona este repositorio:
   ```bash
   git clone <url-del-repositorio>
   cd sem09-Iac
   ```

2. Inicia la infraestructura Jenkins:
   ```bash
   docker-compose up -d
   ```

3. Accede a la interfaz web de Jenkins:
   - URL: http://localhost:8080
   - Usuario: `admin`
   - Contraseña: `admin` (definida en jenkins.yaml)

4. Para detener la infraestructura:
   ```bash
   docker-compose down
   ```

5. Para eliminar completamente la infraestructura incluyendo volúmenes:
   ```bash
   docker-compose down -v
   ```

### Verificación de Docker Cloud

Para verificar que Docker Cloud está configurado correctamente:
1. Inicia sesión en la interfaz web de Jenkins
2. Ve a "Administrar Jenkins" > "Administrar Nodos y Nubes" > "Configurar Nubes"
3. Deberías ver "docker" en la lista de nubes

### Creación de un Job de Prueba

Para probar la creación dinámica de agentes:
1. Crea un nuevo "Pipeline Job"
2. Usa el siguiente script de pipeline:

```groovy
pipeline {
    agent {
        label 'docker-agent'
    }
    stages {
        stage('Test') {
            steps {
                sh 'echo "Ejecutando en agente Docker dinámico"'
                sh 'hostname'
            }
        }
    }
}
```

## Estructura del Proyecto

La estructura del proyecto optimizada es la siguiente:

| Archivo/Directorio | Propósito |
|----------------|---------|
| `docker-compose.yaml` | Archivo principal de definición de infraestructura |
| `casc_configs/` | Directorio con archivos de configuración como código |
| `casc_configs/jenkins.yaml` | Configuración principal de Jenkins (JCasC) |
| `plugins.txt` | Lista de plugins a instalar en Jenkins |
| `README.md` | Documentación del proyecto (este archivo) |

### Archivos de Configuración Clave

#### 1. docker-compose.yaml

Este archivo define toda la pila de infraestructura, incluyendo el controlador Jenkins y el servicio DinD:

```yaml
services:
  jenkins-controller:
    image: jenkins/jenkins:lts
    # Configuración del controlador
  
  docker-dind:
    image: docker:24.0.8-dind
    # Configuración de Docker-in-Docker
    
volumes:
  jenkins_home:
  jenkins-docker-certs:
  jenkins-docker-data:
  
networks:
  jenkins-net:
    driver: bridge
```

#### 2. casc_configs/jenkins.yaml

Este archivo de configuración como código define toda la configuración de Jenkins:

```yaml
jenkins:
  systemMessage: "Jenkins configurado con Configuration as Code - Entorno de desarrollo"
  securityRealm:
    local:
      allowsSignup: false
      users:
        - id: "admin"
          password: "admin"
  
  clouds:
    - docker:
        name: "docker"
        # Configuración de Docker Cloud
```

#### 3. plugins.txt

Lista de plugins esenciales para Jenkins:

```
workflow-aggregator:latest
git:latest
configuration-as-code:latest
generic-webhook-trigger:latest
docker-plugin:latest
```

## Configuración y Personalización

### Cambio de Credenciales

Para cambiar las credenciales predeterminadas del administrador, modifica el archivo `casc_configs/jenkins.yaml`:

```yaml
securityRealm:
  local:
    users:
      - id: "tunombre"
        password: "tucontraseña"
```

### Añadir Plugins Adicionales

Para instalar plugins adicionales, añádelos al archivo `plugins.txt`:

```
workflow-aggregator:latest
git:latest
configuration-as-code:latest
generic-webhook-trigger:latest
docker-plugin:latest
blueocean:latest  # Plugin adicional
```

### Configuración de Plantillas de Agentes

Para modificar la configuración de los agentes Docker, edita la sección `templates` en `casc_configs/jenkins.yaml`:

```yaml
templates:
  - labelString: "docker-agent-custom"
    dockerTemplateBase:
      image: "tu-imagen-personalizada:tag"
```

## Solución de Problemas Comunes

### Docker Cloud No Se Conecta a DinD

**Problema**: Jenkins no puede conectarse al daemon Docker.

**Soluciones**:
1. Verifica que el servicio `docker-dind` está en ejecución: `docker-compose ps`
2. Revisa los logs del servicio DinD: `docker-compose logs docker-dind`
3. Asegúrate de que la URI en la configuración de Docker Cloud sea correcta (tcp://docker-dind:2376)

### Error al Crear Agentes Dinámicos

**Problema**: Los agentes no se crean o fallan al iniciar.

**Solución**:
1. Revisa los logs de Jenkins para ver errores específicos
2. Verifica que la imagen del agente especificada en `jenkins.yaml` exista y sea accesible
3. Comprueba la configuración de red entre Jenkins y DinD

### Jenkins No Inicia Correctamente

**Problema**: El controlador Jenkins no arranca o muestra errores en el inicio.

**Soluciones**:
1. Revisa los logs del controlador: `docker-compose logs jenkins-controller`
2. Verifica que el archivo `jenkins.yaml` tenga una sintaxis YAML válida
3. Intenta reiniciar el servicio: `docker-compose restart jenkins-controller`

### Problemas con JCasC

**Problema**: La configuración como código no se aplica correctamente.

**Solución**:
1. Verifica que la variable de entorno `CASC_JENKINS_CONFIG` esté correctamente configurada
2. Revisa los logs de Jenkins en busca de errores relacionados con JCasC
3. Asegúrate de que el plugin `configuration-as-code` esté instalado

## Referencias y Recursos

- [Documentación de Jenkins](https://www.jenkins.io/doc/)
- [Jenkins Configuration as Code](https://www.jenkins.io/projects/jcasc/)
- [Docker Plugin para Jenkins](https://plugins.jenkins.io/docker-plugin/)
- [Docker-in-Docker (DinD)](https://hub.docker.com/_/docker)
- [Imágenes Docker de Jenkins](https://github.com/jenkinsci/docker)

## Licencia

Este proyecto está licenciado bajo la Licencia MIT - ver el archivo LICENSE para más detalles.
