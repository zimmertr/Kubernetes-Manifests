#!/bin/sh

HTTP_STATUS_CODE=$(curl -s -o /dev/null -w "%{http_code}" -H "$HEADER" "$ENDPOINT")

if [ "$HTTP_STATUS_CODE" -eq 200 ]; then
  echo "HTTP Status Code: $HTTP_STATUS_CODE - Success"
  exit 0
else
  echo "HTTP Status Code: $HTTP_STATUS_CODE - Failure"
  exit 1
fi
