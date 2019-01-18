#!/usr/bin/env bash

echo "Running BDD tests for Quickstarts"

jx version -b

export GHE_CREDS_PSW="$(jx step credential -s jx-pipeline-git-github-ghe)"
export JENKINS_CREDS_PSW="$(jx step credential -s  test-jenkins-user)"
export GKE_SA="$(jx step credential -s gke-sa)"

# give the BDD report nicer names
export REPO_NAME="base"
export BRANCH_NAME="qs"

export TESTS="test-create-spring"
#export TESTS="all"

# TODO maybe only need this if BUILD_NUMBER is actually "$BUILD_ID" and hasn't been expanded?
export BUILD_NUMBER="$BUILD_ID"

echo ""
echo "JX_BUILD_NUMBER: $JX_BUILD_NUMBER"
echo "BUILD_NUMBER:    $BUILD_NUMBER"
echo "BUILD_ID:        $BUILD_ID"
echo ""

echo "setup kube context and git"

# lets point the BDD tests at a different context and location
export DUMMY_DIR=/tmp/my-kube-context
mkdir -p $DUMMY_DIR
export KUBECONFIG=$DUMMY_DIR
export JX_HOME=$DUMMY_DIR

gcloud auth activate-service-account --key-file $GKE_SA
gcloud container clusters get-credentials anthorse --zone europe-west1-b --project jenkinsx-dev

git config --global --add user.name JenkinsXBot
git config --global --add user.email jenkins-x@googlegroups.com

echo "starting the BDD Quickstart tests"

jx step bdd -b  --provider=gke --git-provider=ghe --git-provider-url=https://github.beescloud.com --git-username dev1 --git-api-token $GHE_CREDS_PSW --default-admin-password $JENKINS_CREDS_PSW --no-delete-app --no-delete-repo --tests install --tests $TESTS --ignore-fail  &> /tmp/build-log.txt

echo ""
echo ""
echo "Generated reports:"
#ls -al reports
ls -al /home/jenkins/go/jenkins-x/bdd-jx/reports
echo ""
echo "storing the test results on stable storage..."

unset KUBECONFIG
unset JX_HOME

cp /tmp/build-log.txt /home/jenkins/go/jenkins-x/bdd-jx/reports
jx step stash -c tests  --basedir "/home/jenkins/go/jenkins-x/bdd-jx/reports" -p "/home/jenkins/go/jenkins-x/bdd-jx/reports/*"

echo "BDD Tests Done!"

