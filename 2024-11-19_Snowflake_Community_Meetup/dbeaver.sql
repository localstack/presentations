-- 1. verify that the objects are created correctly from init hook
SELECT * FROM DB_MEETUP.S_MEETUP.T_MEETUP;

-- 2. Clone the table
CREATE TABLE DB_MEETUP.S_MEETUP.T_MEETUP_CLONE CLONE DB_MEETUP.S_MEETUP.T_MEETUP;

-- 3. Verify if the table is successfully cloned
SELECT * FROM DB_MEETUP.S_MEETUP.T_MEETUP_CLONE;

-- 4. Create file format
CREATE FILE FORMAT test_format TYPE = CSV;

-- 5. Create storage integration
CREATE STORAGE INTEGRATION test_storage TYPE=EXTERNAL_STAGE ENABLED=TRUE
STORAGE_PROVIDER='S3'
STORAGE_AWS_ROLE_ARN='arn:aws:iam::000000000000:role/s3-role'
STORAGE_ALLOWED_LOCATIONS=('s3://test-bucket');

-- 6. Create stage with storage integration and file format
CREATE STAGE test_stage STORAGE_INTEGRATION=test_storage FILE_FORMAT=test_format;

-- 7. Verify if the stage was created successfully
DESCRIBE STAGE "test_stage";

-- 8. Create tag
CREATE TAG i_like_tags;

-- 9. Show tags
SHOW TAGS;

-- create bucket
-- 10. create external volume which is used to define the location of the files
-- that Snowflake will use to store the table data
CREATE OR REPLACE EXTERNAL VOLUME test_volume
    STORAGE_LOCATIONS = (
    (
        NAME = 'aws-s3-test'
        STORAGE_PROVIDER = 'S3'
        STORAGE_BASE_URL = 's3://test-bucket/'
        STORAGE_AWS_ROLE_ARN = 'arn:aws:iam::000000000000:role/s3-role'
        ENCRYPTION=(TYPE='AWS_SSE_S3')
    )
);


-- 11. Create Iceberg table
CREATE ICEBERG TABLE test_table (c1 TEXT)
CATALOG='SNOWFLAKE', EXTERNAL_VOLUME='test_volume', BASE_LOCATION='test';

-- 12. Insert data to Iceberg table
INSERT INTO test_table(c1) VALUES ('test'), ('foobar');

-- 13. Select from Iceberg table
SELECT * FROM test_table;
