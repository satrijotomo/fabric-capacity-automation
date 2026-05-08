# 🚀 Microsoft Fabric Capacity Auto-Pause (Azure Automation)

This solution automatically pauses Microsoft Fabric capacity at a scheduled time using Azure Automation, helping reduce unnecessary compute costs.

---

## ✅ What this does

- Checks Fabric capacity state
- Pauses capacity **only if it's Active**
- Skips execution safely otherwise
- Runs on a schedule (e.g., daily at 9 PM)

---

## 🧱 Architecture

- Azure Automation (Runbook)
- Managed Identity (Authentication)
- Azure Resource Manager (ARM REST API for Fabric)
- Timer-based schedule

---

## 📂 Project Structure
- runbooks/pause-fabric-capacity.ps1
- scripts/create-custom-role.json
- docs/architecture.md

---

## ⚙️ Prerequisites

- Microsoft Fabric capacity (F SKU)
- Azure Automation account
- Managed Identity enabled
- Required RBAC permissions:
Microsoft.Fabric/capacities/read
Microsoft.Fabric/capacities/write
Microsoft.Fabric/capacities/suspend/action
Microsoft.Fabric/capacities/resume/action

---

## 🚀 Deployment Steps

### 1. Create Azure Automation Account

- Enable **System-assigned managed identity**
- Import modules:
  - Az.Accounts
  - Az.Resources

---

### 2. Assign Permissions

Option A (quick test):
- Assign **Contributor** role

Option B (recommended):
- Use `/scripts/create-custom-role.json`
- Assign custom role to:
  - Automation Account Managed Identity

---

### 3. Upload Runbook

1. Go to:
   Azure Portal → Automation Account → Runbooks
2. Create a new runbook:
   - Type: PowerShell
3. Paste script from:
/runbooks/pause-fabric-capacity.ps1

4. Save → Publish

---

### 4. Configure Schedule

- Create a schedule:
- Type: Recurring
- Frequency: Daily
- Time: 21:00 (9 PM)
- Timezone: your local timezone

- Assign parameters:

| Parameter | Value |
|----------|------|
| SubscriptionId | `<your-sub-id>` |
| ResourceGroupName | `<your-rg>` |
| CapacityName | `<your-capacity>` |


## 🔍 How it works

### Step 1:
Calls ARM API:
GET /capacities/{name}

Checks:
- state == Active
- provisioningState == Succeeded

### Step 2:
If conditions match:
POST /capacities/{name}/suspend

---

### Step 3:
Otherwise:
- Skips execution (safe behavior)

---

## ✅ Expected Results

| Scenario | Outcome |
|----------|--------|
| Active capacity | ✅ Paused |
| Already paused | ⏭ Skipped |
| Updating/scaling | ⏭ Skipped |
| Invalid config | ⚠ Logs error |

---

## ⚠️ Important Notes

- Pausing capacity makes Fabric workloads unavailable
- Ensure workloads are not needed during scheduled time
- Consider pairing with a **morning resume job**

---

## 🧠 Enhancements (Future)

- Resume automation (e.g., 7 AM)
- Multi-capacity support via tags
- Slack / Teams notifications
- Cost tracking dashboard

---

## 📜 License

MIT 
