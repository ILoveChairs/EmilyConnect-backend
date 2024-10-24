import json

output: str
with open("private_key.json", "r") as f:
    output = json.dumps(json.load(f))

print(output)
