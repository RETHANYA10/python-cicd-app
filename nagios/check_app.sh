#!/bin/bash

URL="http://python-app-service/health"

STATUS=$(curl -s -o /dev/null -w "%{http_code}" $URL)

if [ "$STATUS" -eq 200 ]; then
  echo "OK - Application is healthy"
  exit 0
else
  echo "CRITICAL - Application is down"
  exit 2
fi
