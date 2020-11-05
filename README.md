# README

Application responsible for storing metadata versions for all the services created by the
Ministry of Justice Online Form Builder tool.

Further documentation about requests and responses to and from the API can be found here:

https://ministryofjustice.github.io/form-builder-metadata-api-docs/

## Dependencies

* Docker

## Setup

```
  make build
```

## Running specs

```
  make spec
```

### Running integration tests only

```
  make integration
```

This spins up the Service Token Cache as well as a Redis instance in order to simulate the
JWT authentication requests. It does not currently create a Kubernetes cluster which is
what underpins the platform apps in production.

A temporary private and public key is generated using `./scripts/seed_test_public_key.rb`
and the public key is put into the Redis instance. All requests made by the integration
tests are signed using the private key.

### Running unit tests only

```
  make all_units
```
