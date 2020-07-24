# Codeship Pro with Cypress

## Developing locally
Codeship offers a cli that you can use locally to test your build steps. You'll need to install the [jet-cli and docker](https://documentation.codeship.com/pro/jet-cli/installation/). After that, to run the `codeship-steps` locally, you can run `jet steps`

## Codeship files
The `codeship-steps` file lists a list of steps to run in CI. These steps will begin to build the declared service and given dependencies, and once the declared service is built, will execute the command and `entrypoint` command. 

The `codeship-services` file lists the given services with corresponding docker files, entry points, ports, and other configuration. This is similar to a `docker-compose` file used with `docker compose` commands.

Each service can take a list of dependencies through the `depends_on` directive. It's important to note that this simply _starts_ the declared dependency containers (and dependencies of those dependencies), but does not guarentee anything about whether the processes have completed before building the next container. Because of this, `entrypoint` files have been created to guarentee the healthiness of containers before running `entrypoint` commands.

An `entrypoint` file serves as a command that will be run every time a container is built. The [docker documentation](https://docs.docker.com/compose/startup-order/) suggests using bash scripts to ensure that services are healthy before running commands that depend on them, and so the easiest way to chain all of these services together was a combination of the dependencies listed alongside health checks through `entrypoint` files.

Here is a simplified explination of the current dependency and healthcheck order:

1. Cypress depends on React
2. React depends on Rails
3. Rails depends on Postgres
4. Sidekiq depends on Rails (to ensure migrations have run before attempting to connect to Postgres).
5. Mailhog and Redis take a very short time to build (neither require additional configuration through a Dockerfile), so they are run in parallel when the steps command starts.

## Build Arguments and Environment Variables
Build arguments are like environment variables, but are used within Dockerfiles to be used at build time.  Because we will be dynamically pulling code based on repository names, there are currently 2 build arguments to be aware of:

1. `GITHUB_TOKEN` which is used to access our private repositories
2. `NPM_TOKEN` which is necessary for access to `pp-ui`
3. `BRANCH` which is automatically set through Codeship when it builds. Note that this _isn't_ available locally when using `jet`, and as such should be replaced with a branch name in the `codeship-services` file if a repository other than `develop` is desired for build. This can be done through changing `BRANCH: "{{ .Branch }}"` to `BRANCH: my_feature_branch`

Environment variables are used at run time for each container, and both environment variables and build arguments can be encrypted locally before being checked in. This can be done by [downloading an AES key](https://documentation.codeship.com/pro/builds-and-configuration/environment-variables/#downloading-your-aes-key) and then running `jet encrypt env env.encrypted` where `env` is the raw env file and `env.encrypted` is the updated encrypted file. This will need to be done when moving these files into any individual project, as the encryption will change per project.

Examples of unencrypted environment and build argument files can be found in the folder `codeship/unencrypted-examples`.
