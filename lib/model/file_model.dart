class FileModel {
  late String _name;
  late double _size;
  late String _extension;
  late Map<String, List<String>> _supportedOutputFormats;
  FileModel(this._name, this._size, this._extension);

  get name => this._name;

  set name(value) => this._name = value;

  get size => this._size;

  set size(value) => this._size = value;

  get supportedOutputFormats => this._supportedOutputFormats;

  set supportedOutputFormats(value) => this._supportedOutputFormats = value;
}
