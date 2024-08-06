#DIRENV
eval "$(direnv hook bash)"

#OVH EU
#export OVH_APPLICATION_KEY="{{ ovh_application_key_eu }}"
#export OVH_APPLICATION_SECRET="{{ ovh_application_secret_eu }}"
#export OVH_CONSUMER_KEY="{{ ovh_consumer_key_eu }}"
#export OVH_ENDPOINT="{{ ovh_endpoint_eu }}"

#OVH US
#export OVH_APPLICATION_KEY="{{ ovh_application_key_us }}"
#export OVH_APPLICATION_SECRET="{{ ovh_application_secret_us }}"
#export OVH_CONSUMER_KEY="{{ ovh_consumer_key_us }}"
#export OVH_ENDPOINT="{{ ovh_endpoint_us }}"

#NETBOX
export NETBOX_ADDR="{{ netbox_addr }}"
export NETBOX_TOKEN="{{ netbox_token_rw }}"

#VAULT
export VAULT_ADDR="{{ vault_addr }}"
export VAULT_TOKEN="{{ vault_token }}"

#PDNS
export PDNS_API_KEY="{{ pdns_api_key }}"
export PDNS_SERVER="{{ pdns_server }}"

#CERTS
export REQUESTS_CA_BUNDLE="/etc/ssl/certs/ca-certificates.crt"
