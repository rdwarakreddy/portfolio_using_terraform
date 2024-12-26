resource "aws_s3_bucket" "example" {
  bucket = var.bucketname
}

# Changing the control of the Bucket
resource "aws_s3_bucket_ownership_controls" "example" {
  bucket = aws_s3_bucket.example.id

  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

# Making the Bucket Public
resource "aws_s3_bucket_public_access_block" "example" {
  bucket = aws_s3_bucket.example.id

  block_public_acls       = false
  block_public_policy     = false  # This should be false to allow public policies
  ignore_public_acls      = false
  restrict_public_buckets = false
}

# ACL setting for the Bucket
resource "aws_s3_bucket_acl" "example" {
  depends_on = [
    aws_s3_bucket_ownership_controls.example,
    aws_s3_bucket_public_access_block.example,
  ]

  bucket = aws_s3_bucket.example.id
  acl    = "public-read"
}

# Upload the file into the bucket (index.html)
resource "aws_s3_object" "index" {
  bucket = aws_s3_bucket.example.id
  key    = "index.html"
  source = "index.html"
  acl    = "public-read"
  content_type = "text/html"
}

# Upload the file into the bucket (profile image)
resource "aws_s3_object" "profile" {
  bucket = aws_s3_bucket.example.id
  key    = "Dwarak image.jpg"
  source = "Dwarak image.jpg"
  acl    = "public-read"
}

# Configure the Bucket to act as a website
resource "aws_s3_bucket_website_configuration" "website" {
  bucket = aws_s3_bucket.example.id

  index_document {
    suffix = "index.html"
  }

  depends_on = [aws_s3_bucket_acl.example]
}

# Add a Bucket Policy to allow public access (for GET requests)
resource "aws_s3_bucket_policy" "example" {
  bucket = aws_s3_bucket.example.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect    = "Allow"
        Principal = "*"
        Action    = "s3:GetObject"
        Resource  = "${aws_s3_bucket.example.arn}/*"
      }
    ]
  })
}
