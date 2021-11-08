output "s3_bucket_id" {
  value = module.s3_cross_accout_module.s3_bucket_id
}

output "s3_bucket_arn" {
  value = module.s3_cross_accout_module.s3_bucket_arn
}

output "kms_arn" {
  value = module.s3_cross_accout_module.kms_arn
}

output "s3_bucket_region" {
    value = module.s3_cross_accout_module.s3_bucket_region
}