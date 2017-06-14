#!/usr/bin/env bash

function usage {
    programName=$0
    echo "description: use this program to post messages to Slack channel"
    echo "usage: $programName [-t \"hex color or color keyword\"] [-b \"message body\"] [-c \"mychannel\"] [-n \"user name\"] [-u \"slack url\"]"
    echo "    -t    the color of the message (good or danger)"
    echo "    -b    The message body"
    echo "    -c    The channel you are posting to"
    echo "    -n    The user name post under"
    echo "    -u    The slack hook url to post to"
    exit 1
}

while getopts ":t:b:c:u:n:h" opt; do
  case ${opt} in
    t) color="$OPTARG"
    ;;
    u) slackUrl="$OPTARG"
    ;;
    b) msgBody="$OPTARG"
    ;;
    n) userName="$OPTARG"
    ;;
    c) channelName="$OPTARG"
    ;;
    h) usage
    ;;
    \?) echo "Invalid option -$OPTARG" >&2
    ;;
  esac
done

if [[ ! "${color}" ||  ! "${slackUrl}" || ! "${msgBody}" || ! "${channelName}" || ! "${userName}" ]]; then
    echo "all arguments are required"
    usage
fi

read -d '' payLoad << EOF
{
        "channel": "#${channelName}",
        "username": "${userName}",
        "attachments": [
            {
                "color": "${color}",
                "fields": [{
                    "value": "${msgBody}",
                    "short": false
                }]
            }
        ]
    }
EOF


statusCode=$(curl \
        --write-out %{http_code} \
        --silent \
        --output /dev/null \
        -X POST \
        -H 'Content-type: application/json' \
        --data "${payLoad}" ${slackUrl})

echo ${statusCode}
