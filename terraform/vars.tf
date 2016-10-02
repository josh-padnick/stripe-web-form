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

variable "logs_expiration_time_in_days" {
    description = "The number of days before which CloudFront log files in S3 are automatically deleted. Enter 0 to never delete."
}

variable "geo_restriction_type" {
  description = "The method to use to restrict availability of the website by country (none, whitelist, or blacklist)"
}

variable "geo_locations_list" {
  description = "The ISO 3166-1-alpha-2 codes (https://goo.gl/lbnFRg) for which the website will either be available (whitelist) or unavailable (blacklist), depending on the value of var.geo_restriction_type."
  type = "list"
}

variable "acm_certificate_arn" {
  description = "The ARN of the TLS/SSL certifcate issued by the Amazon Certificate Manager"
}