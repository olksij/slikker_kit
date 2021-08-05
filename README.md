# **Slikker Kit**
### Slikker Kit is a Flutter package which provides Slikker Design System components

<br>

![UI Preview](./res/Preview.png)
#### The preview of the future version `1.1.0`.
#### [Alpha development changelog](1.1.0-alpha-CHANGELOG.md)

<br>

___

<br>

### Table of contents.
1. [Installing package](#installing-package)
2. [Running example](#running-example)
3. [License](#license)

<br>

___

<br>

## Installing package

1. Run the command to add dependency and update dependencies:
```shell
$ flutter pub add slikker_kit
```
This will add a line like this to your package's pubspec.yaml (and run an implicit `dart pub get`): 
```yaml
dependencies:
   slikker_kit: ^1.1.0-alpha.22
```

2. Import `slikker_kit` to your dart file:
```dart
import 'package:slikker_kit/slikker_kit.dart';
```
3. Now you can use Slikker components! Example:

```dart
Widget button = SlikkerButton(
   padding: EdgeInsets.all(15),
   child: Text('Hello World!'),
   onTap: () => print('Yayyy'),
);
```

<br>

___


<br>

## Running example

1. Clone the repository.
```shell
$ git clone https://github.com/AlexBesida/slikker_kit.git
```

2. Move to the example directory
```shell
$ cd slikker_kit/example
```

3. Run `flutter pub get`, and then run the app!
```shell
$ flutter run
```

<br>

___

<br>

## License
MIT License

Copyright (c) 2020-2021 Alexey Besida

[Full licence](LICENSE.md)