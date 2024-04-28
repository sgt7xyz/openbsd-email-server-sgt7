#!/usr/bin/env ksh

# This preps the scripts and configuration files for your domain name.
# Simply run this script with your new domain name as an argument

# Check if domain name is provided
if [ "$#" -ne 1 ]; then
    echo "Usage: $0 new-domain-name"
    exit 1
fi

newDomainName=$1

# Use sed to replace 'DOMAIN-NAME' with the new domain name
#LC_ALL=C find . -type f -not -name 'prepConfiguration.sh' -exec sed -i '' "s/DOMAIN-NAME/${newDomainName}/g" {} \;

LC_ALL=C find . -type f -not -name 'prepConfiguration.sh' -exec sed "s/DOMAIN-NAME/${newDomainName}/g" {} > tmpfile \; -exec mv tmpfile {} \;
