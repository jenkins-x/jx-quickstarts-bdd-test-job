#!/usr/bin/env bash

echo "Running BDD tests for Quickstarts"

jx version -b

export $GHE_CREDS_PSW="$(jx step credential -s jx-pipeline-git-github-ghe -k password)"
export $JENKINS_CREDS_PSW="$(jx step credential -s  test-jenkins-user -k password)"

echo "starting the BDD Quickstart tests"

jx step bdd -b  --provider=gke --git-provider=ghe --git-provider-url=https://github.beescloud.com --git-username dev1 --git-api-token $GHE_CREDS_PSW --default-admin-password $JENKINS_CREDS_PSW --no-delete-app --no-delete-repo --tests install --tests test-create-spring --ignore-fail

echo "storing the test results on stable storage..."

# TODO transform junit.xml into a HTML report via https://github.com/jenkins-x-images/xunit-viewer

jx step collect -c tests -p "reports/junit.xml"

echo "Done!"

