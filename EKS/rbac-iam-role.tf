#Creatin IAM role for super-admin

resource "aws_iam_role" "super-admin_role" {
  name = "super-admin-${var.cluster_name}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action    = "sts:AssumeRole",
        Effect    = "Allow",
        Principal = {
          AWS = "*"
        }
      }
    ]
  })
}

# Attach EKS full access policy to the IAM role
resource "aws_iam_role_policy_attachment" "eks_full_access_policy_attachment" {
  role       = aws_iam_role.super-admin_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
}

resource "aws_iam_role_policy_attachment" "eks_service_policy_attachment" {
  role       = aws_iam_role.super-admin_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSServicePolicy"
}