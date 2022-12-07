#!/bin/bash

#-- globals --#
quantum_engines=("ai-prod" "django" "quantum-ui")
engine_branches=("ai-branches" "django-branches" "ui-branches")
repository_ssh_links=("git@github.com:quantumgears/ai-prod.git" "git@github.com:quantumgears/django.git" "git@github.com:quantumgears/quantum-ui.git") 
major_release_branches=("v1.15" "gensim_4.0_uc2" "uc2_bcn1" "rf1")
active_branches=("rf1_uc3" "rf1_be2" "bcn1")
all_branches=("v1.15" "gensim_4.0_uc2" "uc2_bcn1" "rf1" "rf1_uc3" "rf1_be2" "bcn1")
current_database_version=("v1")

#-- prompts --#
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
choose_branch(){
    branch_var=$1
    branch_prompt="Enter the branch you would like to use: "
    open_ended_prompt "$branch_prompt" $branch_var
}
success_message(){
  echo -e "\nSUCESS! COMPLETED $1\n\n"
}
continue_message(){
  read "?Press enter to continue  "
  clear
}

#-- helpers --# 
add_major_engines_directory_structure(){
  curr_path=$1

  for branch in "${engine_branches[@]}"
  do
    mkdir -p ~/quantumgears/$curr_path/$branch
  done
}
add_major_release_branches(){
  curr_path=$1
  engine=$2

  for branch in "${major_release_branches[@]}"
  do
    mkdir -p ~/quantumgears/$curr_path/$engine/$branch
  done  
}
add_active_branches(){
  curr_path=$1

  for engine in "${engine_branches[@]}"
  do
    for branch in "${active_branches[@]}"
    do
      mkdir -p ~/quantumgears/$curr_path/$engine/$branch
    done
  done
}
add_all_branches(){
  curr_path=$1
  engine=$2

  for branch in "${all_branches[@]}"
  do
    mkdir -p ~/quantumgears/$curr_path/$engine/$branch
  done
}
clone_engine_repositories_into_directories(){
  repository_ssh_links=("git@github.com:quantumgears/ai-prod.git" "git@github.com:quantumgears/django.git" "git@github.com:quantumgears/quantum-ui.git")
  curr_path=$1

  for link in "${repository_ssh_links[@]}"
  do
    cd ~/quantumgears/$curr_path
    git clone $link
  done
}

#-- 1. check_and_handle_previous_quantumgears_directory + helpers --#
save_old_qg_to_desktop(){
  mv ~/quantumgears ~/Desktop
}
handle_old_qg_directory(){
  save_qg_prompt="Would you like to save your current ~/quantumgears directory to ~/Desktop before creating new directory structure?"
  yes_or_no_prompt "$save_qg_prompt"
  wants_to_save=$?

  if [ $wants_to_save -eq 3 ]; then
    save_old_qg_to_desktop
  else
    echo "OVER-WRITING PREVIOUS '~/quantumgears' DIRECTORY"
  fi
}
check_for_quantumgears_directory(){
  cd ~/quantumgears
}
check_and_handle_previous_quantumgears_directory(){
  check_for_quantumgears_directory
  if [ $? -eq 0 ]; then
    clear
    echo -e "FOUND 'quantumgears' DIRECTORY IN HOME PATH\n"
    handle_old_qg_directory
  fi
}

#-- 2. create_basic_directory_structure + helpers --#
add_quantumgears_directory_to_home_path(){
  mkdir -p ~/quantumgears
}
add_major_sub_directories(){
  sub_directories=("main" "branch" "builds" "data" "packageInstaller")
  for sub_directory in "${sub_directories[@]}"
  do
    mkdir -p ~/quantumgears/$sub_directory
  done
}
create_basic_directory_structure(){
  add_quantumgears_directory_to_home_path
  add_major_sub_directories
  success_message "CREATING BASIC DIRECTORY STRUCTURE."
  continue_message
}

#-- 3. create_main_structure + helpers --#
clone_repositories_into_main(){
  cd ~/quantumgears/main
  for link in "${repository_ssh_links[@]}"
  do
    git clone $link
  done
}
create_main_structure(){
  clone_repositories_into_main
  success_message "CLONING AI-PROD, DJANGO, AND QUANTUM-UI INTO '~/quantumgears/main' ON MAIN BRANCHES"
  continue_message
}

#-- 4. create_branch_structure + helpers --#
add_major_release_and_active_branches_directories(){
  curr_path=$1
  
  for engine in "${engine_branches[@]}"
  do
    add_all_branches "$curr_path" "$engine"
  done
}
clone_repositories_and_checkout_to_relative_branch(){
  counter=1
  
  for engine in "${engine_branches[@]}"
  do
    for branch in "${all_branches[@]}"
    do 
      cd ~/quantumgears/branch/$engine/$branch
      git clone "${repository_ssh_links[counter]}"
      cd ~/quantumgears/branch/$engine/$branch/${quantum_engines[counter]}
      git checkout $branch
      git pull
    done
    ((counter++))
  done
}
create_branch_structure(){
  add_major_engines_directory_structure "branch"
  add_major_release_and_active_branches_directories "branch"
  clone_repositories_and_checkout_to_relative_branch
  success_message "ADDING '~/quantumgears/branch' DIRECTORY STRUCTURE, CLONING AI-PROD, DJANGO, AND QUANTUM-UI BRANCHES AND CHECKING OUT TO THE RELATIVE BRANCH."
  continue_message
}

#-- 5. create_builds_structure + helpers --#
add_builds_directories(){
  mkdir -p ~/quantumgears/builds/current
  mkdir -p ~/quantumgears/builds/old_builds
}
add_major_release_and_active_branches_directories_to_builds(){
  curr_path=$1
  
  for branch in "${all_branches[@]}"
  do
    mkdir -p ~/quantumgears/builds/old_builds/$branch
  done
}
create_builds_structure(){
  add_builds_directories
  add_major_release_and_active_branches_directories_to_builds "builds"
  success_message "SETTING UP '~/quantumgears/builds' DIRECTORY STRUCTURE"
  continue_message
}

#-- 6. create_data_structure + helpers --#
create_data_structure(){
  for db_version in "${current_database_version}"
  do
    mkdir -p ~/quantumgears/data/$db_version
    mkdir -p ~/quantumgears/data/$db_version/docker
    mkdir -p ~/quantumgears/data/$db_version/local
  done

  success_message "SETTING UP '~/quantumgears/data' DIRECTORY STRUCTURE"
  continue_message
}

#-- 7. create_shortcuts_structure + helpers --#
create_shortcuts_structure(){
  cd ~/quantumgears
  git clone git@github.com:quantumgears/dev-shortcuts.git

  success_message "CLONING SHORTCUTS INTO: '~/quantumgears/dev-shortcuts'"
  continue_message
}

#-- 8. create_packageInstaller_structure + helpers --#
clone_packager_repo(){
  cd ~/quantumgears/packageInstaller
  git clone git@github.com:quantumgears/packaging.git
  cd packaging

  clear
  echo 'CHOOSING PACKAGER BRANCH'
  choose_branch "packager_branch"
  git checkout $packager_branch
  git pull
}
clone_installer_repo(){
  cd ~/quantumgears/packageInstaller
  git clone git@github.com:quantumgears/installer.git
  cd installer

  clear
  echo 'CHOOSING INSTALLER BRANCH'
  choose_branch "installer_branch"
  git checkout $installer_branch
  git pull
}
add_packageInstaller_repos(){
  clone_packager_repo
  clone_installer_repo
}
create_packageInstaller_structure(){
  add_packageInstaller_repos
  success_message "SETTING UP '~/quantumgears/packageInstaller' DIRECTORY STRUCTURE"
  continue_message
}

#-- 9. create_ai-docker-lib_structure + helpers --#
create_ai-docker-lib_structure(){
  cd ~/quantumgears
  git clone git@github.com:quantumgears/ai-docker-lib.git
  cd ai-docker-lib

  clear
  echo 'CHOOSING ai-docker-lib BRANCH'
  choose_branch "ai_docker_lib_branch"
  git checkout $ai_docker_lib_branch 
  git pull

  success_message "CLONING AI-DOCKER-LIB INTO: '~/quantumgears/ai-docker-lib'"
  continue_message
}

#-- init --#
init(){
  check_and_handle_previous_quantumgears_directory # 1
  create_basic_directory_structure # 2
  create_main_structure # 3 
  create_branch_structure # 4
  create_builds_structure # 5
  create_data_structure # 6
  create_shortcuts_structure # 7
  create_packageInstaller_structure # 8
  create_ai-docker-lib_structure # 9

  clear
  success_message "SETTING UP '~/quantumgears' DIRECTORY STRUCTURE!"
  continue_message

  exit 0
}

init