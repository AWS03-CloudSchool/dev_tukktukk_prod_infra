resource "aws_s3_bucket" "court_image_storage" {
  bucket = "${var.tuktuk_env}-court-image-storage"
}

resource "aws_s3_bucket_public_access_block" "court_image_storage_accblock" {
  bucket = aws_s3_bucket.court_image_storage.id

  block_public_acls   = false
  block_public_policy = false
  ignore_public_acls  = false
  restrict_public_buckets = false

  depends_on = [ aws_s3_bucket.court_image_storage ]
}

resource "aws_s3_bucket_policy" "court_image_storage_policy" {
  bucket = aws_s3_bucket.court_image_storage.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "allowGetObjectPRODCourtImage"
        Effect    = "Allow"
        Principal = "*"
        Action    = "s3:GetObject"
        Resource  = "${aws_s3_bucket.court_image_storage.arn}/*"
      },
    ]
  })

  depends_on = [ aws_s3_bucket_public_access_block.court_image_storage_accblock ]
}
