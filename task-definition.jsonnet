local version = std.extVar('version');  // git sha string or image tag
assert std.length(version) > 0 : 'Version string cannot be empty';

local aws_account_id = std.extVar('aws_account_id');

local service = 'hello-service';

local region = std.extVar('region');
assert region == 'eu-central-1' : 'Region must be eu-central-1';

{
  family: service,
  taskRoleArn: std.format('arn:aws:iam::%s:role/ecsTaskExecutionRole', [aws_account_id]),
  executionRoleArn: std.format('arn:aws:iam::%s:role/ecsTaskExecutionRole', [aws_account_id]),
  networkMode: 'awsvpc',
  requiresCompatibilities: [
    'FARGATE',
  ],
  cpu: '256',
  memory: '512',
  containerDefinitions: [
    {
      essential: true,
      name: service,
      image: std.format('%s.dkr.ecr.%s.amazonaws.com/%s:%s', [aws_account_id, region, service, version]),
      portMappings: [
        {
          containerPort: 5000,
          protocol: 'tcp',
        },
      ],
      environment: [
        {
          name: 'FLASK_APP',
          value: 'hello',
        }
      ],
    },
  ],
}
