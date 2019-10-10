#!/bin/bash

DIR="/apps/errors"
REPOS="git@github.com:username/repository.git"
BRANCH="gh-pages"
CHECKOUT_DIR="errors/"

mkdir -p $DIR
if [ -d "$DIR" ]; then
  cd $DIR
  git init
  git remote add -f origin $REPOS
  git fetch --all
  git config core.sparseCheckout true
  if [ -f .git/info/sparse-checkout]; then
    rm .git/info/sparse-checkout
  fi
  echo $CHECKOUT_DIR >> .git/info/sparse-checkout
  git checkout $BRANCH
  git merge --ff-only origin/$BRANCH
fi
