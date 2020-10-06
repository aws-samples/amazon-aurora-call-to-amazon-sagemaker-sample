import json
import boto3
import csv
import mysql.connector
import sys
import os

ENDPOINT=os.environ['ENDPOINT']
PORT=os.environ['PORT']
USR=os.environ['USR']
PASWD=os.environ['PASWD']
REGION=os.environ['REGION']
DBNAME=os.environ['DBNAME']
os.environ['LIBMYSQL_ENABLE_CLEARTEXT_PLUGIN'] = '1'

client = boto3.client('rds')

s3_resource = boto3.resource('s3')

def lambda_handler(event, context):
    for record in event['Records']:
        bucket=record['s3']['bucket']['name']
        key=record['s3']['object']['key']
        print('bucket='+bucket)
        print('key='+key)
        s3_object = s3_resource.Object(bucket, key)
        data = s3_object.get()['Body'].read().decode('utf-8').splitlines()
        lines = csv.reader(data,delimiter=' ')
        values=''
        for line in lines:
            m_ticks=line[0]
            m_kart_id=line[1]
            m_action=line[2]
            m_value=line[3]
            m_value_l=line[4]
            m_value_r=line[5]
            value='('+m_ticks+','+m_kart_id+','+m_action+','+m_value+','+m_value_l+','+m_value_r+')'
            if(values):
              values=values+','+value
            else:
              values=value
 
        insert_stmt=(
          "INSERT INTO actions (m_ticks,m_kart_id,m_action,m_value,m_value_l,m_value_r)" 
          "VALUES"+values 
        )
    try:
        conn =  mysql.connector.connect(host=ENDPOINT, user=USR, passwd=PASWD, port=PORT, database=DBNAME)
        cur = conn.cursor()
        #cur.execute("""SELECT now()""")
        print(insert_stmt)
        cur.execute(insert_stmt)
        conn.commit()
    except Exception as e:
        print("Database connection failed due to {}".format(e)) 
        conn.rollback()
    return {
        'statusCode': 200,
        'body': json.dumps('bulk insert to stk')
    }
