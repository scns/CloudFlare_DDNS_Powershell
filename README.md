# ☁️ Cloudflare DDNS Updater (PowerShell)

Automatically update your dynamic IP address in Cloudflare DNS using PowerShell. Ideal for home servers, VPNs, and remote access setups where your public IP changes frequently.

---

## ✨ Features

- 🔍 Retrieves Zone ID automatically
- 🌐 Updates A-record (IPv4) and optionally AAAA-record (IPv6)
- ⚡ Only updates DNS when your IP changes
- 🛠️ Fast, lightweight, and easy to configure

---

## 📝 Requirements

- 💻 PowerShell 5.1 or later (Windows, Linux, macOS)
- 🔑 Cloudflare API Token with `Zone.DNS` permissions

---

## 🚀 Setup & Usage

1. Download `cloudflare_DDNS.ps1` to your system.
2. Open the script and fill in the configuration section:
   - `ApiToken`: Your Cloudflare API token
   - `ZoneName`: Your domain/zone (e.g. `example.com`)
   - `RecordName`: The FQDN to update (e.g. `home.example.com`)
   - Adjust other options as needed (TTL, Proxied, IPv6)
3. Run the script:

```powershell
.\cloudflare_DDNS.ps1
```

---

## ⏰ Run as a Scheduled Task (Windows)

To keep your DNS records updated automatically, you can run this script as a scheduled task:

1. Open **Task Scheduler** and create a new task.
2. Set the trigger (e.g. every 30 minutes).
3. Set the action:
   - Program/script: `powershell.exe`
   - Add arguments: `-File "C:\Path\To\cloudflare_DDNS.ps1"`
   - Start in: `C:\Path\To\`
4. Make sure the task runs with highest privileges and is set to run whether user is logged in or not.
5. Save and enable the task.

**Example PowerShell command for quick setup:**

```powershell
SchTasks /Create /SC MINUTE /MO 30 /TN "CloudflareDDNS" /TR "powershell.exe -File C:\Path\To\cloudflare_DDNS.ps1" /RL HIGHEST /F
```

---

## ⚙️ Example Configuration

```powershell
$ApiToken   = "YOUR_API_TOKEN"
$ZoneName   = "example.com"
$RecordName = "home.example.com"
$TTL        = 120
$Proxied    = $false
$EnableIPv6 = $false
```

---

## 💡 Notes

- The script checks multiple public IP sources for reliability.
- IPv6 support is optional and can be enabled in the config.
- No third-party dependencies required.

---

## 📄 License

MIT
