#!/bin/bash

function create_github_repo() {

    create=false
    delete=false
    install=false
    usage=false
    debug=false
    name=""
    vis=""
    config=""

    while getopts "bcdihn:v:g:" OPTION
    do
        case $OPTION in
            c)
                create=true
                shift
                ;;
            d)
                delete=true
                shift
                ;;
            i)
                install=true
                shift
                ;;
            b)
                debug=true
                shift
                ;;
            n)
                name="$OPTARG"
                create=true
                shift
                ;;
            v)
                vis="$OPTARG"
                create=true
                shift
                ;;
            g)
                config="$OPTARG"
                create=true
                shift
                ;;
            \?|h)
                #usage
                echo 'help!!!'
                exit 0
                ;;
        esac
    done

    if [[ $debug ]]; then
        __create_project 'debug'
        __delete_project 'debug'
        exit 0
    fi

    if [[ $create ]] && [[ ! $delete ]] && [[ ! $install ]]; then
    #CREATE command
        if [[ $name -eq "" ]] || [[ $vis -eq "" ]]; then
            echo 'Pass in the name of the project you want to delete with the flag -n <project_name>'
            echo 'Pass in the name of the project you want to delete with the flag -v <private>/<public>'
            exit 1
        fi

        if [[ ! $config -eq "" ]]; then
            __create_project $name $vis $config
        fi
        __create_project $name $vis

    elif [[ ! $create ]] && [[ $delete ]] && [[ ! $install ]]; then
    #DELETE command
        #No name, exit
        if [[ $name -eq "" ]]; then
            echo 'Pass in the name of the project you want to delete with the flag -n <project_name>'
            exit 1
        fi
        #COnfig file passed in
        if [[ ! $config -eq "" ]]; then
            __delete_project $name $config
        fi
        #Default config
        __delete_project $name

    elif [[ ! $create ]] && [[ ! $delete ]] && [[ $install ]]; then
    #install command
        __install

    else
    #error
        echo 'Error: the create, delete and install commands are mutually exclusive'
        echo 'Help is below:'
        #usage
    fi

    exit 0
}

# Creates new project
function __create_project() {
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
        PROJS_FOLDER=$(python3 -c "import json; print(json.load(open('$CONFIG_FILE'))['project_folder'])")
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
            echo error found, check log; exit 0 ;;
    else
        # Do inital commit with a .gitignore file
        echo $REPO
        cd $CURR_PROJ_FOLDER
        git config --global credential.helper cache
        git clone $REPO .
        git branch -a
        touch .gitignore
        git add -A
        git commit -m "Initial Commit with .gitignore"
        git push origin master
    fi

    exit 0

}

function __delete_project() {
    if [ $# -lt 1 ] && [ $# -gt 2 ]; then
        exit 1
    fi

    if [ 'debug' = $1 ]; then
        # Going into Debug mode
        echo 'debug mode'
        # Set configuration file to custom
        CONFIG_FILE=.custom_config_file.json
        PROJ_FOLDER='test'
        PROJS_FOLDER=$(python3 -c "import json; print(json.load(open('$CONFIG_FILE'))['project_folder'])")
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
        PROJS_FOLDER=$(python3 -c "import json; print(json.load(open('$CONFIG_FILE'))['project_folder'])")
        CURR_PROJ_FOLDER=$PROJS_FOLDER$PROJ_FOLDER


    fi

    USER=$(python3 -c "import json; print(json.load(open('$CONFIG_FILE'))['user'])")
    TOKEN=$(python3 -c "import json; print(json.load(open('$CONFIG_FILE'))['token'])")
    echo $USER
    echo $TOKEN
    curl -u $USER:$TOKEN -X DELETE https://api.github.com/repos/$USER/$PROJ_FOLDER
    cd $CURR_PROJ_FOLDER
    cd ..
    rm -rf $PROJ_FOLDER
    cd ~

    exit 0
}

function __install() {
    if [[ -f ~/.create_github_repo_config.json ]]; then
        sudo cp .create_github_repo.sh .create_github_repo.py ~
    fi
    sudo cp .create_github_repo.sh .create_github_repo_config.json .create_github_repo.py ~
    if [[ ! grep -Fxq "source ~/.create_github_repo.sh"]]; then
        echo 'source ~/.create_github_repo.sh' >> ~/.bashrc
    fi
    echo 'Installation complete'

    exit 0

}