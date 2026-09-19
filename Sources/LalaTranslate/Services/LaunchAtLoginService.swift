import ServiceManagement
import SwiftUI
@MainActor
final class LaunchAtLoginService: ObservableObject {
    @Published var enabled = false
    @Published var message: String?
    init() { refresh() }
    func refresh() {
        enabled = SMAppService.mainApp.status == .enabled
        if SMAppService.mainApp.status == .requiresApproval { message = "请在系统设置 → 通用 → 登录项中允许 Lala Translate。" }
    }
    func setEnabled(_ value: Bool) {
        do {
            if value { try SMAppService.mainApp.register() } else { try SMAppService.mainApp.unregister() }
            message = nil; refresh()
        } catch {
            refresh(); message = "无法修改登录启动设置。请将应用放入 Applications 后，在系统设置中检查登录项。"
        }
    }
}
