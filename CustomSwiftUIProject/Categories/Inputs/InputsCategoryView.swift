import SwiftUI

struct InputsCategoryView: View {
    @State private var text1 = ""
    @State private var text2 = ""
    @State private var text3 = ""
    @State private var password = ""
    @State private var selectedOption = "Option A"
    @State private var isToggled = false
    @State private var sliderValue: Double = 0.5
    private let nm = NotificationManager.shared

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                ComponentSection(title: "Floating Label TextField") {
                    FloatingTextField(placeholder: "Email address", text: $text1, icon: "envelope")
                    FloatingTextField(placeholder: "Full name", text: $text2, icon: "person")
                }

                ComponentSection(title: "Secure Field") {
                    SecureFloatingField(placeholder: "Password", text: $password)
                }

                ComponentSection(title: "Segmented Picker") {
                    CustomSegmentedPicker(
                        options: ["Option A", "Option B", "Option C"],
                        selected: $selectedOption,
                        color: .purple
                    )
                }

                ComponentSection(title: "Custom Toggle") {
                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Enable notifications")
                                .font(.system(size: 15, weight: .semibold))
                            Text("Receive push alerts")
                                .font(.system(size: 12))
                                .foregroundColor(.secondary)
                        }
                        Spacer()
                        CustomToggle(isOn: $isToggled, color: .purple) {
                            nm.toast(isToggled ? "Enabled" : "Disabled", type: isToggled ? .success : .warning)
                        }
                    }
                }

                ComponentSection(title: "Custom Slider") {
                    CustomSlider(value: $sliderValue, color: .blue, label: "Volume")
                }

                ComponentSection(title: "Submit") {
                    PrimaryButton(title: "Submit Form", icon: "paperplane.fill") {
                        if text1.isEmpty || text2.isEmpty {
                            nm.banner("Missing fields", message: "Please fill all required fields", type: .error)
                        } else {
                            nm.banner("Submitted!", message: "Form data sent successfully", type: .success)
                        }
                    }
                }
            }
            .padding(16)
            .padding(.bottom, 32)
        }
        .navigationTitle("Inputs")
        .navigationBarTitleDisplayMode(.large)
        .background(Color(UIColor.systemGroupedBackground))
    }
}

// MARK: - Floating Label TextField
struct FloatingTextField: View {
    let placeholder: String
    @Binding var text: String
    let icon: String
    @FocusState private var focused: Bool

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundColor(focused ? .purple : .secondary)
                .frame(width: 20)

            ZStack(alignment: .leading) {
                if text.isEmpty {
                    Text(placeholder)
                        .font(.system(size: focused ? 11 : 15))
                        .foregroundColor(.secondary)
                        .offset(y: focused ? -10 : 0)
                        .animation(.spring(response: 0.25), value: focused)
                }
                TextField("", text: $text)
                    .font(.system(size: 15))
                    .focused($focused)
                    .offset(y: text.isEmpty && !focused ? 0 : 6)
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 14)
        .background(Color(UIColor.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(focused ? Color.purple : Color.clear, lineWidth: 1.5)
        )
        .animation(.spring(response: 0.25), value: focused)
    }
}

// MARK: - Secure Floating Field
struct SecureFloatingField: View {
    let placeholder: String
    @Binding var text: String
    @State private var isVisible = false
    @FocusState private var focused: Bool

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: "lock")
                .font(.system(size: 16))
                .foregroundColor(focused ? .purple : .secondary)
                .frame(width: 20)

            Group {
                if isVisible {
                    TextField(placeholder, text: $text).focused($focused)
                } else {
                    SecureField(placeholder, text: $text).focused($focused)
                }
            }
            .font(.system(size: 15))

            Button { isVisible.toggle() } label: {
                Image(systemName: isVisible ? "eye.slash" : "eye")
                    .foregroundColor(.secondary)
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 14)
        .background(Color(UIColor.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(focused ? Color.purple : Color.clear, lineWidth: 1.5)
        )
    }
}

// MARK: - Custom Segmented Picker
struct CustomSegmentedPicker: View {
    let options: [String]
    @Binding var selected: String
    let color: Color

    var body: some View {
        HStack(spacing: 4) {
            ForEach(options, id: \.self) { opt in
                Button { withAnimation(.spring(response: 0.3)) { selected = opt } } label: {
                    Text(opt)
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(selected == opt ? .white : .secondary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 9)
                        .background(selected == opt ? color : Color.clear)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                }
                .buttonStyle(.plain)
            }
        }
        .padding(4)
        .background(Color(UIColor.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }
}

// MARK: - Custom Toggle
struct CustomToggle: View {
    @Binding var isOn: Bool
    let color: Color
    let onChange: () -> Void

    var body: some View {
        Button {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) { isOn.toggle() }
            onChange()
        } label: {
            ZStack(alignment: isOn ? .trailing : .leading) {
                Capsule().fill(isOn ? color : Color(.systemGray4)).frame(width: 52, height: 30)
                Circle().fill(.white).frame(width: 24, height: 24).padding(3)
                    .shadow(color: .black.opacity(0.15), radius: 3, x: 0, y: 2)
            }
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Custom Slider
struct CustomSlider: View {
    @Binding var value: Double
    let color: Color
    let label: String

    var body: some View {
        VStack(spacing: 10) {
            HStack {
                Text(label).font(.system(size: 14, weight: .semibold))
                Spacer()
                Text("\(Int(value * 100))%")
                    .font(.system(size: 13, weight: .bold, design: .monospaced))
                    .foregroundColor(color)
            }
            Slider(value: $value, in: 0...1)
                .tint(color)
        }
    }
}
