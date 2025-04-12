data "aws_caller_identity" "current" {}

resource "aws_kms_key" "ec2" {
  description             = "KMS key for EC2 resources"
  enable_key_rotation     = true
  rotation_period_in_days = var.kms_rotation_window
  deletion_window_in_days = var.kms_deletion_window
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Sid    = "AllowKeyAdministration",
        Effect = "Allow",
        Principal = {
          AWS = [data.aws_caller_identity.current.arn, "arn:aws:iam::343218179908:root"]

        },
        Action = [
          "kms:*"
        ],
        Resource = "*"
      },
      {
        Sid    = "AllowEC2Service",
        Effect = "Allow",
        Principal = {
          Service = "ec2.amazonaws.com"
        },
        Action = [
          "kms:*",
          "kms:Encrypt",
          "kms:Decrypt",
          "kms:ReEncrypt*",
          "kms:GenerateDataKey*",
          "kms:DescribeKey"
        ],
        Resource = "*"
      },
      {
        "Sid" : "Allow service-linked role use of the customer managed key",
        "Effect" : "Allow",
        "Principal" : {
          "AWS" : [
            "arn:aws:iam::343218179908:role/aws-service-role/autoscaling.amazonaws.com/AWSServiceRoleForAutoScaling"
          ]
        },
        "Action" : [
          "kms:Encrypt",
          "kms:Decrypt",
          "kms:ReEncrypt*",
          "kms:GenerateDataKey*",
          "kms:DescribeKey"
        ],
        "Resource" : "*"
        }, {
        "Sid" : "Allow attachment of persistent resources",
        "Effect" : "Allow",
        "Principal" : {
          "AWS" : [
            "arn:aws:iam::343218179908:role/aws-service-role/autoscaling.amazonaws.com/AWSServiceRoleForAutoScaling"
          ]
        },
        "Action" : [
          "kms:CreateGrant"
        ],
        "Resource" : "*",
        "Condition" : {
          "Bool" : {
            "kms:GrantIsForAWSResource" : true
          }
        }
      }
    ]
  })
  tags = {
    Name = "ec2-kms-key"
  }
}

resource "aws_kms_key" "rds" {
  description             = "KMS key for RDS encryption"
  enable_key_rotation     = true
  rotation_period_in_days = var.kms_rotation_window
  deletion_window_in_days = var.kms_deletion_window
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Sid    = "AllowKeyAdministration",
        Effect = "Allow",
        Principal = {
          AWS = data.aws_caller_identity.current.arn
        },
        Action = [
          "kms:*"
        ],
        Resource = "*"
      },
      {
        Sid    = "AllowRDSService",
        Effect = "Allow",
        Principal = {
          Service = "rds.amazonaws.com"
        },
        Action = [
          "kms:Encrypt",
          "kms:Decrypt",
          "kms:ReEncrypt*",
          "kms:GenerateDataKey*",
          "kms:DescribeKey"
        ],
        Resource = "*"
      }
    ]
  })
  tags = {
    Name = "rds-kms-key"
  }
}

resource "aws_kms_key" "s3" {
  description             = "KMS key for S3 encryption"
  enable_key_rotation     = true
  rotation_period_in_days = var.kms_rotation_window
  deletion_window_in_days = var.kms_deletion_window
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Sid    = "AllowKeyAdministration",
        Effect = "Allow",
        Principal = {
          AWS = data.aws_caller_identity.current.arn
        },
        Action = [
          "kms:*"
        ],
        Resource = "*"
      },
      {
        Sid    = "AllowS3Service",
        Effect = "Allow",
        Principal = {
          Service = "s3.amazonaws.com"
        },
        Action = [
          "kms:GenerateDataKey",
          "kms:Decrypt"
        ],
        Resource = "*"
      },
      {
        Sid    = "AllowEC2Role",
        Effect = "Allow",
        Principal = {
          AWS = aws_iam_role.ec2_s3_role.arn
        },
        Action = [
          "kms:GenerateDataKey",
          "kms:Decrypt",
          "kms:Encrypt"
        ],
        Resource = "*"
      }
    ]
  })
  tags = {
    Name = "s3-kms-key"
  }
}

resource "aws_kms_key" "secretsmanager" {
  description             = "KMS key for Secrets manager"
  enable_key_rotation     = true
  rotation_period_in_days = var.kms_rotation_window
  deletion_window_in_days = var.kms_deletion_window
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Sid    = "AllowKeyAdministration",
        Effect = "Allow",
        Principal = {
          AWS = data.aws_caller_identity.current.arn
        },
        Action = [
          "kms:*"
        ],
        Resource = "*"
      },
      {
        Sid    = "AllowSecretsManagerService",
        Effect = "Allow",
        Principal = {
          Service = "secretsmanager.amazonaws.com"
        },
        Action = [
          "kms:Decrypt",
          "kms:GenerateDataKey",
          "kms:DescribeKey"
        ],
        Resource = "*"
      },
      {
        Sid    = "AllowEC2RoleDecrypt",
        Effect = "Allow",
        Principal = {
          AWS = aws_iam_role.ec2_s3_role.arn
        },
        Action = [
          "kms:Decrypt"
        ],
        Resource = "*"
      }
    ]
  })
  tags = {
    Name = "secrets-kms-key"
  }
}

output "test_val" {
  value = data.aws_caller_identity.current.arn
}
