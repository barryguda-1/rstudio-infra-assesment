# rstudio-infra-assesment
R-Studio Connect Automation
## How to run
Ensure you have Terraform installed and aws cli configured on your environment

## 1.First clone the project
    [ec2-user@XXXXXXX tmp]$ git clone git@github.com:barryguda-1/rstudio-infra-assesment.git

## 2. Intialize the environment
    [ec2-user@XXXXXXX tmp] terraform init

## 3. Validate the Syntax
    [ec2-user@XXXXXXX tmp] terraform validate

## 4. Generate deployment plan to be deployed
    [ec2-user@XXXXXXX tmp] terraform plan -out rstudio.plan

## 5. Apply the deployment using the generated plan
    [ec2-user@XXXXXXX tmp] terraform apply rstudio.plan --auto-approve

## 6. View data about the deployment
    [ec2-user@XXXXXXX tmp] terraform show

## 7. Get the Public IP to access the applications on port 3939
    [ec2-user@XXXXXXX tmp] terraform output
       R-Studioter-Public-IP = "xx.xx.xx.xx":3939
## 8. Destroy the deployment when done
    [ec2-user@XXXXXXX tmp] terraform destroy

