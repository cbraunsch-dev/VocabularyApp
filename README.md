# Vocabulary App

This project lays the foundation for a simple vocabulary app. You can use the app to do the following:

1. Create multiple vocabulary sets
2. Import a vocabulary list from a CSV file
3. Practice your vocabulary just like you would if you had index cards

![Screenshot](https://github.com/cbraunsch-dev/VocabularyApp/blob/master/VocabularyAppTests/SnapshotTests/en/ReferenceImages_64/VocabularyAppTests.AddSetViewControllerSnapshotTests/testViewDidLoad_when_nameSpecified_iPhone_320x568%402x.png "Screenshot")

![Screenshot](https://github.com/cbraunsch-dev/VocabularyApp/blob/master/VocabularyAppTests/SnapshotTests/en/ReferenceImages_64/VocabularyAppTests.AddVocabularyViewControllerSnapshotTests/testImportFromFile_then_displayImportedVocabularyPairs_iPhone_320x568%402x.png "Screenshot")

![Screenshot](https://github.com/cbraunsch-dev/VocabularyApp/blob/master/VocabularyAppTests/SnapshotTests/en/ReferenceImages_64/VocabularyAppTests.PracticeSetViewControllerSnapshotTests/testShowValue_then_showDefinitionOfCurrentVocabularyPair_iPhone_320x568%402x.png "Screenshot")

## Software Architecture

The app uses a functional-reactive approach and the model-view-view model pattern to achieve a high level of statelessness and a high degree of testability. More about this approach can be [found here](https://github.com/cbraunsch-dev/TaskManagerApp).