# ---
# Sample 1: Hello World
# ---

# --> Let's run some simple queries in DBeaver!


# ---
# Sample 2: Covid19 vaccine dataset
# ---
# see: https://quickstarts.snowflake.com/guide/data_science_with_dataiku/index.html

# create stage, upload data to stage
snow sql -c local --query 'CREATE STAGE s1'
snow sql -c local --query 'PUT file:///tmp/cdc-moderna-covid-19-vaccine.csv @s1/test'
# list files in stage bucket
awslocal s3 ls s3://snowflake-assets/uploads/NAMED/s1/
# copy data in CSV file from stage into table
snow_sql.sh 'CREATE TABLE covid19(jurisdiction text, week timestamp, dose1_allocations int, dose2_allocations int)'
snow_sql.sh 'COPY INTO covid19 FROM @s1/test FILE_FORMAT(TYPE=CSV SKIP_HEADER=TRUE)'
# run some SELECT queries on the data
snow_sql.sh 'SELECT * FROM covid19 LIMIT 10'
snow_sql.sh 'SELECT jurisdiction, sum(dose1_allocations) as vaccinations FROM covid19 group by jurisdiction ORDER BY vaccinations DESC'


# ---
# Sample 3: NYC Citibike data
# ---
# https://quickstarts.snowflake.com/guide/getting_started_with_snowflake/#2
# https://github.com/Snowflake-Labs/sfguide-data-apps-demo
# make sure to start LocalStack Snowflake with: DNS_NAME_PATTERNS_TO_RESOLVE_UPSTREAM=demo-citibike-data.s3.amazonaws.com

cd ../../localstack-samples/sfguide-data-apps-demo/
# list the files in the public S3 bucket
aws s3 ls s3://demo-citibike-data/ --no-sign-request
# `make seed` - see: https://quickstarts.snowflake.com/guide/data_app/index.html#3
snow_sql.sh "create stage demo_data url='s3://demo-citibike-data'"
# create 'trips' table and import data from public CSV files
snow_sql.sh 'create or replace table trips(tripduration integer,starttime timestamp,stoptime timestamp,start_station_id integer,end_station_id integer,bikeid integer,usertype string,birth_year integer,gender integer);'
snow_sql.sh 'copy into trips from @demo_data file_format=(type=csv skip_header=1) PATTERN = '"'"'trips__0_0_0.*csv.*'"'"
# create 'weather' table and import data from public CSV files
snow_sql.sh 'create or replace table weather(STATE TEXT,OBSERVATION_DATE DATE,DAY_OF_YEAR NUMBER,TEMP_MIN_F NUMBER,TEMP_MAX_F NUMBER,TEMP_AVG_F NUMBER,TEMP_MIN_C FLOAT,TEMP_MAX_C FLOAT,TEMP_AVG_C FLOAT,TOT_PRECIP_IN NUMBER,TOT_SNOWFALL_IN NUMBER,TOT_SNOWDEPTH_IN NUMBER,TOT_PRECIP_MM NUMBER,TOT_SNOWFALL_MM NUMBER,TOT_SNOWDEPTH_MM NUMBER);'
snow_sql.sh 'copy into weather from @demo_data file_format=(type=csv skip_header=1) PATTERN = '"'"'weather__0_2_0.*csv.*'"'"

# start Web UI
make start
# --> open http://localhost:3000 in browser


# ---
# Sample 4: Table Streams
# ---

# --> see DBeaver

# ---
# Sample 5: Cloud Pods
# ---

localstack pod load pod-snowflake
snow_sql.sh 'select * from test'

# ---
# Sample 6: Simple Streamlit App
# ---

cd ../../tmp/localstack-snowflake-samples/streamlit-snowpark-dynamic-filters

