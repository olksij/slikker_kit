<p align="center">
   <span style="font-family: 'monospace'; font-size: 2em;"><b><i>Slikker Kit</i></b></span>
   <br>
   <span style="font-family: 'monospace'; font-size: 1.25em; opacity: 0.7;"><b><i>Slikker Kit is a Flutter package which provides Slikker Design System components</i></b></span>
   <br>
</p>

## **Installation**

of your flutter project, add the following dependency
1. In your `pubspec.yaml` add the following dependency:
```
dependencies:
   ...
   slikker_ripple: 
      git:
         url: git://github.com/AlexBesida/slikker_kit.git
```
2. Run command to update the dependencies:
```
$ flutter pub get
```
#### // *Soon the way will be simplified*

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