#!/bin/bash

#-- helpers --#
yes_or_no_prompt(){
    current_prompt="$1"
    user_choice=""

    while [ "$user_choice" != 'y' ] && [ "$user_choice" != 'n' ]; do
        echo -e "$current_prompt: [y/n]"
        read user_choice
        user_choice=$(echo "$user_choice" | tr '[:upper:]' '[:lower:]')
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
          clear
          echo -e "ERROR: EMPTY VALUE ENTERED\nPLEASE ENTER A NON-EMPTY VALUE.\n"
        fi
    done

    declare -g $2=$user_response
}

#-- create_docker_postgres_db --#
get_postgres_image_id(){
  declare -g postgres_image_id=$(docker images | grep postgres | tr -s ' ' | cut -d ' ' -f 3)
}
remove_old_postgres_from_image(){
  docker rmi $(docker images -f "dangling=true" -q)
}
get_postgres_container_id(){
  declare -g postgres_container_id=$(docker ps | grep 5432 | tr -s ' ' | cut -d ' ' -f 1)
}
bring_down_current_postgres_docker_db(){
  get_postgres_container_id
  docker stop $postgres_container_id
}
prune_docker_container_and_volumes(){
  clear

  echo -e "PRUNING ALL STOPPED DOCKER CONTAINERS\n"
  docker container prune

  clear

  echo -e "PRUNING ALL STOPPED DOCKER VOLUMES\n"
  docker volume prune

  clear
}
check_for_running_postgres(){
  docker ps | grep 5432
  if [ $? -eq 1 ]; then
      create_docker_postgres_db
  else
      clear
      echo -e "ALREADY RUNNING POSTGRES DOCKER CONTAINER!\n"

      prompt="Would you to keep the running postgres container?"
      yes_or_no_prompt "$prompt"
      if [ $? -eq -1 ]; then
          bring_down_current_postgres_docker_db
          prune_docker_container_and_volumes
          create_docker_postgres_db
      else
          clear
          echo -e "LEAVING CURRENT RUNNING POSTGRES\n"
          return 5
      fi
  fi
}
create_docker_postgres_db() {
  prompt="Would you like to pull the latest postgres image from the docker hub?"
  yes_or_no_prompt "$prompt"
  clear
  user_response=$?

  if [ $user_response -eq 3 ]; then
      docker pull postgres
      remove_old_postgres_from_image
  fi

  get_postgres_image_id
  
  docker run -d -p 5432:5432 -e POSTGRES_USER=postgres -e POSTGRES_PASSWORD=postgres -it $postgres_image_id
}

#-- init --#
init(){
  check_for_running_postgres
  # exit 1
}

init