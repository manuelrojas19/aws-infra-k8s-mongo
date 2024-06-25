# Certificate Creation for MongoDB Using OpenSSL

This guide outlines the steps to create a private key and self-signed certificate for MongoDB using OpenSSL. The resulting certificate can be used to establish a simple Certificate Authority (CA) and issue certificates for MongoDB nodes.

## Table of Contents

1. [Introduction](#introduction)
2. [Generate a Private Key](#generate-a-private-key)
3. [Create CA Certificate](#create-ca-certificate)
4. [Create SAN Configuration File](#create-san-configuration-file)
5. [Issue Self-Signed Certificates](#issue-self-signed-certificates)
6. [Concepts and Use Cases](#concepts-and-use-cases)
7. [License](#license)
8. [Contributing](#contributing)

## Introduction

This project simplifies the process of generating a private key and a self-signed certificate for MongoDB nodes. The generated certificate includes Subject Alternative Names (SANs), making it valid for multiple domain names.

## Generate a Private Key

Generate a new private key using OpenSSL:

```bash
openssl genrsa -aes256 -passout pass:'<passphrase>' -out mongoCA.key 8192
```

Replace <passphrase> with a secure passphrase of your choice.

## Create CA Certificate

Create a Certificate Authority (CA) certificate:

```bash
openssl req -x509 -new -extensions v3_ca -key mongoCA.key -days 365 -out mongoCA.crt -passin pass:'<passphrase>' -subj "/C=MX/ST=Mexico City/L=Mexico/O=/OU=DevOps/CN=mongo1.example.io/emailAddress=test@mail.com"
```

Replace the -passin pass option with the <passphrase> created while generating your private key. You can also use the -subj option to pass your organization details in the command line.

Example:

- `/C=MX`: Country is set to Mexico.
- `/ST=Mexico City`: State is set to Mexico City.
- `/L=Mexico City`: Locality is set to Mexico City.
- `/O=`: Organization field is left empty.
- `/OU=DevOps`: Organizational Unit is set to DevOps.
- `/CN=mongo1.example.io`: Common Name is set to mongo1.example.io.
- `/emailAddress=test@mail.com`: Email Address is set to test@mail.com