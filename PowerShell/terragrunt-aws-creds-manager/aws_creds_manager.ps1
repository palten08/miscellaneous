Import-Module powershell-yaml

Write-Host -ForegroundColor Magenta "Reading AWS credentials"

Get-Content "aws" | Foreach-Object {
    $LineValue = $_.Split('=')
    New-Variable -Name $LineValue[0] -Value $LineValue[1]
 }

Write-Host -ForegroundColor Magenta "Reading existing Terragrunt config"

$TerraformConfigRaw = ''
Get-Content "credentials.yml" | ForEach-Object {
    $TerraformConfigRaw = $TerraformConfigRaw + "`n" + $_
}

$TerraformConfigYAML = ConvertFrom-YAML $TerraformConfigRaw

Write-Host -ForegroundColor Magenta "Updating credentials in Terragrunt config with values from the AWS credentials file"

$TerraformConfigYAML.access_key = $aws_access_key_id
$TerraformConfigYAML.secret_key = $aws_secret_access_key
$TerraformConfigYAML.session_token = $aws_session_token

Write-Host -ForegroundColor Magenta "Writing new Terragrunt config file"

$OutputYAML = ConvertTo-YAML $TerraformConfigYAML

$OutputYAML | Out-File "credentials.yml"

Write-Host -ForegroundColor Magenta "Setting AWS credential environment variables for use with the AWS CLI"

if (!(Get-Item -Path Env:\AWS_ACCESS_KEY_ID -ErrorAction SilentlyContinue)) {
    Write-Host -ForegroundColor Yellow "No environment variable for AWS_ACCESS_KEY_ID, creating it now"
    New-Item -Path Env:\AWS_ACCESS_KEY_ID -Value $aws_access_key_id
} else {
    $CurrentVariable = Get-Item -Path Env:\AWS_ACCESS_KEY_ID
    if ($CurrentVariable.Value -ne $aws_access_key_id) {
        Write-Host -ForegroundColor Yellow "Changing value for the AWS_ACCESS_KEY_ID environment variable"
        Set-Item -Path Env:\AWS_ACCESS_KEY_ID -Value $aws_access_key_id
    } else {
        Write-Host -ForegroundColor Yellow "No change for the AWS_ACCESS_KEY_ID environment variable"
    }
}

if (!(Get-Item -Path Env:\AWS_SECRET_ACCESS_KEY -ErrorAction SilentlyContinue)) {
    Write-Host -ForegroundColor Yellow "No environment variable for AWS_SECRET_ACCESS_KEY, creating it now"
    New-Item -Path Env:\AWS_SECRET_ACCESS_KEY -Value $aws_secret_access_key
} else {
    $CurrentVariable = Get-Item -Path Env:\AWS_SECRET_ACCESS_KEY
    if ($CurrentVariable.Value -ne $aws_secret_access_key) {
        Write-Host -ForegroundColor Yellow "Changing value for the AWS_SECRET_ACCESS_KEY environment variable"
        Set-Item -Path Env:\AWS_SECRET_ACCESS_KEY -Value $aws_secret_access_key
    } else {
        Write-Host -ForegroundColor Yellow "No change for the AWS_SECRET_ACCESS_KEY environment variable"
    }
}

if (!(Get-Item -Path Env:\AWS_SESSION_TOKEN -ErrorAction SilentlyContinue)) {
    Write-Host -ForegroundColor Yellow "No environment variable for AWS_SESSION_TOKEN, creating it now"
    New-Item -Path Env:\AWS_SESSION_TOKEN -Value $aws_session_token
} else {
    $CurrentVariable = Get-Item -Path Env:\AWS_SESSION_TOKEN
    if ($CurrentVariable.Value -ne $aws_secret_access_key) {
        Write-Host -ForegroundColor Yellow "Changing value for the AWS_SESSION_TOKEN environment variable"
        Set-Item -Path Env:\AWS_SESSION_TOKEN -Value $aws_session_token
    } else {
        Write-Host -ForegroundColor Yellow "No change for the AWS_SESSION_TOKEN environment variable"
    }
}

Write-Host -ForegroundColor Green "Done!"