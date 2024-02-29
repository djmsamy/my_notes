//----------------Login Exceptions--------------------------
class WrongEmailOrPasswordAuthException implements Exception {
  
}
//

//-----------------Register Exceptions------------------------
class UsedEmailAuthException implements Exception {
  
}

class WeakPasswordAuthException implements Exception {
  
}

class InvalidEmailAuthException implements Exception {
  
}

//

//---------------------------Generic Exceptions----------------------
class GenericAuthException implements Exception {
  
}

class UserNotLoggedInAuthException implements Exception {
  
}

