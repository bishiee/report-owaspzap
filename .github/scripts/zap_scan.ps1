# Set variables
$zapApiKey = "3aq6vrr0ld2i7dcom51mgtfhap"
$zapHost = "localhost"
$zapPort = "8080"
$targetUrl = "http://localhost/laradesk-1.1.2"

# Start a new session
Invoke-WebRequest -Uri "http://$zapHost:$zapPort/JSON/core/action/newSession/?apikey=$zapApiKey"

# Open the target URL
Invoke-WebRequest -Uri "http://$zapHost:$zapPort/JSON/core/action/accessUrl/?apikey=$zapApiKey&url=$targetUrl"

# Start the scan
$response = Invoke-WebRequest -Uri "http://$zapHost:$zapPort/JSON/ascan/action/scan/?apikey=$zapApiKey&url=$targetUrl"

# Get the scan ID
$scanId = ($response.Content | ConvertFrom-Json).scan

# Poll the status of the scan until it completes
$scanStatus = 0
while ($scanStatus -lt 100) {
    Start-Sleep -Seconds 10
    $scanStatus = (Invoke-WebRequest -Uri "http://$zapHost:$zapPort/JSON/ascan/view/status/?apikey=$zapApiKey&scanId=$scanId").Content | ConvertFrom-Json
    Write-Host "Scan progress: $scanStatus%"
}

# Generate the report
Invoke-WebRequest -Uri "http://$zapHost:$zapPort/OTHER/core/other/htmlreport/?apikey=$zapApiKey" -OutFile "zap_report.html"
Invoke-WebRequest -Uri "http://$zapHost:$zapPort/OTHER/core/other/jsonreport/?apikey=$zapApiKey" -OutFile "zap_report.json"
