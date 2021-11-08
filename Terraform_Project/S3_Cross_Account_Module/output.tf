
# Requirement: It must output the bucket id, the bucket arn, and the kms arn.

output "s3_bucket_id" {
  value = aws_s3_bucket.main_bucket.id
}

output "s3_bucket_arn" {
  value = aws_s3_bucket.main_bucket.arn
}

output "kms_arn" {
  value = aws_kms_key.mykey.arn
}

output "s3_bucket_region" {
    value = aws_s3_bucket.main_bucket.region
}