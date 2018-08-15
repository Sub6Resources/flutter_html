import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';

void main() {
  runApp(
    MaterialApp(
      home: Scaffold(
        body: Html(
          data: """
          <div>
            <h1>Demo Page</h1>
            <p>This is a fantastic nonexistent product that you should buy!</p>
            <h2>Pricing</h2>
            <p>Lorem ipsum <b>dolor</b> sit amet.</p>
            <h2>The Team</h2>
            <p>There isn't <i>really</i> a team...</p>
            <h2>Installation</h2>
            <p>You <u>cannot</u> install a nonexistent product!</p>
          </div>
          """,
          //Optional parameters:
          padding: EdgeInsets.all(8.0),
          backgroundColor: Colors.white70,
          defaultTextStyle: TextStyle(color: Colors.black),
        ),
      ),
    ),
  );
}
