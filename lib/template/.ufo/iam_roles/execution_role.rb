# Example starter execution role. Add the iam role permissions that the host needs here:
#
# More docs: https://ufoships.com/docs/iam-roles/
#
managed_iam_policy("AmazonSSMReadOnlyAccess")
managed_iam_policy("SecretsManagerReadWrite")
managed_iam_policy("service-role/AmazonECSTaskExecutionRolePolicy")
