# Github Creation Command

## Command: create_project *project_name private/public [configFile]*

This terminal command will create a new repo in GitHub and it will also create a new project folder and initialize the repo inside of it. 

It is controlled by the JSON config file, generate a token on [GitHub](https://github.com/settings/tokens) and fill out the rest of the fields on the JSON file.

To run the command:
1. Download the files
3. Place .my_custom_commands.sh .create_github_repo.py and .create_github_repo_config.json on your /home folder
4. Open JSON file and fill out the fields, and save
5. Open ~/.bashrc file, on the last line write *source ~/.my_custom_commands.sh*, and save the file
6. Open another terminal and generate a GitHub repo!
