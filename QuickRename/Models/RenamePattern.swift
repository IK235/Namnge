import Foundation

enum AIProvider: String, CaseIterable {
    case local      // Apple Vision (only option)
}

enum RenamePattern: String, CaseIterable, Identifiable {
    case findReplace = "Find & Replace"
    case sequential = "Sequential Numbers"
    case prefix = "Add Prefix"
    case suffix = "Add Suffix"
    case removeText = "Remove Text"
    case changeCase = "Change Case"
    case dateStamp = "Add Date"
    case regex = "Regex Pattern"
    case aiSmart = "AI Smart Rename"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .findReplace: return "rectangle.and.pencil.and.ellipsis"
        case .sequential: return "123.rectangle"
        case .prefix: return "arrow.left.to.line"
        case .suffix: return "arrow.right.to.line"
        case .removeText: return "minus.circle"
        case .changeCase: return "textformat"
        case .dateStamp: return "calendar.badge.clock"
        case .regex: return "asterisk.circle"
        case .aiSmart: return "sparkles"
        }
    }

    var description: String {
        switch self {
        case .findReplace: return "Replace text in filenames"
        case .sequential: return "Add sequential numbers (1, 2, 3...)"
        case .prefix: return "Add text to the beginning"
        case .suffix: return "Add text to the end"
        case .removeText: return "Remove specific text"
        case .changeCase: return "Uppercase, lowercase, or title case"
        case .dateStamp: return "Add current date/time"
        case .regex: return "Advanced pattern matching"
        case .aiSmart: return "AI generates smart, descriptive names"
        }
    }
}

enum CaseStyle: String, CaseIterable {
    case lowercase = "lowercase"
    case uppercase = "UPPERCASE"
    case titleCase = "Title Case"
    case camelCase = "camelCase"
    case snakeCase = "snake_case"
}

struct RenameOperation {
    var pattern: RenamePattern
    var findText: String = ""
    var replaceText: String = ""
    var prefixText: String = ""
    var suffixText: String = ""
    var removeText: String = ""
    var caseStyle: CaseStyle = .lowercase
    var sequentialStart: Int = 1
    var sequentialPadding: Int = 2
    var dateFormat: String = "yyyy-MM-dd"
    var regexPattern: String = ""
    var regexReplacement: String = ""

    // AI Settings
    var aiPrompt: String = ""
    var aiProvider: AIProvider = .local

    func apply(to filename: String) -> String {
        let components = filename.split(separator: ".", omittingEmptySubsequences: false)
        guard components.count >= 1 else { return filename }

        let ext = components.count > 1 ? ".\(components.last!)" : ""
        let nameWithoutExt = components.dropLast(components.count > 1 ? 1 : 0).joined(separator: ".")

        var result = nameWithoutExt

        switch pattern {
        case .findReplace:
            if !findText.isEmpty {
                result = result.replacingOccurrences(of: findText, with: replaceText)
            }

        case .sequential:
            // Sequential numbers will be applied separately with index
            break

        case .prefix:
            if !prefixText.isEmpty {
                result = prefixText + result
            }

        case .suffix:
            if !suffixText.isEmpty {
                result = result + suffixText
            }

        case .removeText:
            if !removeText.isEmpty {
                result = result.replacingOccurrences(of: removeText, with: "")
            }

        case .changeCase:
            result = applyCase(to: result, style: caseStyle)

        case .dateStamp:
            let formatter = DateFormatter()
            formatter.dateFormat = dateFormat
            let dateString = formatter.string(from: Date())
            result = result + "_" + dateString

        case .regex:
            if !regexPattern.isEmpty {
                do {
                    let regex = try NSRegularExpression(pattern: regexPattern)
                    let range = NSRange(result.startIndex..., in: result)
                    result = regex.stringByReplacingMatches(
                        in: result,
                        range: range,
                        withTemplate: regexReplacement
                    )
                } catch {
                    // Invalid regex - return original
                }
            }

        case .aiSmart:
            // AI renaming handled by main app, not extension
            break
        }

        return result + ext
    }

    func applySequential(to filename: String, index: Int) -> String {
        let result = apply(to: filename)
        let components = result.split(separator: ".", omittingEmptySubsequences: false)
        let ext = components.count > 1 ? ".\(components.last!)" : ""
        let nameWithoutExt = components.dropLast(components.count > 1 ? 1 : 0).joined(separator: ".")

        let number = sequentialStart + index
        let paddedNumber = String(format: "%0*d", sequentialPadding, number)

        return nameWithoutExt + "_" + paddedNumber + ext
    }

    private func applyCase(to text: String, style: CaseStyle) -> String {
        switch style {
        case .lowercase:
            return text.lowercased()
        case .uppercase:
            return text.uppercased()
        case .titleCase:
            return text.capitalized
        case .camelCase:
            let words = text.components(separatedBy: CharacterSet.alphanumerics.inverted)
            return words.enumerated().map { index, word in
                index == 0 ? word.lowercased() : word.capitalized
            }.joined()
        case .snakeCase:
            return text.lowercased().replacingOccurrences(of: " ", with: "_")
        }
    }
}
