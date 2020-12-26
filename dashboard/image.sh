#!/bin/bash
list='dashboard:v2.0.0
metrics-scraper:v1.0.4'
for item in ${list}
  do

    docker pull registry.aliyuncs.com/google_containers/$item && docker tag registry.aliyuncs.com/google_containers/$item kubernetesui/$item && docker rmi registry.aliyuncs.com/google_containers/$item

  done
