# Define the list of git repositories
$repositories = @(
    "https://github.com/user/repo1.git",
    "https://github.com/user/repo2.git"
# Add more repositories as needed
)

# Define the CODEOWNERS content
$CODEOWNERS_CONTENT = "* @your-github-username"

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

    # Get all branches that start with "release/"
    $branches = git branch -r | Where-Object { $_ -match "origin/release/" } | ForEach-Object { $_.Trim() -replace "origin/", "" }

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
        $CODEOWNERS_CONTENT | Out-File -FilePath ".github\CODEOWNERS" -Encoding utf8
        git add .github\CODEOWNERS

        # Commit the changes
        Write-Host "Committing changes in branch: $branch"
        git commit -m "Move CODEOWNERS file to .github folder"

        # Push the changes
        Write-Host "Pushing changes to branch: $branch"
        git push origin $branch
    }

    # Check out the main branch again
    Write-Host "Checking out main branch"
    git checkout main

    # Return to the parent directory
    Write-Host "Returning to parent directory"
    Set-Location -Path ..
}