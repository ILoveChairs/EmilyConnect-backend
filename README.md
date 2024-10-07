# Documentation

## Description

Emily Connect project.

This API has the job of creating and deleting users in both Firebase Auth and
Firestore. In the future this could be delegated to cloud functions.

Only admins should be able operate in this API, however authentication and
authorization are not implemented yet.

Updates may be added in the future.

Endpoints will also be passed to a yaml probably.

## ENDPOINTS:

For all endpoints the following is required:
- Headers: {"Content-Type": "application/json"}

&emsp;

=> /user/

-> POST
- EXPECTED POST BODY: {
 "ci": (string),
 "first_name": (string),
 "last_name": (string),
 "role": (string) (optional)
}
- ON SUCCESS: 201
- ON ERROR: 400, 409, 503 => {"error": (string), "msg": (string)}

&emsp;

-> DELETE

EXPECTED DELETE BODY: {
 "ci": (string)
}

ON SUCCESS: 204

ON ERROR: 400, 404, 503 => {"error": (string), "msg": (string)}

&ensp;

=> /user/multiple

-> POST

EXPECTED POST BODY: {
 users: [
   ...
   {
     "ci": (string),
     "first_name": (string),
     "last_name": (string),
     "role": (string) (optional)
   }
 ]
}

ON SUCCESS: 201

ON ERROR: 400 => {"error": (string), "msg": (string)}

&emsp;

-> DELETE

EXPECTED DELETE BODY: {
 users: [
   ...
   "ci": (string)
 ]
}

ON SUCCESS: 204 => {"results": {...<ci>: (string)}}

ON ERROR: 400 => {"error": (string), "msg": (string)}
