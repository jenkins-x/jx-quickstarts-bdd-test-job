#!/usr/bin/env bash

echo "Running BDD tests for Quickstarts"

jx step bdd -b  --provider=gke --git-provider=ghe --git-provider-url=https://github.beescloud.com --git-username dev1 --git-api-token $GHE_CREDS_PSW --default-admin-password $JENKINS_CREDS_PSW --no-delete-app --no-delete-repo --tests install --tests test-create-spring --ignore-fail

echo "How storing the test results"

# TODO tranform junit.xml into a HTML report via https://github.com/jenkins-x-images/xunit-viewer

jx step collect -c tests -p "reports/junit.xml"

