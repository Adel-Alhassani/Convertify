class FileModel {
  late String _name;
  late double _size;
  late List _outputFormats;
  
  get name => this._name;

 set name(value) => this._name = value;

  get size => this._size;

 set size( value) => this._size = value;

  get outputFormats => this._outputFormats;

 set outputFormats( value) => this._outputFormats = value;
}
