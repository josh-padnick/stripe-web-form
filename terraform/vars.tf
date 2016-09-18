# ---------------------------------------------------------------------------------------------------------------------
# ENVIRONMENT VARIABLES
# Define these secrets as environment variables
# ---------------------------------------------------------------------------------------------------------------------

# AWS_ACCESS_KEY_ID
# AWS_SECRET_ACCESS_KEY

# ---------------------------------------------------------------------------------------------------------------------
# MODULE PARAMETERS
# These variables are expected to be passed in by the operator
# ---------------------------------------------------------------------------------------------------------------------

variable "aws_region" {
  description = "The AWS region in which all resources will be created"
}

variable "aws_account_ids" {
  description = "A list of AWS Account IDs. Only these IDs may be operated on by this template. The first account ID is considered the primary, where all the resources should be created."
  type = "list"
}

variable "website_domain_name" {
    description = "The fully-qualified domain name of the website that will host the form. E.g. payment.gruntwork.io"
}