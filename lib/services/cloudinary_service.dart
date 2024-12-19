// uploading files to cloudinary
import 'dart:convert';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
//import 'package:flutter_dotenv/flutter_dotenv.dart';
import "package:http/http.dart" as http;
import 'package:crypto/crypto.dart';
import 'package:path_provider/path_provider.dart';
// import 'package:permission_handler/permission_handler.dart'; // For accessing device directories

Future<Map<String, String>?> uploadToCloudinary(FilePickerResult? filePickerResult) async {
  if (filePickerResult == null || filePickerResult.files.isEmpty) {
    print("No file selected!");
    return null;
  }

  File file = File(filePickerResult.files.single.path!);

  String cloudName ='dlgwtb6mi' ?? '';


  // For single replace raw -> Image
  var uri = Uri.parse("https://api.cloudinary.com/v1_1/$cloudName/image/upload");
  var request = http.MultipartRequest("POST", uri);

  // Read the file content as bytes
  var fileBytes = await file.readAsBytes();

  var multipartFile = http.MultipartFile.fromBytes(
    'file', // The form field name for the file
    fileBytes,
    filename: file.path.split("/").last, //The file name to send in the request
  );

  // Add the file part to the request
  request.files.add(multipartFile);

  request.fields['upload_preset'] = "swap-it"; // folder name that create in cloudinary
  request.fields['resource_type'] = "image";



  // Send the request and await the response
  var response = await request.send();

  // Get the response as text
  var responseBody = await response.stream.bytesToString();

  // Print the response
  // print(responseBody);

  if (response.statusCode == 200) {
    var jsonResponse = jsonDecode(responseBody);
    Map<String, String> requiredData = {
      "name": filePickerResult.files.first.name,
      "id": jsonResponse["public_id"],
      "extension": filePickerResult.files.first.extension!,
      "size": jsonResponse["bytes"].toString(),
      "url": jsonResponse["secure_url"],
      "created_at": jsonResponse["created_at"],
    };

    // await DbService().saveUploadedFilesData(requiredData);
    // print("Online Upload successful!");
    return requiredData;
  } else {
    print("Upload failed with status: ${response.statusCode}");
    return null;
  }
}

