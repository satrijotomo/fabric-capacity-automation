# Architecture

This solution uses Azure Automation to schedule and execute Fabric capacity pause operations.

## Components

- Azure Automation Account
- Managed Identity (for authentication)
- Azure Resource Manager REST API
- Microsoft Fabric Capacity

## Flow

1. Runbook executes on schedule
2. Authenticates using Managed Identity
3. Calls ARM API to check capacity state
4. Calls suspend API if conditions are met

## Benefits

- Cost optimization
- Fully automated
- No user dependency