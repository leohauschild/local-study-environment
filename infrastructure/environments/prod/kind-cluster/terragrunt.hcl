include {
  path = find_in_parent_folders()
}

terraform {
  source = "/home/lhausch/my-repos/local-study-environment/infrastructure/tf-modules/kind-cluster/"
}

inputs = {
  cluster_name = "prod"
  workers      = 1
}
