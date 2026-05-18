import logging
import os
import azure.functions as func
from azure.data.tables import TableServiceClient, UpdateMode
from azure.core.exceptions import ResourceNotFoundError


def main(req: func.HttpRequest) -> func.HttpResponse:
    logging.info('Visitor counter function triggered.')

    connection_string = os.environ["COSMOS_CONNECTION_STRING"]
    table_service = TableServiceClient.from_connection_string(connection_string)
    table_client = table_service.get_table_client(table_name="VisitorCounter")

    try:
        entity = table_client.get_entity(partition_key="counter", row_key="visits")
        entity["count"] += 1
        table_client.update_entity(mode=UpdateMode.REPLACE, entity=entity)
    except ResourceNotFoundError:
        entity = {
            "PartitionKey": "counter",
            "RowKey": "visits",
            "count": 1
        }
        table_client.create_entity(entity=entity)

    return func.HttpResponse(
        body=str(entity["count"]),
        status_code=200,
        mimetype="text/plain"
    )