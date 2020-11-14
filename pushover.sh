#!/bin/bash

# Script path necessary for proper file mapping
SCRIPTPATH="$( cd "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"

source ${SCRIPTPATH}/settings

function curlPushover() {
curl -s \
	--form-string "token=${varToken}" \
	--form-string "user=${varUser}" \
	--form-string "title=${varTitle}" \
	--form-string "message=${varMessage}" \
	--form-string "url=${varURL}" \
	--form-string "url_title=${varURLTitle}" \
	https://api.pushover.net/1/messages.json
}
