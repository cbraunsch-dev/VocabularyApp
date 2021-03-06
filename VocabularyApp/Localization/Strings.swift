// swiftlint:disable all
// Generated using SwiftGen, by O.Halligon — https://github.com/SwiftGen/SwiftGen

import Foundation

// swiftlint:disable superfluous_disable_command
// swiftlint:disable file_length

// MARK: - Strings

// swiftlint:disable explicit_type_interface function_parameter_count identifier_name line_length
// swiftlint:disable nesting type_body_length type_name
internal enum L10n {

  internal enum Action {
    /// Cancel
    internal static let cancel = L10n.tr("Localizable", "action.cancel")
    /// Learn
    internal static let learn = L10n.tr("Localizable", "action.learn")
    /// Ok
    internal static let ok = L10n.tr("Localizable", "action.ok")
    /// Practice
    internal static let practice = L10n.tr("Localizable", "action.practice")
    /// Train
    internal static let train = L10n.tr("Localizable", "action.train")
    internal enum AddSet {
      /// Press the + button to add a new vocabulary set.
      internal static let hint = L10n.tr("Localizable", "action.addSet.hint")
      /// Set name
      internal static let name = L10n.tr("Localizable", "action.addSet.name")
    }
    internal enum AddVocabulary {
      /// Press the + button to add vocabulary to your set.
      internal static let hint = L10n.tr("Localizable", "action.addVocabulary.hint")
    }
    internal enum ImportVocabulary {
      /// Import from CSV file
      internal static let csv = L10n.tr("Localizable", "action.importVocabulary.csv")
    }
  }

  internal enum Alert {
    internal enum AddSet {
      /// Enter a name for the set.
      internal static let message = L10n.tr("Localizable", "alert.addSet.message")
      internal enum TextField {
        /// Set name
        internal static let placeholder = L10n.tr("Localizable", "alert.addSet.textField.placeholder")
      }
    }
  }

  internal enum Error {
    /// Error
    internal static let error = L10n.tr("Localizable", "error.error")
    /// An error occurred
    internal static let generic = L10n.tr("Localizable", "error.generic")
    /// The set could not be found
    internal static let setNotFound = L10n.tr("Localizable", "error.setNotFound")
    internal enum CsvImportVocabularyError {
      /// An error occurred while importing the vocabulary from a CSV file. The CSV file contains a row with incorrect number of columns. Make sure not to use commas in your vocabulary list since commas are used to separate the different columns.
      internal static let incorrectNumberOfColumns = L10n.tr("Localizable", "error.csvImportVocabularyError.incorrectNumberOfColumns")
      /// No CSV data could be found. Make sure your file is in the CSV file format.
      internal static let noData = L10n.tr("Localizable", "error.csvImportVocabularyError.noData")
    }
    internal enum DataAccess {
      /// Failed to access local database
      internal static let failedToAccessDb = L10n.tr("Localizable", "error.dataAccess.failedToAccessDb")
      /// The item to delete was not found
      internal static let itemToDeleteNotFound = L10n.tr("Localizable", "error.dataAccess.itemToDeleteNotFound")
      /// Out of disk space
      internal static let outOfDiskSpace = L10n.tr("Localizable", "error.dataAccess.outOfDiskSpace")
    }
  }

  internal enum Title {
    /// Add Set
    internal static let addSet = L10n.tr("Localizable", "title.addSet")
    /// Add Vocabulary
    internal static let addVocabulary = L10n.tr("Localizable", "title.addVocabulary")
    /// Your Sets
    internal static let sets = L10n.tr("Localizable", "title.sets")
  }

  internal enum ViewController {
    internal enum AddSet {
      /// Tap on the item below to set or change the name of the set.
      internal static let hint = L10n.tr("Localizable", "viewController.addSet.hint")
    }
    internal enum PracticeSet {
      /// Welcome to the practice mode. Swipe up to learn more.
      internal static let hint1 = L10n.tr("Localizable", "viewController.practiceSet.hint1")
      /// Swipe left to see the first word and swipe up to reveal that word's definition.
      internal static let hint2 = L10n.tr("Localizable", "viewController.practiceSet.hint2")
    }
  }
}
// swiftlint:enable explicit_type_interface function_parameter_count identifier_name line_length
// swiftlint:enable nesting type_body_length type_name

// MARK: - Implementation Details

extension L10n {
  private static func tr(_ table: String, _ key: String, _ args: CVarArg...) -> String {
    let format = NSLocalizedString(key, tableName: table, bundle: Bundle(for: BundleToken.self), comment: "")
    return String(format: format, locale: Locale.current, arguments: args)
  }
}

private final class BundleToken {}
