import SwiftUI

// MARK: - Settings View
struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss

    // Persisted values (used by Me page too)
    @AppStorage("penny.profile.name") private var storedName: String = ""
    @AppStorage("penny.profile.email") private var storedEmail: String = ""
    @AppStorage("penny.logoDev.publishableKey") private var storedLogoDevKey: String = ""
    @AppStorage("penny.preferences.languageCode") private var storedLanguageCode = AppLanguage.english.rawValue
    @AppStorage(Haptics.settingsKey) private var hapticsEnabled = true

    @State private var profile = SettingsProfile(
        name: "",
        email: ""
    )

    // Editing
    @State private var activeProfileEditor: Field?
    @State private var activePreferenceEditor: PreferenceSheet?
    @State private var showLogoProviderEditor = false
    @State private var draftFirstName = ""
    @State private var draftLastName = ""
    @State private var draftEmail = ""
    @State private var draftLogoDevKey = ""

    @FocusState private var focusedField: Field?

    private enum Field: Identifiable {
        case name, email

        var id: Self { self }
    }

    private enum PreferenceSheet: Identifiable {
        case language

        var id: Self { self }
    }

    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(spacing: 0) {
                headerSection

                // ── Account & Security ───────────────────────────────────
                sectionLabel(language.text(.accountSecurity))

                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                    tappableGridCell(
                        label: language.text(.name),
                        value: profile.name
                    ) {
                        openEditor(.name)
                    }

                    tappableGridCell(
                        label: language.text(.email),
                        value: profile.email
                    ) {
                        openEditor(.email)
                    }
                }

                divider

                sectionLabel(language.text(.app))

                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                    tappableGridCell(
                        label: language.text(.language),
                        value: selectedLanguage.title
                    ) {
                        activePreferenceEditor = .language
                    }

                    toggleGridCell(
                        label: language.text(.haptics),
                        value: hapticsEnabled ? language.text(.on) : language.text(.off),
                        isOn: $hapticsEnabled
                    )
                }

                tappableGridCell(
                    label: language.text(.merchantLogos),
                    value: storedLogoDevKey.isEmpty ? language.text(.notConfigured) : language.text(.logoConnected),
                    valueColor: storedLogoDevKey.isEmpty ? .white.opacity(0.6) : MeTheme.success,
                    hasAccent: !storedLogoDevKey.isEmpty
                ) {
                    openLogoProviderEditor()
                }
                .padding(.top, 12)
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 120)
        }
        .background(backgroundGradient)
        .navigationBarHidden(true)
        .onAppear {
            profile.name = storedName
            profile.email = storedEmail
        }
        .onChange(of: profile.name) { _, _ in
            autoPersistProfile()
        }
        .onChange(of: profile.email) { _, _ in
            autoPersistProfile()
        }
        .sheet(item: $activeProfileEditor) { field in
            profileEditorSheet(for: field)
                .presentationCornerRadius(26)
                .presentationDragIndicator(.visible)
        }
        .sheet(item: $activePreferenceEditor) { sheet in
            switch sheet {
            case .language:
                languageSelectionSheet
                    .presentationCornerRadius(26)
                    .presentationDragIndicator(.visible)
            }
        }
        .sheet(isPresented: $showLogoProviderEditor) {
            logoProviderSheet
                .presentationCornerRadius(26)
                .presentationDragIndicator(.visible)
        }
    }

    // MARK: - Header
    private var headerSection: some View {
        HStack {
            Button { dismiss() } label: {
                Image(systemName: "chevron.left")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white.opacity(0.6))
                    .frame(width: 36, height: 36)
                    .background(MeTheme.surface)
                    .clipShape(Circle())
                    .overlay(Circle().stroke(MeTheme.glassBorder, lineWidth: 1))
            }

            Spacer()

            Text(language.text(.settings).uppercased())
                .font(.system(size: 13, weight: .semibold))
                .tracking(2)
                .foregroundColor(.white.opacity(0.4))

            Spacer()
                .frame(width: 36)
        }
        .padding(.top, 8)
        .padding(.bottom, 24)
    }

    // MARK: - FIXED TAPPABLE CELL
    private func tappableGridCell(
        label: String,
        value: String,
        valueColor: Color = .white,
        hasAccent: Bool = false,
        action: @escaping () -> Void
    ) -> some View {
        Button {
            Haptics.light()
            action()
        } label: {
            gridCell(label: label, value: value, valueColor: valueColor, hasAccent: hasAccent)
                .overlay(alignment: .topTrailing) {
                    Image(systemName: "pencil")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(.white.opacity(0.35))
                        .padding(12)
                }
        }
        .buttonStyle(.plain)
    }

    // MARK: - Grid Cell
    private func gridCell(
        label: String,
        value: String,
        valueColor: Color = .white,
        hasAccent: Bool = false,
        isDisabled: Bool = false
    ) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(label.uppercased())
                .font(.system(size: 10, weight: .bold))
                .foregroundColor(.white.opacity(0.4))
                .tracking(1.5)

            Text(value)
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(valueColor)
                .lineLimit(1)
                .minimumScaleFactor(0.9)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(MeTheme.surface)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(MeTheme.glassBorder, lineWidth: 1)
        )
        .overlay(alignment: .leading) {
            if hasAccent {
                RoundedRectangle(cornerRadius: 2)
                    .fill(MeTheme.accent)
                    .frame(width: 3)
                    .padding(.vertical, 10)
            }
        }
        .opacity(isDisabled ? 0.4 : 1.0)
    }

    private func toggleGridCell(label: String, value: String, isOn: Binding<Bool>) -> some View {
        HStack(alignment: .center) {
            VStack(alignment: .leading, spacing: 6) {
                Text(label.uppercased())
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(.white.opacity(0.4))
                    .tracking(1.5)

                Text(value)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(.white)
            }

            Spacer(minLength: 12)

            Toggle("", isOn: isOn)
                .labelsHidden()
                .tint(MeTheme.accent)
        }
        .padding(16)
        .background(MeTheme.surface)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(MeTheme.glassBorder, lineWidth: 1)
        )
    }

    // MARK: - Editor Sheet
    private func profileEditorSheet(for field: Field) -> some View {
        ZStack {
            MeTheme.canvas.ignoresSafeArea()

            VStack(alignment: .leading, spacing: 18) {
                VStack(alignment: .leading, spacing: 14) {
                    ZStack {
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [
                                        Color(red: 1.0, green: 0.55, blue: 0.36),
                                        Color(red: 1.0, green: 0.42, blue: 0.16)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 42, height: 42)

                        Image(systemName: field == .name ? "person.text.rectangle.fill" : "envelope.fill")
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundColor(.white)
                    }

                    VStack(alignment: .leading, spacing: 6) {
                        Text(field == .name ? language.text(.editName) : language.text(.editEmail))
                            .font(.system(size: 22, weight: .semibold))
                            .foregroundColor(.white)
                    }
                }
                .padding(.top, 6)

                VStack(spacing: 0) {
                    if field == .name {
                        compactField(title: language.text(.firstName), text: $draftFirstName, keyboard: .default)
                            .focused($focusedField, equals: .name)

                        Divider()
                            .background(Color.white.opacity(0.06))
                            .padding(.leading, 16)

                        compactField(title: language.text(.lastName), text: $draftLastName, keyboard: .default)
                    } else {
                        compactField(title: language.text(.email), text: $draftEmail, keyboard: .emailAddress)
                            .focused($focusedField, equals: .email)
                    }
                }
                .background(MeTheme.surface)
                .clipShape(RoundedRectangle(cornerRadius: 20))
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.white.opacity(0.04), lineWidth: 1)
                )

                Spacer(minLength: 0)

                HStack(spacing: 12) {
                    Button {
                        dismissProfileEditor()
                    } label: {
                        Text(language.text(.cancel))
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundColor(.white.opacity(0.72))
                            .frame(maxWidth: .infinity)
                            .frame(height: 52)
                            .background(
                                RoundedRectangle(cornerRadius: 18)
                                    .fill(Color.white.opacity(0.04))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 18)
                                            .stroke(Color.white.opacity(0.08), lineWidth: 1)
                                    )
                            )
                    }
                    .buttonStyle(.plain)

                    Button { saveFromSheet(field) } label: {
                        Text(language.text(.save))
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 52)
                            .background(
                                RoundedRectangle(cornerRadius: 18)
                                    .fill(
                                        LinearGradient(
                                            colors: [
                                                Color(red: 1.0, green: 0.55, blue: 0.36),
                                                Color(red: 1.0, green: 0.42, blue: 0.16)
                                            ],
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                    )
                            )
                    }
                    .buttonStyle(.plain)
                }
                .padding(.bottom, 12)
            }
            .padding(20)
        }
        .onAppear {
            if field == .name {
                let parts = profile.name
                    .trimmingCharacters(in: .whitespacesAndNewlines)
                    .split(separator: " ", maxSplits: 1, omittingEmptySubsequences: true)
                draftFirstName = parts.first.map(String.init) ?? ""
                draftLastName = parts.dropFirst().first.map(String.init) ?? ""
            } else {
                draftEmail = profile.email
            }
        }
    }

    private func compactField(title: String, text: Binding<String>, keyboard: UIKeyboardType) -> some View {
        let isEmailField = keyboard == .emailAddress

        return VStack(alignment: .leading, spacing: 8) {
            Text(title.uppercased())
                .font(.system(size: 10, weight: .bold))
                .foregroundColor(.white.opacity(0.4))
                .tracking(2)

            TextField(title, text: text)
                .keyboardType(keyboard)
                .textInputAutocapitalization(isEmailField ? .never : .words)
                .autocorrectionDisabled(isEmailField)
                .foregroundColor(.white)
                .padding(.horizontal, 14)
                .frame(height: 48)
                .background(
                    RoundedRectangle(cornerRadius: 14)
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color(red: 0.14, green: 0.09, blue: 0.07),
                                    Color(red: 0.10, green: 0.06, blue: 0.05)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                )
        }
        .padding(16)
    }

    private var logoProviderSheet: some View {
        ZStack {
            MeTheme.canvas.ignoresSafeArea()

            VStack(spacing: 16) {
                HStack {
                    Text(language.text(.merchantLogos))
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.white)
                    Spacer()
                    Button(language.text(.save)) { saveLogoProvider() }
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(MeTheme.accent)
                }
                .padding(.top, 8)

                VStack(alignment: .leading, spacing: 10) {
                    Text("LOGO.DEV PUBLISHABLE KEY")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(.white.opacity(0.4))
                        .tracking(2)

                    TextField("pk_...", text: $draftLogoDevKey)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                        .foregroundColor(.white)
                        .padding(.horizontal, 14)
                        .frame(height: 48)
                        .background(
                            RoundedRectangle(cornerRadius: 14)
                                .fill(Color.white.opacity(0.05))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 14)
                                        .stroke(Color.white.opacity(0.08), lineWidth: 1)
                                )
                        )

                    Text("Used for high-quality merchant logos in transactions. Leave blank to fall back to category icons.")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.white.opacity(0.5))
                        .lineSpacing(3)
                }
                .padding(16)
                .background(MeTheme.surface)
                .clipShape(RoundedRectangle(cornerRadius: 18))
                .overlay(
                    RoundedRectangle(cornerRadius: 18)
                        .stroke(MeTheme.glassBorder, lineWidth: 1)
                )

                Button {
                    draftLogoDevKey = ""
                } label: {
                    Text("Clear Key")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(.white.opacity(0.65))
                        .frame(maxWidth: .infinity)
                        .frame(height: 46)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color.white.opacity(0.04))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 16)
                                        .stroke(Color.white.opacity(0.08), lineWidth: 1)
                                )
                        )
                }
                .buttonStyle(.plain)

                Spacer(minLength: 0)

                Button { saveLogoProvider() } label: {
                    Text("Save")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 52)
                        .background(
                            RoundedRectangle(cornerRadius: 18)
                                .fill(
                                    LinearGradient(
                                        colors: [
                                            Color(red: 1.0, green: 0.55, blue: 0.36),
                                            Color(red: 1.0, green: 0.42, blue: 0.16)
                                        ],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                        )
                }
                .padding(.bottom, 12)
            }
            .padding(20)
        }
        .onAppear {
            draftLogoDevKey = storedLogoDevKey
        }
    }

    private var languageSelectionSheet: some View {
        ZStack {
            MeTheme.canvas.ignoresSafeArea()

            VStack(alignment: .leading, spacing: 18) {
                Text(language.text(.appLanguage))
                    .font(.system(size: 22, weight: .semibold))
                    .foregroundColor(.white)
                    .padding(.top, 8)

                VStack(spacing: 0) {
                    ForEach(AppLanguage.allCases) { language in
                        Button {
                            storedLanguageCode = language.rawValue
                            Haptics.medium()
                            activePreferenceEditor = nil
                        } label: {
                            HStack {
                                VStack(alignment: .leading, spacing: 3) {
                                    Text(language.title)
                                        .font(.system(size: 15, weight: .semibold))
                                        .foregroundColor(.white)

                                    Text(language.nativeTitle)
                                        .font(.system(size: 12, weight: .medium))
                                        .foregroundColor(.white.opacity(0.45))
                                }

                                Spacer()

                                if storedLanguageCode == language.rawValue {
                                    Image(systemName: "checkmark.circle.fill")
                                        .font(.system(size: 18, weight: .semibold))
                                        .foregroundColor(MeTheme.accent)
                                }
                            }
                            .padding(16)
                        }
                        .buttonStyle(.plain)

                        if language != AppLanguage.allCases.last {
                            Divider()
                                .background(Color.white.opacity(0.06))
                                .padding(.leading, 16)
                        }
                    }
                }
                .background(MeTheme.surface)
                .clipShape(RoundedRectangle(cornerRadius: 20))
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.white.opacity(0.04), lineWidth: 1)
                )

                Spacer(minLength: 0)
            }
            .padding(20)
        }
    }

    private func openEditor(_ field: Field) {
        activeProfileEditor = field

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
            focusedField = field
        }
    }

    private func openLogoProviderEditor() {
        draftLogoDevKey = storedLogoDevKey
        showLogoProviderEditor = true
    }

    private func saveFromSheet(_ field: Field) {
        switch field {
        case .name:
            let first = draftFirstName.trimmingCharacters(in: .whitespacesAndNewlines)
            let last = draftLastName.trimmingCharacters(in: .whitespacesAndNewlines)
            profile.name = [first, last].filter { !$0.isEmpty }.joined(separator: " ")
        case .email:
            profile.email = draftEmail.trimmingCharacters(in: .whitespacesAndNewlines)
        }
        saveProfile()
        activeProfileEditor = nil
    }

    private func saveProfile() {
        profile.name = profile.name.trimmingCharacters(in: .whitespacesAndNewlines)
        profile.email = profile.email.trimmingCharacters(in: .whitespacesAndNewlines)
        storedName = profile.name
        storedEmail = profile.email

        Haptics.medium()
        focusedField = nil
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }

    private func autoPersistProfile() {
        let trimmedName = profile.name.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedEmail = profile.email.trimmingCharacters(in: .whitespacesAndNewlines)

        if storedName != trimmedName {
            storedName = trimmedName
        }

        if storedEmail != trimmedEmail {
            storedEmail = trimmedEmail
        }
    }

    private func dismissProfileEditor() {
        focusedField = nil
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
        activeProfileEditor = nil
    }

    private func saveLogoProvider() {
        storedLogoDevKey = draftLogoDevKey.trimmingCharacters(in: .whitespacesAndNewlines)
        Haptics.medium()
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
        showLogoProviderEditor = false
    }

    private func sectionLabel(_ text: String) -> some View {
        HStack {
            Text(text.uppercased())
                .font(.system(size: 10, weight: .bold))
                .foregroundColor(.white.opacity(0.4))
                .tracking(2)
            Spacer()
        }
        .padding(.horizontal, 4)
        .padding(.bottom, 12)
    }

    private var divider: some View {
        LinearGradient(
            colors: [.clear, .white.opacity(0.08), .clear],
            startPoint: .leading,
            endPoint: .trailing
        )
        .frame(height: 1)
        .padding(.vertical, 24)
    }

    private var selectedLanguage: AppLanguage {
        AppLanguage(rawValue: storedLanguageCode) ?? .english
    }

    private var backgroundGradient: some View {
        PennyWarmBackground()
    }

    private var language: AppLanguage {
        AppLanguage(rawValue: storedLanguageCode) ?? .english
    }
}

// MARK: - Models
struct SettingsProfile {
    var name: String
    var email: String
}

#Preview {
    SettingsView()
        .preferredColorScheme(.dark)
}
