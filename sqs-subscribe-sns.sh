#!/bin/sh

# SETUP

queue_arn=$(awslocal sqs create-queue --queue-name test_queue --output text)

echo "Queue ARN: $queue_arn"

topic_arn=$(awslocal sns create-topic --name test_topic --output text)

echo "Topic ARN: $topic_arn"

subscription_arn=$(awslocal sns subscribe \
    --topic-arn "$topic_arn" \
    --protocol sqs \
    --notification-endpoint "$queue_arn" \
    --output text)

echo "Subscription ARN: $subscription_arn" 

awslocal sns set-subscription-attributes \
    --subscription-arn "$subscription_arn" \
    --attribute-name FilterPolicy \
    --attribute-value "{ \"EVENT_TYPE\": [\"SUCCESS\"] }"

# TEST

awslocal sns publish \
    --topic-arn "$topic_arn" \
    --message "SUCCESS PAYLOAD (SHOULD GO TO THE QUEUE)" \
    --message-attributes '{"EVENT_TYPE" : { "DataType":"String", "StringValue":"SUCCESS"}}'

awslocal sns publish \
    --topic-arn "$topic_arn" \
    --message "ERROR PAYLOAD (SHOULD NOT GO TO THE QUEUE)" \
    --message-attributes '{"EVENT_TYPE" : { "DataType":"String", "StringValue":"ERROR"}}'


awslocal sqs get-queue-attributes \
	--queue-url http://localhost:4576/queue/test_queue \
	--attribute-names All







