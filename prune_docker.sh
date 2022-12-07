#!/bin/bash

yes_or_no_prompt(){
    current_prompt="$1"
    user_choice=""

    while [ "$user_choice" != 'y' ] && [ "$user_choice" != 'n' ]; do
        echo -e "$current_prompt: [y/n]" || read user_choice || user_choice=$(echo "$user_choice" | tr '[:upper:]' '[:lower:]')
    done

    if [ $user_choice = 'y' ]; then
        return 3
    else
        return -1
    fi
}

open_ended_prompt(){
    current_prompt="$1"
    user_response=""

    while [ "$user_response" = "" ]; do
        echo -e "$current_prompt" 
        read user_response  
        user_response=$(echo "$user_response" | tr '[:upper:]' '[:lower:]')

        if [ "$user_response" = "" ]; then
          clear || echo -e "ERROR: EMPTY VALUE ENTERED\nPLEASE ENTER A NON-EMPTY VALUE.\n"
        fi
    done

    declare -g $2=$user_response
}

prune_docker_containers(){
  clear
  echo -e "PRUNING DOCKER CONTAINERS\n"
  
  docker container prune
  docker ps

  read "?Press enter to continue  "
  clear
}

prune_docker_volumes(){
  clear
  echo -e "PRUNING DOCKER VOLUMES\n"

  docker volume prune
  docker volume ls
  
  read "?Press enter to continue  "
  clear
}

remove_dangling_docker_images(){
  clear
  echo -e "PRUNING ALL DANGLING DOCKER IMAGES\n"

  docker rmi $(docker images -f "dangling=true" -q)
}

remove_quantum_docker_images(){
  echo -e "PRUNING ALL QUANTUM DOCKER IMAGES\n"

  docker images | grep quantumgears | tr -s ' ' | cut -d ' ' -f 3 | xargs -I {} docker rmi {}
  
  read "?Press enter to continue  "
  clear
}

init(){
  prune_docker_containers

  prune_docker_volumes

  remove_dangling_docker_images

  remove_quantum_docker_images
}

init