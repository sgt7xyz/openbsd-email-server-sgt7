![Image of Puffy](images/puflogv200X130.gif)

# DIY Email Server

#### Create a new VM in a cloud provider that supports OpenBSD. I use Vultr. Here is an [affiliate link](https://www.vultr.com/?ref=7126277git pulkl) if you want to help me out a little. ;-)

<br>

#### I named mine mail01 in the event I want to add additional servers. Simply clone this repo over to the root directory of a new install of OpenBSD 6.8, modify the follwing files prior to executing the scripts.

<br>

## I Prior To Installing

#### Upon first login run the following script, which will update the packages, patch OpenBSD, and reboot the server.

<br>

```bash
mail01# preInstallMail.sh
```

#### Log in and patch again from the CLI with the following two commands. The server should be fully up to date.

```bash
mail01# pkg_add -u
mail01# syspatch
```

#### If you haven't already login as root and clone this repo and modify the following files accordingly for your install.

```bash
#Modify the follwing files for your server
mail/smtpd.conf

#Modify the file for your desired maibox layout
mail/virtuals

#Modify this for your domain
rspamd/dkim_signing.conf

#Modify the ssl_cert and ssl_key lines for your install
dovecot/local.conf
```

#### Create your SPF Record and add to your DNS e.g.

```txt
v=spf1 mx -all
```

#### Also, ensure you have a DNS pointer record set up, so that your IP resolves to your hostname. In Vultr this is in the "Settings" section.

#### Create your DMARC Record and add to your DNS. A good resource is at:

<br>

```txt
https://dmarcguide.globalcyberalliance.org/
```

#### There are numerous methods for obtaining TLS certificates for OpenSMTPD. I use Cloudflare, which makes it easy to obtain certificates for /etc/ssl/ and /etc/ssl/private/. Which method you choose will determine how you edit the "Creating Public/Private Keys for OpenSMTPD And Setting Permissions" section of postInstallMail.sh

<br>

#### Once you have your certs configure them in /etc/mail/smtpd.conf file

<br>

## II Execute The Script

#### Run the following command

```bash
mail01# ./postInstallMail.sh
```

#### After running the script modify the mail/secrets file. These accounts are "non-user" email accounts.

```txt
mail/secrets
```

## Verifying The Install

#### Ensure local.conf was edited for your domain name otherwise dovecot will fail to start.

<br>

#### Verify Dovecot can correctly read /etc/mail/secrets.

```bash
mail01# doveadm user user@<yourdomainname>
```

#### Verify a user can login.

```bash
mail01# doveadm auth login user@<yourdomainname>
```

#### Running the following commands should produce similar output.

```bash
mail01# ps ax | grep dovecot
62668 ??  I        0:00.08 /usr/local/sbin/dovecot
62165 ??  I        0:00.03 dovecot/anvil
42059 ??  I        0:00.03 dovecot/log
13201 ??  I        0:00.13 dovecot/config
32644 ??  I        0:00.05 dovecot/stats
28386 ??  I        0:00.06 dovecot/imap-login
59068 ??  I        0:00.06 dovecot/imap
67269 ??  I        0:00.04 dovecot/imap-login
58913 ??  I        0:00.03 dovecot/imap
57001 p0  R+p/0    0:00.01 grep dovecot
mail01#
```
