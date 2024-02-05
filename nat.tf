resource "aws_eip" "nat_prod" {
  vpc = true

  lifecycle {
    create_before_destroy = true
  }
  depends_on = [aws_internet_gateway.this]
}

resource "aws_nat_gateway" "nat_gw" {
  allocation_id = aws_eip.nat_prod.id
  subnet_id     = aws_subnet.public[0].id

  tags = {
    Name = "NAT_gateway"
  }

  # To ensure proper ordering, it is recommended to add an explicit dependency
  # on the Internet Gateway for the VPC.
  depends_on = [aws_eip.nat_prod]
}