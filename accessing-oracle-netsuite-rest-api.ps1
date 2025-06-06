# NOTE:  This script is provided free for use without warranty for educational purposes only
# PowerShell 6 (Core) or better required

# typ is always JWT
# alg is the Algorithm use to sign the request, others are supported, but RS256 is all that I could get to work
# kid is the certificate ID provided on the OAuth 2.0 Client Credentials Setup screen, we use the private key to sign later
[hashtable]$header = @{
    "typ" = "JWT";
    "alg" = "PS256";
    "kid" = "[Certificate ID from OAuth 2.0 Client Credentials Setup]";
}

# Serialize to JSON, Convert to Base64 string, make Base64 string URL safe
[string]$encodedHeader = [Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes($(ConvertTo-Json $header))) -replace '\+','-' -replace '/','_' -replace '='

# iss is the Client ID provided during the Integration Setup, the information is only provided once immediately after setup
# scope is the comma delimited list of possible services:  restlets, rest_webservices, suite_analytics
# aud is always the token endpoint
# exp is the date the JWT expires (60 minutes is the max) in Epoch/Unix numeric time, note this is NOT the expiration of the access_token
# iat is the date the JWT was issued (current date/time) in Epoch/Unix numeric time
[hashtable]$payload = @{
    "iss" = "[Client ID provided during Integration Setup]";
    "scope" = "rest_webservices";
    "aud" = "https://<accountID>.suitetalk.api.netsuite.com/services/rest/auth/oauth2/v1/token";
    "exp" = ([System.DateTimeOffset]$((Get-Date).AddSeconds(3600))).ToUnixTimeSeconds();
    "iat" = ([System.DateTimeOffset]$(Get-Date)).ToUnixTimeSeconds()
}

# Serialize to JSON, Convert to Base64 string, make Base64 string URL safe
[string]$encodedPayload = [Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes($(ConvertTo-Json $payload))) -replace '\+','-' -replace '/','_' -replace '='

# Combine header and payload
[string]$baseSignature = "$encodedHeader.$encodedPayload"
[byte[]]$byteSignature = [System.Text.Encoding]::UTF8.GetBytes($baseSignature)

# Load certificate
[System.Security.Cryptography.X509Certificates.X509Certificate2]$signingCertificate = [System.Security.Cryptography.X509Certificates.X509Certificate2]::CreateFromPemFile("<File path to public.pem>","<File path to private.pem>")

# Sign using private key
[byte[]]$byteSignedSignature = $signingCertificate.PrivateKey.SignData($byteSignature,[System.Security.Cryptography.HashAlgorithmName]::SHA256,[System.Security.Cryptography.RSASignaturePadding]::Pss)

# Convert to Base64 string and make Base64 string URL safe
[string]$signedSignature = [Convert]::ToBase64String($byteSignedSignature) -replace '\+','-' -replace '/','_' -replace '='

# grant_type is always client_credentials
[string]$grant_type = "client_credentials"

# client_assertion_type is always urn:ietf:params:oauth:client-assertion-type:jwt-bearer, needs to be URL encoded
[string]$client_assertion_type = [System.Web.HttpUtility]::UrlEncode("urn:ietf:params:oauth:client-assertion-type:jwt-bearer")

# client_assertion is a combination of the $baseSignature and $signedSignature
[string]$client_assertion = "$baseSignature.$signedSignature"

# send access_token request
 $response = Invoke-WebRequest `
                 -Uri "https://<accountId>.suitetalk.api.netsuite.com/services/rest/auth/oauth2/v1/token" `
                 -Method "POST" `
                 -Body "grant_type=$grant_type&client_assertion_type=$client_assertion_type&client_assertion=$client_assertion" `
                 -Headers @{"Content-Type"="application/x-www-form-urlencoded";} `
                 -UseBasicParsing

                 # should get a JSON response body
if ($null -ne $response `
    -and (Test-Json $response.Content)) {
     [hashtable]$token = ConvertFrom-Json $response.Content -AsHashtable
     if ($token.ContainsKey("access_token") `
         -and $token["access_token"].Length -gt 0) {

         # now we can use the access_token in subsequent requests via the Authorization header
         $response = Invoke-WebRequest `
                         -Uri "https://<accountId>.suitetalk.api.netsuite.com/services/rest/record/v1/customer/<id>" `
                         -Method "GET" `
                         -Headers @{"Authorization"="Bearer $($token["access_token"])";} `
                         -UseBasicParsing

        Write-Output (ConvertFrom-Json ([System.Text.Encoding]::UTF8.GetString($response.Content)))
    }
}
