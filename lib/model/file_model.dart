import 'dart:io';

class FileModel {
  File? file;
   final String name;
   final double size;
   final String extension;
   late Map<String, List<String>> _supportedOutputFormats;

     FileModel({required this.name, required this.size, required this.extension});

//   get name => this._name;

// //  set name( value) => this._name = value;

//   get size => this._size;

// //  set size( value) => this._size = value;

//   get extension => this._extension;

//  set extension( value) => this._extension = value;

  get supportedOutputFormats => this._supportedOutputFormats;

 set supportedOutputFormats( value) => this._supportedOutputFormats = value;

 
}
