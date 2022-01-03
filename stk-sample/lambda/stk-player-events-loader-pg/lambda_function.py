import json
import base64
import re
import boto3
import csv
import pg8000
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
#print('endpoint={},port={},user={},password={},region={},dbname={}'.format(ENDPOINT,PORT,USR,PASWD,REGION,DBNAME))
try:
  conn=pg8000.connect(
        DBNAME,
        host = ENDPOINT,
        password = PASWD
  )
  conn.autocommit=True
  print('after connecting to rds')
except Exception as e:
  print("ERROR: Could not connect to Postgres instance:"+ENDPOINT)
  print("Database connection failed due to {}".format(e)) 

def lambda_handler(event, context):
    for record in event['Records']:
        bucket=record['s3']['bucket']['name']
        key=record['s3']['object']['key']
        print('bucket='+bucket)
        print('key='+key)
        s3_object = s3_resource.Object(bucket, key)
        data = s3_object.get()['Body'].read().decode('utf-8').splitlines()
        #data = s3_object.get()['Body'].read().decode('utf-8').split(': ')[2].split(',')[0].strip()
        print('data='+str(data))
        insert_stmt=''
        lines = csv.reader(data,delimiter=' ')
        values=''
        for raw_line in lines:
            #print('raw_line='+str(raw_line))
            created_at_raw=raw_line[0].split('\"')[3].replace("T"," ").replace("Z","")
            m_ticks=raw_line[14]
            m_kart_id=raw_line[15]
            m_action=raw_line[16]
            m_value=raw_line[17]
            m_value_l=raw_line[18]
            m_value_r=raw_line[19].replace("\"","").replace("}","")
            #m_value_r=raw_line[16].split(',')[0].replace("\\n","").replace("\\","").replace("\"","")
            #created_at_raw=raw_line[16].split(',')[2].split('\"')[3].replace("\\","")
            created_at="\'"+created_at_raw+"\'"
            value='('+created_at+','+m_ticks+','+m_kart_id+','+m_action+','+m_value+','+m_value_l+','+m_value_r+')'
            if(values):
              values=values+','+value
            else:
              values=value
        print('values='+str(values)) 
        insert_stmt=(
          "INSERT INTO actions (created_at,m_ticks,m_kart_id,m_action,m_value,m_value_l,m_value_r)" 
          "VALUES"+values 
        )
    try:
        print('insert_stmt in try='+insert_stmt)
        cur = conn.cursor()
        cur.execute(insert_stmt)
        cur.close()
    except Exception as e:
        print("Database connection failed due to {}".format(e)) 
    print("about the return")
    return {
        'statusCode': 200,
        'body': json.dumps('bulk insert to stk')
    }
