# rsschool-devops-course-tasks

Public repository `rsschool-devops-course-tasks` was created to pass the AWS DevOps course by RSSchool and have the single source of truth for all up and running AWS resources and additional settings.
As of now project has next directories and files:
1. Directory `tf_init` is used to create S3 bucket to save Terraform state for all other AWS resources. Make `terraform init/plan/apply` into this directory on your local system to deploy S3 bucket and then use bucket name to specify it into `backend.tf` file into `tf_resources` directory. Terraform state for this setup will be saved on your local storage into the same directory.
**Important note!** Strongly recommended - be careful with this S3 bucket and .tfstate files into it and don't delete them due to it will impact the Terraform state for all the infrastructure created via `tf_resource` directory.
2. Directory `tf_resources` is used to create all the rest resources of project. It's necessary to specify S3 bucket name from `tf_init` directory for `backend.tf` file and make `terraform init/plan/apply` into this directory on your local system to deploy the compulsory resources for GitHub actions workflow. After these actions you can manage your infrastructure by pushing code into feature branches or creating PRs into default branch (`main`).
3. Directory `.github/workflows` contains `tf_deployment.yaml` file to describe jobs which should be executed automatically by GitHub actions after pushing or creating of PRs for dedicated branches.
4. File `.gitignore` contains the names or masks of files and directories which should be ignored by Git.
5. File `README.md` contains the documentation of the project to setup and manage infrastructure correctly.


## Task 2
https://github.com/rolling-scopes-school/tasks/blob/master/devops/modules/1_basic-configuration/task_2.md

During this task we implemented:
1. dedicated VPC with public and private subnets in both us-east-1a and us-east-1b AZs
2. test instances in both types of subnets with auto-check of accessible neighbours and access beyond VPC
3. bastion host to access instances from private subnets
4. NAT Gateway to provide access out of VPC for private instances
5. SG/NACL to secure our resources

Please use `terraform init/plan/apply` commands from `tf_resources` directory to deploy all of these resources. Or just push your changes into `task_2` branch or create PR to `master`.

Instances from public subnets are publicly accessible from world by HTTP/HTTPS via public IPs. They use Internet Gateway to reach resources out of VPC. Also they are accessible by SSH only within VPC (you can use bastion host to reach them from your personal IP).

Instances from private subnets are not publicly accessible. They use NAT Gateway to reach resources out of VPC. Since they are located into private subnets they are accessible by HTTP/HTTPS or SSH only within VPC (you can use bastion host to reach them from your personal IP).

You can review all the screenshots and details into PR to Task 2: https://github.com/shall-it/rsschool-devops-course-tasks/pull/2

**Important note!** Strongly recommended - destroy all instances in both public and private subnets, bastion host and NAT Gateway especially when you don't need them to save your money since these resources are most expensive!

## Task 3
https://github.com/rolling-scopes-school/tasks/blob/master/devops/modules/2_cluster-configuration/task_3.md

During this task we implemented:
1. Created the instance for kOps management and the bastion host for access to it
2. Deployed automatically kOps cluster (master + node) with all related infrastrusture
3. Organized and verified access from local computer to the deployed kOps cluster (content of the kubeconfig file was copied from instance for kOps managing to ~/.kube/config file on local computer)
4. Deployed and checked the simple workload inside the running kOps cluster

Please use `terraform init/plan/apply` commands from `tf_resources` directory to deploy all of these resources. Or just push your changes into `task_3` branch or create PR to `master`.

**Important note!** Strongly recommended - destroy cluster and all related infrastrusture, instance for kOps managing and bastion host when you don't need them to save your money!
Example of command to delete kOps cluster and all related infrastructure from instance for kOps managing: `kops delete cluster --name=kops.k8s.local --state=s3://rss-aws-kops --yes`