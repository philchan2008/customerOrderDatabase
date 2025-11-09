--  1. Check Queue Status and Activation
SELECT
    name AS QueueName,
    is_receive_enabled,
    is_activation_enabled,
    activation_procedure,
    create_date
FROM sys.service_queues
WHERE name = 'StockQtyUpdateTargetQueue';

--  2. Peek at Messages in the Queue
SELECT
    conversation_handle,
    message_type_name,
    message_body
FROM StockQtyUpdateTargetQueue;

--  3. Monitor Queue Health (Activation Status)
SELECT
    DB_NAME(database_id) AS DatabaseName,
    OBJECT_NAME(queue_id, database_id) AS QueueName,
    state,
    last_activated_time,
    last_empty_rowset_time
FROM sys.dm_broker_queue_monitors
WHERE OBJECT_NAME(queue_id, database_id) = 'StockQtyUpdateTargetQueue';

--  4. Check Transmission Queue for Errors
SELECT
    conversation_handle,
    to_service_name,
    transmission_status,
    message_body
FROM sys.transmission_queue
WHERE to_service_name = 'StockQtyUpdateTarget';





--  1. Check Queue Status and Activation
SELECT
    name AS QueueName,
    is_receive_enabled,
    is_activation_enabled,
    activation_procedure,
    create_date
FROM sys.service_queues
WHERE name = 'AccountBalanceUpdateTargetQueue';

--  2. Peek at Messages in the Queue
SELECT
    conversation_handle,
    message_type_name,
    message_body
FROM AccountBalanceUpdateTargetQueue;

--  3. Monitor Queue Health (Activation Status)
SELECT
    DB_NAME(database_id) AS DatabaseName,
    OBJECT_NAME(queue_id, database_id) AS QueueName,
    state,
    last_activated_time,
    last_empty_rowset_time
FROM sys.dm_broker_queue_monitors
WHERE OBJECT_NAME(queue_id, database_id) = 'AccountBalanceUpdateTargetQueue';

--  4. Check Transmission Queue for Errors
SELECT
    conversation_handle,
    to_service_name,
    transmission_status,
    message_body
FROM sys.transmission_queue
WHERE to_service_name = 'AccountBalanceUpdateTarget';

---
SELECT COUNT(*) FROM AccountBalanceUpdateTargetQueue;

SELECT activation_procedure, is_activation_enabled
FROM sys.service_queues
WHERE name = 'AccountBalanceUpdateTargetQueue';


SELECT * FROM sys.transmission_queue
WHERE to_service_name = 'AccountBalanceUpdateTarget';


DECLARE @dialogHandle UNIQUEIDENTIFIER;
BEGIN DIALOG CONVERSATION @dialogHandle
    FROM SERVICE AccountBalanceUpdateInitiator
    TO SERVICE 'AccountBalanceUpdateTarget'
    ON CONTRACT AccountBalanceUpdateContract
    WITH ENCRYPTION = OFF;

SEND ON CONVERSATION @dialogHandle
MESSAGE TYPE AccountBalanceUpdateMessage (N'<TestMessage />');

