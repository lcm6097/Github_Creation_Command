"""
    This script will create a GitHub repository, Trello Board, and a directory 
    in the personal projects area.

    Could use githubpy3 but wanna create my own
"""

import os
import requests
import sys
import json
import pprint
import logging

# Project location
projectLocation = ''
# User Data
user = ""
token = ""
#GitHub preferences
license_template = ''
auto_init = ''


def set_global_variables(configFile='.create_github_repo_config.json'):
    """
    This cuntion reads the json config file to find the preferences the user set to send to
    GitHub API and also to set a project folder location. MAKE SURE THE LOCATION EXISTS ALREADY.
    @param: configFile: A user can pass in a custom config file for one off runs or it will use the
                        default config file
    """
    # Gets the path of the JSON file, it should be in the same directory as the python file
    json_file_path = str(os.path.dirname(os.path.realpath(__file__))+'/'+str(configFile))
    # Opens file in read mode
    json_file = open(json_file_path, 'r')
    # Loads JSON file
    config = json.load(json_file)

    # Sets global variables so the API function can use it
    global projectLocation
    projectLocation = config['project_folder']
    logging.debug('Setting project location to: '+projectLocation)
    global user
    user = config['user']
    logging.debug('Setting user to: '+user)
    global token
    token = config['token']
    logging.debug('Setting token to: '+token)
    global license_template
    license_template = config['license_template']
    logging.debug('Setting license_template to: '+license_template)
    global auto_init
    auto_init = config['auto_init']
    logging.debug('Setting auto_init to: '+auto_init)
    
    return


def create_folder(projectName):
    """
    This function creates the folder for the project in the Projects directory
    @param: projectName: Name of the project, which will also be the name of the folder
    """
    # Make directory
    try:
        # ###########FIX: This will later become a config file setting
        os.mkdir(projectLocation+projectName)
        logging.debug("Directory created")
        return True
    except FileExistsError:
        logging.error("Folder already exists")
        return False


def create_repository(projectName, visibility):
    """
    This function will use GitHub's API with the users authentication token and user name,
    to create the repository for the new project with an empty README.
    @param: projectName: Name of the project and the GitHub repository
            visibility: Either a private or public repository
            description: Description of the new project
    """

    # Github REST API URL
    url = "https://api.github.com/"

    logging.debug("Describe the project:")
    description = input()
    # Payload to create a repository
    payload = {'name': projectName,
                'description': description,
                'private': visibility,
                'auto_init': auto_init,
                'license_template': license_template}

    # Make POST request to create repository 
    r = requests.post((url+'user/repos'), auth=(user,token), json=payload)
    logging.debug("Response Status code is "+str(r.status_code))

    # Convert data to JSON
    data = r.json()
    
    if r.status_code == 201:
        clone_url = data['clone_url']
        logging.debug("Clone URL -> "+str(clone_url))
        logging.debug("Repository creation for project " + projectName + " in GitHub is complete")
        return clone_url
    else:
        logging.error("API call failed")
        logging.error(str(data['message']) +"  "+ str(data['errors'][0]['message']))
        return ''


if __name__ == "__main__":
    #logging settings
    logging.basicConfig(level=logging.DEBUG)

    # Project name and folder name in Project folder
    projName = str(sys.argv[1])
    logging.debug("Setting the projName var to -> "+projName)
    # Is project private or public on GitHub
    visibility = str(sys.argv[2]).lower()
    logging.debug("Setting the visibility var to -> "+visibility)

    # Set visibility on GitHub
    if visibility == 'private':
        visibility = 'true'
    elif visibility == 'public':
        visibility = 'false'
    else:
        logging.error('Set visibility to either "private" or "public"')
        print('ERROR')
        exit()
    logging.debug("visibility set to -> "+visibility)


    if len(sys.argv) == 4:
        set_global_variables(configFile=sys.argv[3])
        logging.debug("Using CUSTOM config file " + sys.argv[3])
    else:
        set_global_variables()
        logging.debug("Using DEFAULT config file .create_github_repo_config.json")

    #folder = create_folder(projName)
    '''
    if folder:
        repo = create_repository(projName, visibility)
        if repo == '':
            print('ERROR')
        else:
            print(repo) 
            logging.debug(repo[1])
    else:
        print('ERROR')
        '''
