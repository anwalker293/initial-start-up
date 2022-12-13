#!/bin/bash

# Probably need to run as sudo
# $1 is the absolute path of the project (i.e. home/alex.walker/Indicio/cardea-docker)
# $2 is the branch to checkout project on (i.e. fix/proxy-timeout corresponds to git checkout fix/proxy-timeout)

# dirs initialized to support the-cardea-docker
dirs=(health-issuer-api health-issuer-ui primary-verifier-api primary-verifier-ui secondary-verifier-api secondary-verifier-ui)

cd $1
git checkout $2
git pull
git submodule init
git pull

counter=0

subdir_init() {
  echo "Navigating to $item"
  sleep 1
  if [[ $counter -eq 0 ]]
  then
    cd $item
    (( counter ++))
  else
    cd ../$item
  fi

  echo "Current pwd"
  sleep 1
  pwd
  git checkout main
  git pull
  npm i
  echo "Wrapping up with respect to $item..."
}

for item in "${dirs[@]}"
do
  subdir_init
done

cd ../
cp dev.env .env
git checkout $2
git pull

echo "Building, please wait a moment"
sleep 1
docker-compose -f docker-compose.dev.yml build --no-cache

echo "Upping, please wait a few moments"
sleep 1
docker-compose -f docker-compose.dev.yml up
