# END-TO-END RESERVATION TEST SCRIPT (PowerShell Native)
$BASE_URL = "http://localhost:8080/api/v1"
$EMAIL = "test.student@std.yeditepe.edu.tr"
$PASSWORD = "Password123!"

function Write-Step($msg) { Write-Host "`n--- $msg ---" -ForegroundColor Cyan }

Write-Step "1. REGISTERING USER"
$regBody = @{
    email = $EMAIL
    password = $PASSWORD
    name = "Test Student"
    nickname = "Tester"
    departmentId = "cse"
    year = 3
}
$regResponse = Invoke-RestMethod -Uri "$BASE_URL/auth/register" -Method Post -Body ($regBody | ConvertTo-Json) -ContentType "application/json"
$regResponse | Format-List

Write-Step "2. LOGGING IN"
$loginBody = @{
    email = $EMAIL
    password = $PASSWORD
}
$loginResponse = Invoke-RestMethod -Uri "$BASE_URL/auth/login" -Method Post -Body ($loginBody | ConvertTo-Json) -ContentType "application/json"
$token = $loginResponse.accessToken
Write-Host "Token: $token"

$headers = @{ Authorization = "Bearer $token" }

Write-Step "3. FETCHING WORKSPACES"
$workspaces = Invoke-RestMethod -Uri "$BASE_URL/reservations/workspaces?date=2026-05-01&slotId=slot-1&type=individual" -Method Get -Headers $headers
$workspaces | Format-Table

Write-Step "4. CREATING RESERVATION"
$resBody = @{
    workspaceId = "desk-1"
    date = "2026-05-01"
    slotId = "slot-1"
    courseCode = "CSE323"
    reservationType = "individual"
    allowStudyBuddy = $true
    participantNicknames = @()
}
$resResponse = Invoke-RestMethod -Uri "$BASE_URL/reservations" -Method Post -Body ($resBody | ConvertTo-Json) -ContentType "application/json" -Headers $headers
$resResponse | Format-List
$resId = $resResponse.id

Write-Step "5. VERIFYING 'MY RESERVATIONS'"
$myRes = Invoke-RestMethod -Uri "$BASE_URL/reservations/me" -Method Get -Headers $headers
$myRes | Format-Table

Write-Step "6. CANCELLING RESERVATION"
$cancelBody = @{
    cancelledAt = "2026-04-20T10:00:00"
    slotStartAt = "2026-05-01T10:00:00"
}
$cancelResponse = Invoke-RestMethod -Uri "$BASE_URL/reservations/$resId/cancel" -Method Post -Body ($cancelBody | ConvertTo-Json) -ContentType "application/json" -Headers $headers
$cancelResponse | Format-List

Write-Step "7. VERIFYING CANCELLATION STATUS"
$myResFinal = Invoke-RestMethod -Uri "$BASE_URL/reservations/me" -Method Get -Headers $headers
$myResFinal | Format-Table
