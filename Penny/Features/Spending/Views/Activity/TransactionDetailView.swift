import SwiftUI
import PhotosUI
import UniformTypeIdentifiers
import UIKit

struct TransactionDetailView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(SpendingStore.self) private var spending

    let transactionId: UUID

    @State private var draftNotes = ""
    @State private var draftTags: [String] = []
    @State private var tagInput = ""
    @State private var draftAttachments: [TransactionAttachment] = []
    @State private var isImpulse = false
    @State private var selectedPhoto: PhotosPickerItem?
    @State private var showFileImporter = false
    @State private var saveMessage: String?

    private var transaction: SpendingTransaction? {
        spending.transaction(for: transactionId)
    }

    private var merchantHistory: [SpendingTransaction] {
        guard let transaction else { return [] }
        return spending.merchantHistory(for: transaction)
    }

    private var transactionDateString: String {
        guard
            let transaction,
            let date = spending.date(forTransactionId: transaction.id)
        else { return "Date unavailable" }

        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d, yyyy"
        return "\(formatter.string(from: date)) • \(transaction.time)"
    }

    private var amountColor: Color {
        transaction?.isImpulse == true ? DetailTheme.accent : (transaction?.kind.signedAmountColor ?? .white)
    }

    var body: some View {
        ZStack {
            background

            if let transaction {
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 22) {
                        header(transaction: transaction)
                        summaryCard(transaction: transaction)
                        notesCard
                        tagsCard
                        attachmentsCard
                        merchantHistoryCard(current: transaction)
                        Color.clear.frame(height: 120)
                    }
                    .padding(.horizontal, 22)
                    .padding(.top, 18)
                }

                footer
            } else {
                missingState
            }
        }
        .onAppear(perform: loadDraft)
        .onChange(of: transaction?.id) { _, _ in
            loadDraft()
        }
        .onChange(of: selectedPhoto) { _, newItem in
            guard let newItem else { return }
            Task { await importPhoto(from: newItem) }
        }
        .fileImporter(
            isPresented: $showFileImporter,
            allowedContentTypes: [.image, .pdf, .plainText, .data],
            allowsMultipleSelection: false
        ) { result in
            importDocument(result)
        }
    }

    private var background: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color(red: 0.04, green: 0.04, blue: 0.05),
                    Color(red: 0.05, green: 0.04, blue: 0.04),
                    .black
                ],
                startPoint: .top,
                endPoint: .bottom
            )

            RadialGradient(
                colors: [
                    DetailTheme.accent.opacity(0.85),
                    DetailTheme.accent.opacity(0.24),
                    .clear
                ],
                center: UnitPoint(x: 0.5, y: -0.2),
                startRadius: 0,
                endRadius: 430
            )
        }
        .ignoresSafeArea()
    }

    private func header(transaction: SpendingTransaction) -> some View {
        HStack {
            Button { dismiss() } label: {
                Circle()
                    .fill(DetailTheme.surface)
                    .frame(width: 42, height: 42)
                    .overlay(Circle().stroke(DetailTheme.line, lineWidth: 1))
                    .overlay(
                        Image(systemName: "chevron.left")
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundColor(.white)
                    )
            }

            Spacer()

            Text("TRANSACTION DETAIL")
                .font(.system(size: 11, weight: .bold))
                .tracking(2)
                .foregroundColor(.white.opacity(0.45))

            Spacer()

            Button(action: saveChanges) {
                Text("Save")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 14)
                    .frame(height: 42)
                    .background(Capsule().fill(DetailTheme.accent.opacity(0.8)))
            }
            .buttonStyle(.plain)
        }
        .padding(.top, 6)
    }

    private func summaryCard(transaction: SpendingTransaction) -> some View {
        detailCard {
            VStack(spacing: 16) {
                RoundedRectangle(cornerRadius: 18)
                    .fill(Color(red: 0.1, green: 0.1, blue: 0.12))
                    .frame(width: 72, height: 72)
                    .overlay(
                        RoundedRectangle(cornerRadius: 18)
                            .stroke(transaction.borderColor, lineWidth: 1)
                    )
                    .overlay(
                        BrandLogoView(
                            name: transaction.title,
                            size: 72,
                            fallbackIcon: transaction.icon,
                            fallbackColor: transaction.iconColor
                        )
                    )

                VStack(spacing: 6) {
                    Text(transaction.title)
                        .font(.system(size: 28, weight: .semibold))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)

                    Text(transaction.category.rawValue.uppercased())
                        .font(.system(size: 10, weight: .bold))
                        .tracking(2)
                        .foregroundColor(.white.opacity(0.42))

                    Text(transactionDateString)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.white.opacity(0.42))
                }

                Text(transaction.amount)
                    .font(.system(size: 54, weight: .light, design: .serif))
                    .foregroundColor(amountColor)

                VStack(spacing: 10) {
                    statRow(label: "Type", value: transaction.kind.rawValue)
                    statRow(label: "Account", value: spending.accountName(for: transaction.accountId) ?? "Unassigned")
                    statRow(label: "Merchant", value: transaction.merchantNormalized ?? transaction.title)
                    if transaction.kind.usesImpulseFlag {
                        Toggle(isOn: $isImpulse) {
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Impulse Purchase")
                                    .font(.system(size: 13, weight: .semibold))
                                    .foregroundColor(.white.opacity(0.84))
                                Text("Use this for habit tracking and daily vibe scoring.")
                                    .font(.system(size: 11, weight: .medium))
                                    .foregroundColor(.white.opacity(0.45))
                            }
                        }
                        .tint(DetailTheme.accent)
                    }
                }
            }
        }
    }

    private var notesCard: some View {
        detailCard(title: "NOTES") {
            VStack(alignment: .leading, spacing: 12) {
                TextEditor(text: $draftNotes)
                    .scrollContentBackground(.hidden)
                    .frame(minHeight: 120)
                    .padding(12)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color.white.opacity(0.04))
                            .overlay(RoundedRectangle(cornerRadius: 16).stroke(DetailTheme.line, lineWidth: 1))
                    )
                    .foregroundColor(.white)

                if let saveMessage {
                    Text(saveMessage)
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(.white.opacity(0.45))
                }
            }
        }
    }

    private var tagsCard: some View {
        detailCard(title: "TAGS") {
            VStack(alignment: .leading, spacing: 14) {
                FlowLayout(spacing: 8) {
                    ForEach(draftTags, id: \.self) { tag in
                        Button {
                            draftTags.removeAll { $0 == tag }
                        } label: {
                            HStack(spacing: 6) {
                                Text("#\(tag)")
                                Image(systemName: "xmark")
                                    .font(.system(size: 9, weight: .bold))
                            }
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundColor(.white.opacity(0.86))
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(
                                Capsule()
                                    .fill(Color.white.opacity(0.06))
                                    .overlay(Capsule().stroke(DetailTheme.line, lineWidth: 1))
                            )
                        }
                        .buttonStyle(.plain)
                    }
                }

                HStack(spacing: 10) {
                    TextField("Add a tag", text: $tagInput)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                        .foregroundColor(.white)
                        .padding(.horizontal, 14)
                        .frame(height: 44)
                        .background(
                            RoundedRectangle(cornerRadius: 14)
                                .fill(Color.white.opacity(0.04))
                                .overlay(RoundedRectangle(cornerRadius: 14).stroke(DetailTheme.line, lineWidth: 1))
                        )

                    Button(action: addTag) {
                        Image(systemName: "plus")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(.white)
                            .frame(width: 44, height: 44)
                            .background(Circle().fill(DetailTheme.accent.opacity(0.9)))
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    private var attachmentsCard: some View {
        detailCard(title: "RECEIPTS & ATTACHMENTS") {
            VStack(alignment: .leading, spacing: 14) {
                HStack(spacing: 10) {
                    PhotosPicker(selection: $selectedPhoto, matching: .images) {
                        attachmentActionLabel(icon: "photo.fill", title: "Add Photo")
                    }
                    .buttonStyle(.plain)

                    Button {
                        showFileImporter = true
                    } label: {
                        attachmentActionLabel(icon: "paperclip", title: "Add File")
                    }
                    .buttonStyle(.plain)
                }

                if draftAttachments.isEmpty {
                    Text("No receipt or attachment added yet.")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.white.opacity(0.42))
                } else {
                    VStack(spacing: 10) {
                        ForEach(draftAttachments) { attachment in
                            HStack(spacing: 12) {
                                attachmentPreview(for: attachment)

                                VStack(alignment: .leading, spacing: 4) {
                                    Text(attachment.fileName)
                                        .font(.system(size: 13, weight: .semibold))
                                        .foregroundColor(.white)
                                        .lineLimit(1)

                                    Text(attachment.kind == .image ? "Image attachment" : "Document attachment")
                                        .font(.system(size: 11, weight: .medium))
                                        .foregroundColor(.white.opacity(0.45))
                                }

                                Spacer()

                                Button {
                                    removeAttachment(attachment)
                                } label: {
                                    Image(systemName: "trash")
                                        .font(.system(size: 13, weight: .semibold))
                                        .foregroundColor(.white.opacity(0.72))
                                        .frame(width: 30, height: 30)
                                        .background(Circle().fill(Color.white.opacity(0.06)))
                                }
                                .buttonStyle(.plain)
                            }
                            .padding(12)
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(Color.white.opacity(0.04))
                                    .overlay(RoundedRectangle(cornerRadius: 16).stroke(DetailTheme.line, lineWidth: 1))
                            )
                        }
                    }
                }
            }
        }
    }

    private func merchantHistoryCard(current transaction: SpendingTransaction) -> some View {
        detailCard(title: "MERCHANT HISTORY") {
            VStack(alignment: .leading, spacing: 10) {
                if merchantHistory.isEmpty {
                    Text("No other transactions from this merchant yet.")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.white.opacity(0.42))
                } else {
                    ForEach(merchantHistory) { item in
                        HStack(alignment: .center, spacing: 12) {
                            Circle()
                                .fill(item.category.color.opacity(0.16))
                                .frame(width: 10, height: 10)

                            VStack(alignment: .leading, spacing: 3) {
                                Text(item.subtitle.isEmpty ? item.category.rawValue : item.subtitle)
                                    .font(.system(size: 13, weight: .semibold))
                                    .foregroundColor(.white)

                                Text(historyDateString(for: item))
                                    .font(.system(size: 11, weight: .medium))
                                    .foregroundColor(.white.opacity(0.45))
                            }

                            Spacer()

                            Text(item.amount)
                                .font(.system(size: 15, weight: .medium, design: .serif))
                                .foregroundColor(item.kind.signedAmountColor)
                        }
                        .padding(.vertical, 6)
                    }
                }
            }
        }
    }

    private var footer: some View {
        VStack {
            Spacer()

            VStack(spacing: 14) {
                Button(action: saveChanges) {
                    Text("Save Changes")
                        .font(.system(size: 15, weight: .bold))
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(Capsule().fill(.white))
                }
                .buttonStyle(.plain)

                Button("Close") {
                    dismiss()
                }
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(.white.opacity(0.58))
            }
            .padding(.horizontal, 26)
            .padding(.bottom, 24)
            .background(
                LinearGradient(
                    colors: [
                        Color.clear,
                        Color.black.opacity(0.85)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .frame(height: 200)
            )
            .ignoresSafeArea(edges: .bottom)
        }
    }

    private var missingState: some View {
        VStack(spacing: 16) {
            Text("Transaction not found")
                .font(.system(size: 28, weight: .semibold, design: .serif))
                .foregroundColor(.white)

            Text("This transaction may have been deleted or moved.")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.white.opacity(0.54))

            Button("Close") { dismiss() }
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.black)
                .padding(.horizontal, 18)
                .frame(height: 44)
                .background(Capsule().fill(.white))
        }
        .padding(24)
    }

    private func detailCard<Content: View>(title: String? = nil, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            if let title {
                Text(title)
                    .font(.system(size: 10, weight: .bold))
                    .tracking(2)
                    .foregroundColor(.white.opacity(0.38))
            }

            content()
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 26)
                .fill(DetailTheme.surface)
                .overlay(RoundedRectangle(cornerRadius: 26).stroke(DetailTheme.line, lineWidth: 1))
        )
    }

    private func statRow(label: String, value: String) -> some View {
        HStack {
            Text(label.uppercased())
                .font(.system(size: 10, weight: .bold))
                .tracking(1.8)
                .foregroundColor(.white.opacity(0.36))

            Spacer()

            Text(value)
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(.white.opacity(0.84))
        }
    }

    private func attachmentActionLabel(icon: String, title: String) -> some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
            Text(title)
        }
        .font(.system(size: 13, weight: .semibold))
        .foregroundColor(.white)
        .padding(.horizontal, 14)
        .frame(height: 42)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(Color.white.opacity(0.06))
                .overlay(RoundedRectangle(cornerRadius: 14).stroke(DetailTheme.line, lineWidth: 1))
        )
    }

    @ViewBuilder
    private func attachmentPreview(for attachment: TransactionAttachment) -> some View {
        if attachment.kind == .image,
           let image = UIImage(contentsOfFile: attachmentURL(for: attachment).path) {
            Image(uiImage: image)
                .resizable()
                .scaledToFill()
                .frame(width: 50, height: 50)
                .clipShape(RoundedRectangle(cornerRadius: 12))
        } else {
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white.opacity(0.06))
                .frame(width: 50, height: 50)
                .overlay(
                    Image(systemName: attachment.kind == .image ? "photo.fill" : "doc.fill")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.white.opacity(0.78))
                )
        }
    }

    private func historyDateString(for transaction: SpendingTransaction) -> String {
        guard let date = spending.date(forTransactionId: transaction.id) else { return transaction.time }
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d"
        return "\(formatter.string(from: date)) • \(transaction.time)"
    }

    private func addTag() {
        let normalized = tagInput
            .replacingOccurrences(of: "#", with: "")
            .trimmingCharacters(in: .whitespacesAndNewlines)

        guard !normalized.isEmpty else { return }
        if !draftTags.contains(normalized) {
            draftTags.append(normalized)
        }
        tagInput = ""
    }

    private func saveChanges() {
        guard let transaction else { return }
        spending.updateTransactionDetails(
            transactionId: transaction.id,
            notes: draftNotes,
            tags: draftTags,
            isImpulse: isImpulse,
            attachments: draftAttachments
        )
        saveMessage = "Saved just now"
        Haptics.medium()
    }

    private func loadDraft() {
        guard let transaction else { return }
        draftNotes = transaction.notes ?? ""
        draftTags = transaction.tags
        draftAttachments = transaction.attachments
        isImpulse = transaction.isImpulse
    }

    private func importDocument(_ result: Result<[URL], Error>) {
        guard case let .success(urls) = result, let url = urls.first else { return }
        let shouldStop = url.startAccessingSecurityScopedResource()
        defer {
            if shouldStop {
                url.stopAccessingSecurityScopedResource()
            }
        }

        do {
            let attachment = try storeAttachment(from: url)
            draftAttachments.append(attachment)
        } catch {
            saveMessage = "Could not attach that file"
        }
    }

    private func importPhoto(from item: PhotosPickerItem) async {
        do {
            guard let data = try await item.loadTransferable(type: Data.self) else { return }
            let storedFileName = "\(UUID().uuidString).jpg"
            let destination = attachmentsDirectory().appendingPathComponent(storedFileName)
            try data.write(to: destination, options: .atomic)

            let attachment = TransactionAttachment(
                fileName: "Receipt Photo.jpg",
                storedFileName: storedFileName,
                kind: .image
            )

            await MainActor.run {
                draftAttachments.append(attachment)
                selectedPhoto = nil
            }
        } catch {
            await MainActor.run {
                saveMessage = "Could not import that photo"
                selectedPhoto = nil
            }
        }
    }

    private func attachmentsDirectory() -> URL {
        let documents = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first ?? URL(fileURLWithPath: NSTemporaryDirectory())
        let directory = documents.appendingPathComponent("TransactionAttachments", isDirectory: true)

        if !FileManager.default.fileExists(atPath: directory.path) {
            try? FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true, attributes: nil)
        }

        return directory
    }

    private func storeAttachment(from url: URL) throws -> TransactionAttachment {
        let storedFileName = "\(UUID().uuidString)-\(url.lastPathComponent)"
        let destination = attachmentsDirectory().appendingPathComponent(storedFileName)

        if FileManager.default.fileExists(atPath: destination.path) {
            try FileManager.default.removeItem(at: destination)
        }
        try FileManager.default.copyItem(at: url, to: destination)

        let type = UTType(filenameExtension: url.pathExtension)?.conforms(to: .image) == true
            ? TransactionAttachment.Kind.image
            : .document

        return TransactionAttachment(
            fileName: url.lastPathComponent,
            storedFileName: storedFileName,
            kind: type
        )
    }

    private func attachmentURL(for attachment: TransactionAttachment) -> URL {
        attachmentsDirectory().appendingPathComponent(attachment.storedFileName)
    }

    private func removeAttachment(_ attachment: TransactionAttachment) {
        let url = attachmentURL(for: attachment)
        if FileManager.default.fileExists(atPath: url.path) {
            try? FileManager.default.removeItem(at: url)
        }
        draftAttachments.removeAll { $0.id == attachment.id }
    }
}

private enum DetailTheme {
    static let surface = Color(red: 0.071, green: 0.071, blue: 0.086).opacity(0.82)
    static let line = Color.white.opacity(0.06)
    static let accent = Color(red: 1.0, green: 0.42, blue: 0.16)
}

#Preview {
    TransactionDetailView(transactionId: UUID())
}
