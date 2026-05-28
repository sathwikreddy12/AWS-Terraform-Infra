# ─── S3 BUCKET ──────────────────────────────────────────────

resource "aws_s3_bucket" "main" {
  bucket = var.bucket_name
  # bucket name must be globally unique
  # if name is taken terraform apply will fail

  tags = {
    Name        = var.bucket_name
    Environment = var.environment
    ManagedBy   = "terraform"
  }
}

# ─── BLOCK ALL PUBLIC ACCESS ────────────────────────────────

resource "aws_s3_bucket_public_access_block" "main" {
  bucket = aws_s3_bucket.main.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
  # all four must be true to fully block public access
  # without this anyone on internet could read your files
  # this is the most important security setting for S3
}

# ─── VERSIONING ─────────────────────────────────────────────

resource "aws_s3_bucket_versioning" "main" {
  bucket = aws_s3_bucket.main.id

  versioning_configuration {
    status = var.enable_versioning ? "Enabled" : "Suspended"
    # ternary operator — works like if/else
  }
}

# ─── ENCRYPTION ─────────────────────────────────────────────

resource "aws_s3_bucket_server_side_encryption_configuration" "main" {
  bucket = aws_s3_bucket.main.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
      # AES256 = industry standard encryption algorithm
      # every file stored in this bucket is encrypted
    }
  }
}

