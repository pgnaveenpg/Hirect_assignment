resource "aws_ecr_repository" "repo" {
  name = "${var.name}"
}

data "aws_caller_identity" "current" {}

data "aws_iam_policy_document" "repo" {
  statement {
    actions = [
      "ecr:BatchCheckLayerAvailability",
      "ecr:BatchGetImage",
      "ecr:DescribeImageScanFindings",
      "ecr:DescribeImages",
      "ecr:DescribeRepositories",
      "ecr:GetDownloadUrlForLayer",
      "ecr:GetLifecyclePolicy",
      "ecr:GetLifecyclePolicyPreview",
      "ecr:GetRepositoryPolicy",
      "ecr:ListImages",
      "ecr:ListTagsForResource",
      
    ]
    principals {
      identifiers = [
        "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root",
        "arn:aws:iam::${element(var.cross_account_ids,1)}:root"
      ]
      type = "AWS"
    }
    sid     = "AllowReadonlyAccesstoCrossAccountUsers"
  }
}

resource "aws_ecr_repository_policy" "repo" {
  policy      = "${data.aws_iam_policy_document.repo.json}"
  repository  = "${aws_ecr_repository.repo.name}"
}

resource "aws_ecr_lifecycle_policy" "repo" {
  policy      = "${file("${path.module}/lifecycle-policy.json")}"
  repository  = "${aws_ecr_repository.repo.name}"
}