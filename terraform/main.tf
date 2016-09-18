# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# SETUP A WEB FORM TO COLLECT CREDIT CARD AND BANK ACCOUNT INFO FOR STRIPE.
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

# ---------------------------------------------------------------------------------------------------------------------
# CONFIGURE OUR AWS CONNECTION
# ---------------------------------------------------------------------------------------------------------------------

provider "aws" {
  # The AWS region in which all resources will be created
  region = "${var.aws_region}"

  # Only these AWS Account IDs may be operated on by this template
  allowed_account_ids = ["${var.aws_account_ids}"]
}

# ---------------------------------------------------------------------------------------------------------------------
# CREATE THE S3 BUCKET WHERE THE WEB FORM WILL BE HOSTED
# ---------------------------------------------------------------------------------------------------------------------

resource "aws_s3_bucket" "webform" {
    bucket = "${var.website_domain_name}"
    acl = "public-read"

    website {
        index_document = "index.html"
        error_document = "error.html" 
    }

    # As a precaution, we choose to save every version of every file uploaded to the S3 bucket.
    versioning {
      enabled = true
    }
}
