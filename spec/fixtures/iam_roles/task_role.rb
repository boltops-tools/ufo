iam_policy("AmazonS3ReadOnlyAccess",
  Action: [
    "s3:Get*",
    "s3:List*"
  ],
  Effect: "Allow",
  Resource: "*"
)
iam_policy("CloudwatchWrite",
  Action: [
    "cloudwatch:PutMetricData",
  ],
  Effect: "Allow",
  Resource: "*"
)

managed_iam_policy("AmazonS3ReadOnlyAccess", "AmazonEC2ReadOnlyAccess")
