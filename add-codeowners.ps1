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
    git clone $repo
    Set-Location -Path $repoName

    # Fetch all branches
    git fetch --all

    # Get all branches that start with "release/"
    $branches = git branch -r | Where-Object { $_ -match "origin/release/" } | ForEach-Object { $_.TrimStart("origin/") }

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
        git checkout $branch

        # Remove the old CODEOWNERS file from the root folder if it exists
        if (Test-Path -Path "CODEOWNERS") {
            Remove-Item -Path "CODEOWNERS"
            git rm CODEOWNERS
        }

        # Create .github directory if it doesn't exist
        if (-not (Test-Path -Path ".github")) {
            New-Item -ItemType Directory -Path ".github"
        }

        # Add the CODEOWNERS file to the .github directory
        $CODEOWNERS_CONTENT | Out-File -FilePath ".github\CODEOWNERS" -Encoding utf8
        git add .github\CODEOWNERS

        # Commit the changes
        git commit -m "Move CODEOWNERS file to .github folder"

        # Push the changes
        git push origin $branch
    }

    # Check out the main branch again
    git checkout main

    # Return to the parent directory
    Set-Location -Path ..
}