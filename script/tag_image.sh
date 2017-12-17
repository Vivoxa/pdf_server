#!/bin/bash
set -e

    if [[ $1 == *"--production"* ]] ;then
      docker tag $2 084857879641.dkr.ecr.eu-west-1.amazonaws.com/pwpr:$3
      if [[ $4 == *"--push"* ]] ;then
        docker push 084857879641.dkr.ecr.eu-west-1.amazonaws.com/pwpr:$3
      fi
    fi

    if [[ $@ == *"--preprod"* ]] ;then
      docker tag $2 054960824384.dkr.ecr.eu-west-1.amazonaws.com/pre-pdf_server:$3
      if [[ $4 == *"--push"* ]] ;then
        docker push 054960824384.dkr.ecr.eu-west-1.amazonaws.com/pre-pdf_server:$3
      fi
    fi
