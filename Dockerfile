FROM jenkins/jenkins:lts

USER root

RUN apt-get update && \
    apt-get install -y make gcc && \
    apt-get clean

USER jenkins
