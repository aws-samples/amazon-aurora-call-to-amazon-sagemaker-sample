# Amazon Aurora and Amazon ML Services Sample

This is sample demonstrates a tool that helps organizations to easily access ML services deployed on Amazon SageMaker or Amazon Comprehend. In this sample we use multiple sources such as customer care, order system, financial systems to train, deploy a model and use it to predict business outcomes. Each source may need a different algorithm, e.g. linear regression for classified data, anomaly detection for unclassified data and we’d want to reconcile them. Gaming is an example of multiple data sources.

## The cheating problem in gaming
The game industry generated an estimated $174B worldwide in 2019 (IDC). Player churn grows as cheating grows 60% of online games were negatively impacted by cheaters. 77% of players would stop playing a multiplayer game if they thought opponents were cheating (Irdeto). Similar issues may exist in other industries. 

In this session, we’ll look at 3 types of cheat detection: transaction fraud, authentication, and player moves. Players' transaction data and auth are managed by customer care. Both data sources are already tagged by reps. So this is a good candidate for supervised learning. On the other hand, players' moves are logged in a big data system that has no easy way to classify, so we use unsupervised learning for moves classification.


### The business problem
Before we look at the models we trained and the db schema, let’s review the example business problem: 

* We built a massively multiplayer online (MMO) game called EmuStar One that enables players to fight, build, explore and trade goods with other. 

* Players authenticating from a supported clients e.g., PC, Console etc

        * Emulants are defined by five personality traits and game events.
        
        * Emulants can move, forge, dodge etc
        
        * Emulants can transact virtual goods 


* What does cheating look like in the data?

  * Players can cheat as they make illegal trades or running bots that manipulate other game moves on behalf of other players. Cheat can manifest in various ways. For example, consecutive failed login attempts from two different sources at once. Or a micro-transaction that was tagged as fraud by other players. Finally, players move anomalies e.g., player walk and shoot at the opposite direction while performing other tasks. 
  
 * How we stop cheating in our game?
 We formed an anti-cheat team that takes actions against cheater players. e.g., force logout with hard captcha as a warning with proper messaging. 
 
 * When we found something suspicious, we escalate the actions as needed. However, cheaters learn the system behavior. In the case of false-positive, legitimate players that perform well in the game are impacted by the anti-cheating, causing further frustration to the legitimate players.
 
 * The team needs to have tools to operate the anti-cheat scenario

#### The Game Data Schema
Lets look at the game data:

```json
Player move:
{
  timestamp:"2020-05-08 09:29:51",
  playerGuid:"463ca444-cdd8-4b64-b6c9-9ddc0de78854",
  playerX:199.0827,
  playerZ:49.08284,
  quadrant:"Quadrant 3",
  sector:"Sector 0,-2",
  event:"TraverseSector",
}

Player transaction:
{
  timestamp:"2020-05-29 19:39:38",
  playerGuid:"821f2ac8-5206-44e4-8450-79ab5448cef1",
  type:"LootBoxesType2",
  user-agent:"Mozilla/5.0 (compatible; MSIE 10.0; Windows NT 6.1; Trident/5.0; Xbox)"
}

Player authentication:
{
  timestamp:"2020-05-29 19:39:38",
  method:"Xbox-live-token",
  playerGuid:"821f2ac8-5206-44e4-8450-79ab5448cef1",
  user-agent:"Mozilla/5.0 (compatible; MSIE 10.0; Windows NT 6.1; Trident/5.0; Xbox)",
  source-ip:"208.249.139.4",
  geo-location:"us-west-2",
  cidr:"208.249.139/24"
}
```

* We choose ultimate algorithm for each data set.

  * For authentication we used  IP Insights. An unsupervised learning algorithm for detecting anomalous behavior and usage patterns of IP addresses.

https://aws.amazon.com/blogs/machine-learning/detect-suspicious-ip-addresses-with-the-amazon-sagemaker-ip-insights-algorithm/

  * For player transactions we use supervised  linear regression algorithm because most of the transactions are already classified by the customer care and surveys.

https://docs.aws.amazon.com/solutions/latest/fraud-detection-using-machine-learning/components.html

  * For player moves we use Random Cut Forest (RCF) Algorithm because we assume most of the player moves are legit and anomalous indicates on potential cheat. 

https://docs.aws.amazon.com/sagemaker/latest/dg/randomcutforest.html

#### Data Preparation

We run a simulation that generated a total of legit and non-legit events:

    * 65326500 player moves
    * 1358980 player transactions
    * 769298 player authentications

Between 0.1%-3% of each data set was meant to be non-legitimate move, transaction or authentication 

Let’s look at how we built those models:
We used Jupyter notebooks hosted by SageMaker. S3 to store the training data and the model. We also hosted inference endpoints on SageMaker and integrated the Aurora database with SageMaker. 

While we are not going to review each notebook we highlight the common practice of the data preparation in both the notebook and the database. 


* In general, ML models likes number, integers doubles or floats. Therefore we needed to take all the String attributes and encode them. We also need to apply the same on the Aurora side.

For example we transformed 

* Player move event such as TraverseSector or Travel.Explore. 
   
* Player move Sector attribute, the game engine generates String values like `Sector 0,-2` 

* Player move quadrant attribute, he game engine generates String values like `Quadrant 3`

In the Jupyter notebooks we used `OneHotEncoder` e.g.,

```python
*import* *csv*
*import* *sys*
*import* *pandas* *as* *pd*
*from* *sklearn**.**preprocessing* *import* OneHotEncoder
*from* *sklearn**.**preprocessing* *import* LabelEncoder

label_encoder = LabelEncoder()
integer_quadrant_encoded = label_encoder.fit_transform(player_data.quadrant)
player_data["quadrant_encoded"]=integer_quadrant_encoded

integer_sector_encoded = label_encoder.fit_transform(player_data.sector)
player_data["sector_encoded"]=integer_sector_encoded

integer_event_encoded = label_encoder.fit_transform(player_data.event)
player_data["event_encoded"]=integer_event_encoded
```

Instead of using libraries like *sklearn* we used the following for encoding event name:

```sql
DECLARE enc_cursor
          CURSOR FOR
                 SELECT distinct eventName FROM encounters;
  DECLARE CONTINUE HANDLER
  ...
  OPEN enc_cursor;

  get_encounter: LOOP
       FETCH enc_cursor INTO c_eventName;
       IF finished =1 THEN
         LEAVE getEncounter;
       END IF;
       select encoded_event+1 into encoded_event;
       update encounters set encoded_event=encoded_event where eventName=c_eventName;
  END LOOP get_encounter;
  CLOSE enc_cursor;
  ...
  ```
  
  Our team maintains three materialized views. Each for data source. Let’s see what the data would look like in our MySQL database, and how we use SQL queries to find who is cheating.We start by validating the daily, hourly materialized views of transactions(`trs_cheat_mv`), moves(`move_cheat_mv`) and authentication (`auth_cheat_mv`). Lets look at how it’s being created:
  
```sql
CREATE table auth_cheat_mv AS
SELECT t.timestamp,
        t.playerGuid
FROM 
    (SELECT timestamp,
        playerGuid,
        auth_cheat_score(uagent,
        day,
        month,
        hour,
        minute,
        src_ip_encoded) cls
    FROM auth) AS t
WHERE cls>0;

CREATE table trs_cheat_mv AS
SELECT t.timestamp,
        t.playerGuid
FROM 
    (SELECT playerGuid,
        timestamp,
        trans_cheat_score(month,
        day,
        hour,
        minute,
        name_encoded,
        uagent) cls
    FROM transactions t) AS t
WHERE cls>0;

CREATE table move_cheat_mv AS
SELECT t.timestamp,
        t.playerGuid
FROM 
    (SELECT timestamp,
        playerGuid,
        move_cheat_score(playerX,
        playerZ,
        quadrant,
        sector,
        event) cls
    FROM dist_player_moves) AS t
WHERE cls>2;
```

Let’s look for suspicious transactions and authentications. We figure anomaly score greater than 2 indicates a suspicious move. Lets assume the data freshness is an hour. The following query returns players and timestamp that executed suspicious transactions according to the model (i.e. in `trs_cheat_mv`) with relation to suspicious authentication activities (i.e., in `auth_cheat_mv`) 

```sql
mysql> select distinct t.timestamp,t.playerGuid from (select playerGuid,timestamp,trans_cheat_score(month,day,hour,minute,name_encoded,uagent) cls from transactions t) as t where cls>0 and DATE(timestamp) between '2020-05-15' and '2020-05-18';
+---------------------+--------------------------------------+
| timestamp | playerGuid |
+---------------------+--------------------------------------+
| 2020-05-16 15:38:32 | 46fb2825-dd04-443e-9357-d6418b390c26 |
| 2020-05-15 16:59:13 | e474dfa0-f269-41cc-83e4-43315110f375 |
| 2020-05-16 03:32:56 | 20a74aa3-eff2-4d9a-b9c7-a122d661c5c3 |
| 2020-05-15 03:09:02 | 3cbbfebe-e474-4866-b0d6-d62a93fb7a1e |
| 2020-05-16 06:15:14 | 3cbbfebe-e474-4866-b0d6-d62a93fb7a1e |
| 2020-05-18 04:45:01 | 5c3d087a-e823-48c7-8a9b-4eea94772659 |
| 2020-05-18 00:26:49 | 52e5ec16-d5e2-4dee-a078-1464f52c7c48 |
| 2020-05-15 03:23:29 | d5959f4e-4576-4e82-911d-a7656691b3f9 |
| 2020-05-15 07:02:47 | cdda0082-2934-4dca-b00f-0fbc32a2025e |
| 2020-05-16 23:22:45 | cdda0082-2934-4dca-b00f-0fbc32a2025e |
| 2020-05-18 21:52:19 | 6c497f82-dc2c-4c8f-aeb8-b2d1a49199aa |
| 2020-05-18 07:48:23 | a3186242-9cdb-4686-8b3a-c7a22eb192de |
| 2020-05-17 11:15:26 | 12d84e0a-15a3-49f3-a90e-d329a7e30661 |
+---------------------+--------------------------------------+
13 rows in set (9.12 sec)
```

Now lets look at the this from authentication perspectives:

```sql
mysql> select auth_cheat_mv.timestamp, trs_cheat_mv.* from trs_cheat_mv, auth_cheat_mv where trs_cheat_mv.playerGuid=auth_cheat_mv.playerGuid and auth_cheat_mv.timestamp<trs_cheat_mv.timestamp and DATE(trs_cheat_mv.timestamp) between '2020-05-15' and '2020-05-18';
+---------------------+---------------------+--------------------------------------+
| timestamp | timestamp | playerGuid |
+---------------------+---------------------+--------------------------------------+
| 2020-05-15 06:37:32 | 2020-05-15 07:02:47 | cdda0082-2934-4dca-b00f-0fbc32a2025e |
| 2020-05-15 06:37:32 | 2020-05-16 23:22:45 | cdda0082-2934-4dca-b00f-0fbc32a2025e |
| 2020-05-16 16:37:32 | 2020-05-16 23:22:45 | cdda0082-2934-4dca-b00f-0fbc32a2025e |
+---------------------+---------------------+--------------------------------------+
3 rows in set (0.00 sec)
```

We see the same player login to the system before the suspicious transaction. Let’s see if the player’s move as suspicious too.

```sql
mysql> select distinct timestamp,playerGuid from (select timestamp,playerGuid,playerX,playerZ,quadrant,sector,event,move_cheat_score(playerX,playerZ,quadrant,sector,event) cls from dist_player_moves where DATE(timestamp) between '2020-05-15' and '2020-05-18') as t where cls>2;
+---------------------+--------------------------------------+
| timestamp | playerGuid |
+---------------------+--------------------------------------+
| 2020-05-15 07:08:25 | cdda0082-2934-4dca-b00f-0fbc32a2025e |
| 2020-05-16 02:20:30 | 7695a00b-ef68-4890-befd-e535eab7c925 |
| 2020-05-17 11:02:40 | 12d84e0a-15a3-49f3-a90e-d329a7e30661 |
| 2020-05-17 15:32:47 | 3d143db5-6d5d-4d4c-b328-97a9fe49cb76 |
| 2020-05-18 00:41:46 | aee05e11-676a-4b00-82df-0fea59fbaed9 |
| 2020-05-18 14:15:32 | 2b3292d1-aa5a-4912-981c-aebdf905cc9f |
+---------------------+--------------------------------------+
6 rows in set (13.28 sec)
```

Here we see two suspicious moves, two was made by the suspicious transactions but only one was marked as suspicious auth. Lets see what special in those moves.

```sql
mysql> select distinct timestamp,playerGuid,quadrant,sector from (select timestamp,playerGuid,playerX,playerZ,quadrant,sector,event,move_cheat_score(playerX,playerZ,quadrant,sector,event) cls from dist_player_moves where DATE(timestamp) between '2020-05-15' and '2020-05-18') as t where cls>2;
+---------------------+--------------------------------------+----------+--------+
| timestamp | playerGuid | quadrant | sector |
+---------------------+--------------------------------------+----------+--------+
| 2020-05-15 07:08:25 | cdda0082-2934-4dca-b00f-0fbc32a2025e | 3 | 35 |
| 2020-05-16 02:20:30 | 7695a00b-ef68-4890-befd-e535eab7c925 | 3 | 35 |
| 2020-05-17 11:02:40 | 12d84e0a-15a3-49f3-a90e-d329a7e30661 | 3 | 35 |
| 2020-05-17 15:32:47 | 3d143db5-6d5d-4d4c-b328-97a9fe49cb76 | 3 | 35 |
| 2020-05-18 00:41:46 | aee05e11-676a-4b00-82df-0fea59fbaed9 | 3 | 35 |
| 2020-05-18 14:15:32 | 2b3292d1-aa5a-4912-981c-aebdf905cc9f | 3 | 35 |
+---------------------+--------------------------------------+----------+--------+
6 rows in set (12.82 sec)
```

#### Behind the scenes: how does Aurora optimize ML query processing?

Overview of Aurora ML query processing. Explain the diagram of Aurora ML batching (uses an Amazon Comprehend sentiment analysis example). Aurora ML optimizes the number of request made to the model. Let’s look at an example:

We first resets the counters for key caches:

```sql
mysql> flush status;
Query OK, 0 rows affected (0.00 sec)

mysql> show global status like '%aurora_ml%';
+--------------------------------+-------+
| Variable_name | Value |
+--------------------------------+-------+
| Aurora_ml_actual_request_cnt | 0 |
| Aurora_ml_actual_response_cnt | 0 |
| Aurora_ml_cache_hit_cnt | 0 |
| Aurora_ml_logical_request_cnt | 0 |
| Aurora_ml_logical_response_cnt | 0 |
| Aurora_ml_retry_request_cnt | 0 |
| Aurora_ml_single_request_cnt | 0 |
+--------------------------------+-------+
7 rows in set (0.00 sec)

mysql> select t.playerGuid from (select playerGuid, trans_cheat_score(month,day,hour,minute,name_encoded,uagent) cls from transactions t) as t where cls>0;
....
| 1f310857-8fdd-4870-9c7d-ef62cc2bdd70 |
| e123d51c-edd4-442b-a420-731a593cc75a |
+--------------------------------------+
1750 rows in set (8.90 sec)

mysql> show global status like '%aurora_ml%';
+--------------------------------+---------+
| Variable_name | Value |
+--------------------------------+---------+
| Aurora_ml_actual_request_cnt | 1351 |
| Aurora_ml_actual_response_cnt | 1351 |
| Aurora_ml_cache_hit_cnt | 1229584 |
| Aurora_ml_logical_request_cnt | 1358980 |
| Aurora_ml_logical_response_cnt | 129396 |
| Aurora_ml_retry_request_cnt | 0 |
| Aurora_ml_single_request_cnt | 0 |
+--------------------------------+---------+
7 rows in set (0.00 sec)
```

As you can see transactions table have about 1.3M records and 1.2M out if 1.3M records hit the cache (no sagemaker calls for these rows) and 1349 actual requests were made.

  








