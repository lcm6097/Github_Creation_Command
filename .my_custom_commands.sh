#!/bin/bash

# Creates new project
function create_project() {
    if [ 'debug' = $1 ]; then
        # Going into Debug mode
        echo 'debug mode'
        # Set configuration file to custom
        CONFIG_FILE=.custom_config_file.json
        PROJ_FOLDER='test'
        VIS='private'

        # Create test repository
        REPO=$(python3 .create_github_repo.py $PROJ_FOLDER $VIS $CONFIG_FILE)
        # Get test project folder
        PROJS_FOLDER=$(python3 -c "import json; print(json.load('$CONFIG_FILE')['project_folder'])")
        CURR_PROJ_FOLDER=$PROJS_FOLDER$PROJ_FOLDER
        echo $CURR_PROJ_FOLDER
    
    else
        # Actual call for a creation of a project
        if [ $# = 3 ]; then
            # if a config file was given run that
            CONFIG_FILE=~/$3
            REPO=$(python3 .create_github_repo.py $1 $2 $3)
        else
            CONFIG_FILE=~/.create_github_repo_config.json
            # if no config file was given then use default
            REPO=$(python3 .create_github_repo.py $1 $2)
        fi
        # Get path for project folder
        PROJS_FOLDER=$(python3 -c "import json; print(json.load(open('$CONFIG_FILE'))['project_folder'])")
        # Get current project folder
        CURR_PROJ_FOLDER=$PROJS_FOLDER$1
        echo $PROJS_FOLDER
        echo $CURR_PROJ_FOLDER
    fi

    if [ "$REPO" = "ERROR" ]; then
            # Error when creating the REPO
            echo error found, check log
    else
        # Do inital commit with a .gitignore file
        echo $REPO
        cd $CURR_PROJ_FOLDER
        git clone $REPO .
        git branch -a
        touch .gitignore
        git add -A
        git commit -m "Initial Commit with .gitignore"
        git push origin master
    fi

}

function delete_project() {
    if [ $# -lt 1 ] && [ $# -gt 2 ]; then
        exit 1
    fi

    if [ 'debug' = $1 ]; then
        # Going into Debug mode
        echo 'debug mode'
        # Set configuration file to custom
        CONFIG_FILE=.custom_config_file.json
        PROJ_FOLDER='test'
        PROJS_FOLDER=$(python3 -c "import json; print(json.load('$CONFIG_FILE')['project_folder'])")
        CURR_PROJ_FOLDER=$PROJS_FOLDER$PROJ_FOLDER

    else

        # Actual call for deletion of a project
        if [ $# = 2 ]; then
            # if a config file was given run that
            CONFIG_FILE=~/$2
        else
            # if no config file was given then use default
            CONFIG_FILE=~/.create_github_repo_config.json
        fi
        PROJ_FOLDER=$1
        PROJS_FOLDER=$(python3 -c "import json; print(json.load('$CONFIG_FILE')['project_folder'])")
        CURR_PROJ_FOLDER=$PROJS_FOLDER$PROJ_FOLDER


    fi

    USER=$(python3 -c "import json; print(json.load('$CONFIG_FILE')['user'])")
    TOKEN=$(python3 -c "import json; print(json.load('$CONFIG_FILE')['token'])")
    echo $USER
    echo $TOKEN
    curl -u $USER:$TOKEN -X DELETE https://api.github.com/repos/$USER/$PROJ_FOLDER
    cd $CURR_PROJ_FOLDER
    cd ..
    rm -rf $PROJ_FOLDER
        
}