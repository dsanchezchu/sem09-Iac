# Jenkins CI/CD con Docker y Configuration as Code

## Descripción del Proyecto

Este proyecto implementa una infraestructura de Jenkins optimizada para CI/CD usando Docker Compose. Incluye:

- **Jenkins Controller**: Servidor principal de Jenkins, configurado automáticamente con JCasC.
- **Agente Dinámico Docker-in-Docker (DinD)**: Permite la ejecución de agentes Jenkins como contenedores Docker.
- **Configuración como Código (JCasC)**: Toda la configuración de Jenkins está definida en YAML.
- **Plugins esenciales**: Instalados automáticamente desde `plugins.txt`.

## Estructura del Proyecto

```
docker-compose.yaml
Dockerfile
plugins.txt
README.md
casc_configs/
  jenkins.yaml
```

## Componentes

### Jenkins Controller

- Imagen base: `jenkins/jenkins:lts`
- Plugins preinstalados: ver [`plugins.txt`](plugins.txt)
- Configuración automática: [`casc_configs/jenkins.yaml`](casc_configs/jenkins.yaml)
- Volúmenes persistentes para datos y configuración
- Acceso al socket Docker del host para administración de contenedores

### Jenkins Agent (DinD)

- Imagen: `docker:24.0.7-dind`
- Permite la ejecución de agentes Docker aislados
- Volúmenes para certificados y datos Docker

## Requisitos

- Docker Engine >= 20.10
- Docker Compose >= 2.0
- 4GB RAM mínimo recomendado

## Instalación y Puesta en Marcha

1. **Clona el repositorio**
   ```sh
   git clone <url-del-repositorio>
   cd sem09-Iac
   ```

2. **Construye la imagen de Jenkins**
   > **Importante:** Asegúrate de usar el GID correcto del grupo `docker` de tu host (ver sección de solución de errores).
   ```sh
   DOCKER_GID=$(getent group docker | cut -d: -f3)
   docker-compose build --build-arg DOCKER_GID=$DOCKER_GID
   ```

3. **Lanza la infraestructura**
   ```sh
   docker-compose up -d
   ```

4. **Accede a Jenkins**
   - URL: http://localhost:8080
   - Usuario: `admin`
   - Contraseña: `admin` (definida en [`casc_configs/jenkins.yaml`](casc_configs/jenkins.yaml))

5. **Detén la infraestructura**
   ```sh
   docker-compose down
   ```

6. **Elimina completamente (incluyendo volúmenes)**
   ```sh
   docker-compose down -v
   ```

## Configuración y Personalización

- **Plugins adicionales:** Añádelos a [`plugins.txt`](plugins.txt).
- **Configuración Jenkins:** Modifica [`casc_configs/jenkins.yaml`](casc_configs/jenkins.yaml).
- **Credenciales:** Cambia usuario y contraseña en el mismo archivo YAML.

## Solución de Problemas

### Error: `java.lang.RuntimeException: java.net.BindException: Permission denied` en administración de Docker

Si ves este error en "Administrar Docker" de Jenkins, sigue estos pasos **(no necesitas cambiar el código del proyecto)**:

1. **Verifica los permisos del socket Docker en tu host**
   ```sh
   ls -l /var/run/docker.sock
   ```
   Debe verse así:
   ```
   srw-rw---- 1 root docker ... /var/run/docker.sock
   ```
   El grupo debe ser `docker` y los permisos `rw` para el grupo.

2. **Asegúrate de que el usuario Jenkins en el contenedor pertenece al grupo `docker` con el mismo GID que en el host**
   - Obtén el GID del grupo docker:
     ```sh
     getent group docker
     ```
     Ejemplo de salida: `docker:x:998:`
   - Si el GID es, por ejemplo, `998`, construye la imagen Jenkins así:
     ```sh
     docker-compose build --build-arg DOCKER_GID=998
     ```
   - El [`Dockerfile`](Dockerfile) ya incluye:
     ```dockerfile
     ARG DOCKER_GID=998
     USER root
     RUN groupadd -g ${DOCKER_GID} docker && usermod -aG docker jenkins
     USER jenkins
     ```

3. **Reinicia los contenedores**
   ```sh
   docker-compose down
   docker-compose up -d
   ```

4. **Si el problema persiste**
   Puedes temporalmente dar permisos más amplios al socket (no recomendado para producción):
   ```sh
   sudo chmod 666 /var/run/docker.sock
   ```

---

## Referencias

- [Jenkins](https://www.jenkins.io/)
- [Jenkins Configuration as Code](https://www.jenkins.io/projects/jcasc/)
- [Docker Plugin](https://plugins.jenkins.io/docker-plugin/)
- [Docker-in-Docker](https://hub.docker.com/_/docker)

---
