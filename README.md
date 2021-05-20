# Automated Deployment for Drupal Dev Server on AWS

Objective: develop some automated tools to create dev servers on AWS. This assumes a simple server is needed, which will support the application server, database and file system.

Terraform is used to build the server resources on AWS.
* ec2 instance
* security group
* key pair

Ansible can be used to configure the servers on AWS.
* install and configure database
* install and configure apache
* install and configure other dependencies?
* generate additional users and configure permissions?
* copy application code and/or files

## Terraform

### Resources

https://github.com/terraform-aws-modules/terraform-aws-ec2-instance/tree/master/examples/basic

https://learn.hashicorp.com/tutorials/terraform/aws-build

https://dev.to/aakatev/deploy-ec2-instance-in-minutes-with-terraform-ip2

### AMI

Specify the amd ID in the aws_instance resource. This is using the current Ubuntu Server 20.04 LTS (HVM) for x86: ami-00399ec92321828f5

If needed, it's possible to look-up the current ID for a type of resource, using name filters, etc. There are other ways to query for "latest" ami using the AWS CLI tool.

For the Ubuntu server, the default user is "ubuntu".

### Configuration

ami: this is the ID for the AMI (default is Ubuntu Server 20.04 LTS)

tags.Name: this is helpful to identify the instance in the AWS console

aws_key_pair: required for SSH

provider.profile: this is the AWS CLI profile used when making remote calls. `ec2_user` is a user I created in Console. Could this be pushed to TF with some attached policies? Alternatively use "default" here and it's on the individual user to have that set up on their local AWS CLI.

### Security Group

This is used to define inbound traffic rules. It can be used to allow/disallow HTTP, HTTPS, SSH etc. It can also be finetuned to accept traffic for specific ports, or from specific IP ranges. To allow traffic from all sources, use "0.0.0.0/0".

By default, Terraform seems to disable egress, so we restore that manually.

### IAM Role

Should be set in console already? Should this move to a credentials file here?

https://blog.gruntwork.io/authenticating-to-aws-with-the-credentials-file-d16c0fbcbf9e
(also details using separate AWS user profiles in cli)

### SSH Key Pair

A key pair is required to connect to a machine via SSH. Example here assumes the private key is already generated and placed in the appropriate location on the local machine.

One alternative is to add a simple make file here that would generate a new public/private key pair. That would be a preliminary step before running terraform. That public key would be used in the TF plan.

Connect to the machine using the "ubuntu" user.

Is it possible to add multiple users and multiple public keys? Or multiple public keys to the "ubuntu" user?

## Ansible

Ansible expects host IPs to be set in the /etc/ansible/hosts file in order to run commands on a remote machine. The IP from the terraform-created server would have to be copied into the file above.

Test the connection:

`ansible all -m ping -u ubuntu`

* `-u`: flag to specify the ssh username (AWS Ubuntu image uses the "ubuntu" user by default)
* `all`: group name to specify the IPs to communicate with

**To-do**: define a group for these servers, or specify by name in playbook.yml, so we aren't running commands against "all"?

### Resources

https://github.com/geerlingguy/ansible-role-drupal

https://github.com/do-community/ansible-playbooks

### Things to Install

* apache
* db
* php modules required by Drupal
* composer?
* create test web page?

### Things to Configure

* apache
* db
* site config

## Future

* AWS: add attached file system
* AWS: elastic IP
* terraform: create a Production version that generates a separate DB instance and some networking resources to connect them
* terraform: move some properties to a variables.tf file to simplify/force some basic project setup
* ansible: confirm PHP modules
* ansible: confirm DB setup. Do we want o use MariaDB?
* ansible: PHP version is OK? Any reason to use 7.3? That requires adding another rep
* ansible: additional user setup, beyond drupal_user?