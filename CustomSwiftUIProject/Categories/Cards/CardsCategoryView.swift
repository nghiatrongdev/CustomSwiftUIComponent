import SwiftUI

struct CardsCategoryView: View {
    private let nm = NotificationManager.shared

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                ComponentSection(title: "Info Card") {
                    InfoCard(
                        title: "SwiftUI Tips",
                        subtitle: "5 min read",
                        bodyText: "Sử dụng @StateObject cho owned objects và @ObservedObject cho injected ones để tránh memory leak.",
                        icon: "lightbulb.fill",
                        color: .orange
                    )
                }

                ComponentSection(title: "Stat Cards") {
                    HStack(spacing: 12) {
                        StatCard(value: "128", label: "Components", icon: "cube.fill", color: .blue)
                        StatCard(value: "4.9★", label: "Rating", icon: "star.fill", color: .orange)
                    }
                    HStack(spacing: 12) {
                        StatCard(value: "12K", label: "Downloads", icon: "arrow.down.circle.fill", color: .green)
                        StatCard(value: "Pro", label: "Version", icon: "bolt.fill", color: .purple)
                    }
                }

                ComponentSection(title: "Action Card") {
                    ActionCard(
                        title: "Upgrade to Pro",
                        description: "Unlock all 128 components và nhận update vĩnh viễn.",
                        buttonTitle: "Get Pro — $29",
                        color: .purple
                    ) {
                        nm.banner("Coming soon!", message: "Pro version đang phát triển 🚀", type: .info)
                    }
                }

                ComponentSection(title: "Swipeable Card") {
                    SwipeableCard()
                }
            }
            .padding(16)
            .padding(.bottom, 32)
        }
        .navigationTitle("Cards")
        .navigationBarTitleDisplayMode(.large)
        .background(Color(UIColor.systemGroupedBackground))
    }
}

// MARK: - Info Card
struct InfoCard: View {
    let title: String
    let subtitle: String
    let bodyText: String
    let icon: String
    let color: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                HStack(spacing: 8) {
                    Image(systemName: icon)
                        .foregroundColor(color)
                        .font(.system(size: 16, weight: .semibold))
                    Text(title)
                        .font(.system(size: 16, weight: .bold))
                }
                Spacer()
                Text(subtitle)
                    .font(.system(size: 12))
                    .foregroundColor(.secondary)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(color.opacity(0.1))
                    .clipShape(Capsule())
            }
            Divider()
            Text(bodyText)
                .font(.system(size: 14))
                .foregroundColor(.secondary)
                .lineSpacing(5)
        }
        .padding(16)
        .background(Color(UIColor.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(color.opacity(0.2), lineWidth: 1)
        )
    }
}

// MARK: - Stat Card
struct StatCard: View {
    let value: String
    let label: String
    let icon: String
    let color: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Image(systemName: icon)
                .font(.system(size: 20, weight: .semibold))
                .foregroundColor(color)
            Text(value)
                .font(.system(size: 24, weight: .bold, design: .rounded))
            Text(label)
                .font(.system(size: 12))
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(Color(UIColor.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}

// MARK: - Action Card
struct ActionCard: View {
    let title: String
    let description: String
    let buttonTitle: String
    let color: Color
    let action: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(title).font(.system(size: 17, weight: .bold))
                    Text(description).font(.system(size: 13)).foregroundColor(.secondary).lineSpacing(4)
                }
                Spacer()
                Image(systemName: "crown.fill")
                    .font(.system(size: 28))
                    .foregroundColor(color.opacity(0.8))
            }
            Button(action: action) {
                Text(buttonTitle)
                    .font(.system(size: 15, weight: .bold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 13)
                    .background(LinearGradient(colors: [color, color.opacity(0.75)], startPoint: .leading, endPoint: .trailing))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .buttonStyle(.plain)
        }
        .padding(16)
        .background(
            LinearGradient(colors: [color.opacity(0.08), color.opacity(0.03)],
                           startPoint: .topLeading, endPoint: .bottomTrailing)
        )
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay(RoundedRectangle(cornerRadius: 16).stroke(color.opacity(0.2), lineWidth: 1))
    }
}

// MARK: - Swipeable Card
struct SwipeableCard: View {
    @State private var offset: CGFloat = 0
    @State private var deleted = false
    private let nm = NotificationManager.shared

    var body: some View {
        ZStack {
            // Background action
            HStack {
                Spacer()
                Image(systemName: "trash.fill")
                    .foregroundColor(.white)
                    .font(.system(size: 18, weight: .semibold))
                    .padding(.trailing, 24)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.red)
            .clipShape(RoundedRectangle(cornerRadius: 16))

            // Card
            HStack(spacing: 12) {
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.blue.opacity(0.15))
                    .frame(width: 44, height: 44)
                    .overlay(Image(systemName: "photo.fill").foregroundColor(.blue))

                VStack(alignment: .leading, spacing: 3) {
                    Text("Swipe to delete").font(.system(size: 15, weight: .semibold))
                    Text("Kéo sang trái để xóa card này").font(.system(size: 12)).foregroundColor(.secondary)
                }
                Spacer()
            }
            .padding(14)
            .background(Color(UIColor.secondarySystemGroupedBackground))
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .offset(x: offset)
            .gesture(
                DragGesture()
                    .onChanged { v in offset = min(0, v.translation.width) }
                    .onEnded { v in
                        if v.translation.width < -100 {
                            withAnimation(.spring()) { offset = -400 }
                            nm.toast("Đã xóa card", type: .error)
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                withAnimation { deleted = true }
                            }
                        } else {
                            withAnimation(.spring()) { offset = 0 }
                        }
                    }
            )
        }
        .frame(height: 72)
        .opacity(deleted ? 0 : 1)
        .overlay(
            deleted ? AnyView(
                Button("Khôi phục") {
                    withAnimation { deleted = false; offset = 0 }
                }
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.blue)
            ) : AnyView(EmptyView())
        )
    }
}
