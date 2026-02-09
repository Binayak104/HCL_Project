# HCL Project Teardown Script
# Destroys infrastructure in reverse order (Layer 2 -> Layer 1)

$ErrorActionPreference = "Stop"

Write-Host "⚠️  STARTING INFRASTRUCTURE TEARDOWN ⚠️" -ForegroundColor Red
Write-Host "This will destroy all AWS resources for the HCL Project."
Write-Host "Press Ctrl+C to cancel, or wait 5 seconds to proceed..."
Start-Sleep -s 5

# --- Function to run Terraform Destroy ---
function Run-Terraform-Destroy {
    param (
        [string]$Path
    )
    Write-Host "--------------------------------------------------" -ForegroundColor Yellow
    Write-Host "Destroying: $Path" -ForegroundColor Yellow
    Write-Host "--------------------------------------------------" -ForegroundColor Yellow
    
    Push-Location $Path
    
    # Initialize to ensure backend config is correct
    terraform init -reconfigure
    
    # Run destroy with auto-approve
    terraform destroy -auto-approve
    
    if ($LASTEXITCODE -ne 0) {
        Write-Error "Terraform destroy failed for $Path"
    }
    
    Pop-Location
}

# --- Step 1: Destroy Layer 2 (Application) ---
# Depends on Layer 1, so must go first.
Run-Terraform-Destroy -Path "./infrastructure/layer2"

# --- Step 2: Destroy Layer 1 (Base/Networking) ---
Run-Terraform-Destroy -Path "./infrastructure/layer1"

# --- Step 3: Destroy Bootstrap (State Bucket) - Optional ---
# Usually we keep this, but if "Everything" means "Everything":
Write-Host "--------------------------------------------------" -ForegroundColor Yellow
Write-Host "NOTE: The Terraform State S3 Bucket (Bootstrap layer) still exists." -ForegroundColor Yellow
Write-Host "To delete it, you must empty the bucket manually in the AWS Console," -ForegroundColor Yellow
Write-Host "then run 'terraform destroy' in ./infrastructure/bootstrap" -ForegroundColor Yellow
Write-Host "--------------------------------------------------" -ForegroundColor Yellow

Write-Host "✅ Teardown Complete!" -ForegroundColor Green
