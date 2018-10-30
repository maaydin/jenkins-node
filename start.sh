#!/bin/bash
set -e
export HTTP_PROXY=${http_proxy}
export HTTPS_PROXY=${https_proxy}

curl -v -o /opt/jenkins/slave.jar ${url}jnlpJars/slave.jar
java -jar /opt/jenkins/slave.jar -jnlpUrl ${url}computer/${node}/slave-agent.jnlp -secret ${secret}