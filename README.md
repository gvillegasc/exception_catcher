# exception_catcher

A new Flutter package project to send smtp mails when exceptions are thrown.

## Instalation

Add the package on pubspec.yaml file of the project

```yaml
chat_widget:
  git:
    url: git://github.com/gvillegasc/exception_catcher
    ref: master
```

Next get the flutter package with

```sh
flutter pub get
```

## Using

In the principal file, replace the `main` method

```dart
void main() {
    runApp(MyApp())
};
```

for

```dart
void main() {
    WidgetsFlutterBinding.ensureInitialized();
    ExceptionCatcher(
        rootWidget: MyApp(),
        subject: 'Hello',
        username: 'username@email.com',
        password: 'password',
        recipient: 'recipient@email.com',
        ccRecipients: ['recipient2@email.com']);
}
```

If you want send mails in debug mode add the attribute `sendInDebug` in `true` (by default is `false`)

## License

This package is licensed under the MIT License - see the [LICENSE.md](https://github.com/gvillegasc/exception_catcher/blob/master/LICENSE) file for details
