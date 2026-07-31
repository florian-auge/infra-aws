import boto3
import os
import time

rds = boto3.client('rds')
db_instance_id = os.environ['DB_INSTANCE_ID']

def lambda_handler(event, context):
    """
    Déclenché par un event EventBridge quand RDS redémarre automatiquement.
    Attend que l'instance soit 'available', puis la stoppe.
    """
    while True:
        response = rds.describe_db_instances(DBInstanceIdentifier=db_instance_id)
        status = response['DBInstances'][0]['DBInstanceStatus']

        if status == 'available':
            break

        time.sleep(15)

    rds.stop_db_instance(DBInstanceIdentifier=db_instance_id)

    return {
        'statusCode': 200,
        'body': f'Instance {db_instance_id} stoppée après redémarrage automatique'
    }