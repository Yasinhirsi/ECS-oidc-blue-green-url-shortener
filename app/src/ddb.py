import os, boto3

# TABLE_NAME must be provided via ECS task environment
_table = boto3.resource("dynamodb").Table(os.environ["TABLE_NAME"])

def put_mapping(short_id: str, url: str):
    _table.put_item(Item={"id": short_id, "url": url})

def get_mapping(short_id: str):
    resp = _table.get_item(Key={"id": short_id})
    return resp.get("Item")
