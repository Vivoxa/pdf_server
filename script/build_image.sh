#!/bin/bash
set -e

    if [[ $@ == *"--production"* ]] ;then
    shopt -s nullglob
      files=(log/*)
      if (( ${#files[*]} )); then
        echo 'Removing log files....................'
        rm -r log/*
      fi
      shopt -u nullglob
      echo ''
      echo '***********************************************************************'
      echo '####      Logging in to AWS with pwpr-production credentials      #####'
      echo '***********************************************************************'
      echo ''
      eval "$(aws ecr get-login --profile pwpr-production --region eu-west-1)"
      echo ''
      echo '****************************************************************'
      echo '          Building the command to run on the container'
      command="RAILS_ENV=production rackup config.ru -p 2030 -o '0.0.0.0'"
      echo $command
      echo '***************************************************************'
      echo ''
      docker build --build-arg APP_DIR=pdf_server --build-arg COMMAND="$command" -t=pdf_service .
      echo ''
      echo ''
      echo '***********************************************************************'
      echo '                Docker image built, all done......'
      echo '***********************************************************************'
      echo ''
    fi

    if [[ $@ == *"--preprod"* ]] ;then
      shopt -s nullglob
      files=(log/*)
      if (( ${#files[*]} )); then
        echo 'Removing log files....................'
        rm -r log/*
      fi
      shopt -u nullglob
      echo ''
      echo '***********************************************************************'
      echo '####      Logging in to AWS with pwpr-preprod credentials         #####'
      echo '***********************************************************************'
      echo ''
      eval "$(aws ecr get-login --profile pwpr-preprod --region eu-west-1)"
      echo ''
      echo '********************************************************************************************************************************************'
      echo '             Building the command to run on the container'
      command="RAILS_ENV=preprod rackup config.ru -p 2030 -o '0.0.0.0'"
      echo $command
      echo '********************************************************************************************************************************************'
      echo ''
      docker build --build-arg APP_DIR=pdf_server --build-arg COMMAND="$command" -t=pdf_service .
      echo ''
      echo ''
      echo '***********************************************************************'
      echo '                Docker image built, all done......'
      echo '***********************************************************************'
      echo ''
    fi
