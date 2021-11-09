
data "aws_caller_identity" "current" {}


# Creating aws iam policy document

data "aws_iam_policy_document" "lambda" {
  statement {
    actions = [
      "s3:*"
    ]
    condition {
      test = "Bool"
      values = [
        "false"
      ]
      variable = "aws:SecureTransport"
    }
    effect = "Deny"
    principals {
      identifiers = [
        "*"
      ]
      type = "AWS"
    }
    resources = [
      "${aws_s3_bucket.main_bucket.arn}",
      "${aws_s3_bucket.main_bucket.arn}/*"
    ]
    sid = "DenyUnsecuredTransport"
  }
  statement {
    actions = [
      "s3:PutObject"
    ]
    condition {
      test = "StringNotEquals"
      values = [
        "AES256"
      ]
      variable = "s3:x-amz-server-side-encryption"
    }
    effect = "Deny"
    principals {
      identifiers = [
        "*"
      ]
      type = "AWS"
    }
    resources = [
      "${aws_s3_bucket.main_bucket.arn}",
      "${aws_s3_bucket.main_bucket.arn}/*"
    ]
    sid = "DenyIncorrectEncryptionHeader"
  }
  statement {
    actions = [
      "s3:PutObject"
    ]
    condition {
      test = "Null"
      values = [
        "true"
      ]
      variable = "s3:x-amz-server-side-encryption"
    }
    effect = "Deny"
    principals {
      identifiers = [
        "*"
      ]
      type = "AWS"
    }
    resources = [
      "${aws_s3_bucket.main_bucket.arn}",
      "${aws_s3_bucket.main_bucket.arn}/*"
    ]
    sid = "DenyUnencryptedObjectUploads"
  }
  statement {
    actions = [
      "s3:GetObject",
      "s3:ListBucket",
     ]
    principals {
      identifiers = [
        "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root",
      # "arn:aws:iam::${data.aws_caller_identity.guest.account_id}:root",
        "arn:aws:iam::${element(var.cross_account_ids,1)}:root"
      ]
      type = "AWS"
    }
    resources = [
      "${aws_s3_bucket.main_bucket.arn}",
      "${aws_s3_bucket.main_bucket.arn}/*"
    ]
    sid = "AllowCrossAccountAccess"
  }
}


# Creating Logging bucket
resource "aws_s3_bucket" "log_bucket" {
  bucket = "${var.name_prefix}-lambda-functions"
  acl    = "log-delivery-write"



 tags = {
    Name        = "${var.name_prefix}-lambda-functions"
    Environment = "Log_Glacier_Backend"
  }

}

# KMS key generation

resource "aws_kms_key" "mykey" {
  description             = "This key is used to encrypt bucket objects"
  deletion_window_in_days = 10
}

# Creating Main Bucket

resource "aws_s3_bucket" "main_bucket" {
  bucket = "${var.name_prefix}-lambda-functions-main-bucket"
   
   tags = {
   Name        = "Main_bucket"
   Environment = "Prod"
  }

  versioning {
     enabled = true
   }

  lifecycle {
    prevent_destroy = true
  }
  
  lifecycle_rule {
    abort_incomplete_multipart_upload_days = 7
    id      = "versions"
    enabled = true
    expiration {
      expired_object_delete_marker = true
    }
         
    noncurrent_version_expiration {
      days = 180
    }
    noncurrent_version_transition {
      days          = 30
      storage_class = "GLACIER"
    }
  }

    logging {
    target_bucket = aws_s3_bucket.log_bucket.id
    target_prefix = "s3/${var.name_prefix}-lambda-functions/"
  }

   server_side_encryption_configuration {
     rule {
      apply_server_side_encryption_by_default {
        kms_master_key_id = aws_kms_key.mykey.arn
        sse_algorithm     = "aws:kms"
      }
    }
  }
   
}

resource "aws_s3_bucket_policy" "lambda" {
  bucket = "${aws_s3_bucket.main_bucket.id}"
  policy = "${data.aws_iam_policy_document.lambda.json}"
}































