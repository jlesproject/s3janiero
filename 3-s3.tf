provider "aws" {
  region = "us-east-1"  # Set your desired AWS region
}

resource "aws_s3_bucket" "my_bucket" {
  bucket = "bucketsinjaneiro"
  acl    = "public-read"  # Set the ACL at the bucket level for public read access

  tags = {
    Name        = "MyBucket"
    Environment = "Production"
  }

  website {
    index_document = "index.html"
    error_document = "error.html"
  }
}

resource "aws_s3_bucket_object" "dist" {
  for_each = fileset("/Users/jamieleslie/Documents/terraform/AWS/s3homepage/bucketobjects/", "*")

  bucket = aws_s3_bucket.my_bucket.bucket
  key    = each.value
  source = "/Users/jamieleslie/Documents/terraform/AWS/s3homepage/bucketobjects/${each.value}"
  etag   = "fixed-etag"   # Set a fixed etag to force re-upload on every apply
}

resource "aws_s3_bucket_policy" "bucket_policy" {
  bucket = aws_s3_bucket.my_bucket.bucket
  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Sid" : "PublicReadGetObject",
        "Effect" : "Allow",
        "Principal" : "*",
        "Action" : "s3:GetObject",
        "Resource": ["arn:aws:s3:::bucketsinjaneiro/*"]
      }
    ]
  })
}

resource "aws_s3_bucket_object" "index" {
  bucket = aws_s3_bucket.my_bucket.bucket
  key    = "index.html"

  content = <<-EOF
<!DOCTYPE html>
<html>
<head>
  <title>Your Exciting Website</title>
  <style>
    body {
      font-family: 'Arial', sans-serif;
      background-color: #ffeb3b; 
      color: #e91e63;
      text-align: center;
    }

    h1 {
      font-size: 3em; 
      margin-bottom: 20px; 
    }

    p {
      font-size: 1.5em; 
    }

    img {
      width: 35%; 
      border-radius: 10px; 
      margin-top: 20px; 
    }
  </style>
</head>
<body>
  <h1>She told me to tell you...</h1>
  <p>Don't Stop Grinding!</p>
  <img src="https://bucketsinjaneiro.s3.amazonaws.com/brazil.gif" alt="Brazil Image">
</body>
</html>
  EOF

  content_type = "text/html"    # Set the content type of the index.html file
}
