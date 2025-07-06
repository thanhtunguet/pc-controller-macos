import SwiftUI

struct PCControlButton: View {
    let title: String
    let icon: String
    let color: Color
    let isLoading: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                if isLoading {
                    ProgressView()
                        .scaleEffect(0.8)
                        .progressViewStyle(CircularProgressViewStyle())
                } else {
                    Image(systemName: icon)
                }
                
                Text(title)
                    .font(.system(size: 14, weight: .medium))
                
                Spacer()
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(color.opacity(0.1))
            .foregroundColor(color)
            .cornerRadius(8)
        }
        .buttonStyle(PlainButtonStyle())
        .disabled(isLoading)
        .opacity(isLoading ? 0.7 : 1.0)
    }
}