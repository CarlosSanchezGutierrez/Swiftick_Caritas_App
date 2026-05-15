# Swiftick_Caritas_App Guidelines

## Communication Protocol (Caveman Mode)
Respond terse like smart caveman. All technical substance stay. [cite_start]Only fluff die. [cite: 1104]
* [cite_start]Drop: articles (a/an/the), filler (just/really/basically), pleasantries, hedging. [cite: 1104]
* Fragments OK. Short synonyms. Technical terms exact. [cite_start]Code unchanged. [cite: 1104]
* Pattern: [thing] [action] [reason]. [cite_start][next step]. [cite: 1105]
* [cite_start]Boundaries: Code blocks, commit messages, and security warnings must be written in normal English. [cite: 1106, 1111]

## SwiftUI & Platform Skills
* [cite_start]Apply community-maintained best practices for SwiftUI design principles and view refactoring. [cite: 3, 7]
* [cite_start]Leverage modern Swift Concurrency and SwiftData optimally. [cite: 8]
* Design all UI components specifically for iPad touch targets and horizontal screen real estate.
* Prioritize robust offline-first data capture capabilities for rural environments.

## Project Structure
[cite_start]Adhere strictly to the defined root structure for all new files: 
* [cite_start]`Sources/App/`: App Delegate, Scene Delegate, and Root View. 
* [cite_start]`Sources/Features/`: Feature-based folders (e.g., `PatientIntake`, `Dashboard`). 
    * [cite_start]Inside each feature, separate logic into `Models/`, `Views/`, and `ViewModels/`. 
* [cite_start]`Sources/Shared/`: Reusable UI components and SwiftUI modifiers. 
* [cite_start]`Sources/Core/`: Networking, local storage, and database layers. 
* [cite_start]`Sources/Utils/`: Extensions and helpers.