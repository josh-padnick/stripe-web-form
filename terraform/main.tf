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

# We create an S3 bucket where our static web form files (e.g. HTML, CSS, JS) will be stored.
resource "aws_s3_bucket" "webform" {
  bucket = "${var.website_domain_name}"
  acl    = "public-read"

  # Define an S3 bucket policy that grants everyone access to all S3 objects. This way, we don't have to specify an Access
  # Control List (ACL) for each individual S3 object to allow it to be readable by the public. 
  policy = <<-EOF
    {
        "Version":"2012-10-17",
        "Statement":[{
            "Sid":"PublicReadGetObject",
            "Effect":"Allow",
            "Principal": "*",
            "Action":["s3:GetObject"],
            "Resource":["arn:aws:s3:::${var.website_domain_name}/*"]
        }]
    }
    EOF

  # Configure S3 Static Website Hosting options
  website {
    index_document = "index.html"
    error_document = "error.html"
  }

  # As a precaution, we choose to save every version of every file uploaded to the S3 bucket.
  versioning {
    enabled = true
  }
}

# Create an S3 bucket for storing log files
resource "aws_s3_bucket" "webform_logs" {
  bucket = "${var.website_domain_name}-logs"
  acl = "private"

    lifecycle_rule {
        id = "log"
        prefix = ""
        enabled = true

        expiration {
            days = "${var.logs_expiration_time_in_days}"
        }
    }
}

# ---------------------------------------------------------------------------------------------------------------------
# UPLOAD INDIVIDUAL PAGES TO THE S3 BUCKET
# Note that we do not need to specify a "public-read" Access Control List (ACL) because our S3 Bucket Policy handles this
# for us.
# ---------------------------------------------------------------------------------------------------------------------

resource "aws_s3_bucket_object" "index" {
  bucket       = "${aws_s3_bucket.webform.id}"
  key          = "index.html"
  source       = "${path.module}/web/index.html"
  etag         = "${md5(file("${path.module}/web/index.html"))}"
  content_type = "text/html"
}

# ---------------------------------------------------------------------------------------------------------------------
# CREATE A CLOUDFRONT WEB DISTRIBUTION
# We can't serve an S3 webiste over HTTPS unless we route it through CloudFront. So we create a CloudFront distribution
# where our origin server will be the S3 bucket created earlier.
# ---------------------------------------------------------------------------------------------------------------------

# To prevent users from accessing files directly in S3, we create a CloudFront Origin Access Identity, which is basically
# a user identity assumed by CloudFront. We can then tell the S3 bucket to only server files to this user identity. 
resource "aws_cloudfront_origin_access_identity" "origin_access_identity" {
  comment = "For ${var.website_domain_name}"
}

# Create the CloudFront Distribution itself. To understand each of the properties,
# see https://www.terraform.io/docs/providers/aws/r/cloudfront_distribution.html.
resource "aws_cloudfront_distribution" "webform" {
  origin {
    domain_name = "${var.website_domain_name}.s3.amazonaws.com"
    origin_id   = "${var.website_domain_name}"

    s3_origin_config {
      origin_access_identity = "${aws_cloudfront_origin_access_identity.origin_access_identity.cloudfront_access_identity_path}"
    }
  }

  aliases             = ["${var.website_domain_name}"]
  enabled             = true
  comment             = "Serve ${var.website_domain_name} over HTTPS."
  default_root_object = "index.html"

  logging_config {
    include_cookies = true
    bucket          = "${aws_s3_bucket.webform_logs.id}.s3.amazonaws.com"
    prefix          = ""
  }

  default_cache_behavior {
    allowed_methods  = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "${aws_s3_bucket.webform.id}"

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "redirect-to-https"
    min_ttl                = 0
    default_ttl            = 30
    max_ttl                = 60
  }

  price_class = "PriceClass_100"

  restrictions {
    geo_restriction {
      restriction_type = "${var.geo_restriction_type}"
      locations        = ["${var.geo_locations_list}"]
    }
  }

  viewer_certificate {
    cloudfront_default_certificate = false
    acm_certificate_arn = "${var.acm_certificate_arn}"
    minimum_protocol_version = "TLSv1"
    ssl_support_method = "sni-only"
  }
}