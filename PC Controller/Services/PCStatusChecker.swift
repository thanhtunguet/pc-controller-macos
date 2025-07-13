import Foundation
import Network

actor ConnectionState {
    private var hasResumed: Bool = false
    
    func checkAndSetResumed() -> Bool {
        if hasResumed {
            return true
        }
        hasResumed = true
        return false
    }
}

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
            
            let resumeState = ConnectionState()
            
            let timeoutTask = Task {
                try await Task.sleep(nanoseconds: UInt64(timeoutInterval * 1_000_000_000))
                let wasAlreadyResumed = await resumeState.checkAndSetResumed()
                if !wasAlreadyResumed {
                    continuation.resume(returning: false)
                    connection.cancel()
                }
            }
            
            connection.stateUpdateHandler = { state in
                Task {
                    switch state {
                    case .ready:
                        let wasAlreadyResumed = await resumeState.checkAndSetResumed()
                        if !wasAlreadyResumed {
                            timeoutTask.cancel()
                            continuation.resume(returning: true)
                            connection.cancel()
                        }
                    case .failed(_), .cancelled:
                        let wasAlreadyResumed = await resumeState.checkAndSetResumed()
                        if !wasAlreadyResumed {
                            timeoutTask.cancel()
                            continuation.resume(returning: false)
                            connection.cancel()
                        }
                    default:
                        break
                    }
                }
            }
            
            connection.start(queue: .global())
        }
    }
    
    func continuousMonitoring(ipAddress: String, port: Int, interval: TimeInterval = 30.0) -> AsyncStream<PCStatus> {
        return AsyncStream { continuation in
            let task = Task { [weak self] in
                guard let self = self else { return }
                
                // Send initial status
                let initialStatus = await self.checkStatus(ipAddress: ipAddress, port: port)
                continuation.yield(initialStatus)
                
                // Continue monitoring
                while !Task.isCancelled {
                    try? await Task.sleep(nanoseconds: UInt64(interval * 1_000_000_000))
                    if !Task.isCancelled {
                        let status = await self.checkStatus(ipAddress: ipAddress, port: port)
                        continuation.yield(status)
                    }
                }
            }
            
            continuation.onTermination = { @Sendable _ in
                task.cancel()
            }
        }
    }
}