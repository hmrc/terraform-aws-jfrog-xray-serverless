resource "artifactory_local_repository" "test_generic" {
  key          = "test-local-generic-repo"
  package_type = "generic"
  xray_index   = true
}

# resource "artifactory_xray_policy" "example" {
#   name        = "policy-name"
#   description = "license policy description"
#   type        = "license"

#   rules {
#     name     = "license-rule"
#     priority = 1
#     criteria {
#       allowed_licenses = ["0BSD", "AAL"]
#     }

#     actions {
#       fail_build = false
#       mails      = []
#       webhooks   = []

#       block_download {
#         active    = false
#         unscanned = false
#       }
#     }
#   }
# }

# resource "artifactory_xray_watch" "example" {
#   name  = "watch-name"

#   resources {
#     type = "all-repos"
#     name = "All Repositories"
#   }

#   assigned_policies {
#     name = artifactory_xray_policy.example.name
#     type = "license"
#   }
# }
