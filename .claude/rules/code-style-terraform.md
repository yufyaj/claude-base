---
paths:
  - "terraform/*"
---

# 環境
- dev
- stg
- prod

# 遵守事項
- 以下の構成に従ってください
terraform
├── modules
│   ├── cloud_run
│   │    ├── main.tf
│   │    ├── variables.tf
│   │    └── output.tf
│   └── cloud_storage
│        ├── main.tf
│        ├── variables.tf
│        └── output.tf
├── dev
│   ├── main.tf
│   ├── variables.tf
│   └── terraform.tfvars
├── prd
│   ├── main.tf
│   ├── variables.tf
│   └── terraform.tfvars
└── stg
    ├── main.tf
    ├── variables.tf
    └── terraform.tfvars
- セキュリティを最重要視してください
- オーバースペックにしないでください
- 公式のモジュールを採用してください
- 単語の区切りはアンダースコアを使用してください
