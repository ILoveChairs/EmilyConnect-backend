# Documentation

This repo is for the backend of emily connect

## ENDPOINTS:
POST /
login endpoint
=> {ci: <str>, password: <str>}
<= (200) {token: <str>}

POST /user/create/
create a user without restriction (dev only)
=> {ci: <str>, password: <str>}
<= (201)

POST /user/create/multiple
create multiple users without restriction (dev only)
=> {users = [..{ci: <str>, password: <str>}]}
<= (201)

