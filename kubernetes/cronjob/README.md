# Lesson 23 - Kubernetes Jobs and CronJobs

Date: 16.10.2026
Environment: Minikube, Kubernetes v1.35.1

## Completed exercises

### 1. Job - migrate
- Successful one-time execution.
- Job status: Complete.

### 2. Job - notagoodjob
File: job-failing.yaml
- backoffLimit: 3
- Container exits with code 1.
- Kubernetes retries the Job.
- Final status: Failed.

### 3. Job - jobwilldead
File: job-deadline.yaml
- activeDeadlineSeconds: 20
- Command sleeps for 600 seconds.
- Job terminated due to time limit.

### 4. Job - jobimbug
File: job-bug.yaml
- podFailurePolicy with FailJob action.
- Exit code 42.
- Kubernetes stops the Job without exhausting retries.

### 5. CronJob - report
File: cronjob.yaml
- Schedule: every minute.
- concurrencyPolicy: Forbid.
- Automatic execution: Complete.
- Manual execution: report-manual - Complete.

### 6. CronJob - slow-backup
File: slow-backup.yaml
- Schedule: every minute.
- Execution duration: 90 seconds.
- concurrencyPolicy: Allow in YAML.
- Confirmed overlapping Jobs.
- Changed live policy to Forbid.
- Suspended both CronJobs after testing.

## Important concepts

- backoffLimit: controls retries.
- activeDeadlineSeconds: limits total Job execution time.
- podFailurePolicy: handles specific failure conditions.
- Allow: permits concurrent Jobs.
- Forbid: skips starting a new Job while the previous one runs.
- Replace: replaces the running Job with a new one.
- suspend: prevents new scheduled executions.

## Results

All planned Job and CronJob examples were tested.
The Forbid configuration was applied but its runtime behavior was not separately verified.
