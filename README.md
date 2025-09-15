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
