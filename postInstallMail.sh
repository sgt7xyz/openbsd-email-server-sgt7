#!/usr/bin/env ksh

# Read through ALL the documentation, config files etc. before executing!
# Author: Steven Tardonia

# Install and configure a Mail Server on OpenBSD 7.5
# This configures an OpenBSD server just for email.
# Clone the repo and run the prepConfiguration.sh script and the configuration 
# files should be updated for the most part. Very little manual configuration should be needed. 

####################################################
#Update Packages
pkg_add -u

echo '#########################################################'
echo '################ Begin Software Install #################'
echo '#########################################################'

# Add additional sofware. This is based upon personal preference.

# Install zsh
pkg_add zsh

# Install Unzip
pkg_add unzip

# Install OpenSMTP Extras, Redis, rspamd, and Dovecot, 
pkg_add opensmtpd-extras opensmtpd-filter-rspamd redis rspamd-3.8.4 dovecot-2.3.21v0 dovecot-pigeonhole-0.5.21v1

echo '#########################################################'
echo '################# Begin setup of email ##################'
echo '#########################################################'
sleep 2

echo '######## Creating Public/Private Keys for DKIM And Setting Permissions ########'
sleep 2
mkdir /etc/mail/dkim
openssl genrsa -out "/etc/mail/dkim/DOMAIN-NAME.key" 1024
openssl rsa -in "/etc/mail/dkim/DOMAIN-NAME.key" -pubout -out /etc/mail/dkim/DOMAIN-NAME.pub""
chmod 0440 /etc/mail/dkim/DOMAIN-NAME.key
chmod 0400 /etc/mail/dkim/DOMAIN-NAME.pub
chown root:_rspamd /etc/mail/dkim/DOMAIN-NAME.key

# Use the dkim.txt to create the follwing record. I like to use the date of creation as the selector e.g.
# 20210131._domainkey.example.com.	IN TXT
# v=DKIM1;k=rsa;p=your public key here
# e.g. 20210131._domainkey.example.com. IN TXT "v=DKIM1;k=rsa;p=MIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQDDeM5OB34vhU1HNRpFGKymLvKJ
# 0beROiopOT8onk68fROm2Z71yRQ0sgE9NRSOXcLP7/uKWmgXJT6TbbAHt44AS46sm
# odyxe0lvlMToN+CykiWEdtotmugPHZQzO8hPx9L3bU2ZCs08j+jn6CUm4RQQUHdf
# hV0xb9QjAgcAxYfukQIDAQAB;"

# Capture Public Key for DKIM DNS Record
cat "/etc/mail/dkim/DOMAIN-NAME.pub" > ~/dkim.txt

echo '######## Creating dkim_signing.conf'
echo 'Make sure this file has been edited for your domain.'
sleep 2
cp rspamd/dkim_signing.conf /etc/rspamd/local.d/dkim_signing.conf

echo '######## Begin Configuring OpenSMTPD ########'
sleep 2
echo '######## Creating Public/Private Keys for OpenSMTPD And Setting Permissions ########'
# There are numerous ways to secure OpenSMTPD with TLS. Everything from self signed certs to Let's Encrypt
# I use Cloudflare
# echo 'Copying Public/Private Keys for OpenSMTPD Email Encryption And Setting Permissions'
# cp ssl/DOMAIN-NAME.pub /etc/ssl/DOMAIN-NAME.pub
# cp ssl/private/DOMAIN-NAME.key /etc/ssl/private/DOMAIN-NAME.key
# chmod 0400 /etc/ssl/*.pub
# chmod 0400 /etc/ssl/private/*.key

# If you use Cloudflare like me obviously comment out the next four lines.
openssl genrsa -out /etc/ssl/private/DOMAIN-NAME.key 4096
openssl req -x509 -new -nodes -key /etc/ssl/private/DOMAIN-NAME.key -out /etc/ssl/DOMAIN-NAME.pub -days 3650 -sha256
chmod 0400 /etc/ssl/DOMAIN-NAME.pub
chmod 0400 /etc/ssl/private/DOMAIN-NAME.key
sleep 2

# Backup the smtpd.conf file and copy new configuration to /etc/mail
cp -p /etc/mail/smtpd.conf /etc/mail/smtpd.conf.original
cp mail/smtpd.conf /etc/mail/smtpd.conf

#Create the secrets file. Obviously change the example passwords before running
cp mail/secrets /etc/mail/secrets

# Set passwords for vmail accounts.
# Obviously you don't want these default passwords 
smtpctl encrypt 1734923456 >> /etc/mail/secrets
smtpctl encrypt 1234789456 >> /etc/mail/secrets
smtpctl encrypt 1234562853 >> /etc/mail/secrets
smtpctl encrypt 1285323456 >> /etc/mail/secrets

echo '######## Created Secrets File########'
echo 'Edit your your secrets file accordingly'
echo 'Replacing the  $examplePassword fields with the appropriate secret respectively'
echo 'and editing the appropriate fields for your domain name'
sleep 2
cat /etc/mail/secrets
chown _smtpd:_dovecot /etc/mail/secrets
chmod 0440 /etc/mail/secrets
echo 'Ensure you delete encrypted strings you do not use!'
echo 'Otherwise you will not be able to send email!'
sleep 2

echo '######## Creating Virtual Mail Account and Setting Security ########'
sleep 2
useradd -c "Virtual Mail Account" -d /var/vmail -s /sbin/nologin -u 2000 -g =uid -L staff vmail
mkdir /var/vmail
chown vmail:vmail /var/vmail
chmod -R 0700 /var/vmail

echo '######## Creating The Virutal User Mapping ########'
echo 'Make sure you edited the virtuals file accordingly for your domain'
echo 'under /etc/mail/virtuals'
sleep 2
cp mail/virtuals /etc/mail/virtuals

echo '######## Testing OpenSMTPD Server Configuration ########'
smtpd -n
sleep 5

echo '######## Begin Configuring Dovecot ########'
sleep 2
# Back up original login.conf file
cp /etc/login.conf /etc/login.conf.original

echo '######## Modifying the local.conf file for your server ########'
echo '' >> /etc/login.conf
echo 'dovecot:\' >> /etc/login.conf
echo '        :openfiles-cur=1024:\' >> /etc/login.conf
echo '        :openfiles-max=2048:\' >> /etc/login.conf
echo '        :tc=daemon:' >> /etc/login.conf
echo '' >> /etc/login.conf
sleep 2

echo '######## Configuring Dovecot IMAP ########'
cp -f dovecot/local.conf /etc/dovecot
cp -f dovecot/report-ham.sieve /usr/local/lib/dovecot/sieve
cp -f dovecot/report-spam.sieve /usr/local/lib/dovecot/sieve
cp -f dovecot/sa-learn-ham.sh /usr/local/lib/dovecot/sieve
cp -f dovecot/sa-learn-spam.sh /usr/local/lib/dovecot/sieve
cp -f dovecot/10-ssl.conf /etc/dovecot/conf.d/10-ssl.conf

sievec /usr/local/lib/dovecot/sieve/report-ham.sieve
sievec /usr/local/lib/dovecot/sieve/report-spam.sieve

chmod 0755 /usr/local/lib/dovecot/sieve/sa-learn-ham.sh

chmod 0755 /usr/local/lib/dovecot/sieve/sa-learn-spam.sh

echo '######## Enabling OpenSMTPD Redis and Rspamd ########'
rcctl enable smtpd dovecot redis rspamd

echo 'After modifying your secrets file run restartmail.sh'
