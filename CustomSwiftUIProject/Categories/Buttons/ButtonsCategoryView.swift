import SwiftUI

struct ButtonsCategoryView: View {
    private let nm = NotificationManager.shared

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                ComponentSection(title: "Primary Button") {
                    PrimaryButton(title: "Get Started", icon: "arrow.right") {
                        nm.toast("Primary tapped!", message: "PrimaryButton action fired", type: .info)
                    }
                }

                ComponentSection(title: "Gradient Button") {
                    GradientButton(title: "Upgrade to Pro", colors: [.purple, .blue]) {
                        nm.banner("Upgrade!", message: "GradientButton tapped", type: .success)
                    }
                }

                ComponentSection(title: "Outline Button") {
                    OutlineButton(title: "Learn More", color: .blue) {
                        nm.toast("Outline tapped", type: .info)
                    }
                }

                ComponentSection(title: "Icon Button") {
                    HStack(spacing: 12) {
                        IconButton(icon: "heart.fill", color: .red) {
                            nm.toast("Liked!", type: .success)
                        }
                        IconButton(icon: "bookmark.fill", color: .orange) {
                            nm.toast("Saved!", type: .success)
                        }
                        IconButton(icon: "square.and.arrow.up", color: .blue) {
                            nm.toast("Sharing…", type: .info)
                        }
                        IconButton(icon: "trash.fill", color: .red) {
                            nm.banner("Deleted!", message: "Item removed", type: .error)
                        }
                    }
                }

                ComponentSection(title: "Loading Button") {
                    LoadingButton()
                }

                ComponentSection(title: "Destructive Button") {
                    DestructiveButton(title: "Delete Account") {
                        nm.banner("Account deleted", message: "This action cannot be undone", type: .error)
                    }
                }
            }
            .padding(16)
            .padding(.bottom, 32)
        }
        .navigationTitle("Buttons")
        .navigationBarTitleDisplayMode(.large)
        .background(Color(UIColor.systemGroupedBackground))
    }
}

// MARK: - Custom Buttons

struct PrimaryButton: View {
    let title: String
    let icon: String?
    let action: () -> Void
    init(title: String, icon: String? = nil, action: @escaping () -> Void) {
        self.title = title; self.icon = icon; self.action = action
    }

    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Text(title).font(.system(size: 16, weight: .bold))
                if let icon { Image(systemName: icon).font(.system(size: 14, weight: .bold)) }
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 15)
            .background(Color.blue)
            .clipShape(RoundedRectangle(cornerRadius: 14))
            .shadow(color: Color.blue.opacity(0.35), radius: 8, x: 0, y: 4)
        }
        .buttonStyle(.plain)
    }
}

struct GradientButton: View {
    let title: String
    let colors: [Color]
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 15)
                .background(LinearGradient(colors: colors, startPoint: .leading, endPoint: .trailing))
                .clipShape(RoundedRectangle(cornerRadius: 14))
                .shadow(color: colors.first?.opacity(0.4) ?? .clear, radius: 10, x: 0, y: 5)
        }
        .buttonStyle(.plain)
    }
}

struct OutlineButton: View {
    let title: String
    let color: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(color)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(color.opacity(0.06))
                .clipShape(RoundedRectangle(cornerRadius: 14))
                .overlay(RoundedRectangle(cornerRadius: 14).stroke(color, lineWidth: 1.5))
        }
        .buttonStyle(.plain)
    }
}

struct IconButton: View {
    let icon: String
    let color: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(color)
                .frame(width: 52, height: 52)
                .background(color.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 14))
                .overlay(RoundedRectangle(cornerRadius: 14).stroke(color.opacity(0.2), lineWidth: 1))
        }
        .buttonStyle(.plain)
    }
}

struct LoadingButton: View {
    @State private var isLoading = false

    var body: some View {
        Button {
            isLoading = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                isLoading = false
                NotificationManager.shared.toast("Done!", message: "Action completed", type: .success)
            }
        } label: {
            HStack(spacing: 10) {
                if isLoading {
                    ProgressView().progressViewStyle(.circular).tint(.white).scaleEffect(0.85)
                    Text("Loading…")
                } else {
                    Image(systemName: "bolt.fill")
                    Text("Tap to Load")
                }
            }
            .font(.system(size: 16, weight: .bold))
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 15)
            .background(isLoading ? Color.gray : Color.indigo)
            .clipShape(RoundedRectangle(cornerRadius: 14))
            .animation(.spring(response: 0.3), value: isLoading)
        }
        .disabled(isLoading)
        .buttonStyle(.plain)
    }
}

struct DestructiveButton: View {
    let title: String
    let action: () -> Void
    @State private var confirm = false

    var body: some View {
        Button {
            if confirm { action(); confirm = false }
            else { confirm = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 3) { confirm = false }
            }
        } label: {
            Text(confirm ? "Nhấn lần nữa để xác nhận" : title)
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 15)
                .background(confirm ? Color.red : Color.red.opacity(0.75))
                .clipShape(RoundedRectangle(cornerRadius: 14))
                .animation(.spring(response: 0.3), value: confirm)
        }
        .buttonStyle(.plain)
    }
}
