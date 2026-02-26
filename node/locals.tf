locals {
  vcluster_name      = nonsensitive(var.vcluster.instance.metadata.name)
  vcluster_namespace = nonsensitive(var.vcluster.instance.metadata.namespace)

  subnet_id             = nonsensitive(var.vcluster.nodeEnvironment.outputs.infrastructure["private_subnet_ids"][random_integer.subnet_index.result])
  instance_type         = nonsensitive(var.vcluster.nodeType.spec.properties["instance-type"])
  security_group_id     = nonsensitive(var.vcluster.nodeEnvironment.outputs.infrastructure["security_group_id"])
  user_data             = var.vcluster.userData != "" ? var.vcluster.userData : null
  instance_profile_name = nonsensitive(var.vcluster.nodeEnvironment.outputs.infrastructure["instance_profile_name"])
  cluster_tag           = nonsensitive(var.vcluster.nodeEnvironment.outputs.infrastructure["cluster_tag"])
  
  # All properties coming from the Loft NodeClaim
  node_properties = try(var.vcluster.nodeClaim.spec.properties, {})

  # Simple test
  test_tag = try(local.node_properties["test"], null)

  # Optional: allow passing many tags as JSON in a single property
  aws_extra_tags = try(jsondecode(local.node_properties["awsTagsJson"]), {})

  derived_aws_tags = merge(
    local.aws_extra_tags,
    local.test_tag != null ? { test = tostring(local.test_tag) } : {}
  )
}
