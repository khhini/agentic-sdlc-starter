---
Type: Runbook
title: "<AlertNameOrService> Incident Runbook"
Purpose: Operational triage and resolution procedures for <AlertNameOrService>.
Audience: On-call Engineers, SREs, Software Engineers
Outcome: Zero-ambiguity incident diagnosis, immediate mitigation, and permanent recovery.
severity: P1-Critical # P1-Critical | P2-High | P3-Medium
owning-team: Platform / Core Engineering
alert-binding: "https://prometheus.internal.net/alerts/<AlertName>"
Last Updated: YYYY-MM-DD
---

# Runbook: <AlertNameOrService>

## Table of Contents
1. [Metadata & Escalation](#1-metadata--escalation)
2. [Immediate Mitigation (Stop the Bleeding)](#2-immediate-mitigation-stop-the-bleeding)
3. [Diagnostic Invariants (Probes & Queries)](#3-diagnostic-invariants-probes--queries)
4. [Permanent Remediation & Recovery](#4-permanent-remediation--recovery)
5. [Verification & Post-Mortem](#5-verification--post-mortem)

---

## 1. Metadata & Escalation
- **Primary Alert:** `<AlertName>`
- **SLO Impact:** Affects `<p99 Latency / Error Rate / Availability>` budget.
- **Target MTTR:** `< 15 minutes`
- **Escalation Path:** On-call Lead (`#incident-channel` or PagerDuty escalation policy).

---

## 2. Immediate Mitigation (Stop the Bleeding)
Execute within the first 5 minutes to restore service availability:

```bash
# 1. Immediate rollback to previous stable revision:
kubectl rollout undo deployment/<service-name> -n production

# 2. Or toggle emergency feature flag / circuit breaker:
curl -X POST -H "Authorization: Bearer ${OP_TOKEN}" \
  https://config.internal.net/api/v1/flags/emergency-circuit-breaker/enable
```

---

## 3. Diagnostic Invariants (Probes & Queries)
Replace vague assertions with exact executable probes:

```bash
# Diagnostic 1: Check pod restarts and container termination reasons
kubectl get pods -n production -l app=<service-name> -o jsonpath='{range .items[*]}{.metadata.name}{"\t"}{.status.containerStatuses[0].restartCount}{"\t"}{.status.containerStatuses[0].lastState.terminated.reason}{"\n"}{end}'

# Diagnostic 2: Query 5xx distribution over the last 5 minutes
curl -G -s "http://prometheus.internal:9090/api/v1/query" \
  --data-urlencode 'query=sum(rate(http_requests_total{job="<service-name>",code=~"5.."}[5m])) by (handler)' | jq .

# Diagnostic 3: Tail application error logs
kubectl logs -n production -l app=<service-name> --tail=100 | grep -E "ERROR|FATAL|Exception"
```

---

## 4. Permanent Remediation & Recovery

1. **Database Connection Saturation:**
   ```bash
   # Drain idle connections:
   kubectl exec -it deploy/<service-name> -n production -- /bin/drain-connections.sh
   ```
2. **Rolling Restart:**
   ```bash
   kubectl rollout restart deployment/<service-name> -n production
   kubectl rollout status deployment/<service-name> -n production --timeout=120s
   ```

---

## 5. Verification & Post-Mortem
1. Verify 5xx error rate drops below SLO threshold (`< 0.1%`):
   ```bash
   curl -s "http://prometheus.internal:9090/api/v1/query" \
     --data-urlencode 'query=sum(rate(http_requests_total{job="<service-name>",code=~"5.."}[5m])) / sum(rate(http_requests_total{job="<service-name>"}[5m]))' | jq .
   ```
2. File post-incident review ticket if P1/P2 threshold was breached.
