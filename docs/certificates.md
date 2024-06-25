# Certificate Creation for MongoDB Using OpenSSL

This guide outlines the steps to create a private key and self-signed certificate for MongoDB using OpenSSL. The resulting certificate can be used to establish a simple Certificate Authority (CA) and issue certificates for MongoDB nodes.

## Table of Contents

1. [Introduction](#introduction)
2. [Generate a Private Key](#generate-a-private-key)
3. [Create CA Certificate](#create-ca-certificate)
4. [Create SAN Configuration File](#create-san-configuration-file)
5. [Issue Self-Signed Certificates](#issue-self-signed-certificates)
6. [Concepts and Use Cases](#concepts-and-use-cases)


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
- `/L=Mexico`: Locality is set to Mexico.
- `/O=`: Organization field is left empty.
- `/OU=DevOps`: Organizational Unit is set to DevOps.
- `/CN=mongo1.example.io`: Common Name is set to mongo1.example.io.
- `/emailAddress=test@mail.com`: Email Address is set to test@mail.com

## Create CA Certificate

Create SAN Configuration File

To ensure we have a single certificate that can access all the MongoDB nodes, create the configuration file san.conf with the following content:

```bash
[req]
distinguished_name = req_distinguished_name
req_extensions = v3_req

[req_distinguished_name]

[v3_req]
basicConstraints = CA:FALSE
keyUsage = nonRepudiation, digitalSignature, keyEncipherment
subjectAltName = @alt_names

[alt_names]
DNS.1 = mongo1.example.io
DNS.2 = mongo2.example.io
DNS.3 = mongo3.example.io
```
This configuration allows the certificate to be valid for multiple domain names.

## Issue Self-Signed Certificates

Using the san.conf configuration file, issue a single self-signed certificate to be used across all nodes. Replace the -subj and -passin pass options with your organization's details and selected passphrase respectively.

Generate a Certificate Signing Request (CSR):

```bash
openssl req -new -nodes -newkey rsa:4096 -keyout mongo.key -out mongo.csr -subj "/C=MX/ST=Mexico City/L=Mexico/O=/OU=DevOps/CN=mongo1.example.io/emailAddress=test@mail.com" -config san.conf
```

Sign the CSR with the CA:

```bash
openssl x509 -CA mongoCA.crt -CAkey mongoCA.key -CAcreateserial -req -days 365 -in mongo.csr -out mongo.crt -passin pass:'<passphrase>' -extensions v3_req -extfile san.conf
```

Combine the key and certificate into a PEM file:

```bash
cat mongo.key mongo.crt > mongo.pem
```

The resulting PEM file can be used for securing communication in applications like MongoDB, which require both the private key and the certificate in a single file.

## Concepts and Use Cases

### Concepts

- **X.509 Certificate:** A standard defining the format of public-key certificates. It includes information about the certificate holder, the public key, the digital signature, and the certificate issuer (CA).

- **Self-Signed Certificate:** A certificate signed by its own private key, indicating that the entity presenting the certificate is vouching for its own identity.

- **v3_ca Extension:** An X.509 extension often used for CA certificates.

### Use Cases

- **Establishing a basic Certificate Authority for internal use:** Setting up a CA allows organizations to issue and manage certificates internally, ensuring secure communication within their network without relying on external CAs.

- **Testing and development environments where a self-signed certificate is sufficient:** Self-signed certificates are useful in non-production environments where encryption and identity verification are needed but full validation by a public CA is unnecessary.

The generated private key and self-signed certificate form the foundation for a simple Certificate Authority. This CA can be used to issue and sign certificates for other entities, such as servers, clients, or individuals within an organization.

This setup is useful in scenarios where a full-fledged public CA is not necessary, such as internal testing environments or small-scale deployments. It's essential to understand that self-signed certificates, while suitable for certain use cases, are not typically trusted in public-facing production systems without additional configuration. In production, certificates signed by widely recognized public CAs are generally preferred for secure communication.

## License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.

## Contributing

Contributions are welcome! Please submit a pull request or open an issue to discuss your ideas.


