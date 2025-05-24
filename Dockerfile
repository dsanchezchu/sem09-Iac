FROM jenkins/jenkins:lts

# Skip initial setup
ENV JAVA_OPTS -Djenkins.install.runSetupWizard=false
ENV CASC_JENKINS_CONFIG /var/jenkins_home/casc_configs

# Install required plugins
RUN jenkins-plugin-cli --plugins \
    workflow-aggregator:latest \
    git:latest \
    configuration-as-code:latest \
    generic-webhook-trigger:latest \
    docker-plugin:latest

# Set up admin user credentials
ENV JENKINS_ADMIN_ID admin
ENV JENKINS_ADMIN_PASSWORD admin

# Healthcheck
HEALTHCHECK --interval=30s --timeout=10s --retries=3 \
  CMD curl -sSf http://localhost:8080/login || exit 1

USER jenkins

