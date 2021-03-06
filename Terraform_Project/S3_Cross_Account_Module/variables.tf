
variable "name_prefix" {
  type        = string
  default     = "assignment"
}

# We can use list of accounts for multiple cross-account access 

   variable "cross_account_ids" {
   type = list
   default = ["856866741119","064349442911"]
 }

# If we already have a s3 bucket  created for logging then we can directly use log bucket id 
# variable "log_bucket_id" {
#  type = "string"
# }


