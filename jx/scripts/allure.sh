#!/usr/bin/env bash

echo "Generating the Allure Report from the test results in build $BUILD_ID"

echo "Using allure: $(allure --version)"

git config --global --add user.name JenkinsXBot
git config --global --add user.email jenkins-x@googlegroups.com

git clone -b gh-pages https://github.com/jenkins-x/jx-devops-results.git

cd jx-devops-results/jenkins-x/tests/jenkins-x/jx-quickstarts-bdd-test-job

echo "Generating allure report"
pwd

allure generate --clean -o allure qs/$BUILD_ID/artifacts

echo "Now adding files to git"

git add allure
git commit -m "updated Allure report"
git push

echo "Pushed changes"






