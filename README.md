# Script for automatically generating clean architecture files and folders.

This project utilizes Flutter's clean architecture with Cubit. However, creating every necessary folder and file for each new feature can be a tedious task. To simplify the development process, I have created a script file that automates the creation of the folder structure and necessary files for a new feature. This not only saves time, but also ensures consistency in the code structure. The script file also includes a basic code structure for each new feature.

To execute the clean_architecture.sh script, navigate to your root project folder and enter the following command:

./clean_architecture.sh argument1 argument2

Please note that argument1 is a required argument, while argument2 is optional. Including argument2 will create an additional root folder.

If you encounter a permission issue when attempting to run the script file, use the following command to modify the file permissions:

chmod 777 clean_architecture.sh

This will grant read, write, and execute permissions to all users, allowing the script file to be run without encountering permission issues.

