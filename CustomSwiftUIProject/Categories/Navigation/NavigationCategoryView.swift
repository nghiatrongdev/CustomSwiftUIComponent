import SwiftUI

struct NavigationCategoryView: View {
    private let nm = NotificationManager.shared

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                ComponentSection(title: "Custom Tab Bar") {
                    CustomTabBarDemo()
                }

                ComponentSection(title: "Step Indicator") {
                    StepIndicatorDemo()
                }

                ComponentSection(title: "Breadcrumb") {
                    BreadcrumbView(items: ["Home", "Library", "Buttons", "Primary"])
                }

                ComponentSection(title: "Sidebar Menu") {
                    SidebarMenuDemo()
                }
            }
            .padding(16)
            .padding(.bottom, 32)
        }
        .navigationTitle("Navigation")
        .navigationBarTitleDisplayMode(.large)
        .background(Color(UIColor.systemGroupedBackground))
    }
}

// MARK: - Custom Tab Bar Demo
struct CustomTabBarDemo: View {
    @State private var selectedTab = 0
    let tabs = [
        ("house.fill", "Home"),
        ("magnifyingglass", "Search"),
        ("heart.fill", "Saved"),
        ("person.fill", "Profile"),
    ]

    var body: some View {
        VStack(spacing: 12) {
            // Content area
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(UIColor.tertiarySystemGroupedBackground))
                .frame(height: 60)
                .overlay(
                    Text("Tab: \(tabs[selectedTab].1)")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(.secondary)
                )

            // Tab bar
            HStack(spacing: 0) {
                ForEach(tabs.indices, id: \.self) { i in
                    Button {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) { selectedTab = i }
                    } label: {
                        VStack(spacing: 4) {
                            ZStack {
                                if selectedTab == i {
                                    RoundedRectangle(cornerRadius: 10)
                                        .fill(Color.blue.opacity(0.12))
                                        .frame(width: 40, height: 30)
                                }
                                Image(systemName: tabs[i].0)
                                    .font(.system(size: 17, weight: selectedTab == i ? .bold : .regular))
                                    .foregroundColor(selectedTab == i ? .blue : .secondary)
                            }
                            Text(tabs[i].1)
                                .font(.system(size: 10, weight: .medium))
                                .foregroundColor(selectedTab == i ? .blue : .secondary)
                        }
                        .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 10)
            .background(Color(UIColor.secondarySystemGroupedBackground))
            .clipShape(RoundedRectangle(cornerRadius: 16))
        }
    }
}

// MARK: - Step Indicator Demo
struct StepIndicatorDemo: View {
    @State private var currentStep = 0
    let steps = ["Info", "Review", "Payment", "Done"]
    private let nm = NotificationManager.shared

    var body: some View {
        VStack(spacing: 16) {
            // Steps row
            HStack(spacing: 0) {
                ForEach(steps.indices, id: \.self) { i in
                    // Step circle
                    ZStack {
                        Circle()
                            .fill(i <= currentStep ? Color.blue : Color(UIColor.tertiarySystemGroupedBackground))
                            .frame(width: 32, height: 32)
                        if i < currentStep {
                            Image(systemName: "checkmark")
                                .font(.system(size: 13, weight: .bold))
                                .foregroundColor(.white)
                        } else {
                            Text("\(i + 1)")
                                .font(.system(size: 13, weight: .bold))
                                .foregroundColor(i == currentStep ? .white : .secondary)
                        }
                    }

                    // Connector line (not last)
                    if i < steps.count - 1 {
                        Rectangle()
                            .fill(i < currentStep ? Color.blue : Color(UIColor.separator))
                            .frame(height: 2)
                            .frame(maxWidth: .infinity)
                    }
                }
            }

            // Step label
            Text(steps[currentStep])
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.blue)

            // Buttons
            HStack(spacing: 10) {
                if currentStep > 0 {
                    OutlineButton(title: "Back", color: .secondary) {
                        withAnimation(.spring(response: 0.35)) { currentStep -= 1 }
                    }
                }
                PrimaryButton(title: currentStep == steps.count - 1 ? "Finish ✓" : "Next →") {
                    if currentStep < steps.count - 1 {
                        withAnimation(.spring(response: 0.35)) { currentStep += 1 }
                    } else {
                        currentStep = 0
                        nm.banner("Hoàn thành!", message: "Tất cả các bước đã xong", type: .success)
                    }
                }
            }
        }
    }
}

// MARK: - Breadcrumb
struct BreadcrumbView: View {
    let items: [String]

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 4) {
                ForEach(Array(items.enumerated()), id: \.offset) { i, item in
                    HStack(spacing: 4) {
                        Text(item)
                            .font(.system(size: 13, weight: i == items.count - 1 ? .bold : .medium))
                            .foregroundColor(i == items.count - 1 ? .primary : .secondary)
                        if i < items.count - 1 {
                            Image(systemName: "chevron.right")
                                .font(.system(size: 10))
                                .foregroundColor(.secondary)
                        }
                    }
                }
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
            .background(Color(UIColor.secondarySystemGroupedBackground))
            .clipShape(RoundedRectangle(cornerRadius: 10))
        }
    }
}

// MARK: - Sidebar Menu Demo
struct SidebarMenuDemo: View {
    @State private var selected = "Dashboard"
    private let nm = NotificationManager.shared

    let items: [(String, String, Color)] = [
        ("Dashboard", "square.grid.2x2.fill", .blue),
        ("Analytics", "chart.bar.fill", .purple),
        ("Messages", "bubble.left.and.bubble.right.fill", .green),
        ("Settings", "gearshape.fill", .gray),
    ]

    var body: some View {
        VStack(spacing: 4) {
            ForEach(items, id: \.0) { name, icon, color in
                Button {
                    withAnimation(.spring(response: 0.3)) { selected = name }
                    nm.toast(name + " selected", type: .info)
                } label: {
                    HStack(spacing: 12) {
                        Image(systemName: icon)
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(selected == name ? color : .secondary)
                            .frame(width: 24)

                        Text(name)
                            .font(.system(size: 15, weight: selected == name ? .bold : .medium))
                            .foregroundColor(selected == name ? .primary : .secondary)

                        Spacer()

                        if selected == name {
                            Circle().fill(color).frame(width: 8, height: 8)
                        }
                    }
                    .padding(.horizontal, 14)
                    .padding(.vertical, 12)
                    .background(selected == name ? color.opacity(0.1) : Color.clear)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                .buttonStyle(.plain)
            }
        }
        .padding(8)
        .background(Color(UIColor.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}
