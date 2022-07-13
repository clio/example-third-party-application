## Docker Setup

Before continuing with this setup, ensure that you have your valid API key pairs for both Clio Manage and Clio Identity, have cloned the example application repository and updated the environment variables as outlined in the [readme](../README.md).

### Docker

Install Docker from [docs.docker.com/get-docker](https://docs.docker.com/get-docker/) or via brew: `brew install docker`.

### Start

Now that you have Docker installed you can build the image: `docker compose build`.

Then create the database: `docker compose run sb_app rake db:create`.

And  boot the app: `docker compose up`.

The example third-party application should now be running at http://localhost:3013/.
