# Define variables
$gitHubOrg = "alpha-eng"
$repoName = "your-repo-name"
$accessToken = $env:GITHUB_ACCESS_TOKEN
$gitHubBaseUrl = "https://api.github.com"

# Define the headers
$headers = @{
    "Authorization" = "token $accessToken"
    "Accept" = "application/vnd.github.v3+json"
}

# Define the API URL for listing collaborators
$collaboratorsApiUrl = "$gitHubBaseUrl/repos/$gitHubOrg/$repoName/collaborators"

# Get the list of collaborators
Write-Host "Fetching list of collaborators for repository: $repoName"
$collaborators = Invoke-RestMethod -Uri $collaboratorsApiUrl -Method GET -Headers $headers

# Remove each collaborator
foreach ($collaborator in $collaborators) {
    $removeCollaboratorUrl = "$gitHubBaseUrl/repos/$gitHubOrg/$repoName/collaborators/$($collaborator.login)"
    Write-Host "Removing collaborator: $($collaborator.login)"
    Invoke-RestMethod -Uri $removeCollaboratorUrl -Method DELETE -Headers $headers
}

# Define the API URL for listing teams
$teamsApiUrl = "$gitHubBaseUrl/repos/$gitHubOrg/$repoName/teams"

# Get the list of teams
Write-Host "Fetching list of teams for repository: $repoName"
$teams = Invoke-RestMethod -Uri $teamsApiUrl -Method GET -Headers $headers

# Remove each team
foreach ($team in $teams) {
    $removeTeamUrl = "$gitHubBaseUrl/orgs/$gitHubOrg/teams/$($team.slug)/repos/$gitHubOrg/$repoName"
    Write-Host "Removing team: $($team.slug)"
    Invoke-RestMethod -Uri $removeTeamUrl -Method DELETE -Headers $headers
}

# Define the teams to add
$teamsToAdd = @("your-team-slug", "team-code-owners")

# Loop through each team and make the API request to add the team to the repository with write access
foreach ($teamSlug in $teamsToAdd) {
    # Define the API URL
    $apiUrl = "$gitHubBaseUrl/orgs/$gitHubOrg/teams/$teamSlug/repos/$gitHubOrg/$repoName"

    # Define the body
    $body = @{
        "permission" = "push"
    } | ConvertTo-Json

    # Make the API request
    Write-Host "Adding team $teamSlug with write access to repository: $repoName"
    $response = Invoke-RestMethod -Uri $apiUrl -Method PUT -Headers $headers -Body $body

    # Output the response
    Write-Host "Response for team ${teamSlug}: $($response | ConvertTo-Json -Depth 10)"
}

# Define the user to add with admin access
$user = "srv_sabuild"

# Define the API URL for the user
$userApiUrl = "$gitHubBaseUrl/repos/$gitHubOrg/$repoName/collaborators/$user"

# Define the body for the user
$userBody = @{
    "permission" = "admin"
} | ConvertTo-Json

# Make the API request to add the user to the repository with admin access
Write-Host "Adding user $user with admin access to repository: $repoName"
$userResponse = Invoke-RestMethod -Uri $userApiUrl -Method PUT -Headers $headers -Body $userBody

# Output the response for the user
Write-Host "Response for user ${user}: $($userResponse | ConvertTo-Json -Depth 10)"