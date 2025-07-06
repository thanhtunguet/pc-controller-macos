import Foundation
import Network

class PCStatusChecker {
    private let timeoutInterval: TimeInterval = 5.0
    
    func checkStatus(ipAddress: String, port: Int) async -> PCStatus {
        let reachable = await checkReachability(host: ipAddress, port: port)
        return reachable ? .online : .offline
    }
    
    func pingHost(ipAddress: String) async -> Bool {
        return await checkReachability(host: ipAddress, port: 80)
    }
    
    private func checkReachability(host: String, port: Int) async -> Bool {
        return await withCheckedContinuation { continuation in
            let connection = NWConnection(
                to: NWEndpoint.hostPort(
                    host: NWEndpoint.Host(host),
                    port: NWEndpoint.Port(integerLiteral: NWEndpoint.Port.IntegerLiteralType(port))
                ),
                using: .tcp
            )
            
            var hasResumed = false
            
            let timeoutTask = Task {
                try await Task.sleep(nanoseconds: UInt64(timeoutInterval * 1_000_000_000))
                if !hasResumed {
                    hasResumed = true
                    continuation.resume(returning: false)
                    connection.cancel()
                }
            }
            
            connection.stateUpdateHandler = { state in
                switch state {
                case .ready:
                    if !hasResumed {
                        hasResumed = true
                        timeoutTask.cancel()
                        continuation.resume(returning: true)
                        connection.cancel()
                    }
                case .failed(_), .cancelled:
                    if !hasResumed {
                        hasResumed = true
                        timeoutTask.cancel()
                        continuation.resume(returning: false)
                        connection.cancel()
                    }
                default:
                    break
                }
            }
            
            connection.start(queue: .global())
        }
    }
    
    func continuousMonitoring(ipAddress: String, port: Int, interval: TimeInterval = 30.0) -> AsyncStream<PCStatus> {
        return AsyncStream { continuation in
            let timer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { _ in
                Task {
                    let status = await self.checkStatus(ipAddress: ipAddress, port: port)
                    continuation.yield(status)
                }
            }
            
            continuation.onTermination = { _ in
                timer.invalidate()
            }
            
            Task {
                let initialStatus = await self.checkStatus(ipAddress: ipAddress, port: port)
                continuation.yield(initialStatus)
            }
        }
    }
}