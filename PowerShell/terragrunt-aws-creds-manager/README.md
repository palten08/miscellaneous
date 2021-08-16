# Terragrunt AWS credentials manager

I got tired of manually swapping out my AWS credentials in my Terragrunt config everytime my session timed out, so I wrote this little script to automatically change them. It reads the new credentials from a file named "aws", and then updates the Terragrunt config as well as the environment variables so the AWS CLI will be up-to-date as well.

### Usage

 Copy your AWS credentials from the "programmatic access" section, and then paste them as-is into a file named "aws" in the same directory as the script. Provided your placing your credentials in a file called "credentials.yml", all you need to do is run the script.