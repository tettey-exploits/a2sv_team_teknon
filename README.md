# FarmNETS - AI for Impact
Welcome to the FarmNETS GitHub repository. FarmNETS is an LLM-powered mobile application that caters for both smallholder farmers and extension officers, promoting access to critical information and digital tools by facilitating communication and interaction in the user’s preferred language through the voice interface. This repository contains the source code, development history, and supporting materials for the FarmNETS mobile application.

## Structure
This repository is structured as follows:
* `Mobile application/`:
    - `android/`: Contains the Android-specific configuration and code.
    - `assets/` : Includes assets such as images, fonts, and other resources.
    - `ios/`: Contains the iOS-specific configuration and code.
    - `lib/`: The main directory for the Dart codebase, structured as follows:
        - auth: Handles authentication-related code.
        - chat_feature: Contains code related to the chat functionality.
        - constants: Stores constant values used throughout the app.
        - database: Manages database interactions and related operations.
        - l10n: Manages localization files.
        - models: Contains data models used in the app.
        - providers: Includes provider classes for state management.
        - screens: Contains the UI screens of the app.
        - services: Holds service classes for various functionalities such as - network calls, etc.
        - themes: Manages the app's theme and styling.
        - widgets: Contains reusable UI components.
* `Colab Notebooks/`:
    - This section describes the Colab notebooks included in the project.

## Purpose
The purpose of this repository is to provide a collaborative space for development and improvement of the FarmNETS mobile application. By making the repository publicly accessible, we aim to foster community engagement, allowing developers, contributors, and users to explore the codebase, report issues, and suggest enhancements.

## How to install the FarmNETS app
This guide will walk you through the installation process for the FarmNETS Flutter mobile application.

### Prerequisites
**Tested on Android only.** <br>
Before you begin, make sure you have the following installed on your development machine:

- [Flutter SDK](https://flutter.dev/docs/get-started/install)
- [Android Studio](https://developer.android.com/studio) (for Android development)

### API keys
- Kindly request for the `.env` file by sending an email to ``` oh.shalom.0@gmail.com ```

### Building from source
Follow these steps to build and install the FarmNETS app on your device:
1. **Clone the Repository:**
   ```
   git clone https://github.com/tettey-exploits/team_farmnets.git
   ```

2. **Move to the cloned repo's directory and switch to the main branch**
   ```
    cd team_farmnets
    ```
    ```
    git switch main
    ```

3. **Get Dependencies:**
   ```
   flutter pub get
   ```

4. **Run the App:**
   - Connect your Android/iOS device to your computer.
   - Ensure USB debugging is enabled on your Android device.
   - Run the following command:
     ```
     flutter gen-l10n
     ```
     ```
     flutter run
     ```
   This will build the app and install it on your connected device.

5. **Alternatively, Use an Emulator:**
   - Open Android Studio and launch the Android Virtual Device (AVD) Manager.
   - Create a new virtual device and start the emulator.
   - Once the emulator is running, repeat step 4.

### How to use the Voice-Enabled OTP Sign-In (Testing Purposes)
1. Akwaaba.  Me din de Kwame, mesrɛ wo ka wo telefon nɔma kyerɛ me. [Twi] => <br>Welcome. My name is Kwame, please mention your phone number. [English]
   - Use any of these numbers: <br>
      * +233 23 456 7890
      * +233 53 523 7471

2. Mesrɛ wo, so eyi ne wo telefon nɔma? [Twi] => <br> Please is this your phone number?[English]
   - Respond "Aannie" to confirm the phone number or...
   - "Daabi" to re-mention your number.

3. Mesrɛ wo, wo din de sɛn? [Twi] => <br> Please what is your name?[English]
    - Mention your name.

4. Mepa wo kyɛw, ka bio [Twi] => <br> Mention your number again [English]
   - Start from step (1)

5. For the number you used, enter the corresponding OTP <br>
   * +233 23 456 7890   .... 654321 (OTP)
   * +233 53 523 7471   .... 123456 (OTP)

## Known Issues
- **Audio Message Saving and Reading on Android with SD Cards**: 
Currently, our app may encounter difficulties saving and reading audio messages on Android devices that have an SD card inserted.
We are actively working on a solution. We apologize for any inconvenience this may cause.