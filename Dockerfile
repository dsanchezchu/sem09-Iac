FROM jenkins/jenkins:lts

ENV JAVA_OPTS -Djenkins.install.runSetupWizard=false
ENV CASC_JENKINS_CONFIG /var/jenkins_home/casc_configs

# Plugins necesarios
RUN jenkins-plugin-cli --plugins \
  workflow-aggregator:latest \
  git:latest \
  configuration-as-code:latest \
  generic-webhook-trigger:latest \
  docker-plugin:latest

# Credenciales de admin
ENV JENKINS_ADMIN_ID admin
ENV JENKINS_ADMIN_PASSWORD admin


HEALTHCHECK --interval=30s --timeout=10s --retries=3 \
  CMD curl -sSf http://localhost:8080/login || exit 1

# Docker group configuration
ARG DOCKER_GID=998
USER root
RUN groupadd -g ${DOCKER_GID} docker && usermod -aG docker jenkins
USER jenkins