## プロジェクト概要

このリポジトリは、**Terraform / Ansible / GitHub Actions を用いて AWS インフラ構築からアプリケーションデプロイまでを完全自動化**することを目的としたポートフォリオ用プロジェクトです。

- **目的**
  - IaC・構成管理・CI/CD を組み合わせた一連の自動化パイプラインを示す
  - AWS 上に Web アプリケーション実行基盤を構築し、監視・WAF まで含めた運用を表現する
- **使用技術**
  - **IaC**: Terraform
  - **構成管理**: Ansible
  - **CI/CD**: GitHub Actions
  - **クラウド**: AWS（VPC, EC2, RDS, ALB, WAFv2, CloudWatch, SNS など）

---

## 全体アーキテクチャ

このプロジェクトでは、以下のような構成で Web アプリケーション基盤を構築します。

- **ネットワーク**
  - 専用 VPC
  - Public / Private サブネット（2AZ）
  - Internet Gateway / Route Table / VPC Endpoint(S3)
- **コンピュート & アプリ**
  - Public Subnet 上の EC2（Amazon Linux 2023）
  - Ansible による Web アプリケーション（Spring Boot）のセットアップ & systemd 管理
- **データベース**
  - Private Subnet 上の RDS MySQL
  - EC2 からのみ接続を許可したセキュリティグループ設計
- **フロント / セキュリティ**
  - ALB（ポート 80）→ EC2（ポート 8080）へのルーティング
  - WAFv2 による Web ACL + AWS Managed Rules
- **監視・通知**
  - EC2 CPU 使用率の CloudWatch Alarm
  - WAF ブロックリクエスト数の CloudWatch Alarm
  - SNS（メール）によるアラート通知

### インフラ構成図

インフラ構成図は、以下のようなイメージを想定しています。

- `images/architecture.png` を作成し、ここに埋め込む想定です。

```markdown
![Architecture](images/architecture.png)
```

---

## インフラ構成（Terraform）

Terraform で以下のモジュール構成を取っています。

- **ルート**
  - `main.tf`: backend 設定、`provider "aws"`、各モジュール呼び出し
  - `variables.tf`: プロジェクト共通の入力変数定義
  - `outputs.tf`: CI/CD や運用で利用する主要な出力（EC2 Public IP, ALB DNS など）
- **モジュール構成**
  - **`modules/network`**: VPC, Public/Private Subnet, Route Table, S3 VPC Endpoint
  - **`modules/security`**: ALB / EC2 / RDS 用 Security Group
  - **`modules/compute`**: EC2 インスタンス（最新 Amazon Linux 2023 AMI, キーペア, SG 適用）
  - **`modules/database`**: RDS MySQL（Private Subnet, SG, バックアップ設定など）
  - **`modules/loadbalancer`**: ALB, Target Group, Listener, TargetGroupAttachment
  - **`modules/monitoring`**: SNS トピック, CloudWatch Alarm（EC2 CPU, WAF BlockedRequests）
  - **`modules/waf`**: WAFv2 Web ACL, CloudWatch Logs 連携, ALB へのアタッチ

### Terraform Backend

- **Backend**: S3 リモートバックエンド
  - バケット名やキーは `main.tf` の `backend "s3"` にハードコードしています（学習用簡略化のため）。
  - 同名バケットが存在しない場合は別途作成が必要です。
- **リージョン**
  - `ap-northeast-1`（東京リージョン）を前提としています。

---

## 構成管理（Ansible）

Ansible Playbook で、Terraform によって作成された EC2 上に Web アプリケーション実行環境を構成します。

- **対象ホスト**
  - Terraform Output から取得した EC2 の Public IP を、GitHub Actions 経由で Ansible のインベントリに一時的に設定
- **主なタスク**
  - Java 21（Amazon Corretto）のインストール
  - Git / MariaDB クライアントのインストール
  - 指定 GitHub リポジトリから Spring Boot アプリのクローン
  - `gradlew` に実行権限を付与
  - `systemd` ユニット（`webapp.service`）を作成し、`gradlew bootRun` でアプリを常駐化
- **アプリケーションリポジトリ**
  - `ansible/playbook.yml` 内の `app_repo_url` で別リポジトリを参照しています  
    （どのアプリをデプロイしているかを README で簡単に説明すると親切です）。

---

## CI/CD パイプライン（GitHub Actions）

`.github/workflows/deploy.yml` で、**Terraform によるインフラ構築から Ansible によるデプロイまでを一気通貫で実行**します。

- **トリガー**
  - `main` ブランチへの `push`
  - `main` ブランチへの `pull_request`
  - 手動実行（`workflow_dispatch`）
- **主なステップ**
  - **Terraform**
    - コードチェックアウト
    - Terraform セットアップ
    - `terraform init`
    - `terraform fmt -check`
    - `terraform validate`
    - `terraform plan`
    - `terraform apply`（`main` ブランチへの `push` 時のみ）
  - **Ansible & SSH 一時開放**
    - Terraform Output から EC2 Public IP / SSH 用 SG ID を取得
    - 実行環境のグローバル IP を検出し、Security Group に一時的に 22/tcp を許可
    - Ansible をインストールし、EC2 に対して Playbook を実行
    - `always()` 条件で最後に SSH 許可ルールを削除（クリーンアップ）

---

## 事前準備

### 必要なツール

- Terraform（例: 1.10.0）
- Ansible（ローカルで実行する場合のみ）
- AWS アカウント

### 必要な AWS リソース

- **Terraform State 用 S3 バケット**
  - `main.tf` に記載されたバケット名・キー・リージョンで事前に作成しておきます。
- **IAM ユーザー or ロール**
  - Terraform / AWS CLI（Security Group 操作）/ SNS / WAF / CloudWatch などに必要な権限を付与
  - このプロジェクトではシンプルさを優先し、GitHub Secrets にアクセスキーを設定する形を取っています。

### GitHub Secrets

- **AWS 認証関連**
  - **`AWS_ACCESS_KEY_ID`**: Terraform / AWS CLI 用アクセスキー ID
  - **`AWS_SECRET_ACCESS_KEY`**: 上記アクセスキーのシークレット
- **Terraform 変数連携**
  - **`TF_VAR_db_password`**: RDS の DB パスワード
  - **`TF_VAR_ALERT_EMAIL`**: CloudWatch Alarm 通知先メールアドレス
  - **`TF_VAR_ALLOWED_SSH_CIDR`**: SSH を許可する CIDR（例: `x.x.x.x/32`）
- **SSH キー**
  - **`SSH_PRIVATE_KEY`**: EC2 への SSH 接続で利用する秘密鍵（`key_name` と対になるキー）

---

## セットアップ & デプロイ手順

### 1. リポジトリのクローン

```bash
git clone <このリポジトリのURL>
cd aws-terraform-ansible-cicd-portfolio
```

### 2. Terraform のローカル実行（任意）

ローカルで挙動を確認したい場合は、USAGE 例として以下のように実行します。

```bash
terraform init
terraform plan
terraform apply
```

- `terraform.tfvars` を作成し、`terraform.tfvars.example` を参考に必要な値を設定してください。

### 3. GitHub Actions によるデプロイ

1. 前述の GitHub Secrets を設定
2. `main` ブランチに `push` するか、`workflow_dispatch` で手動実行
3. Workflow が Terraform → Ansible の順で実行され、最終的に ALB 経由でアプリが公開されます。

### 4. 動作確認

- Terraform の output で表示される `alb_dns_name` をブラウザで開く
- CloudWatch のアラーム・SNS メール通知が期待通り動作するか確認します。

---

## セキュリティ・運用上のポイント

- **セキュリティグループ**
  - ALB: 0.0.0.0/0 からの HTTP(80) のみ許可
  - EC2: 
    - SSH(22) は指定 CIDR のみ許可
    - アプリ(8080) は ALB の Security Group からのみ許可
  - RDS:
    - MySQL(3306) は EC2 の Security Group からのみ許可
- **WAF**
  - AWS Managed Rules（CommonRuleSet）を利用し、一般的な攻撃をブロック
  - ALB に対して WAF Web ACL をアタッチ
- **監視**
  - EC2 の CPU 使用率がしきい値を超えた場合に SNS でメール通知
  - WAF によるブロックリクエストが発生した場合にもアラームを発砲

※ 一部構成（例: RDS 暗号化や SSH ベースの運用など）は、**ポートフォリオ/学習用途として簡略化**している部分があります。

---

## モジュール詳細（技術的補足）

- **`network`**
  - VPC / Subnet / Route Table / Internet Gateway / VPC Endpoint(S3)
- **`security`**
  - ALB / EC2 / RDS 用 Security Group の定義と依存関係（ALB → EC2, EC2 → RDS）
- **`compute`**
  - SSM Parameter Store を用いて最新の Amazon Linux 2023 AMI を参照
  - 指定キーペア・Security Group を付与した EC2 を作成
- **`database`**
  - RDS Subnet Group + RDS MySQL インスタンス（Private Subnet 内）
- **`loadbalancer`**
  - ALB, Target Group, Listener, EC2 とのアタッチ
- **`monitoring`**
  - SNS トピック / CloudWatch Alarm（EC2 CPU, WAF BlockedRequests）
- **`waf`**
  - WAFv2 Web ACL, CloudWatch Logs へのログ出力, ALB との関連付け

---

## 今後の改善アイデア

- GitHub Actions での AWS 認証を **OIDC + IAM ロール** に移行
- EC2 へのアクセスを **SSH ではなく SSM Session Manager ベース** に変更
- Terraform に **tflint / tfsec / checkov** などの静的解析を追加
- RDS の **暗号化・gp3 ストレージ** への移行
- アプリヘルスチェック用の専用エンドポイント（例: `/actuator/health`）を用意し ALB ヘルスチェックに利用

---

## ライセンス / 参考情報

- ライセンスは必要に応じて `LICENSE` ファイルを追加してください。
- 参考にしたドキュメントや記事があれば、ここにリンクをまとめておくと良いです。
