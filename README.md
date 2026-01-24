# AWS Infrastructure & Deployment Automation Portfolio

![GitHub Actions](https://github.com/koujienami/aws-terraform-ansible-cicd-portfolio/actions/workflows/terraform.yml/badge.svg)
Terraform・Ansible・GitHub Actions を用いて、AWSインフラ構築からミドルウェア設定、アプリケーションのデプロイまでを **完全自動化** したポートフォリオです。

単に「動く環境を作る」だけでなく、**「実務での運用・セキュリティ・保守性」** を意識した設計（最小権限の原則、Systemdによるプロセス管理、OSの汎用性担保など）を取り入れています。

## 📖 プロジェクト概要

本プロジェクトは、インフラのコード化 (IaC) と継続的デプロイ (CD) の学習および実践を目的としています。
GitHub の `main` ブランチにコードをプッシュするだけで、以下のフローが自動で完結します。

1.  **Terraform**: AWS環境（VPC, EC2, RDS, ALB, SG等）の構築・変更適用
2.  **Ansible**: OS設定、ミドルウェア導入、アプリのデプロイ・起動設定
3.  **App**: Java (Spring Boot) アプリケーションの稼働

## 🏗 インフラ構成図

![Architecture Diagram](./docs/images/architecture.png)
### 採用技術スタック

| Category | Technology | Detail |
| :--- | :--- | :--- |
| **Cloud Provider** | AWS | VPC, EC2 (Amazon Linux 2023), RDS (MySQL/MariaDB), ALB, S3 |
| **IaC** | Terraform | インフラのリソース管理・構成管理 |
| **Config Mgmt** | Ansible | サーバー内部設定、ミドルウェアインストール、アプリデプロイ |
| **CI/CD** | GitHub Actions | パイプラインの自動実行、テスト、デプロイ |
| **Application** | Java 21 | Spring Boot アプリケーション |
| **Database** | MariaDB | RDSへの接続クライアントとして使用 |

## 💡 こだわりポイント（実務を意識した設計）

本ポートフォリオでは、単なる自動化に留まらず、以下の運用・保守・セキュリティ観点を重視して実装しました。

### 1. セキュリティ：最小権限の原則 (Least Privilege)
Ansible の実行において、全タスクを root で実行するのではなく、**システム設定とアプリケーション操作の権限を明確に分離** しました。
* `dnf` などのシステム変更： `root` 権限
* `git clone` やアプリ起動： `ec2-user` 権限
これにより、アプリケーションプロセスが root で動作するリスクを排除し、ログファイル等の所有権トラブルも防いでいます。

### 2. 可用性・運用性：Systemd によるプロセス管理
学習用によく使われる `nohup` コマンドではなく、**Systemd のユニットファイル (`webapp.service`)** を作成し、OS標準の機能で管理しています。
* サーバー再起動時のアプリケーション自動起動
* プロセスダウン時の自動復旧
* `systemctl` コマンドによる統一的な操作
* `journalctl` によるログ管理

### 3. コードの汎用性・保守性 (Portability)
Ansible Playbook 内でハードコーディング（決め打ち）を避け、**OS情報 (`ansible_distribution`) に基づく動的なパッケージ選定** を実装しました。
これにより、将来的に Amazon Linux 2 や 他のディストリビューションへ移行した際も、コードの大幅な改修なしに対応可能です。

### 4. CI/CD パイプラインの高速化
開発サイクルを回しやすくするため、CIパイプラインにおける `Terraform Test`（リソースの仮作成と破棄）の実行タイミングを最適化し、デプロイ時間を大幅に短縮しました。

## 📂 ディレクトリ構成

```text
.
├── .github
│   └── workflows      # GitHub Actions 定義 (CI/CD)
├── ansible
│   └── playbook.yml   # Ansible Playbook (サーバー設定・デプロイ)
├── terraform
│   ├── modules        # 再利用可能なTerraformモジュール
│   └── main.tf        # AWSリソース定義のエントリーポイント
└── tests              # テストコード
