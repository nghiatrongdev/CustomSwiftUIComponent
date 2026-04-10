import SwiftUI

struct AlertsCategoryView: View {
    @State private var showDialog = false
    @State private var showBottomSheet = false
    @State private var showPopup = false
    @State private var showActionSheet = false
    private let nm = NotificationManager.shared

    var body: some View {
        ZStack {
            ScrollView {
                VStack(spacing: 16) {
                    ComponentSection(title: "Custom Dialog") {
                        OutlineButton(title: "Show Dialog", color: .red) { showDialog = true }
                    }

                    ComponentSection(title: "Bottom Sheet") {
                        OutlineButton(title: "Show Bottom Sheet", color: .purple) { showBottomSheet = true }
                    }

                    ComponentSection(title: "Inline Popup") {
                        OutlineButton(title: "Show Popup", color: .orange) {
                            withAnimation(.spring(response: 0.35)) { showPopup = true }
                            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                                withAnimation { showPopup = false }
                            }
                        }
                    }

                    ComponentSection(title: "Action Sheet") {
                        OutlineButton(title: "Show Action Sheet", color: .green) { showActionSheet = true }
                    }

                    ComponentSection(title: "Inline Alerts") {
                        VStack(spacing: 10) {
                            InlineAlert(message: "Operation completed successfully.", type: .success)
                            InlineAlert(message: "Please check your connection.", type: .warning)
                            InlineAlert(message: "An error occurred. Try again.", type: .error)
                            InlineAlert(message: "Update available in the store.", type: .info)
                        }
                    }
                }
                .padding(16)
                .padding(.bottom, 32)
            }
            .navigationTitle("Alerts")
            .navigationBarTitleDisplayMode(.large)
            .background(Color(UIColor.systemGroupedBackground))

            // Inline popup overlay
            if showPopup {
                VStack {
                    Spacer()
                    InlinePopup(isShowing: $showPopup)
                        .padding(16)
                        .padding(.bottom, 100)
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                }
                .zIndex(10)
            }
        }
        // Custom Dialog
        .overlay(
            showDialog ? AnyView(
                CustomDialog(
                    title: "Xóa dữ liệu?",
                    message: "Hành động này không thể hoàn tác. Tất cả dữ liệu sẽ bị xóa vĩnh viễn.",
                    confirmTitle: "Xóa",
                    confirmColor: .red,
                    onConfirm: {
                        showDialog = false
                        nm.banner("Đã xóa!", message: "Dữ liệu đã được xóa thành công", type: .error)
                    },
                    onCancel: { showDialog = false }
                )
            ) : AnyView(EmptyView())
        )
        // Bottom Sheet
        .sheet(isPresented: $showBottomSheet) {
            CustomBottomSheet(isShowing: $showBottomSheet)
                .presentationDetents([.medium, .large])
                .presentationDragIndicator(.visible)
        }
        // Action Sheet
        .confirmationDialog("Chọn hành động", isPresented: $showActionSheet, titleVisibility: .visible) {
            Button("Chia sẻ") { nm.toast("Sharing…", type: .info) }
            Button("Tải xuống") { nm.toast("Downloading…", type: .info) }
            Button("Báo cáo", role: .destructive) { nm.banner("Đã báo cáo", type: .error) }
            Button("Huỷ", role: .cancel) {}
        }
    }
}

// MARK: - Custom Dialog
struct CustomDialog: View {
    let title: String
    let message: String
    let confirmTitle: String
    let confirmColor: Color
    let onConfirm: () -> Void
    let onCancel: () -> Void

    var body: some View {
        ZStack {
            Color.black.opacity(0.4).ignoresSafeArea()
                .onTapGesture { onCancel() }

            VStack(spacing: 20) {
                Image(systemName: "exclamationmark.triangle.fill")
                    .font(.system(size: 36))
                    .foregroundColor(confirmColor)

                VStack(spacing: 8) {
                    Text(title).font(.system(size: 18, weight: .bold))
                    Text(message)
                        .font(.system(size: 14))
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .lineSpacing(4)
                }

                HStack(spacing: 12) {
                    Button(action: onCancel) {
                        Text("Huỷ")
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundColor(.primary)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 13)
                            .background(Color(UIColor.tertiarySystemBackground))
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    .buttonStyle(.plain)

                    Button(action: onConfirm) {
                        Text(confirmTitle)
                            .font(.system(size: 15, weight: .bold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 13)
                            .background(confirmColor)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(24)
            .background(Color(UIColor.secondarySystemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 24))
            .shadow(color: .black.opacity(0.2), radius: 30, x: 0, y: 10)
            .padding(32)
        }
    }
}

// MARK: - Bottom Sheet content
struct CustomBottomSheet: View {
    @Binding var isShowing: Bool
    private let nm = NotificationManager.shared

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Bottom Sheet").font(.system(size: 22, weight: .bold))
            Text("Đây là custom bottom sheet với `.presentationDetents`. Bạn có thể kéo để thay đổi kích thước.")
                .font(.system(size: 15))
                .foregroundColor(.secondary)
                .lineSpacing(5)

            Divider()

            ForEach(["Option 1", "Option 2", "Option 3"], id: \.self) { opt in
                Button {
                    isShowing = false
                    nm.toast(opt + " selected", type: .success)
                } label: {
                    HStack {
                        Text(opt).font(.system(size: 16, weight: .medium))
                        Spacer()
                        Image(systemName: "chevron.right").foregroundColor(.secondary).font(.system(size: 13))
                    }
                    .padding(14)
                    .background(Color(UIColor.secondarySystemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                .buttonStyle(.plain)
            }
            Spacer()
        }
        .padding(20)
    }
}

// MARK: - Inline Popup
struct InlinePopup: View {
    @Binding var isShowing: Bool

    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: "gift.fill")
                .font(.system(size: 24))
                .foregroundColor(.purple)

            VStack(alignment: .leading, spacing: 3) {
                Text("Special Offer!").font(.system(size: 15, weight: .bold))
                Text("50% off — hôm nay cuối cùng").font(.system(size: 12)).foregroundColor(.secondary)
            }

            Spacer()

            Button { withAnimation { isShowing = false } } label: {
                Image(systemName: "xmark").font(.system(size: 12, weight: .bold)).foregroundColor(.secondary)
                    .padding(7)
                    .background(Color(UIColor.tertiarySystemBackground))
                    .clipShape(Circle())
            }
        }
        .padding(16)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 18))
        .overlay(RoundedRectangle(cornerRadius: 18).stroke(Color.purple.opacity(0.2), lineWidth: 1))
        .shadow(color: .purple.opacity(0.15), radius: 16, x: 0, y: 8)
    }
}

// MARK: - Inline Alert
struct InlineAlert: View {
    let message: String
    let type: NotificationType

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: type.icon)
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(type.color)
            Text(message)
                .font(.system(size: 13))
                .foregroundColor(.primary)
            Spacer()
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 11)
        .background(type.color.opacity(0.08))
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .overlay(RoundedRectangle(cornerRadius: 10).stroke(type.color.opacity(0.2), lineWidth: 1))
    }
}
