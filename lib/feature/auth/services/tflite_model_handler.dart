// import 'package:flutter/services.dart';
// import 'package:tflite_flutter/tflite_flutter.dart';
// import 'package:tflite_flutter_helper_plus/tflite_flutter_helper_plus.dart';

// class TfLiteModelHandler {
//   late Interpreter interpreter; // TensorFlow Lite model interpreter
//   late List<String> vocabulary; // Vocabulary list for tokenization
//   late int inputSize; // Model input size, adjust based on your model

//   // Load model and vocabulary
//   loadModel() async {
//     try {
//       // Load the TFLite model
//       interpreter =
//           await Interpreter.fromAsset('assets/harassment_model.tflite');
//       print("TFLite Model Loaded Successfully!");

//       // Load vocabulary from assets
//       String vocabData = await rootBundle.loadString('vocab.txt');
//       vocabulary = vocabData.split("\n");
//       inputSize = 100; // Adjust based on model's expected input size
//     } catch (e) {
//       print("Failed to load TFLite model: $e");
//     }
//   }

//   // Predict whether a message is harassment
//   Future<bool> predictMessage(String message) async {
//     if (vocabulary.isEmpty) {
//       print("Error: Vocabulary is not initialized.");
//       return false;
//     }
//     // Tokenize and convert the message to a numerical format
//     List<int> tokenizedMessage = tokenizeText(message);

//     // Prepare input tensor (ensure matching input size)
//     List<List<double>> input = [
//       tokenizedMessage.map((e) => e.toDouble()).toList()
//     ];

//     // Pad or truncate the input to match the model's input size
//     while (input[0].length < inputSize) {
//       input[0].add(0.0); // Padding
//     }
//     input[0] = input[0].sublist(0, inputSize); // Truncate if necessary

//     // Create input tensor (use float32 for TensorFlow Lite models)
//     var inputTensor =
//         TensorBuffer.createFixedSize([1, inputSize], TfLiteType.float32);

//     // Pass shape parameter explicitly when loading the list
//     inputTensor.loadList(input[0], shape: [1, inputSize]); // Provide the shape

//     // Output tensor
//     var outputTensor = TensorBuffer.createFixedSize([1, 1], TfLiteType.float32);

//     // Run inference
//     interpreter.run(inputTensor.getBuffer(), outputTensor.getBuffer());

//     // Get prediction result
//     double result = outputTensor.getDoubleValue(0);
//     return result >
//         0.5; // If the result is greater than 0.5, it's non-harassment
//   }

//   // Tokenize the input message based on vocabulary
//   List<int> tokenizeText(String text) {
//     List<String> words = text.toLowerCase().split(" ");
//     return words.map((word) {
//       int index = vocabulary.indexOf(word);
//       return index != -1
//           ? index
//           : 0; // If word is not found in vocabulary, return 0
//     }).toList();
//   }
// }
