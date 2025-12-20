# Conduit Container Project - Checklist

## Table of Contents

1. [Repository](#1-repository)
   - [Required Files](#required-files)
   - [Dockerfiles](#dockerfiles)
   - [.dockerignore Files](#dockerignore-files)
   - [docker-compose.yaml](#docker-composeyaml)
   - [README.md](#readmemd)
2. [Documentation](#2-documentation)
3. [Guidelines](#3-guidelines)
   - [General Guidelines](#general-guidelines)
   - [Security Guidelines](#security-guidelines)
   - [Code Conventions](#code-conventions)
   - [Testing](#testing)

---

## 1. Repository

### Required Files

- [x] A `.gitignore` file has been created that ignores all irrelevant content from the git repository
- [x] There is a Dockerfile for both the backend and frontend application that meets the requirements from the next section
- [x] There is a `docker-compose.yaml` that meets the requirements of the section after next
- [x] A file named `README.md` exists and has been created according to the criteria below

### Dockerfiles

- [x] The Dockerfiles are based on a suitable base image for the respective technology stack (nodejs, python)
- [x] Necessary environment variables are configured within the Dockerfiles
- [x] The Dockerfiles expose a container port for internet access
- [x] The Dockerfiles use multi-stage builds to keep the resulting container image size small

### .dockerignore Files

- [x] There is a `.dockerignore` file that, following the same principle as the gitignore file, lists content that should be ignored during a container build and not copied into the image (e.g., node_modules, etc.)

### docker-compose.yaml

- [x] There is one service each that is defined and configured: frontend, backend, database (Postgres!)
- [x] There is an environment configuration for both services so that all non-critical variables are configured (no auth credentials!)
- [x] There are necessary port releases and corresponding mappings so that the containers are accessible from the internet
- [x] There are volume configurations for the container data so that the content is persisted on a file system and the data is not lost

### README.md

- [x] The README should contain a table of contents (ToC)
- [x] A section with a description of the repository must be present. This description should state what the main contents are and what the purpose of the repository is
- [x] A "Quickstart" section should be included as part of the README. Prerequisites should be briefly mentioned here and a quick start guide should be described
- [x] A detailed version of the aforementioned section should be included as "Usage". This should go into more detail about the configuration and configurability, i.e., it should also explain how relevant passages can be modified to achieve different results

---

## 2. Documentation

- [x] The documentation of the code and the project should be in the repository in the form of a README file
- [x] The documentation language for all projects (and associated documents) is **English**

---

## 3. Guidelines

### General Guidelines

- [x] In addition to your GitHub repository, you should record and provide a short Loom video (maximum 5 minutes) in which you briefly show your submission and present what you have done - you don't have to mention all the details, but you should briefly address and show all relevant steps

### Security Guidelines

- [x] Do not store SSH keys in the workspace of your Git repository
- [x] Do not store passwords, tokens, or usernames in your code. Use environment variables for this instead
- [x] Do not store IP addresses or other sensitive information in a Git repository

### Code Conventions

- [x] The following naming convention applies to build-args, environment variables, and shell variables: `UPPER_CASE_WITH_UNDERSCORE`
- [x] When referencing a variable, always use the `{}` notation to avoid interpretation errors: `${SOME_VAR_VALUE}`, instead of: `$SOME_VAR_VALUE`
- [x] Default values should be configured for build-args or environment variables, but only when it makes sense
- [x] Critical configuration such as tokens, passwords, or similar should not be stored in the code repository, but should be passed into a container, for example, by using a `.env` file

### Testing

Before you submit your project, you should have ensured and tested the following:

- [x] The frontend of your Conduit application is accessible at the IP address of your cloud VM on port **8282**
- [x] Your ENTRYPOINT starts a WSGI application, NOT a dev-server!
- [x] The service containers are restarted as soon as an error occurs that leads to the termination of the container
- [x] You can navigate through the application and data is loaded everywhere
- [x] You can view the logs of your application via CLI and also persist them, i.e., you can save the logs to a file for later use

**Save logs to file:**

```bash
docker logs [container-name] > my-container-logs.txt
```

`[container-name]` must then be replaced with the name of the container accordingly.

---

**Developer Akademie - Conduit Checklist 2024**