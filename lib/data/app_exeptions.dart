
class AppException implements Exception{

  final _message;
  final _prifix;

  AppException([this._message,this._prifix]);

  String toString(){
    return '$_prifix$_message';
  }
}

class FetchDataException extends AppException{
  FetchDataException([String? message]):super(message,'Error during Communication');
}

class BadRequestException extends AppException{
  BadRequestException([String? message]):super(message,'Invalid request');
}

class UnauthorisedException extends AppException{
  UnauthorisedException([String? message]):super(message,'Unauthorised request');
}

class InvalidInputException extends AppException{
  InvalidInputException([String? message]):super(message,'Invalid input');
}
