provider "aws" {
  region = "ap-south-1"
}

resource "aws_s3_bucket" "website_bucket" {
  bucket = "myfirstbucket509123001245"
}

resource "aws_s3_object" "website_bucket" {
  bucket       = aws_s3_bucket.website_bucket.id
  key          = "index.html"
  source       = "index.html"
  content_type = "text/html"
}

#resource "aws_s3_account_public_access_block" "website_bucket" {
  #block_public_acls   = false
  #block_public_policy = false
#}

resource "aws_s3_bucket_public_access_block" "website_bucket" {
  bucket = aws_s3_bucket.website_bucket.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

#resource "aws_s3_bucket_policy" "website_bucket" {
  #Policy = jsonencode({
    #Version = "2012-10-17"
    #Statement = [
      #{
        #Sid = "PublicReadGetObject"
        #Effect = "Allow"
        #Principal = "*"
        #Action = [
          #"s3:GetObject",
          #"s3:ListBucket",
        #]
        #Resource = [
          #"${aws_s3_bucket.website_bucket.arn}",
          #"${aws_s3_bucket.website_bucket.arn}/*"
        #]
      #}
    #]
  #})
#}



resource "aws_cloudfront_distribution" "cdn_static_site" {
  enabled             = true
  is_ipv6_enabled     = true
  default_root_object = "index.html"
  comment             = "my cloudfront in front of the s3 bucket"

  origin {
    domain_name              = aws_s3_bucket.website_bucket.bucket_regional_domain_name
    origin_id                = "s3_origin_id"
    origin_access_control_id = aws_cloudfront_origin_access_control.default.id
  }

  default_cache_behavior {
    min_ttl                = 0
    default_ttl            = 0
    max_ttl                = 0
    viewer_protocol_policy = "redirect-to-https"

    allowed_methods  = ["GET", "HEAD", "OPTIONS"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "s3_origin_id"

    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }
  }

  restrictions {
    geo_restriction {
      locations        = []
      restriction_type = "none"
    }
  }

  viewer_certificate {
    cloudfront_default_certificate = true 
  }
}

resource "aws_cloudfront_origin_access_control" "default" {
  name                              = "example8"
  description                       = "description of OAC"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

output "cloudfront_url" {
  value = aws_cloudfront_distribution.cdn_static_site.domain_name
}

data "aws_iam_policy_document" "website_bucket" {
  statement {
    actions   = ["s3:GetObject"]
    resources = ["${aws_s3_bucket.website_bucket.arn}/*"]
    principals {
      type        = "Service"
      identifiers = ["cloudfront.amazonaws.com"]
    }
    condition {
      test     = "StringEquals"
      variable = "aws:SourceArn"
      values   = [aws_cloudfront_distribution.cdn_static_site.arn]
    }
  }
}

resource "aws_s3_bucket_policy" "website_bucket_policy" {
  bucket = aws_s3_bucket.website_bucket.id
  policy = data.aws_iam_policy_document.website_bucket.json
}
