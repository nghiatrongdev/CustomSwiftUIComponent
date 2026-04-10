import SwiftUI

// MARK: - Category Model
struct ComponentCategory: Identifiable {
    let id = UUID()
    let name: String
    let icon: String
    let color: Color
    let description: String
    let count: Int
}

let allCategories: [ComponentCategory] = [
    ComponentCategory(name: "Buttons",    icon: "hand.tap.fill",           color: .blue,   description: "Các kiểu nút bấm custom", count: 6),
    ComponentCategory(name: "Inputs",     icon: "keyboard",                color: .purple, description: "Text field, picker, toggle…", count: 5),
    ComponentCategory(name: "Cards",      icon: "rectangle.stack.fill",    color: .orange, description: "Card layouts và containers", count: 4),
    ComponentCategory(name: "Alerts",     icon: "bell.badge.fill",         color: .red,    description: "Dialog, bottom sheet, popup", count: 5),
    ComponentCategory(name: "Navigation", icon: "arrow.triangle.branch",   color: .green,  description: "Tab bar, sidebar, breadcrumb", count: 4),
]

// MARK: - Root View
struct RootView: View {
    var body: some View {
        NavigationStack {
            HomeView()
        }
        .withNotificationOverlay()
    }
}

// MARK: - Home View
struct HomeView: View {
    @State private var appeared = false
    @State private var searchText = ""
    private let nm = NotificationManager.shared

    var filtered: [ComponentCategory] {
        searchText.isEmpty ? allCategories :
        allCategories.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Header card
                HeaderBannerView()
                    .offset(y: appeared ? 0 : -30)
                    .opacity(appeared ? 1 : 0)

                // Notification demo
                NotificationDemoRow()
                    .padding(.horizontal, 16)
                    .offset(y: appeared ? 0 : 20)
                    .opacity(appeared ? 1 : 0)
                    .animation(.spring(response: 0.5, dampingFraction: 0.75).delay(0.1), value: appeared)

                // Categories
                VStack(alignment: .leading, spacing: 12) {
                    Text("Categories")
                        .font(.system(size: 20, weight: .bold))
                        .padding(.horizontal, 16)

                    LazyVStack(spacing: 12) {
                        ForEach(Array(filtered.enumerated()), id: \.element.id) { index, cat in
                            NavigationLink(destination: categoryDestination(cat)) {
                                CategoryRow(category: cat)
                                    .padding(.horizontal, 16)
                            }
                            .buttonStyle(.plain)
                            .offset(y: appeared ? 0 : 30)
                            .opacity(appeared ? 1 : 0)
                            .animation(
                                .spring(response: 0.5, dampingFraction: 0.75).delay(Double(index) * 0.08 + 0.15),
                                value: appeared
                            )
                        }
                    }
                }
            }
            .padding(.bottom, 32)
        }
        .navigationTitle("Custom UI Kit")
        .navigationBarTitleDisplayMode(.large)
        .searchable(text: $searchText, prompt: "Tìm category…")
        .background(Color(UIColor.systemGroupedBackground))
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) { appeared = true }
        }
    }

    @ViewBuilder
    func categoryDestination(_ cat: ComponentCategory) -> some View {
        switch cat.name {
        case "Buttons":    ButtonsCategoryView()
        case "Inputs":     InputsCategoryView()
        case "Cards":      CardsCategoryView()
        case "Alerts":     AlertsCategoryView()
        case "Navigation": NavigationCategoryView()
        default:           EmptyView()
        }
    }
}

// MARK: - Header Banner
struct HeaderBannerView: View {
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color.blue, Color.purple],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            // Decorative
            Circle().fill(Color.white.opacity(0.07)).frame(width: 160).offset(x: 120, y: -30)
            Circle().fill(Color.white.opacity(0.05)).frame(width: 100).offset(x: -120, y: 30)

            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Image(systemName: "square.3.layers.3d.down.right.slash")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(.white)
                    Spacer()
                    Text("v1.0")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(.white.opacity(0.7))
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(Color.white.opacity(0.15))
                        .clipShape(Capsule())
                }
                Text("SwiftUI Custom\nComponent Library")
                    .font(.system(size: 22, weight: .bold))
                    .foregroundColor(.white)
                    .lineSpacing(2)
                Text("5 categories · 24 components · 2 notification styles")
                    .font(.system(size: 12))
                    .foregroundColor(.white.opacity(0.75))
            }
            .padding(20)
        }
        .frame(height: 160)
        .clipShape(RoundedRectangle(cornerRadius: 0))
    }
}

// MARK: - Notification Demo Row
struct NotificationDemoRow: View {
    private let nm = NotificationManager.shared

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Notifications")
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(.secondary)

            HStack(spacing: 8) {
                ForEach([
                    ("Toast ✓", NotificationType.success, NotificationStyle.toast),
                    ("Toast ✗", .error, .toast),
                    ("Banner !", .warning, .banner),
                    ("Banner i", .info, .banner),
                ], id: \.0) { label, type, style in
                    Button {
                        if style == .toast {
                            nm.toast(label, message: "Đây là toast notification", type: type)
                        } else {
                            nm.banner(label, message: "Đây là banner notification", type: type)
                        }
                    } label: {
                        Text(label)
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundColor(type.color)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 7)
                            .background(type.color.opacity(0.1))
                            .clipShape(Capsule())
                            .overlay(Capsule().stroke(type.color.opacity(0.25), lineWidth: 1))
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .padding(14)
        .background(Color(UIColor.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }
}

// MARK: - Category Row
struct CategoryRow: View {
    let category: ComponentCategory

    var body: some View {
        HStack(spacing: 14) {
            ZStack {
                RoundedRectangle(cornerRadius: 14)
                    .fill(category.color.opacity(0.12))
                    .frame(width: 56, height: 56)
                Image(systemName: category.icon)
                    .font(.system(size: 22, weight: .semibold))
                    .foregroundColor(category.color)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(category.name)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.primary)
                Text(category.description)
                    .font(.system(size: 13))
                    .foregroundColor(.secondary)
            }

            Spacer()

            HStack(spacing: 6) {
                Text("\(category.count)")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(category.color)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(category.color.opacity(0.1))
                    .clipShape(Capsule())

                Image(systemName: "chevron.right")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(.tertiary)
            }
        }
        .padding(14)
        .background(Color(UIColor.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}
