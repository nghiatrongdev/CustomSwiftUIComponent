import SwiftUI
import Combine
// MARK: - Notification Type
enum NotificationType {
    case success, error, warning, info

    var color: Color {
        switch self {
        case .success: return .green
        case .error:   return .red
        case .warning: return .orange
        case .info:    return .blue
        }
    }

    var icon: String {
        switch self {
        case .success: return "checkmark.circle.fill"
        case .error:   return "xmark.circle.fill"
        case .warning: return "exclamationmark.triangle.fill"
        case .info:    return "info.circle.fill"
        }
    }
}

// MARK: - Notification Model
struct NotificationItem: Equatable {
    let id = UUID()
    let title: String
    let message: String?
    let type: NotificationType
    let style: NotificationStyle

    static func == (lhs: NotificationItem, rhs: NotificationItem) -> Bool {
        lhs.id == rhs.id
    }
}

enum NotificationStyle { case toast, banner }

// MARK: - Global Notification Manager
class NotificationManager: ObservableObject {
    static let shared = NotificationManager()
    @Published var current: NotificationItem? = nil
    private var task: Task<Void, Never>?

    func show(_ item: NotificationItem, duration: Double = 3.0) {
        task?.cancel()
        withAnimation(.spring(response: 0.4, dampingFraction: 0.75)) {
            current = item
        }
        task = Task { @MainActor in
            try? await Task.sleep(nanoseconds: UInt64(duration * 1_000_000_000))
            if !Task.isCancelled {
                withAnimation(.spring(response: 0.4, dampingFraction: 0.75)) {
                    current = nil
                }
            }
        }
    }

    func dismiss() {
        task?.cancel()
        withAnimation(.spring(response: 0.4, dampingFraction: 0.75)) {
            current = nil
        }
    }

    // Convenience
    func toast(_ title: String, message: String? = nil, type: NotificationType = .info) {
        show(NotificationItem(title: title, message: message, type: type, style: .toast))
    }

    func banner(_ title: String, message: String? = nil, type: NotificationType = .info) {
        show(NotificationItem(title: title, message: message, type: type, style: .banner))
    }
}

// MARK: - Toast View
struct ToastView: View {
    let item: NotificationItem
    let onDismiss: () -> Void

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: item.type.icon)
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(item.type.color)

            VStack(alignment: .leading, spacing: 2) {
                Text(item.title)
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.primary)
                if let msg = item.message {
                    Text(msg)
                        .font(.system(size: 12))
                        .foregroundColor(.secondary)
                }
            }

            Spacer(minLength: 4)

            Button(action: onDismiss) {
                Image(systemName: "xmark")
                    .font(.system(size: 11, weight: .bold))
                    .foregroundColor(.secondary)
                    .padding(6)
                    .background(Color(.tertiarySystemBackground))
                    .clipShape(Circle())
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(item.type.color.opacity(0.25), lineWidth: 1)
        )
        .shadow(color: item.type.color.opacity(0.15), radius: 12, x: 0, y: 4)
        .shadow(color: .black.opacity(0.08), radius: 6, x: 0, y: 2)
        .padding(.horizontal, 20)
    }
}

// MARK: - Banner View
struct BannerView: View {
    let item: NotificationItem
    let onDismiss: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: item.type.icon)
                .font(.system(size: 20, weight: .semibold))
                .foregroundColor(.white)

            VStack(alignment: .leading, spacing: 2) {
                Text(item.title)
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.white)
                if let msg = item.message {
                    Text(msg)
                        .font(.system(size: 12))
                        .foregroundColor(.white.opacity(0.85))
                }
            }

            Spacer()

            Button(action: onDismiss) {
                Image(systemName: "xmark")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(.white.opacity(0.8))
                    .padding(6)
                    .background(Color.white.opacity(0.2))
                    .clipShape(Circle())
            }
        }
        .padding(.horizontal, 18)
        .padding(.vertical, 14)
        .background(
            LinearGradient(
                colors: [item.type.color, item.type.color.opacity(0.8)],
                startPoint: .leading, endPoint: .trailing
            )
        )
        .shadow(color: item.type.color.opacity(0.4), radius: 12, x: 0, y: 6)
    }
}

// MARK: - View Modifier
struct NotificationOverlayModifier: ViewModifier {
    @ObservedObject var manager = NotificationManager.shared

    func body(content: Content) -> some View {
        ZStack(alignment: .top) {
            content

            if let item = manager.current {
                Group {
                    if item.style == .toast {
                        ToastView(item: item) { manager.dismiss() }
                            .padding(.top, 8)
                            .transition(.move(edge: .top).combined(with: .opacity))
                    } else {
                        BannerView(item: item) { manager.dismiss() }
                            .transition(.move(edge: .top).combined(with: .opacity))
                    }
                }
                .zIndex(999)
            }
        }
    }
}

extension View {
    /// Attach notification overlay to root view
    func withNotificationOverlay() -> some View {
        modifier(NotificationOverlayModifier())
    }
}
