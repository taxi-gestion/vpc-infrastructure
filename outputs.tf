locals {
  export_as_organization_variable = {
    "vpc_id" = {
      hcl   = false
      value = aws_vpc.vpc.id
    }
    "public_route_table_id" = {
      hcl   = false
      value = aws_route_table.public_route_table.id
    }
    "private_route_table_id" = {
      hcl   = false
      value = aws_route_table.private_route_table.id
    }
    "private_subnets_ids" = {
      hcl   = true
      value = [aws_subnet.private_1.id, aws_subnet.private_2.id]
    }
    "public_subnets_ids" = {
      hcl   = true
      value = [aws_subnet.public_1.id, aws_subnet.public_2.id]
    }
  }
}

data "tfe_organization" "organization" {
  name = var.terraform_organization
}

data "tfe_variable_set" "variables" {
  name         = "variables"
  organization = data.tfe_organization.organization.name
}

resource "tfe_variable" "output_values" {
  for_each = local.export_as_organization_variable

  key             = each.key
  value           = each.value.hcl ? jsonencode(each.value.value) : tostring(each.value.value)
  category        = "terraform"
  description     = "${each.key} variable from the ${var.service} service"
  variable_set_id = data.tfe_variable_set.variables.id
  hcl             = each.value.hcl
}
