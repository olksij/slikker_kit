# **Slikker Kit**
Slikker Kit is a Flutter package which provides Slikker Design System components.

<br>

![UI Preview](./res/Preview.png)
#### The preview of the planned first research batch release, planned in 2022 Q2.

<br>

## ⚠️ Implementation is not stable yet!
For accessing working code, navigate into **dev branch**
> [`dev` branch changelog](1.1.0-alpha-CHANGELOG.md)


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

### 1. Run the command to add dependency and update dependencies:
```shell
$ flutter pub add slikker_kit
```
This will add a line like this to your package's pubspec.yaml (and run an implicit `dart pub get`): 
```yaml
dependencies:
   slikker_kit: any
```

### 2. Import `slikker_kit` to your dart file:
```dart
import 'package:slikker_kit/slikker_kit.dart';
```
### 3. Now you can use Slikker components! Example:

```dart
Widget button = SlikkerButton(
   padding: EdgeInsets.all(15),
   child: Text('Hello World!'),
);
```

<br>

___


<br>

## Running example

1. Clone the repository.
```shell
$ git clone --branch dev https://github.com/AlexBesida/slikker_kit.git
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

Copyright (c) 2020-2022 Alexey Besida

[Full licence](LICENSE.md)