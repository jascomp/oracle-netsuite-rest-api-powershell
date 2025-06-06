# Accessing the Oracle NetSuite REST API with PowerShell

This repository contains a PowerShell script for authenticating and accessing the Oracle NetSuite REST API using OAuth 2.0 JWT Client Credentials flow. The script demonstrates how to generate a JWT, sign it, obtain an access token, and make authenticated API requests to NetSuite.

## Prerequisites

- **PowerShell 6 (Core) or later**  
  (Windows PowerShell is not supported; use [PowerShell Core](https://github.com/PowerShell/PowerShell))
- An Oracle NetSuite account with API access enabled
- OAuth 2.0 Client Credentials integration set up in NetSuite
- Access to your integration's certificate/private key in PEM format

## Usage

1. **Clone this repository or download the script:**
    ```sh
    git clone https://github.com/jascomp/oracle-netsuite-rest-api-powershell.git
    ```

2. **Edit the script:**  
   Open `accessing-oracle-netsuite-rest-api.ps1` and update the following placeholders:
   - `[Certificate ID from OAuth 2.0 Client Credentials Setup]`
   - `[Client ID provided during Integration Setup]`
   - `<accountID>`
   - `<File path to public.pem>`
   - Any other relevant fields in the script

3. **Run the script:**
    ```sh
    pwsh ./accessing-oracle-netsuite-rest-api.ps1
    ```

4. **Expected Output:**  
   If configured correctly, the script will:
   - Generate and sign a JWT
   - Obtain an OAuth access token from the NetSuite token endpoint
   - Use the token to make a sample GET request (e.g., retrieving a customer record)
   - Print the API response in JSON format

## Disclaimer

- This script is for educational purposes only and comes with no warranty.
- Use at your own risk and do not use in production without proper review and adaptation.

## Reference

For a full explanation of the process and script walkthrough, see the accompanying blog post:  
[Accessing Oracle NetSuite REST API Using PowerShell](https://jasonholden.com/accessing-oracle-netsuite-rest-api-using-powershell/)

---

© [Jason Holden](https://jasonholden.com/)
