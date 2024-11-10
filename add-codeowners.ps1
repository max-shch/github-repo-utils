param (
    [string]$CodeOwnersFile = "TARGET-CODEOWNERS.txt",
    [Parameter(Mandatory)]
    [string]$ReposFileName
)

# Read the list of git repositories from the file
$repositories = Get-Content -Path "$ReposFileName"

# Read the CODEOWNERS content from the file
$CODEOWNERS_CONTENT = Get-Content -Path "$CodeOwnersFile"

foreach ($repo in $repositories) {
    # Extract the repo name from the URL
    $repoName = $repo.Split('/')[-1].Replace('.git', '')

    # Clone the repository
    Write-Host "Cloning repository: $repo"
    git clone $repo
    Set-Location -Path $repoName

    # Fetch all branches
    Write-Host "Fetching all branches for repository: $repoName"
    git fetch --all

    # Get all branches that start with "release/" r match ".*\..*\.x"
    $branches = git branch -r | Where-Object { $_ -match "origin/release\/.*" -or $_ -match "origin/\d+\.\d+\.x"} | ForEach-Object { $_.Trim() -replace "origin/", "" }

    if ($branches.Count -eq 0) {
        Write-Host "No release branches found for repository: $repoName"
        $branches = @()
    }

    # Add develop and master branches if they exist
    $additionalBranches = @("develop", "master")
    foreach ($branch in $additionalBranches) {
        if (git branch -r | Select-String -Pattern "origin/$branch") {
            $branches += $branch
        }
    }

    # Loop through each branch
    foreach ($branch in $branches) {
        # Check out the branch
        Write-Host "Checking out branch: $branch"
        git checkout $branch

        # Check if the CODEOWNERS file exists and compare its content
        $codeownersPath = ".github\CODEOWNERS"
        $updateCodeowners = $true
        if (Test-Path -Path $codeownersPath) {
            $existingContent = Get-Content -Path $codeownersPath
            if ($existingContent -eq $CODEOWNERS_CONTENT) {
                Write-Host "CODEOWNERS file is already up to date in branch: $branch"
                $updateCodeowners = $false
            }
        }

        if ($updateCodeowners) {
            # Remove the old CODEOWNERS file from the root folder if it exists
            if (Test-Path -Path "CODEOWNERS") {
                Write-Host "Removing old CODEOWNERS file from branch: $branch"
                Remove-Item -Path "CODEOWNERS"
                git rm CODEOWNERS
            }

            # Create .github directory if it doesn't exist
            if (-not (Test-Path -Path ".github")) {
                Write-Host "Creating .github directory in branch: $branch"
                New-Item -ItemType Directory -Path ".github"
            }

            # Add the CODEOWNERS file to the .github directory
            Write-Host "Adding CODEOWNERS file to .github directory in branch: $branch"
            $CODEOWNERS_CONTENT | Out-File -FilePath $codeownersPath -Encoding utf8
            git add $codeownersPath

            # Commit the changes
            Write-Host "Committing changes in branch: $branch"
            git commit -F "../commit-message.txt"

            # Push the changes
            Write-Host "Pushing changes to branch: $branch"
            git push origin $branch
        }
    }

    # Return to the parent directory
    Write-Host "Returning to parent directory"
    Set-Location -Path ..
}
