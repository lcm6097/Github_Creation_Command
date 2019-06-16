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
# ###########FIX: This will later become a config file setting
projectLocation = '/home/maga8990/Documents/Projects/MyProjects/'
#Create repository in GitHub
# User Data
# ###########FIX: This will later become a config file setting
user = "lcm6097"
token = "5ff87121bee7b5960f428b7b09dac87a46efd519"
#G ithub REST API URL
url = "https://api.github.com/"


def create_folder(projectName):
    """
    This function creates the folder for the project in the Projects directory
    @param: projectName: Name of the project, which will also be the name of the folder
    """
    # Make directory
    try:
        # ###########FIX: This will later become a config file setting
        os.mkdir('/home/maga8990/Documents/Projects/MyProjects/'+projectName)
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
    logging.debug("Describe the project:")
    description = input()
    # Payload to create a repository
    payload = {'name': projectName,
                'description': description,
                'private': visibility,
                'auto_init': 'true',
                'license_template': 'gpl-3.0'}

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

    folder = create_folder(projName)

    if folder:
        repo = create_repository(projName, visibility)
        if repo == '':
            print('ERROR')
        else:
            print(repo) 
            logging.debug(repo[1])
    else:
        print('ERROR')
