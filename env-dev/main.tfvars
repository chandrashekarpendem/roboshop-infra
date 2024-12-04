env = "dev"
default_vpc_id ="vpc-017e4ed2b0978fa6f"

vpc = {
  main = {
    cidr_block="10.0.0.0/16"
    public_cidr_block=["10.0.0.0/24","10.0.1.0/24"]
    private_cidr_block=["10.0.3.0/24","10.0.4.0/24"]
  }
}