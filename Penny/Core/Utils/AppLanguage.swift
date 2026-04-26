import Foundation

enum AppTextKey {
    case spending
    case friends
    case me
    case bank
    case chat
    case settings
    case accountSecurity
    case app
    case name
    case email
    case language
    case haptics
    case on
    case off
    case merchantLogos
    case notConfigured
    case logoConnected
    case editName
    case editEmail
    case firstName
    case lastName
    case cancel
    case save
    case appLanguage
    case notifications
    case alerts
    case spendingAlerts
    case spendingAlertsDescription
    case budgetProgress
    case budgetProgressDescription
    case weeklyDigest
    case weeklyDigestDescription
    case billReminders
    case billRemindersDescription
    case savingTips
    case savingTipsDescription
    case goodMorning
    case goodAfternoon
    case goodEvening
}

enum AppLanguage: String, CaseIterable, Identifiable {
    case english
    case spanish
    case french
    case japanese
    case hindi

    var id: String { rawValue }

    var title: String {
        switch self {
        case .english: return "English"
        case .spanish: return "Spanish"
        case .french: return "French"
        case .japanese: return "Japanese"
        case .hindi: return "Hindi"
        }
    }

    var nativeTitle: String {
        switch self {
        case .english: return "English"
        case .spanish: return "Español"
        case .french: return "Français"
        case .japanese: return "日本語"
        case .hindi: return "हिन्दी"
        }
    }

    var localeIdentifier: String {
        switch self {
        case .english: return "en_US"
        case .spanish: return "es_ES"
        case .french: return "fr_FR"
        case .japanese: return "ja_JP"
        case .hindi: return "hi_IN"
        }
    }

    func text(_ key: AppTextKey) -> String {
        switch self {
        case .english:
            switch key {
            case .spending: return "Spending"
            case .friends: return "Friends"
            case .me: return "Me"
            case .bank: return "Bank"
            case .chat: return "Chat"
            case .settings: return "Settings"
            case .accountSecurity: return "Account & Security"
            case .app: return "App"
            case .name: return "Name"
            case .email: return "Email"
            case .language: return "Language"
            case .haptics: return "Haptics"
            case .on: return "On"
            case .off: return "Off"
            case .merchantLogos: return "Merchant Logos"
            case .notConfigured: return "Not Configured"
            case .logoConnected: return "Logo.dev Connected"
            case .editName: return "Edit Name"
            case .editEmail: return "Edit Email"
            case .firstName: return "First Name"
            case .lastName: return "Last Name"
            case .cancel: return "Cancel"
            case .save: return "Save"
            case .appLanguage: return "App Language"
            case .notifications: return "Notifications"
            case .alerts: return "Alerts"
            case .spendingAlerts: return "Spending Alerts"
            case .spendingAlertsDescription: return "Instant updates on large purchases"
            case .budgetProgress: return "Budget Progress"
            case .budgetProgressDescription: return "Warn when you are close to your limit"
            case .weeklyDigest: return "Weekly Digest"
            case .weeklyDigestDescription: return "Summary of your habits every Sunday"
            case .billReminders: return "Bill Reminders"
            case .billRemindersDescription: return "Heads up before recurring charges hit"
            case .savingTips: return "Saving Tips"
            case .savingTipsDescription: return "Occasional ideas when spending trends shift"
            case .goodMorning: return "Good morning"
            case .goodAfternoon: return "Good afternoon"
            case .goodEvening: return "Good evening"
            }
        case .spanish:
            switch key {
            case .spending: return "Gastos"
            case .friends: return "Amigos"
            case .me: return "Yo"
            case .bank: return "Banco"
            case .chat: return "Chat"
            case .settings: return "Ajustes"
            case .accountSecurity: return "Cuenta y seguridad"
            case .app: return "Aplicación"
            case .name: return "Nombre"
            case .email: return "Correo"
            case .language: return "Idioma"
            case .haptics: return "Hápticos"
            case .on: return "Activado"
            case .off: return "Desactivado"
            case .merchantLogos: return "Logos de comercios"
            case .notConfigured: return "Sin configurar"
            case .logoConnected: return "Logo.dev conectado"
            case .editName: return "Editar nombre"
            case .editEmail: return "Editar correo"
            case .firstName: return "Nombre"
            case .lastName: return "Apellido"
            case .cancel: return "Cancelar"
            case .save: return "Guardar"
            case .appLanguage: return "Idioma de la app"
            case .notifications: return "Notificaciones"
            case .alerts: return "Alertas"
            case .spendingAlerts: return "Alertas de gasto"
            case .spendingAlertsDescription: return "Avisos instantáneos sobre compras grandes"
            case .budgetProgress: return "Progreso del presupuesto"
            case .budgetProgressDescription: return "Avisa cuando estés cerca del límite"
            case .weeklyDigest: return "Resumen semanal"
            case .weeklyDigestDescription: return "Resumen de tus hábitos cada domingo"
            case .billReminders: return "Recordatorios de facturas"
            case .billRemindersDescription: return "Avisos antes de cargos recurrentes"
            case .savingTips: return "Consejos de ahorro"
            case .savingTipsDescription: return "Ideas ocasionales cuando cambian tus gastos"
            case .goodMorning: return "Buenos días"
            case .goodAfternoon: return "Buenas tardes"
            case .goodEvening: return "Buenas noches"
            }
        case .french:
            switch key {
            case .spending: return "Dépenses"
            case .friends: return "Amis"
            case .me: return "Moi"
            case .bank: return "Banque"
            case .chat: return "Chat"
            case .settings: return "Réglages"
            case .accountSecurity: return "Compte et sécurité"
            case .app: return "Application"
            case .name: return "Nom"
            case .email: return "E-mail"
            case .language: return "Langue"
            case .haptics: return "Retour haptique"
            case .on: return "Activé"
            case .off: return "Désactivé"
            case .merchantLogos: return "Logos marchands"
            case .notConfigured: return "Non configuré"
            case .logoConnected: return "Logo.dev connecté"
            case .editName: return "Modifier le nom"
            case .editEmail: return "Modifier l’e-mail"
            case .firstName: return "Prénom"
            case .lastName: return "Nom"
            case .cancel: return "Annuler"
            case .save: return "Enregistrer"
            case .appLanguage: return "Langue de l’app"
            case .notifications: return "Notifications"
            case .alerts: return "Alertes"
            case .spendingAlerts: return "Alertes de dépenses"
            case .spendingAlertsDescription: return "Alertes instantanées pour les achats importants"
            case .budgetProgress: return "Suivi du budget"
            case .budgetProgressDescription: return "Avertit lorsque vous approchez de la limite"
            case .weeklyDigest: return "Résumé hebdomadaire"
            case .weeklyDigestDescription: return "Résumé de vos habitudes chaque dimanche"
            case .billReminders: return "Rappels de factures"
            case .billRemindersDescription: return "Avertit avant les paiements récurrents"
            case .savingTips: return "Conseils d’épargne"
            case .savingTipsDescription: return "Idées occasionnelles quand vos dépenses évoluent"
            case .goodMorning: return "Bonjour"
            case .goodAfternoon: return "Bon après-midi"
            case .goodEvening: return "Bonsoir"
            }
        case .japanese:
            switch key {
            case .spending: return "支出"
            case .friends: return "友達"
            case .me: return "自分"
            case .bank: return "銀行"
            case .chat: return "チャット"
            case .settings: return "設定"
            case .accountSecurity: return "アカウントとセキュリティ"
            case .app: return "アプリ"
            case .name: return "名前"
            case .email: return "メール"
            case .language: return "言語"
            case .haptics: return "触覚"
            case .on: return "オン"
            case .off: return "オフ"
            case .merchantLogos: return "加盟店ロゴ"
            case .notConfigured: return "未設定"
            case .logoConnected: return "Logo.dev 接続済み"
            case .editName: return "名前を編集"
            case .editEmail: return "メールを編集"
            case .firstName: return "名"
            case .lastName: return "姓"
            case .cancel: return "キャンセル"
            case .save: return "保存"
            case .appLanguage: return "アプリの言語"
            case .notifications: return "通知"
            case .alerts: return "アラート"
            case .spendingAlerts: return "支出アラート"
            case .spendingAlertsDescription: return "高額な購入をすぐに通知"
            case .budgetProgress: return "予算の進捗"
            case .budgetProgressDescription: return "上限に近づくと通知"
            case .weeklyDigest: return "週間まとめ"
            case .weeklyDigestDescription: return "毎週日曜に習慣を要約"
            case .billReminders: return "請求リマインダー"
            case .billRemindersDescription: return "定期請求の前にお知らせ"
            case .savingTips: return "節約のヒント"
            case .savingTipsDescription: return "支出傾向が変わったときの提案"
            case .goodMorning: return "おはよう"
            case .goodAfternoon: return "こんにちは"
            case .goodEvening: return "こんばんは"
            }
        case .hindi:
            switch key {
            case .spending: return "खर्च"
            case .friends: return "दोस्त"
            case .me: return "मैं"
            case .bank: return "बैंक"
            case .chat: return "चैट"
            case .settings: return "सेटिंग्स"
            case .accountSecurity: return "अकाउंट और सुरक्षा"
            case .app: return "ऐप"
            case .name: return "नाम"
            case .email: return "ईमेल"
            case .language: return "भाषा"
            case .haptics: return "हैप्टिक्स"
            case .on: return "चालू"
            case .off: return "बंद"
            case .merchantLogos: return "मर्चेंट लोगो"
            case .notConfigured: return "कॉन्फ़िगर नहीं"
            case .logoConnected: return "Logo.dev जुड़ा है"
            case .editName: return "नाम बदलें"
            case .editEmail: return "ईमेल बदलें"
            case .firstName: return "पहला नाम"
            case .lastName: return "अंतिम नाम"
            case .cancel: return "रद्द करें"
            case .save: return "सेव करें"
            case .appLanguage: return "ऐप भाषा"
            case .notifications: return "नोटिफिकेशन"
            case .alerts: return "अलर्ट"
            case .spendingAlerts: return "खर्च अलर्ट"
            case .spendingAlertsDescription: return "बड़ी खरीद पर तुरंत अपडेट"
            case .budgetProgress: return "बजट प्रगति"
            case .budgetProgressDescription: return "सीमा के पास पहुँचने पर चेतावनी"
            case .weeklyDigest: return "साप्ताहिक सारांश"
            case .weeklyDigestDescription: return "हर रविवार आपकी आदतों का सार"
            case .billReminders: return "बिल रिमाइंडर"
            case .billRemindersDescription: return "आवर्ती शुल्क से पहले सूचना"
            case .savingTips: return "बचत सुझाव"
            case .savingTipsDescription: return "खर्च बदलने पर कभी-कभी सुझाव"
            case .goodMorning: return "सुप्रभात"
            case .goodAfternoon: return "नमस्ते"
            case .goodEvening: return "शुभ संध्या"
            }
        }
    }
}
