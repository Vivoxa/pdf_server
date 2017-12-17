#!/bin/bash
set -e

    if [[ $@ == *"--clean"* ]] ;then
      echo 'Cleaning...'
      docker-compose kill
      docker stop pdf_server
      docker rm pdf_server
    fi

    docker-compose up -d
		docker attach pdf_server
