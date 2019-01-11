#!/usr/bin/env bash

echo "Running BDD tests for Quickstarts"

jx version -b

export GHE_CREDS_PSW="$(jx step credential -s jx-pipeline-git-github-ghe)"
export JENKINS_CREDS_PSW="$(jx step credential -s  test-jenkins-user)"
export GKE_SA="$(jx step credential -s gke-sa)"

# give the BDD report nicer names
export REPO_NAME="base"
export BRANCH_NAME="qs"

echo ""
echo "JX_BUILD_NUMBER: $JX_BUILD_NUMBER"
echo "BUILD_NUMBER:    $BUILD_NUMBER"
echo "BUILD_ID:        $BUILD_ID"
echo ""

echo "setup kube context and git"

gcloud auth activate-service-account --key-file $GKE_SA
gcloud container clusters get-credentials anthorse --zone europe-west1-b --project jenkinsx-dev

git config --global --add user.name JenkinsXBot
git config --global --add user.email jenkins-x@googlegroups.com

echo "starting the BDD Quickstart tests"

jx step bdd -b  --provider=gke --git-provider=ghe --git-provider-url=https://github.beescloud.com --git-username dev1 --git-api-token $GHE_CREDS_PSW --default-admin-password $JENKINS_CREDS_PSW --no-delete-app --no-delete-repo --tests install --tests test-create-spring --ignore-fail

echo ""
echo ""
echo "Generated reports:"
#ls -al reports
ls -al /home/jenkins/go/jenkins-x/bdd-jx/reports
echo ""
echo "storing the test results on stable storage..."

# TODO transform junit.xml into a HTML report via https://github.com/jenkins-x-images/xunit-viewer

jx step collect -c tests -p "/home/jenkins/go/jenkins-x/bdd-jx/reports/*" --git-url https://github.com/jenkins-x/jx-devops-results.git

echo "BDD Tests Done!"

