#!/bin/bash

# Creates new project
function create_project() {
    if [ $# = 3 ]; then
        CONFIG_FILE=~/$3
        REPO=$(python3 .create_github_repo.py $1 $2 $3)
    else
        CONFIG_FILE=~/.create_github_repo_config.json
        REPO=$(python3 .create_github_repo.py $1 $2)
    
    echo $CONFIG_FILE
    PROJS_FOLDER=$(python3 -c "import json; print json.load($CONFIG_FILE)['project_folder']")
    echo $PROJS_FOLDER
    CURR_PROJ_FOLDER="$PROJ_FOLDER$1"
    
    # if [ "$REPO" = "ERROR" ]; then
    #     echo error found, check log
    # else
    #     echo $REPO
    #     cd $CURR_PROJ_FOLDER
    #     git clone $REPO .
    #     git branch -a
    #     touch .gitignore
    #     git add -A
    #     git commit -m "Initial Commit with .gitignore"
    #     git push origin master
    # fi

}