import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class Styles {
  final BuildContext context;
  Styles(this.context);

  double get width => MediaQuery.of(context).size.width;
  double get height => MediaQuery.of(context).size.height;

  bool get isMobile => width < 768;
  bool get isTablet => width >= 768 && width < 1100;
  bool get isDesktop => width >= 1100;

  bool get smallerThanTablet => width < 1100;
  bool get largerThanTablet => width >= 1100;
  bool get largerThanMobile => width >= 768;

  bool get isPortrait => height > width;
  bool get isLandscape => width > height;

  Widget rowColumnWidget(List<Widget> children,
          {bool isRow = true,
          MainAxisAlignment mainAxisAlignment = MainAxisAlignment.start,
          MainAxisSize mainAxisSize = MainAxisSize.max,
          CrossAxisAlignment crossAxisAlignment = CrossAxisAlignment.start,
          EdgeInsetsGeometry padding = EdgeInsets.zero}) =>
      isRow
          ? Row(
              mainAxisAlignment: mainAxisAlignment,
              mainAxisSize: mainAxisSize,
              crossAxisAlignment: crossAxisAlignment,
              children: children,
            )
          : Column(
              mainAxisAlignment: mainAxisAlignment,
              mainAxisSize: mainAxisSize,
              crossAxisAlignment: crossAxisAlignment,
              children: children,
            );

  TextStyle title(
          {Color? color,
          FontWeight fontWeight = FontWeight.bold,
          double fontSize = 25,
          String? fontFamily,
          FontStyle? style,
          double height = 1.5}) =>
      GoogleFonts.poppins(
          color: color ?? Colors.black,
          fontWeight: fontWeight,
          fontStyle: style ?? FontStyle.normal,
          height: height,
          fontSize: fontSize);

  TextStyle subtitle(
          {Color? color,
          FontWeight? fontWeight,
          double fontSize = 18,
          FontStyle? style,
          double height = 1.5}) =>
      GoogleFonts.roboto(
          color: color ?? Colors.black,
          fontWeight: fontWeight ?? FontWeight.normal,
          fontStyle: style ?? FontStyle.normal,
          height: height,
          fontSize: fontSize);

  TextStyle body(
          {Color? color,
          FontWeight? fontWeight,
          double fontSize = 15,
          FontStyle? style,
          double height = 1.5}) =>
      GoogleFonts.openSans(
          color: color ?? Colors.black,
          fontWeight: fontWeight ?? FontWeight.normal,
          fontStyle: style ?? FontStyle.normal,
          height: height,
          fontSize: fontSize);
}
