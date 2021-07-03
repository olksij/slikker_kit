# **Slikker Kit**
### Slikker Kit is a Flutter package which provides Slikker Design System components

<br>

![UI Preview](./res/Preview1.png)
##### The preview of the future version `1.1.0`.

<br>

___

<br>

## Usage

1. In your `pubspec.yaml` file add the following dependency:
```yaml
dependencies:
   ...
   slikker_kit: ^1.0.10
```
2. Run the command to update dependencies:
```shell
$ flutter pub get
```
3. Import `slikker_kit` to your dart file:
```dart
import 'package:slikker_kit/slikker_kit.dart';
```
4. Now you can use Slikker components! Example:

```dart
Widget button = SlikkerButton(
   padding: EdgeInsets.all(15),
   child: Text('Hello World!'),
   onTap: () => print('Yayyy'),
);
```

<br>



<br>

## License
MIT License

Copyright (c) 2020-2021 Alexey Besida

[Full licence](LICENSE.md)