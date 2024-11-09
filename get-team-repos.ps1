param (
    [string]$gitHubTeam
)
# Define variables
$gitHubOrg = "alpha-eng"
$accessToken = $env:GITHUB_ACCESS_TOKEN
$gitHubBaseUrl = "https://your-github-enterprise-server/api/v3"

# Define the headers
$headers = @{
    "Authorization" = "token $accessToken"
    "Accept" = "application/vnd.github.v3+json"
}

# Define the API URL for listing repositories the team has access to
$teamReposApiUrl = "$gitHubBaseUrl/orgs/$gitHubOrg/teams/$gitHubTeam/repos"

# Get the list of repositories
Write-Host "Fetching list of repositories for team: $gitHubTeam"
$teamRepos = Invoke-RestMethod -Uri $teamReposApiUrl -Method GET -Headers $headers

# Output the list of repositories
Write-Host "Repositories the team $gitHubTeam has direct access to:"
foreach ($repo in $teamRepos) {
    Write-Host $repo.full_name
}