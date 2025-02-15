// import 'package:http/http.dart' as http;
// import 'dart:convert';

// Future<String> checkHarassment(String message) async {
//   final response = await http.post(
//     Uri.parse(
//         'http://127.0.0.1:5000/predict'), // Ensure Flask is running on your machine
//     headers: <String, String>{
//       'Content-Type': 'application/json',
//     },
//     body: json.encode({'message': message}),
//   );

//   if (response.statusCode == 200) {
//     final data = json.decode(response.body);
//     return data['classification']; // Harassment or Non-Harassment
//   } else {
//     throw Exception('Failed to analyze message');
//   }
// }
