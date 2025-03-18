resource "aws_dynamodb_table" "terraform_lock" {
  name         = "terraform-lock"  # Table name for state locking
  billing_mode = "PAY_PER_REQUEST" # On-demand billing mode

  hash_key = "LockID" # Partition key
  attribute {
    name = "LockID"
    type = "S"
  }

  tags = {
    Name = "Terraform Lock Table"
  }
}
