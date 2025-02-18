
# Create a local variable to store the subnet IDs
locals {
  public_subnet_ids  = { for idx, subnet in aws_subnet.public : "public-${idx}" => subnet.id }
  private_subnet_ids = { for idx, subnet in aws_subnet.private : "private-${idx}" => subnet.id }
}


locals {
  # Logic for multiple condition
  zone_logic = length(data.aws_availability_zones.available.names) >= 3 ? 3 : length(data.aws_availability_zones.available.names)
  new_bit    = ceil(log((2 * local.zone_logic), 2))
}
