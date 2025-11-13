# API and Networking Information

## Expected PC API Endpoints
The app communicates with a PC-side API service via HTTPS.

### Required Endpoints
- `POST /power-on` - Turn on PC
- `POST /power-off` - Turn off PC  
- `GET /status` - Check PC status

### Request Format
```json
{
  "action": "power-on|power-off",
  "apiKey": "optional-api-key"
}
```

### Response Formats

**Status Response:**
```json
{
  "status": "online|offline", 
  "timestamp": "2024-01-01T00:00:00Z",
  "uptime": 3600
}
```

**Control Response:**
```json
{
  "success": true,
  "message": "PC powered on successfully",
  "timestamp": "2024-01-01T00:00:00Z"
}
```

## Configuration Requirements
- **Base URL**: Must be HTTPS with domain name (IP addresses rejected for security)
- **IP Address**: Local IP for Wake-on-LAN
- **MAC Address**: Required for Wake-on-LAN (format: 00:11:22:33:44:55)
- **API Key**: Optional authentication

## Security Constraints
- **HTTPS Only**: All API communication must use HTTPS
- **Domain Validation**: IP addresses are rejected, must use domain names
- **Network Entitlements**: Configured in PC Controller.entitlements
- **Timeout Handling**: Proper timeouts for all network requests

## Wake-on-LAN
- Uses UDP magic packet on port 9 (standard WoL port)
- Requires target MAC address
- Sends to broadcast address or specific IP
- Independent of API endpoints

## Error Handling
- Network timeouts and connectivity issues
- Invalid API responses
- Authentication failures
- Wake-on-LAN delivery failures