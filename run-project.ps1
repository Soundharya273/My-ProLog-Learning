Write-Host "Starting Disaster Resource Allocation System..."
if (-not (Get-Command swipl -ErrorAction SilentlyContinue) -and -not $env:SWIPL_PATH) {
  Write-Warning "SWI-Prolog was not found in PATH. Install it or set `$env:SWIPL_PATH."
}
Start-Process powershell -ArgumentList "-NoExit", "-Command", "Set-Location '$PSScriptRoot/backend'; npm start"
Start-Process powershell -ArgumentList "-NoExit", "-Command", "Set-Location '$PSScriptRoot/frontend'; npm run dev"
Write-Host "Backend and frontend terminals opened."