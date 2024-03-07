#!/bin/bash
set -e

ingress=$1
namespace=$2
env=$3

if [[ -z "${CLOUDFLARE_TOKEN}" ]]; then
  echo CLOUDFLARE_TOKEN not defined!
  exit 1
else
  echo CLOUDFLARE_TOKEN is defined.
fi

# install jq
apt install jq -y >/dev/null

# cloudflare zone id
zone_identifier=df7cd35bc01f6eeafc0ae0c834f46308

echo "Arguments: $ingress $namespace $env "

echo "Waiting for the creation of the public IP.."
sleep 15

if [[ "$ingress" == "api-gateway"* ]]
  then
    public_ip=$(kubectl get gateway $ingress -o=go-template --template='{{(index .status.addresses 0).value}}')
    echo "ip for gateway is:"
    echo $public_ip

    #create records for api-gateway
    new_records=("backend-${namespace}.${env}.nursa.com" "nursa-api-${namespace}.${env}.nursa.com" "public-api-${namespace}.${env}.nursa.com")
    
    for new_record in ${new_records[@]}; do
      records=$(curl --request GET \
        --url https://api.cloudflare.com/client/v4/zones/$zone_identifier/dns_records?name=$new_record \
        --header "Content-Type: application/json" \
        --header "X-Auth-Key: $CLOUDFLARE_TOKEN" \
        --header "Authorization: Bearer $CLOUDFLARE_TOKEN" \
        -s \
        | jq '.result[].id'
      )

      if [ "$records" = "" ]
        then
          protocol=POST
          raw_api_path=dns_records
        else
          protocol=PUT
          raw_api_path=dns_records/$records
      fi

      api_path=$(echo $raw_api_path | tr -d '"')

      curl --request $protocol \
        --url https://api.cloudflare.com/client/v4/zones/$zone_identifier/$api_path \
        --header "Content-Type: application/json" \
        --header "X-Auth-Key: $CLOUDFLARE_TOKEN" \
        --header "Authorization: Bearer $CLOUDFLARE_TOKEN" \
        --data "{
            \"content\": \"$public_ip\",
            \"name\": \"$new_record\",
            \"proxied\": false,
            \"type\": \"A\",
            \"tags\": [
            \"created-by:dns-create-script\",
            \"namespace:$namespace\"
            ],
            \"ttl\": 3600
        }"  

      [ $protocol == "POST" ] && verb="created" || verb="updated"
      echo -e "\n\n DNS Record $verb:\n"
      echo "$new_record"
    done

  else # is this path still used?
    public_ip=$(kubectl get ingress $ingress -n $namespace -o=go-template --template='{{(index .status.loadBalancer.ingress 0 ).ip}}')
    echo "ip for ingress is:"
    echo $public_ip

    #create record for ingress
    # records=$(gcloud dns record-sets list -z "$env-nursa-com" --filter "NAME:$ingress-$namespace.$env.nursa.com")
    records=$(curl --request GET \
      --url https://api.cloudflare.com/client/v4/zones/${zone_identifier}/dns_records?name=backend.dev.nursa.com \
      --header "Content-Type: application/json" \
      --header "X-Auth-Key: ${CLOUDFLARE_TOKEN}" \
      --header "Authorization: Bearer ${CLOUDFLARE_TOKEN}" \
      -s \
      | jq '.result[].id'
    )

    if [ "$records" = "" ]
      then
        operator='create'
      else
        operator='update'
    fi
    # gcloud dns record-sets $operator "$ingress-$namespace.$env.nursa.com" --type A -z "$env-nursa-com" --rrdatas $public_ip
    echo -e "\n\n DNS Record ${operator}d:\n"
    echo "$ingress-$namespace.$env.nursa.com"
fi
