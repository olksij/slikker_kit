# ***Slikker Kit***
### Slikker Kit is a Flutter package which provides Slikker Design System components

<br>

## **Installation**

1. In your `pubspec.yaml` add the following dependency:
```
dependencies:
   ...
   slikker_kit: ^1.0.2
```
2. Run command to update the dependencies:
```
$ flutter pub get
```

<br>

## Usage

1. Import `slikker_kit` to your library:
```
import 'package:slikker_kit/slikker_kit.dart';
```
2. Now you can use Slikker components! Example:

```
Widget button = SlikkerCard(
   padding: EdgeInsets.all(15),
   accent: 240,
   borderRadius: BorderRadius.circular(12),
   child: Text('Hello World!'),
   onTap: () => print('Yayyy'),
)
```
#### // *Component list coming soon*

<br>

## License
MIT License

Copyright (c) 2020 Alexey Besida

[Full licence](LICENSE)