<#

- Cloudflare DDNS updater (Windows / PowerShell)
- Author: Maarten Schmeitz (https://mrtn.blog)
- Automatically retrieves Zone ID
- Finds or creates A-record (IPv4)
- Updates only when IP changes


Fill in the variables under "CONFIG".
#>

# ---------------- CONFIG ----------------
$ApiToken   = "ENTER_TOKEN_HERE"  # API Token with "Zone.DNS" permissions
$ZoneName   = "DOMAIN"           # your domain/zone, without subdomain
$RecordName = "FQDN"       # FQDN you want to update
$TTL        = 120                       # 1-86400 or 1 = Auto
$Proxied    = $false                    # for raw TCP/vpn/DDNS usually false
$IpSourceUrls = @(
  "https://ifconfig.me",
  "https://api.ipify.org",
  "https://ipv4.icanhazip.com"
)
# ---- Optional: also update AAAA-record (IPv6)
$EnableIPv6 = $false
$IPv6SourceUrls = @(
  "https://api64.ipify.org",
  "https://ifconfig.co/ip"
)
# ----------------------------------------

function Get-PublicIP {
  param([string[]]$Urls)
  foreach ($u in $Urls) {
    try {
      $ip = (Invoke-RestMethod -Uri $u -TimeoutSec 5).Trim()
      if ([System.Net.IPAddress]::TryParse($ip, [ref]([System.Net.IPAddress]::Any))) {
        return $ip
      }
    } catch { continue }
  }
  throw "Could not retrieve public IP from: $($Urls -join ', ')"
}

function Use-CfApi {
  param(
    [ValidateSet("GET","POST","PUT","PATCH","DELETE")] [string]$Method,
    [string]$Path,
    [hashtable]$Body
  )
  $base = "https://api.cloudflare.com/client/v4"
  $headers = @{ "Authorization" = "Bearer $ApiToken"; "Content-Type" = "application/json" }
  if ($Body) {
    return Invoke-RestMethod -Method $Method -Uri "$base/$Path" -Headers $headers -Body ($Body | ConvertTo-Json -Depth 5)
  } else {
    return Invoke-RestMethod -Method $Method -Uri "$base/$Path" -Headers $headers
  }
}

try {
  # 1) Retrieve current IPs
  $ipv4 = Get-PublicIP -Urls $IpSourceUrls
  Write-Host "[INFO] Public IPv4: $ipv4"

  if ($EnableIPv6) {
    $ipv6 = Get-PublicIP -Urls $IPv6SourceUrls
    Write-Host "[INFO] Public IPv6: $ipv6"
  }

  # 2) Retrieve Zone ID
  $zoneResp = Use-CfApi -Method GET -Path "zones?name=$ZoneName"
  if (-not $zoneResp.success -or $zoneResp.result.Count -eq 0) {
    throw "Zone '$ZoneName' not found or no access."
  }
  $zoneId = $zoneResp.result[0].id
  Write-Host "[INFO] Zone ID: $zoneId"

  # Helper: process record (A or AAAA)
  function Set-Record {
    param(
      [string]$ZoneId, [string]$RecordName, [string]$Type, [string]$Content, [int]$TTL, [bool]$Proxied
    )
  $q = Use-CfApi -Method GET -Path "zones/$ZoneId/dns_records?type=$Type&name=$RecordName"
    $existing = $null
    if ($q.success -and $q.result.Count -gt 0) { $existing = $q.result[0] }

    if ($existing) {
      if ($existing.content -eq $Content -and ($TTL -eq 1 -or $existing.ttl -eq $TTL) -and $existing.proxied -eq $Proxied) {
        Write-Host "[OK] $Type $RecordName is already up-to-date ($Content)."
        return
      }
      Write-Host "[INFO] Updating: $Type $RecordName -> $Content"
      $body = @{ type=$Type; name=$RecordName; content=$Content; ttl=$TTL; proxied=$Proxied }
  $upd = Use-CfApi -Method PUT -Path "zones/$ZoneId/dns_records/$($existing.id)" -Body $body
      if (-not $upd.success) { throw "Update failed for $RecordName ($Type)." }
      Write-Host "[DONE] Updated."
    } else {
      Write-Host "[INFO] Creating: $Type $RecordName -> $Content"
      $body = @{ type=$Type; name=$RecordName; content=$Content; ttl=$TTL; proxied=$Proxied }
  $crt = Use-CfApi -Method POST -Path "zones/$ZoneId/dns_records" -Body $body
      if (-not $crt.success) { throw "Creation failed for $RecordName ($Type)." }
      Write-Host "[DONE] Created."
    }
  }

  # 3) Update A-record
  Set-Record -ZoneId $zoneId -RecordName $RecordName -Type "A" -Content $ipv4 -TTL $TTL -Proxied $Proxied

  # 4) Optional AAAA-record
  if ($EnableIPv6 -and $ipv6) {
    Set-Record -ZoneId $zoneId -RecordName $RecordName -Type "AAAA" -Content $ipv6 -TTL $TTL -Proxied $Proxied
  }

  Write-Host "[SUCCESS] DDNS update completed for $RecordName"
} catch {
  Write-Error "[ERROR] $($_.Exception.Message)"
  exit 1
}