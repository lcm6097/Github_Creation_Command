#!/bin/bash

# Creates new project
function create_project() {
    PROJS_FOLDER=/home/maga8990/Documents/Projects/MyProjects/
    CURR_PROJ_FOLDER="$PROJ_FOLDER$1"
    REPO=$(python3 .create_github_repo.py $1 $2)
    if [ "$REPO" = "ERROR" ]; then
        echo error found, check log
    else
        echo $REPO
        cd $CURR_PROJ_FOLDER
        git clone $REPO .
        git branch -a
        touch .gitignore
    fi

}