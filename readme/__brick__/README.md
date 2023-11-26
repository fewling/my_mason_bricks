# {{title}}

## What is this?

{{description}}

## Development Log

### 1. Assets Generator

1. Installation
  Works with macOS, Linux and Windows.

    ```bash
    dart pub global activate flutter_gen
    ```

2. Add build_runner and FlutterGen to your package's pubspec.yaml file:

    ```bash
    dev_dependencies:
        build_runner:
        flutter_gen_runner:
    ```

3. Install FlutterGen
        `flutter pub get`

4. Use FlutterGen

      `dart run build_runner build`

5. Example usage

    ```dart
    Image.asset(Assets.images.logo.path);
    ```

### 2. Post-Commit Hook

Creating a post-commit hook script for Git that will generate a Dart file containing the commit hash for displaying in the app.

1. Navigate to the `.git/hooks` directory in this project.
  
      ```bash
      cd .git/hooks
      ```

2. Create a new file named `post-commit`.

    ```bash
    touch post-commit
    ```

3. Add the following script to the `post-commit` file:

    ```bash
    #!/bin/sh

    # Ensure file exists
    directory="./lib/utils"
    file_name="commit_hash.dart"
    file_path="${directory}/${file_name}"

    # Get the commit hash of the latest commit
    commit_hash=$(git rev-parse HEAD)
    echo "${commit_hash}"

    # Generate a Dart file with the commit hash
    echo "const commitHash = '$commit_hash';" > "${file_path}"
    ```

4. Make the `post-commit` hook executable:

    ```bash
    chmod +x .git/hooks/post-commit
    ```

5. Test if the script works, navigate to the root directory of this project:

    ```bash
    ./.git/hooks/post-commit
    ```

6. Test if the script works by making a commit:

    ```bash
    git commit -m "Test commit"
    ```

Now, every time you make a commit, the `commit_hash.dart` file will be generated (or updated if it already exists) with the latest commit hash.

The resulting Dart file (`commit_hash.dart`) will look something like this:

```dart
const commitHash = 'd1e5dada07c7c3f88c71e3518c1d077736c9d3c1';
```

### 3. Firebase Storage/Firestore CORS Configuration & Security Rules

Since student logs contains images/videos/files that allow unauthorized user to view, we need to restrict READ access to this app only, and allow only GET requests. While WRITE access is restricted to authenticated users only (meanwhile only @blueinnotechnology.com).

#### 3.1 CORS Configuration

This is to resolve error when trying to display images from Firebase Storage. Refers to this [guide](https://firebase.google.com/docs/storage/web/download-files#cors_configuration).

1. Create a file named `cors.json` with the following content:

    ```json
    [
      {
        "origin": ["school.blueinnotechnology.com"],
        "method": ["GET"],
        "maxAgeSeconds": 3600
      }
    ]
    ```

2. Run the following command to upload the configuration:
    The `gs` path can be found in Firebase Storage console.

    ```bash
    gsutil cors set cors.json gs://management-system-draft-d08b2.appspot.com/
    ```

#### 3.2 Security Rules (Storage)

This is to allow un-authenticated users to make GET request to Firebase Storage, and allow authenticated users to make CRUD requests to Firebase Storage.

  ```bash
  service firebase.storage {
    match /b/{bucket}/o {
      match /{allPaths=**} {
        allow read: if true
        allow read, write: if request.auth != null
      }
    }
  }
  ```

#### 3.3  Security Rules (Firestore)

This is to allow un-authenticated user to read collection `Portfolios`.

  ```bash
  service cloud.firestore {
    match /databases/{database}/documents {
    
      // Allow anyone to read documents in the 'portfolio' collection
      match /Portfolios/{document=**} {
        allow read: if true;
      }

      // This rule allows anyone with your Firestore database reference to view, edit,
      // and delete all data in your Firestore database. It is useful for getting
      // started, but it is configured to expire after 30 days because it
      // leaves your app open to attackers. At that time, all client
      // requests to your Firestore database will be denied.
      //
      // Make sure to write security rules for your app before that time, or else
      // all client requests to your Firestore database will be denied until you Update
      // your rules
      match /{document=**} {
        allow read, write: if request.auth != null
      }
    }
  }
  ```
