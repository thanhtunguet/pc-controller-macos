import Foundation
import Network

class WakeOnLAN {
    private let udpPort: UInt16 = 9
    
    func wake(macAddress: String, ipAddress: String) async throws {
        let magicPacket = try createMagicPacket(from: macAddress)
        try await sendMagicPacket(magicPacket, to: ipAddress)
    }
    
    private func createMagicPacket(from macAddress: String) throws -> Data {
        let cleanMacAddress = macAddress.replacingOccurrences(of: ":", with: "")
            .replacingOccurrences(of: "-", with: "")
            .replacingOccurrences(of: " ", with: "")
        
        guard cleanMacAddress.count == 12 else {
            throw WakeOnLANError.invalidMacAddress
        }
        
        var macBytes = [UInt8]()
        for i in stride(from: 0, to: 12, by: 2) {
            let hexPair = String(cleanMacAddress[cleanMacAddress.index(cleanMacAddress.startIndex, offsetBy: i)..<cleanMacAddress.index(cleanMacAddress.startIndex, offsetBy: i + 2)])
            guard let byte = UInt8(hexPair, radix: 16) else {
                throw WakeOnLANError.invalidMacAddress
            }
            macBytes.append(byte)
        }
        
        var magicPacket = Data()
        
        for _ in 0..<6 {
            magicPacket.append(0xFF)
        }
        
        for _ in 0..<16 {
            magicPacket.append(contentsOf: macBytes)
        }
        
        return magicPacket
    }
    
    private func sendMagicPacket(_ packet: Data, to ipAddress: String) async throws {
        let broadcastAddress = getBroadcastAddress(from: ipAddress)
        
        return try await withCheckedThrowingContinuation { continuation in
            let connection = NWConnection(
                to: NWEndpoint.hostPort(
                    host: NWEndpoint.Host(broadcastAddress),
                    port: NWEndpoint.Port(rawValue: udpPort)!
                ),
                using: .udp
            )
            
            connection.stateUpdateHandler = { state in
                switch state {
                case .ready:
                    connection.send(
                        content: packet,
                        completion: .contentProcessed { error in
                            if let error = error {
                                continuation.resume(throwing: WakeOnLANError.sendFailed(error.localizedDescription))
                            } else {
                                continuation.resume()
                            }
                            connection.cancel()
                        }
                    )
                case .failed(let error):
                    continuation.resume(throwing: WakeOnLANError.connectionFailed(error.localizedDescription))
                    connection.cancel()
                default:
                    break
                }
            }
            
            connection.start(queue: .global())
        }
    }
    
    private func getBroadcastAddress(from ipAddress: String) -> String {
        let components = ipAddress.split(separator: ".")
        if components.count == 4 {
            return "\(components[0]).\(components[1]).\(components[2]).255"
        }
        return "255.255.255.255"
    }
}

enum WakeOnLANError: Error, LocalizedError {
    case invalidMacAddress
    case connectionFailed(String)
    case sendFailed(String)
    
    var errorDescription: String? {
        switch self {
        case .invalidMacAddress:
            return "Invalid MAC address format"
        case .connectionFailed(let message):
            return "Connection failed: \(message)"
        case .sendFailed(let message):
            return "Send failed: \(message)"
        }
    }
}