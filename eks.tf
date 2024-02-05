# eks Role 생성
resource "aws_iam_role" "eks_cluster_role" {
  name = "cluster-role-${var.infra_name}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "eks.amazonaws.com"
        }
      },
    ]
  })

  tags = {
    "Name" = var.infra_name
  }

  depends_on = [ aws_eip.eip_nat ]
}

resource "aws_iam_role_policy_attachment" "eks_cluster_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.eks_cluster_role.name
}

# eks 생성
resource "aws_eks_cluster" "prod_cluster" {
  name     = var.infra_name
  role_arn = aws_iam_role.eks_cluster_role.arn
  version  = "1.28"  

  vpc_config {
    subnet_ids = aws_subnet.private[*].id
    endpoint_public_access = true
  }


  depends_on = [
    aws_iam_role_policy_attachment.eks_cluster_policy
  ]
}

# 인증정보
data "aws_eks_cluster_auth" "prod_cluster" {
  name = aws_eks_cluster.prod_cluster.name
  depends_on = [ aws_eks_cluster.prod_cluster ]
}