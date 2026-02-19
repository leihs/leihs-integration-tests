# Security Fixes — integration-tests

**Date:** 2026-02-19

## Summary

Six security vulnerabilities were resolved by updating three gems in `Gemfile.lock`.

| Gem | Previous Version | Updated Version |
|---|---|---|
| rack | 2.2.21 | **3.2.5** |
| rack-protection | 3.2.0 | **4.2.1** |
| rack-test | 1.1.0 | **2.2.0** |
| sinatra | 3.2.0 | **4.2.1** |
| net-imap | 0.3.4 | **0.6.3** |

---

## Vulnerabilities Fixed

### 1. Rack — Directory Traversal via Rack::Directory (HIGH)

- **Alert:** #66
- **CVE:** CVE-2026-25500 (related)
- **Severity:** High
- **Fix:** rack >= 2.2.22 / >= 3.1.20 / >= 3.2.5
- **Resolved with:** rack 3.2.5

### 2. Rack — Stored XSS in Rack::Directory via `javascript:` filenames (MODERATE)

- **Alert:** #67
- **CVE:** CVE-2026-25500
- **Severity:** Moderate (CVSS 5.4)
- **Description:** `Rack::Directory` renders filenames starting with `javascript:` as clickable anchor `href` values, allowing script execution when clicked.
- **Fix:** rack >= 2.2.22 / >= 3.1.20 / >= 3.2.5
- **Resolved with:** rack 3.2.5

### 3. net-imap — Possible DoS by memory exhaustion (MODERATE)

- **Alert:** #48
- **CVE:** CVE-2025-25186
- **Severity:** Moderate
- **Description:** A malicious IMAP server can send highly compressed `uid-set` data that expands to enormous arrays when parsed (e.g. 40 bytes expanding to ~1.6 GB).
- **Fix:** net-imap >= 0.3.8 / >= 0.4.19 / >= 0.5.6
- **Resolved with:** net-imap 0.6.3

### 4. net-imap — DoS by memory exhaustion via literal response size (MODERATE)

- **Alert:** #55
- **CVE:** GHSA-j3g3-5qv5-52mj
- **Severity:** Moderate
- **Description:** A malicious server can send literal byte counts in IMAP responses that cause the client to allocate massive amounts of memory without limits.
- **Fix:** net-imap >= 0.3.9 / >= 0.4.20 / >= 0.5.7
- **Resolved with:** net-imap 0.6.3

### 5. Sinatra — Reliance on Untrusted Inputs in a Security Decision (MODERATE)

- **Alert:** #47
- **CVE:** CVE-2024-21510
- **Severity:** Moderate (CVSS 5.4)
- **Description:** Attackers can trigger Open Redirect attacks via the `X-Forwarded-Host` header. When used with caching servers or reverse proxies, this can lead to Cache Poisoning or Routing-based SSRF.
- **Fix:** sinatra >= 4.1.0
- **Resolved with:** sinatra 4.2.1

### 6. Sinatra — ReDoS through ETag header value generation (LOW)

- **Alert:** #65
- **CVE:** CVE-2025-61921
- **Severity:** Low
- **Description:** Crafted input in `If-Match` and `If-None-Match` headers can cause excessive processing time in the `etag` method. Particularly affects applications using Ruby < 3.2.
- **Fix:** sinatra >= 4.2.0
- **Resolved with:** sinatra 4.2.1

---

## Changes Made

### Gemfile

```diff
- gem "net-imap", require: false
+ gem "net-imap", ">= 0.3.9", require: false

- gem "sinatra"
+ gem "sinatra", ">= 4.2.0"
```

### Notes

- Upgrading sinatra from 3.x to 4.x also moved rack from 2.x to 3.x, which resolved the rack vulnerabilities as well.
- `rack-protection` and `rack-session` were updated automatically as sinatra 4.x dependencies.
- `rack-test` was upgraded from 1.1.0 to 2.2.0 to maintain compatibility with rack 3.x.
