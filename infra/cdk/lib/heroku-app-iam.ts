import { Construct } from "constructs";
import * as iam from "aws-cdk-lib/aws-iam";
import * as s3 from "aws-cdk-lib/aws-s3";

export interface HerokuAppIamProps {
  bucket: s3.IBucket;
}

/**
 * Heroku 上の Rails アプリから S3 にアクセスするための IAM ユーザー＋ポリシー
 */
export class HerokuAppIam extends Construct {
  readonly user: iam.User;

  constructor(scope: Construct, id: string, props: HerokuAppIamProps) {
    super(scope, id);

    this.user = new iam.User(this, "HerokuAppUser", {
      userName: "heroku-sato-app",
    });

    const s3Policy = new iam.Policy(this, "HerokuAppS3Policy", {
      statements: [
        new iam.PolicyStatement({
          sid: "ListBucket",
          effect: iam.Effect.ALLOW,
          actions: ["s3:ListBucket"],
          resources: [props.bucket.bucketArn],
        }),
        new iam.PolicyStatement({
          sid: "BucketObjects",
          effect: iam.Effect.ALLOW,
          actions: ["s3:GetObject", "s3:PutObject", "s3:DeleteObject"],
          resources: [props.bucket.arnForObjects("*")],
        }),
      ],
    });

    this.user.attachInlinePolicy(s3Policy);
  }
}

/**
 * ローカル開発用（development）の Rails アプリから S3 にアクセスするための IAM ユーザー＋ポリシー
 * ポリシー内容は Heroku 用と同一で、ユーザー名だけを変えたもの
 */
export class DevAppIam extends Construct {
  readonly user: iam.User;

  constructor(scope: Construct, id: string, props: HerokuAppIamProps) {
    super(scope, id);

    this.user = new iam.User(this, "DevAppUser", {
      userName: "dev-sato-app",
    });

    const s3Policy = new iam.Policy(this, "DevAppS3Policy", {
      statements: [
        new iam.PolicyStatement({
          sid: "ListBucket",
          effect: iam.Effect.ALLOW,
          actions: ["s3:ListBucket"],
          resources: [props.bucket.bucketArn],
        }),
        new iam.PolicyStatement({
          sid: "BucketObjects",
          effect: iam.Effect.ALLOW,
          actions: ["s3:GetObject", "s3:PutObject", "s3:DeleteObject"],
          resources: [props.bucket.arnForObjects("*")],
        }),
      ],
    });

    this.user.attachInlinePolicy(s3Policy);
  }
}
