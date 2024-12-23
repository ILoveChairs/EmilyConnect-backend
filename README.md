# Emily Dickinson User API

[![style: very good analysis][very_good_analysis_badge]][very_good_analysis_link]
[![License: MIT][license_badge]][license_link]
[![Powered by Dart Frog](https://img.shields.io/endpoint?url=https://tinyurl.com/dartfrog-badge)](https://dartfrog.vgv.dev)

[license_badge]: https://img.shields.io/badge/license-MIT-blue.svg
[license_link]: https://opensource.org/licenses/MIT
[very_good_analysis_badge]: https://img.shields.io/badge/style-very_good_analysis-B22C89.svg
[very_good_analysis_link]: https://pub.dev/packages/very_good_analysis

## Description

Emily Connect project.

This API has the job of creating and deleting users in both Firebase Auth and
Firestore. In the future this could be delegated to cloud functions.

Only admins should be able operate in this API, however authentication and
authorization are not implemented yet.

Updates may be added in the future.

Endpoints will also be passed to a yaml probably.

## How to run

In the build folder there should be a dockerfile where you can run it from,
else you can install dart_frog_cli, enter the api folder and run dart_frog dev.

For it to work you'll need the Firebase keys to do operations directly to it.

## Endpoints:

For most endpoints the following is required:
- Headers: {"Content-Type": "application/json"}
- Accept: {"Accept": "application/json"}

DELETE /user/{ci} does not need the previous.

Generic errors:
- 414, 431, 406, 400, 411, 413, 415, 401, 403 => {
    "error": (string), "msg": (string)
}

### => /user/

#### -> POST

- Singular user POST
- - Expected body: {
 "ci": (string),
 "first_name": (string),
 "last_name": (string),
 "role": (string) (optional)
}
- - On success: 201
- - On error: 400, 409, 503 => {"error": (string), "msg": (string)}

- Multiple users POST
- - Expected body: {
 "users": [
   ...
   {
     "ci": (string),
     "first_name": (string),
     "last_name": (string),
     "role": (string) (optional)
   }
 ]
}
- - On success: 200 => {"results": {...(ci): (string)}}
- - On error: 400 => {"error": (string), "msg": (string)}

#### -> DELETE

- Expected DELETE body for multiple users: {
 users: [
   ...
   "ci": (string)
 ]
}
- On success: 200 => {"results": [...(string)]}
- On error: 400 => {"error": (string), "msg": (string)}

&emsp;
&emsp;

### => /user/{ci}

#### -> PATCH
- Expected PATCH body for singular users: {
 "first_name": (string),
 "last_name": (string),
}
- On success: 200
- On error: 400, 404, 503 => {"error": (string), "msg": (string)}

#### -> DELETE
- On success: 204
- On error: 400, 404, 503 => {"error": (string), "msg": (string)}
