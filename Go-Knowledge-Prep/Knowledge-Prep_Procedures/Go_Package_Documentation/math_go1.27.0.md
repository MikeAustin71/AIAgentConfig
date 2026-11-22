## Table of Contents
- [math package - math](#math-package---math)
	- [Constants](#constants)
	- [Functions](#functions)
		- [func Abs](#func-abs)
				- [Example](#example)
		- [func Acos](#func-acos)
				- [Example](#example-1)
		- [func Acosh](#func-acosh)
				- [Example](#example-2)
		- [func Asin](#func-asin)
				- [Example](#example-3)
		- [func Asinh](#func-asinh)
				- [Example](#example-4)
		- [func Atan](#func-atan)
				- [Example](#example-5)
		- [func Atan2](#func-atan2)
				- [Example](#example-6)
		- [func Atanh](#func-atanh)
				- [Example](#example-7)
		- [func Cbrt](#func-cbrt)
				- [Example](#example-8)
		- [func Ceil](#func-ceil)
				- [Example](#example-9)
		- [func Copysign](#func-copysign)
				- [Example](#example-10)
		- [func Cos](#func-cos)
				- [Example](#example-11)
		- [func Cosh](#func-cosh)
				- [Example](#example-12)
		- [func Dim](#func-dim)
				- [Example](#example-13)
		- [func Erf](#func-erf)
		- [func Erfc](#func-erfc)
		- [func Erfcinv](#func-erfcinv)
		- [func Erfinv](#func-erfinv)
		- [func Exp](#func-exp)
				- [Example](#example-14)
		- [func Exp2](#func-exp2)
				- [Example](#example-15)
		- [func Expm1](#func-expm1)
				- [Example](#example-16)
		- [func FMA](#func-fma)
		- [func Float32bits](#func-float32bits)
		- [func Float32frombits](#func-float32frombits)
		- [func Float64bits](#func-float64bits)
		- [func Float64frombits](#func-float64frombits)
		- [func Floor](#func-floor)
				- [Example](#example-17)
		- [func Frexp](#func-frexp)
		- [func Gamma](#func-gamma)
		- [func Hypot](#func-hypot)
		- [func Ilogb](#func-ilogb)
		- [func Inf](#func-inf)
		- [func IsInf](#func-isinf)
		- [func IsNaN](#func-isnan)
		- [func J0](#func-j0)
		- [func J1](#func-j1)
		- [func Jn](#func-jn)
		- [func Ldexp](#func-ldexp)
		- [func Lgamma](#func-lgamma)
		- [func Log](#func-log)
				- [Example](#example-18)
		- [func Log10](#func-log10)
				- [Example](#example-19)
		- [func Log1p](#func-log1p)
		- [func Log2](#func-log2)
				- [Example](#example-20)
		- [func Logb](#func-logb)
		- [func Max](#func-max)
		- [func Min](#func-min)
		- [func Mod](#func-mod)
				- [Example](#example-21)
		- [func Modf](#func-modf)
				- [Example](#example-22)
		- [func NaN](#func-nan)
		- [func Nextafter](#func-nextafter)
		- [func Nextafter32](#func-nextafter32)
		- [func Pow](#func-pow)
				- [Example](#example-23)
		- [func Pow10](#func-pow10)
				- [Example](#example-24)
		- [func Remainder](#func-remainder)
				- [Example](#example-25)
		- [func Round](#func-round)
				- [Example](#example-26)
		- [func RoundToEven](#func-roundtoeven)
				- [Example](#example-27)
		- [func Signbit](#func-signbit)
		- [func Sin](#func-sin)
				- [Example](#example-28)
		- [func Sincos](#func-sincos)
				- [Example](#example-29)
		- [func Sinh](#func-sinh)
				- [Example](#example-30)
		- [func Sqrt](#func-sqrt)
				- [Example](#example-31)
		- [func Tan](#func-tan)
				- [Example](#example-32)
		- [func Tanh](#func-tanh)
				- [Example](#example-33)
		- [func Trunc](#func-trunc)
				- [Example](#example-34)
		- [func Y0](#func-y0)
		- [func Y1](#func-y1)
		- [func Yn](#func-yn)


# math package - math

Package math provides basic constants and mathematical functions.

This package does not guarantee bit-identical results across architectures.

## Constants

<a id="E"></a><a id="Pi"></a><a id="Phi"></a><a id="Sqrt2"></a><a id="SqrtE"></a><a id="SqrtPi"></a><a id="SqrtPhi"></a><a id="Ln2"></a><a id="Log2E"></a><a id="Ln10"></a><a id="Log10E"></a>
```go
const (
	E   = 2.71828182845904523536028747135266249775724709369995957496696763 // https://oeis.org/A001113
	Pi  = 3.14159265358979323846264338327950288419716939937510582097494459 // https://oeis.org/A000796
	Phi = 1.61803398874989484820458683436563811772030917980576286213544862 // https://oeis.org/A001622

	Sqrt2   = 1.41421356237309504880168872420969807856967187537694807317667974 // https://oeis.org/A002193
	SqrtE   = 1.64872127070012814684865078781416357165377610071014801157507931 // https://oeis.org/A019774
	SqrtPi  = 1.77245385090551602729816748334114518279754945612238712821380779 // https://oeis.org/A002161
	SqrtPhi = 1.27201964951406896425242246173749149171560804184009624861664038 // https://oeis.org/A139339

	Ln2    = 0.693147180559945309417232121458176568075500134360255254120680009 // https://oeis.org/A002162
	Log2E  = 1 / Ln2
	Ln10   = 2.30258509299404568401799145468436420760110148862877297603332790 // https://oeis.org/A002392
	Log10E = 1 / Ln10
)
```
Mathematical constants.

<a id="MaxFloat32"></a><a id="SmallestNonzeroFloat32"></a><a id="MaxFloat64"></a><a id="SmallestNonzeroFloat64"></a>
```go
const (
	MaxFloat32             = 0x1p127 * (1 + (1 - 0x1p-23)) // 3.40282346638528859811704183484516925440e+38
	SmallestNonzeroFloat32 = 0x1p-126 * 0x1p-23            // 1.401298464324817070923729583289916131280e-45

	MaxFloat64             = 0x1p1023 * (1 + (1 - 0x1p-52)) // 1.79769313486231570814527423731704356798070e+308
	SmallestNonzeroFloat64 = 0x1p-1022 * 0x1p-52            // 4.9406564584124654417656879286822137236505980e-324
)
```
Floating-point limit values. Max is the largest finite value representable by the type. SmallestNonzero is the smallest positive, non-zero value representable by the type.

<a id="MaxInt"></a><a id="MinInt"></a><a id="MaxInt8"></a><a id="MinInt8"></a><a id="MaxInt16"></a><a id="MinInt16"></a><a id="MaxInt32"></a><a id="MinInt32"></a><a id="MaxInt64"></a><a id="MinInt64"></a><a id="MaxUint"></a><a id="MaxUint8"></a><a id="MaxUint16"></a><a id="MaxUint32"></a><a id="MaxUint64"></a>
```go
const (
	MaxInt    = 1<<(intSize-1) - 1  // MaxInt32 or MaxInt64 depending on intSize.
	MinInt    = -1 << (intSize - 1) // MinInt32 or MinInt64 depending on intSize.
	MaxInt8   = 1<<7 - 1            // 127
	MinInt8   = -1 << 7             // -128
	MaxInt16  = 1<<15 - 1           // 32767
	MinInt16  = -1 << 15            // -32768
	MaxInt32  = 1<<31 - 1           // 2147483647
	MinInt32  = -1 << 31            // -2147483648
	MaxInt64  = 1<<63 - 1           // 9223372036854775807
	MinInt64  = -1 << 63            // -9223372036854775808
	MaxUint   = 1<<intSize - 1      // MaxUint32 or MaxUint64 depending on intSize.
	MaxUint8  = 1<<8 - 1            // 255
	MaxUint16 = 1<<16 - 1           // 65535
	MaxUint32 = 1<<32 - 1           // 4294967295
	MaxUint64 = 1<<64 - 1           // 18446744073709551615
)
```
Integer limit values.

## Functions

<a id="Abs"></a>
### func Abs

```go
func Abs(x float64) float64
```
Abs returns the absolute value of x.

Special cases are:

	Abs(±Inf) = +Inf
	Abs(NaN) = NaN

##### Example

```go
{
	x := math.Abs(-2)
	fmt.Printf("%.1f\n", x)

	y := math.Abs(2)
	fmt.Printf("%.1f\n", y)

}
```
Output:

```
2.0
2.0

```

<a id="Acos"></a>
### func Acos

```go
func Acos(x float64) float64
```
Acos returns the arccosine, in radians, of x.

Special case is:

	Acos(x) = NaN if x < -1 or x > 1

##### Example

```go
{
	fmt.Printf("%.2f", math.Acos(1))

}
```
Output:

```
0.00

```

<a id="Acosh"></a>
### func Acosh

```go
func Acosh(x float64) float64
```
Acosh returns the inverse hyperbolic cosine of x.

Special cases are:

	Acosh(+Inf) = +Inf
	Acosh(x) = NaN if x < 1
	Acosh(NaN) = NaN

##### Example

```go
{
	fmt.Printf("%.2f", math.Acosh(1))

}
```
Output:

```
0.00

```

<a id="Asin"></a>
### func Asin

```go
func Asin(x float64) float64
```
Asin returns the arcsine, in radians, of x.

Special cases are:

	Asin(±0) = ±0
	Asin(x) = NaN if x < -1 or x > 1

##### Example

```go
{
	fmt.Printf("%.2f", math.Asin(0))

}
```
Output:

```
0.00

```

<a id="Asinh"></a>
### func Asinh

```go
func Asinh(x float64) float64
```
Asinh returns the inverse hyperbolic sine of x.

Special cases are:

	Asinh(±0) = ±0
	Asinh(±Inf) = ±Inf
	Asinh(NaN) = NaN

##### Example

```go
{
	fmt.Printf("%.2f", math.Asinh(0))

}
```
Output:

```
0.00

```

<a id="Atan"></a>
### func Atan

```go
func Atan(x float64) float64
```
Atan returns the arctangent, in radians, of x.

Special cases are:

	Atan(±0) = ±0
	Atan(±Inf) = ±Pi/2

##### Example

```go
{
	fmt.Printf("%.2f", math.Atan(0))

}
```
Output:

```
0.00

```

<a id="Atan2"></a>
### func Atan2

```go
func Atan2(y, x float64) float64
```
Atan2 returns the arc tangent of y/x, using the signs of the two to determine the quadrant of the return value.

Special cases are (in order):

	Atan2(y, NaN) = NaN
	Atan2(NaN, x) = NaN
	Atan2(+0, x>=0) = +0
	Atan2(-0, x>=0) = -0
	Atan2(+0, x<=-0) = +Pi
	Atan2(-0, x<=-0) = -Pi
	Atan2(y>0, 0) = +Pi/2
	Atan2(y<0, 0) = -Pi/2
	Atan2(+Inf, +Inf) = +Pi/4
	Atan2(-Inf, +Inf) = -Pi/4
	Atan2(+Inf, -Inf) = 3Pi/4
	Atan2(-Inf, -Inf) = -3Pi/4
	Atan2(y, +Inf) = 0
	Atan2(y>0, -Inf) = +Pi
	Atan2(y<0, -Inf) = -Pi
	Atan2(+Inf, x) = +Pi/2
	Atan2(-Inf, x) = -Pi/2

##### Example

```go
{
	fmt.Printf("%.2f", math.Atan2(0, 0))

}
```
Output:

```
0.00

```

<a id="Atanh"></a>
### func Atanh

```go
func Atanh(x float64) float64
```
Atanh returns the inverse hyperbolic tangent of x.

Special cases are:

	Atanh(1) = +Inf
	Atanh(±0) = ±0
	Atanh(-1) = -Inf
	Atanh(x) = NaN if x < -1 or x > 1
	Atanh(NaN) = NaN

##### Example

```go
{
	fmt.Printf("%.2f", math.Atanh(0))

}
```
Output:

```
0.00

```

<a id="Cbrt"></a>
### func Cbrt

```go
func Cbrt(x float64) float64
```
Cbrt returns the cube root of x.

Special cases are:

	Cbrt(±0) = ±0
	Cbrt(±Inf) = ±Inf
	Cbrt(NaN) = NaN

##### Example

```go
{
	fmt.Printf("%.2f\n", math.Cbrt(8))
	fmt.Printf("%.2f\n", math.Cbrt(27))

}
```
Output:

```
2.00
3.00

```

<a id="Ceil"></a>
### func Ceil

```go
func Ceil(x float64) float64
```
Ceil returns the least integer value greater than or equal to x.

Special cases are:

	Ceil(±0) = ±0
	Ceil(±Inf) = ±Inf
	Ceil(NaN) = NaN

##### Example

```go
{
	c := math.Ceil(1.49)
	fmt.Printf("%.1f", c)

}
```
Output:

```
2.0

```

<a id="Copysign"></a>
### func Copysign

```go
func Copysign(f, sign float64) float64
```
Copysign returns a value with the magnitude of f and the sign of sign.

##### Example

```go
{
	fmt.Printf("%.2f", math.Copysign(3.2, -1))

}
```
Output:

```
-3.20

```

<a id="Cos"></a>
### func Cos

```go
func Cos(x float64) float64
```
Cos returns the cosine of the radian argument x.

Special cases are:

	Cos(±Inf) = NaN
	Cos(NaN) = NaN

##### Example

```go
{
	fmt.Printf("%.2f", math.Cos(math.Pi/2))

}
```
Output:

```
0.00

```

<a id="Cosh"></a>
### func Cosh

```go
func Cosh(x float64) float64
```
Cosh returns the hyperbolic cosine of x.

Special cases are:

	Cosh(±0) = 1
	Cosh(±Inf) = +Inf
	Cosh(NaN) = NaN

##### Example

```go
{
	fmt.Printf("%.2f", math.Cosh(0))

}
```
Output:

```
1.00

```

<a id="Dim"></a>
### func Dim

```go
func Dim(x, y float64) float64
```
Dim returns the maximum of x-y or 0.

Special cases are:

	Dim(+Inf, +Inf) = NaN
	Dim(-Inf, -Inf) = NaN
	Dim(x, NaN) = Dim(NaN, x) = NaN

##### Example

```go
{
	fmt.Printf("%.2f\n", math.Dim(4, -2))
	fmt.Printf("%.2f\n", math.Dim(-4, 2))

}
```
Output:

```
6.00
0.00

```

<a id="Erf"></a>
### func Erf

```go
func Erf(x float64) float64
```
Erf returns the error function of x.

Special cases are:

	Erf(+Inf) = 1
	Erf(-Inf) = -1
	Erf(NaN) = NaN

<a id="Erfc"></a>
### func Erfc

```go
func Erfc(x float64) float64
```
Erfc returns the complementary error function of x.

Special cases are:

	Erfc(+Inf) = 0
	Erfc(-Inf) = 2
	Erfc(NaN) = NaN

<a id="Erfcinv"></a>
### func Erfcinv

```go
func Erfcinv(x float64) float64
```
Erfcinv returns the inverse of [Erfc](#Erfc)(x).

Special cases are:

	Erfcinv(0) = +Inf
	Erfcinv(2) = -Inf
	Erfcinv(x) = NaN if x < 0 or x > 2
	Erfcinv(NaN) = NaN

<a id="Erfinv"></a>
### func Erfinv

```go
func Erfinv(x float64) float64
```
Erfinv returns the inverse error function of x.

Special cases are:

	Erfinv(1) = +Inf
	Erfinv(-1) = -Inf
	Erfinv(x) = NaN if x < -1 or x > 1
	Erfinv(NaN) = NaN

<a id="Exp"></a>
### func Exp

```go
func Exp(x float64) float64
```
Exp returns e\*\*x, the base-e exponential of x.

Special cases are:

	Exp(+Inf) = +Inf
	Exp(NaN) = NaN

Very large values overflow to 0 or +Inf. Very small values underflow to 1.

##### Example

```go
{
	fmt.Printf("%.2f\n", math.Exp(1))
	fmt.Printf("%.2f\n", math.Exp(2))
	fmt.Printf("%.2f\n", math.Exp(-1))

}
```
Output:

```
2.72
7.39
0.37

```

<a id="Exp2"></a>
### func Exp2

```go
func Exp2(x float64) float64
```
Exp2 returns 2\*\*x, the base-2 exponential of x.

Special cases are the same as [Exp](#Exp).

##### Example

```go
{
	fmt.Printf("%.2f\n", math.Exp2(1))
	fmt.Printf("%.2f\n", math.Exp2(-3))

}
```
Output:

```
2.00
0.12

```

<a id="Expm1"></a>
### func Expm1

```go
func Expm1(x float64) float64
```
Expm1 returns e\*\*x - 1, the base-e exponential of x minus 1. It is more accurate than [Exp](#Exp)(x) - 1 when x is near zero.

Special cases are:

	Expm1(+Inf) = +Inf
	Expm1(-Inf) = -1
	Expm1(NaN) = NaN

Very large values overflow to -1 or +Inf.

##### Example

```go
{
	fmt.Printf("%.6f\n", math.Expm1(0.01))
	fmt.Printf("%.6f\n", math.Expm1(-1))

}
```
Output:

```
0.010050
-0.632121

```

<a id="FMA"></a>
### func FMA

```go
func FMA(x, y, z float64) float64
```
FMA returns x \* y + z, computed with only one rounding. (That is, FMA returns the fused multiply-add of x, y, and z.)

<a id="Float32bits"></a>
### func Float32bits

```go
func Float32bits(f float32) uint32
```
Float32bits returns the IEEE 754 binary representation of f, with the sign bit of f and the result in the same bit position. Float32bits(Float32frombits(x)) == x.

<a id="Float32frombits"></a>
### func Float32frombits

```go
func Float32frombits(b uint32) float32
```
Float32frombits returns the floating-point number corresponding to the IEEE 754 binary representation b, with the sign bit of b and the result in the same bit position. Float32frombits(Float32bits(x)) == x.

<a id="Float64bits"></a>
### func Float64bits

```go
func Float64bits(f float64) uint64
```
Float64bits returns the IEEE 754 binary representation of f, with the sign bit of f and the result in the same bit position, and Float64bits(Float64frombits(x)) == x.

<a id="Float64frombits"></a>
### func Float64frombits

```go
func Float64frombits(b uint64) float64
```
Float64frombits returns the floating-point number corresponding to the IEEE 754 binary representation b, with the sign bit of b and the result in the same bit position. Float64frombits(Float64bits(x)) == x.

<a id="Floor"></a>
### func Floor

```go
func Floor(x float64) float64
```
Floor returns the greatest integer value less than or equal to x.

Special cases are:

	Floor(±0) = ±0
	Floor(±Inf) = ±Inf
	Floor(NaN) = NaN

##### Example

```go
{
	c := math.Floor(1.51)
	fmt.Printf("%.1f", c)

}
```
Output:

```
1.0

```

<a id="Frexp"></a>
### func Frexp

```go
func Frexp(f float64) (frac float64, exp int)
```
Frexp breaks f into a normalized fraction and an integral power of two. It returns frac and exp satisfying f == frac × 2\*\*exp, with the absolute value of frac in the interval \[½, 1).

Special cases are:

	Frexp(±0) = ±0, 0
	Frexp(±Inf) = ±Inf, 0
	Frexp(NaN) = NaN, 0

<a id="Gamma"></a>
### func Gamma

```go
func Gamma(x float64) float64
```
Gamma returns the Gamma function of x.

Special cases are:

	Gamma(+Inf) = +Inf
	Gamma(+0) = +Inf
	Gamma(-0) = -Inf
	Gamma(x) = NaN for integer x < 0
	Gamma(-Inf) = NaN
	Gamma(NaN) = NaN

<a id="Hypot"></a>
### func Hypot

```go
func Hypot(p, q float64) float64
```
Hypot returns [Sqrt](#Sqrt)(p\*p + q\*q), taking care to avoid unnecessary overflow and underflow.

Special cases are:

	Hypot(±Inf, q) = +Inf
	Hypot(p, ±Inf) = +Inf
	Hypot(NaN, q) = NaN
	Hypot(p, NaN) = NaN

<a id="Ilogb"></a>
### func Ilogb

```go
func Ilogb(x float64) int
```
Ilogb returns the binary exponent of x as an integer.

Special cases are:

	Ilogb(±Inf) = MaxInt32
	Ilogb(0) = MinInt32
	Ilogb(NaN) = MaxInt32

<a id="Inf"></a>
### func Inf

```go
func Inf(sign int) float64
```
Inf returns positive infinity if sign >= 0, negative infinity if sign \< 0.

<a id="IsInf"></a>
### func IsInf

```go
func IsInf(f float64, sign int) bool
```
IsInf reports whether f is an infinity, according to sign. If sign > 0, IsInf reports whether f is positive infinity. If sign \< 0, IsInf reports whether f is negative infinity. If sign == 0, IsInf reports whether f is either infinity.

<a id="IsNaN"></a>
### func IsNaN

```go
func IsNaN(f float64) (is bool)
```
IsNaN reports whether f is an IEEE 754 “not-a-number” value.

<a id="J0"></a>
### func J0

```go
func J0(x float64) float64
```
J0 returns the order-zero Bessel function of the first kind.

Special cases are:

	J0(±Inf) = 0
	J0(0) = 1
	J0(NaN) = NaN

<a id="J1"></a>
### func J1

```go
func J1(x float64) float64
```
J1 returns the order-one Bessel function of the first kind.

Special cases are:

	J1(±Inf) = 0
	J1(NaN) = NaN

<a id="Jn"></a>
### func Jn

```go
func Jn(n int, x float64) float64
```
Jn returns the order-n Bessel function of the first kind.

Special cases are:

	Jn(n, ±Inf) = 0
	Jn(n, NaN) = NaN

<a id="Ldexp"></a>
### func Ldexp

```go
func Ldexp(frac float64, exp int) float64
```
Ldexp is the inverse of [Frexp](#Frexp). It returns frac × 2\*\*exp.

Special cases are:

	Ldexp(±0, exp) = ±0
	Ldexp(±Inf, exp) = ±Inf
	Ldexp(NaN, exp) = NaN

<a id="Lgamma"></a>
### func Lgamma

```go
func Lgamma(x float64) (lgamma float64, sign int)
```
Lgamma returns the natural logarithm and sign (-1 or +1) of [Gamma](#Gamma)(x).

Special cases are:

	Lgamma(+Inf) = +Inf
	Lgamma(0) = +Inf
	Lgamma(-integer) = +Inf
	Lgamma(-Inf) = -Inf
	Lgamma(NaN) = NaN

<a id="Log"></a>
### func Log

```go
func Log(x float64) float64
```
Log returns the natural logarithm of x.

Special cases are:

	Log(+Inf) = +Inf
	Log(0) = -Inf
	Log(x < 0) = NaN
	Log(NaN) = NaN

##### Example

```go
{
	x := math.Log(1)
	fmt.Printf("%.1f\n", x)

	y := math.Log(2.7183)
	fmt.Printf("%.1f\n", y)

}
```
Output:

```
0.0
1.0

```

<a id="Log10"></a>
### func Log10

```go
func Log10(x float64) float64
```
Log10 returns the decimal logarithm of x. The special cases are the same as for [Log](#Log).

##### Example

```go
{
	fmt.Printf("%.1f", math.Log10(100))

}
```
Output:

```
2.0

```

<a id="Log1p"></a>
### func Log1p

```go
func Log1p(x float64) float64
```
Log1p returns the natural logarithm of 1 plus its argument x. It is more accurate than [Log](#Log)(1 + x) when x is near zero.

Special cases are:

	Log1p(+Inf) = +Inf
	Log1p(±0) = ±0
	Log1p(-1) = -Inf
	Log1p(x < -1) = NaN
	Log1p(NaN) = NaN

<a id="Log2"></a>
### func Log2

```go
func Log2(x float64) float64
```
Log2 returns the binary logarithm of x. The special cases are the same as for [Log](#Log).

##### Example

```go
{
	fmt.Printf("%.1f", math.Log2(256))

}
```
Output:

```
8.0

```

<a id="Logb"></a>
### func Logb

```go
func Logb(x float64) float64
```
Logb returns the binary exponent of x.

Special cases are:

	Logb(±Inf) = +Inf
	Logb(0) = -Inf
	Logb(NaN) = NaN

<a id="Max"></a>
### func Max

```go
func Max(x, y float64) float64
```
Max returns the larger of x or y.

Special cases are:

	Max(x, +Inf) = Max(+Inf, x) = +Inf
	Max(x, NaN) = Max(NaN, x) = NaN
	Max(+0, ±0) = Max(±0, +0) = +0
	Max(-0, -0) = -0

Note that this differs from the built-in function max when called with NaN and +Inf.

<a id="Min"></a>
### func Min

```go
func Min(x, y float64) float64
```
Min returns the smaller of x or y.

Special cases are:

	Min(x, -Inf) = Min(-Inf, x) = -Inf
	Min(x, NaN) = Min(NaN, x) = NaN
	Min(-0, ±0) = Min(±0, -0) = -0

Note that this differs from the built-in function min when called with NaN and -Inf.

<a id="Mod"></a>
### func Mod

```go
func Mod(x, y float64) float64
```
Mod returns the floating-point remainder of x/y. The magnitude of the result is less than y and its sign agrees with that of x.

Special cases are:

	Mod(±Inf, y) = NaN
	Mod(NaN, y) = NaN
	Mod(x, 0) = NaN
	Mod(x, ±Inf) = x
	Mod(x, NaN) = NaN

##### Example

```go
{
	c := math.Mod(7, 4)
	fmt.Printf("%.1f", c)

}
```
Output:

```
3.0

```

<a id="Modf"></a>
### func Modf

```go
func Modf(f float64) (integer float64, fractional float64)
```
Modf returns integer and fractional floating-point numbers that sum to f. Both values have the same sign as f.

Special cases are:

	Modf(±Inf) = ±Inf, NaN
	Modf(NaN) = NaN, NaN

##### Example

```go
{
	int, frac := math.Modf(3.14)
	fmt.Printf("%.2f, %.2f\n", int, frac)

	int, frac = math.Modf(-2.71)
	fmt.Printf("%.2f, %.2f\n", int, frac)

}
```
Output:

```
3.00, 0.14
-2.00, -0.71

```

<a id="NaN"></a>
### func NaN

```go
func NaN() float64
```
NaN returns an IEEE 754 “not-a-number” value.

<a id="Nextafter"></a>
### func Nextafter

```go
func Nextafter(x, y float64) (r float64)
```
Nextafter returns the next representable float64 value after x towards y.

Special cases are:

	Nextafter(x, y)   = x when x == y
	Nextafter(0, y)   = ±SmallestNonzeroFloat64 towards y, for y ≠ 0
	Nextafter(NaN, y) = NaN
	Nextafter(x, NaN) = NaN

<a id="Nextafter32"></a>
### func Nextafter32

```go
func Nextafter32(x, y float32) (r float32)
```
Nextafter32 returns the next representable float32 value after x towards y.

Special cases are:

	Nextafter32(x, y)   = x when x == y
	Nextafter32(0, y)   = ±SmallestNonzeroFloat32 towards y, for y ≠ 0
	Nextafter32(NaN, y) = NaN
	Nextafter32(x, NaN) = NaN

<a id="Pow"></a>
### func Pow

```go
func Pow(x, y float64) float64
```
Pow returns x\*\*y, the base-x exponential of y.

Special cases are (in order):

	Pow(x, ±0) = 1 for any x
	Pow(1, y) = 1 for any y
	Pow(x, 1) = x for any x
	Pow(NaN, y) = NaN
	Pow(x, NaN) = NaN
	Pow(±0, y) = ±Inf for y an odd integer < 0
	Pow(±0, -Inf) = +Inf
	Pow(±0, +Inf) = +0
	Pow(±0, y) = +Inf for finite y < 0 and not an odd integer
	Pow(±0, y) = ±0 for y an odd integer > 0
	Pow(±0, y) = +0 for finite y > 0 and not an odd integer
	Pow(-1, ±Inf) = 1
	Pow(x, +Inf) = +Inf for |x| > 1
	Pow(x, -Inf) = +0 for |x| > 1
	Pow(x, +Inf) = +0 for |x| < 1
	Pow(x, -Inf) = +Inf for |x| < 1
	Pow(+Inf, y) = +Inf for y > 0
	Pow(+Inf, y) = +0 for y < 0
	Pow(-Inf, y) = Pow(-0, -y)
	Pow(x, y) = NaN for finite x < 0 and finite non-integer y

##### Example

```go
{
	c := math.Pow(2, 3)
	fmt.Printf("%.1f", c)

}
```
Output:

```
8.0

```

<a id="Pow10"></a>
### func Pow10

```go
func Pow10(n int) float64
```
Pow10 returns 10\*\*n, the base-10 exponential of n.

Special cases are:

	Pow10(n) =    0 for n < -323
	Pow10(n) = +Inf for n > 308

##### Example

```go
{
	c := math.Pow10(2)
	fmt.Printf("%.1f", c)

}
```
Output:

```
100.0

```

<a id="Remainder"></a>
### func Remainder

```go
func Remainder(x, y float64) float64
```
Remainder returns the IEEE 754 floating-point remainder of x/y.

Special cases are:

	Remainder(±Inf, y) = NaN
	Remainder(NaN, y) = NaN
	Remainder(x, 0) = NaN
	Remainder(x, ±Inf) = x
	Remainder(x, NaN) = NaN

##### Example

```go
{
	fmt.Printf("%.1f", math.Remainder(100, 30))

}
```
Output:

```
10.0

```

<a id="Round"></a>
### func Round

```go
func Round(x float64) float64
```
Round returns the nearest integer, rounding half away from zero.

Special cases are:

	Round(±0) = ±0
	Round(±Inf) = ±Inf
	Round(NaN) = NaN

##### Example

```go
{
	p := math.Round(10.5)
	fmt.Printf("%.1f\n", p)

	n := math.Round(-10.5)
	fmt.Printf("%.1f\n", n)

}
```
Output:

```
11.0
-11.0

```

<a id="RoundToEven"></a>
### func RoundToEven

```go
func RoundToEven(x float64) float64
```
RoundToEven returns the nearest integer, rounding ties to even.

Special cases are:

	RoundToEven(±0) = ±0
	RoundToEven(±Inf) = ±Inf
	RoundToEven(NaN) = NaN

##### Example

```go
{
	u := math.RoundToEven(11.5)
	fmt.Printf("%.1f\n", u)

	d := math.RoundToEven(12.5)
	fmt.Printf("%.1f\n", d)

}
```
Output:

```
12.0
12.0

```

<a id="Signbit"></a>
### func Signbit

```go
func Signbit(x float64) bool
```
Signbit reports whether x is negative or negative zero.

<a id="Sin"></a>
### func Sin

```go
func Sin(x float64) float64
```
Sin returns the sine of the radian argument x.

Special cases are:

	Sin(±0) = ±0
	Sin(±Inf) = NaN
	Sin(NaN) = NaN

##### Example

```go
{
	fmt.Printf("%.2f", math.Sin(math.Pi))

}
```
Output:

```
0.00

```

<a id="Sincos"></a>
### func Sincos

```go
func Sincos(x float64) (sin, cos float64)
```
Sincos returns Sin(x), Cos(x).

Special cases are:

	Sincos(±0) = ±0, 1
	Sincos(±Inf) = NaN, NaN
	Sincos(NaN) = NaN, NaN

##### Example

```go
{
	sin, cos := math.Sincos(0)
	fmt.Printf("%.2f, %.2f", sin, cos)

}
```
Output:

```
0.00, 1.00

```

<a id="Sinh"></a>
### func Sinh

```go
func Sinh(x float64) float64
```
Sinh returns the hyperbolic sine of x.

Special cases are:

	Sinh(±0) = ±0
	Sinh(±Inf) = ±Inf
	Sinh(NaN) = NaN

##### Example

```go
{
	fmt.Printf("%.2f", math.Sinh(0))

}
```
Output:

```
0.00

```

<a id="Sqrt"></a>
### func Sqrt

```go
func Sqrt(x float64) float64
```
Sqrt returns the square root of x.

Special cases are:

	Sqrt(+Inf) = +Inf
	Sqrt(±0) = ±0
	Sqrt(x < 0) = NaN
	Sqrt(NaN) = NaN

##### Example

```go
{
	const (
		a = 3
		b = 4
	)
	c := math.Sqrt(a*a + b*b)
	fmt.Printf("%.1f", c)

}
```
Output:

```
5.0

```

<a id="Tan"></a>
### func Tan

```go
func Tan(x float64) float64
```
Tan returns the tangent of the radian argument x.

Special cases are:

	Tan(±0) = ±0
	Tan(±Inf) = NaN
	Tan(NaN) = NaN

##### Example

```go
{
	fmt.Printf("%.2f", math.Tan(0))

}
```
Output:

```
0.00

```

<a id="Tanh"></a>
### func Tanh

```go
func Tanh(x float64) float64
```
Tanh returns the hyperbolic tangent of x.

Special cases are:

	Tanh(±0) = ±0
	Tanh(±Inf) = ±1
	Tanh(NaN) = NaN

##### Example

```go
{
	fmt.Printf("%.2f", math.Tanh(0))

}
```
Output:

```
0.00

```

<a id="Trunc"></a>
### func Trunc

```go
func Trunc(x float64) float64
```
Trunc returns the integer value of x.

Special cases are:

	Trunc(±0) = ±0
	Trunc(±Inf) = ±Inf
	Trunc(NaN) = NaN

##### Example

```go
{
	fmt.Printf("%.2f\n", math.Trunc(math.Pi))
	fmt.Printf("%.2f\n", math.Trunc(-1.2345))

}
```
Output:

```
3.00
-1.00

```

<a id="Y0"></a>
### func Y0

```go
func Y0(x float64) float64
```
Y0 returns the order-zero Bessel function of the second kind.

Special cases are:

	Y0(+Inf) = 0
	Y0(0) = -Inf
	Y0(x < 0) = NaN
	Y0(NaN) = NaN

<a id="Y1"></a>
### func Y1

```go
func Y1(x float64) float64
```
Y1 returns the order-one Bessel function of the second kind.

Special cases are:

	Y1(+Inf) = 0
	Y1(0) = -Inf
	Y1(x < 0) = NaN
	Y1(NaN) = NaN

<a id="Yn"></a>
### func Yn

```go
func Yn(n int, x float64) float64
```
Yn returns the order-n Bessel function of the second kind.

Special cases are:

	Yn(n, +Inf) = 0
	Yn(n ≥ 0, 0) = -Inf
	Yn(n < 0, 0) = +Inf if n is odd, -Inf if n is even
	Yn(n, x < 0) = NaN
	Yn(n, NaN) = NaN

