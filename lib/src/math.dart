// TODO: Doc
import 'dart:math';

/// This function takes a doubleber as input and returns the square of that doubleber.
double square(double x) => x * x;

/// This function finds the length of the third side of a triangle.
/// Pythagorean theorem is used to make the calculation.
double calculateSide(double side1, double side2, bool isHypotenuse) =>
    sqrt(square(side1) + square(side2) * (isHypotenuse ? -1 : 1));

/// A three-dimensional geometric vector.
class Vector {
  /// Represents a point to which the vector is heading in three-dimensional space.
  final double x, y, z;

  /// Constructs a new Vector.
  ///
  /// The [x], [y], and [z] fields specify the vector's coordinates.
  Vector(this.x, this.y, this.z);

  /// Returns a new Vector where the [x] and [y] components are [x] and [y], respectively,
  /// and the [z] component is computed such that the vector's length is [length].
  factory Vector.z(double x, double y, double length) {
    final projected = sqrt(square(x) + square(y));
    final z = sqrt(square(length) - square(projected));
    return Vector(x, y, z);
  }
}
