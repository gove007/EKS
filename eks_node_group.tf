resource "aws_eks_node_group" "name" {
  cluster_name    = aws_eks_cluster.main.name
  node_group_name = var.project-name
  subnet_ids      = aws_subnet.private[*].id
  node_role_arn   = aws_iam_role.node.arn

  scaling_config {
    desired_size = var.desired_size
    max_size     = var.max_size
    min_size     = var.min_size
  }

  update_config {
    max_unavailable = 1
  }
  ami_type       = "AL2_x86_64"
  disk_size      = 20
  capacity_type  = "ON_DEMAND"
  instance_types = [var.node_group_instance_type]

  depends_on = [
    aws_iam_role_policy_attachment.node_eksworkernode
  ]
  provisioner "local-exec" {
    on_failure = continue
    command    = "aws eks update-kubeconfig --name demo-eks-cluster --region us-east-1 --profile default"
  }

}

resource "aws_iam_role" "node" {
  name               = "${var.project-name}-worker-role"
  assume_role_policy = data.aws_iam_policy_document.assume_role_node.json
  tags = {
    "Name" : "${var.project-name}-worker-role"
  }
}

resource "aws_iam_role_policy_attachment" "node_eksworkernode" {
  for_each   = var.eks_node_role_policy
  role       = aws_iam_role.node.name
  policy_arn = each.value
}

