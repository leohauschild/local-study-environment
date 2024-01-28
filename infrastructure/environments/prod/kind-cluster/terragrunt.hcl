include {
  path = find_in_parent_folders()
}

terraform {
  source = "../../../tf-modules/kind-cluster/"
}

inputs = {
  cluster_name = "prod"
  workers      = 1
}
