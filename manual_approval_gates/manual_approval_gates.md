# Manual Approvals

1. To add manual approval gates for parallel deployments, you must configure Environments in your repository settings and then reference them in your workflow. When a job references an environment with a "Required reviewers" protection rule, it will pause until an authorized user approves it. 

2. Configure the Environment in GitHub 
Navigate to your repository on GitHub and click Settings.
In the left sidebar, click Environments.
Click New environment and give it a name (e.g., production or staging).
Under Deployment protection rules, select Required reviewers.
Add up to 6 people or teams as reviewers and click Save protection rules

3. Update Your Workflow File 
Reference the environment in your job using the environment keyword. 

Parallel Deployment to Multiple Environments
Each job runs in parallel and will trigger its own approval gate if configured.


jobs:
  deploy-aws:
    runs-on: ubuntu-latest
    environment: aws-production  # Reference the env name from Settings
    steps:
      - run: echo "Deploying to AWS..."

  deploy-azure:
    runs-on: ubuntu-latest
    environment: azure-production
    steps:
      - run: echo "Deploying to Azure..."


-----------

Parallel Deployment via Matrix Strategy
If you use a matrix to deploy to multiple targets, you can dynamically assign the environment. GitHub will create a separate deployment for each matrix item.

jobs:
  deploy:
    runs-on: ubuntu-latest
    strategy:
      matrix:
        target: [us-east-1, eu-west-1]
    environment: ${{ matrix.target }}  # Each region must exist in Settings
    steps:
      - run: echo "Deploying to ${{ matrix.target }}..."

----------

Key Considerations
Permissions: Environments with manual approvals are available for all public repositories. For private repositories, you typically need a GitHub Enterprise or Pro plan.
Secrets: You can define environment-specific secrets (e.g., API_KEY) in the environment settings. These are only accessible to the job after the deployment is approved.
Wait Timers: You can also add a Wait timer in the environment settings to force a delay (e.g., 10 minutes) even after approval. 

