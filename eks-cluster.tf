resource "aws_eks_cluster" "main" {
  name     = "${var.project-name}-cluster"
  role_arn = aws_iam_role.cluster.arn
  vpc_config {
    subnet_ids              = flatten([aws_subnet.private[*].id, aws_subnet.public[*].id])
    endpoint_public_access  = true
    endpoint_private_access = true
    public_access_cidrs     = ["0.0.0.0/0"]
  }
  tags = merge(var.common_tags, {
    "Name" : "${var.project-name}-cluster"
  })

  depends_on = [
    aws_iam_role_policy_attachment.cluster_policy_attach
  ]
}

resource "aws_iam_role" "cluster" {
  name               = "${var.project-name}-cluster-role"
  assume_role_policy = data.aws_iam_policy_document.assume_Role.json
}

resource "aws_iam_role_policy_attachment" "cluster_policy_attach" {
  role       = aws_iam_role.cluster.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
}