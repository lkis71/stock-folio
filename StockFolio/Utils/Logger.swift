import Foundation

/// 보안을 고려한 로깅 유틸리티
/// 프로덕션 빌드에서는 로그를 출력하지 않음
enum Logger {

    /// 에러 로그 (DEBUG 빌드에서만 출력)
    static func error(_ message: String, file: String = #file, line: Int = #line) {
        #if DEBUG
        let fileName = (file as NSString).lastPathComponent
        print("❌ [\(fileName):\(line)] \(message)")
        #endif
    }

    /// 경고 로그 (DEBUG 빌드에서만 출력)
    static func warning(_ message: String, file: String = #file, line: Int = #line) {
        #if DEBUG
        let fileName = (file as NSString).lastPathComponent
        print("⚠️ [\(fileName):\(line)] \(message)")
        #endif
    }

    /// 정보 로그 (DEBUG 빌드에서만 출력)
    static func info(_ message: String, file: String = #file, line: Int = #line) {
        #if DEBUG
        let fileName = (file as NSString).lastPathComponent
        print("ℹ️ [\(fileName):\(line)] \(message)")
        #endif
    }

    /// 디버그 로그 (DEBUG 빌드에서만 출력)
    static func debug(_ message: String, file: String = #file, line: Int = #line) {
        #if DEBUG
        let fileName = (file as NSString).lastPathComponent
        print("🔍 [\(fileName):\(line)] \(message)")
        #endif
    }
}
