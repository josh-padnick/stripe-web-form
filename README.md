# Stripe Payment Collection Page

The goal of this repo is to collect a credit card in [Stripe](https://stripe.com/) so that it can be charged for later 
use.

### Motivation

Many solutions exist for building online forms, and most of these integrate with Stripe, but all of them appear to only
allow *charging* a credit card, not *collecting* a credit card for later use via the Stripe dashboard.

At [Gruntwork](http://www.gruntwork.io/), we needed the ability to collect credit card and bank account details securely 
via the Web to more easily enroll our customers in our subscription program, but it was a low priority item since all
our customers are software teams and we could use secure exchange solutions like [Keybase](https://keybase.io) to get 
the info we needed.

But then a charity I donate to on a monthly basis also needed an updated copy of my credit card for recurring billing 
and had no way to securely obtain my credit card. It's the same problem! So I decided to code this up over a few hours.

I can't sustainably be the support guy for a charity using this solution, so I've designed this setup to be as cheap,
hands-off and automated as possible. I'm also thoroughly documenting everything so that if the charity does need help, 
hey can send their helper to these docs.   

### Features

- Expose an HTTPS web page where users can enter their credit card or bank account information.
- All information is directly entered into your [Stripe](https://stripe.com/) account.
- Use the Stripe dashboard to manage everything else.
- No servers to manage.
- No credit card numbers are actually stored by you, only by Stripe.
- Costs as little as I could manage.
- All code is open source.
- Documented everything to allow anyone competent in AWS and NodeJS to manage this.

### Requirements

- This solution uses [Amazon Web Services](https://aws.amazon.com) (AWS) to host and run the code, so you'll need an AWS
  account with a valid credit card.
- The AWS setup is provisioned using [Terraform](https://www.terraform.io/) so you'll need to install that to your local 
  computer, and setup AWS credentials.  
- To more easily manage [terraform remote state](https://www.terraform.io/docs/state/remote/index.html), we use 
  [Terragrunt](https://github.com/gruntwork-io/terragrunt). You'll need to install that as well. 

### Estimated Cost

TODO

## How It Works

*This section is meant for technical users.*

- We have a static HTML page that collects the user's credit card or bank information. This is hosted in AWS S3.
- Because the static HTML page needs to be served over HTTPS, we create an AWS CloudFront "Web" distribution.
- We configure a free, auto-renewing TLS / SSL certifcate using AWS Certificate Manager.
- When a user submits the form, the request is handled by AWS API Gateway.
- API Gateway is configured to route the request to a Lambda function.
- The Lambda function pulls secrets from S3, such as the the Stripe Secret Key and Stripe Publishable Key. It then calls
  the Stripe API and submits the required information.
- Finally, the Lambda function will redirect the user to confirmation page and email a customizable message to the user 
  using AWS SES. 

## Setup

To set this up for your organization, do the following:

1. Select an AWS Region, and create an S3 Bucket where your [Terraform Remote 
   State](https://www.terraform.io/docs/state/remote/index.html) will be stored. 

1. Update the [.terragrunt file](terraform/.terragrunt) with the name and region of the S3 Bucket just created.

