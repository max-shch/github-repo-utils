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

# Initialize an array to hold all repositories
$allRepos = @()

# Function to get the next page URL from the Link header
function Get-NextPageUrl {
    param (
        [string]$linkHeader
    )
    if ($linkHeader -match '<(.*?)>; rel="next"') {
        return $matches[1]
    }
    return $null
}

# Loop to handle pagination
do {
    # Get the list of repositories
    Write-Host "Fetching list of repositories for team: $gitHubTeam"
    $response = Invoke-RestMethod -Uri $teamReposApiUrl -Method GET -Headers $headers -ResponseHeadersVariable responseHeaders

    # Add the repositories to the array
    $allRepos += $response

    # Get the next page URL from the Link header
    $teamReposApiUrl = Get-NextPageUrl -linkHeader $responseHeaders['Link']
} while ($teamReposApiUrl)

# Define the output file name
$outputFileName = "$gitHubTeam-repos.txt"

# Output the list of repositories to the file
Write-Host "Writing repositories to file: $outputFileName"
$allRepos.git_url | Out-File -FilePath $outputFileName -Encoding utf8

# Output the number of repositories found
Write-Host "Number of repositories found: $($allRepos.Count)"
