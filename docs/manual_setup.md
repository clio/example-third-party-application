## Manual Setup

Before continuing with this setup, ensure that you have your valid API key pairs for both Clio Manage and Clio Identity, have cloned the example application repository and updated the environment variables as outlined in the [readme](../README.md).

### PostgreSQL

This application utilizes [PostgreSQL](https://www.postgresql.org/) as it's database system.

For macOS users, we recommend using [Postgres.app](https://postgresapp.com/), which is a simple, native macOS app that runs in the menubar without the need of an installer. Open the app, and you have a PostgreSQL server ready and awaiting new connections. Close the app, and the server shuts down.

On macOS installing the `postgresql` package is also required to be able to use the `psql` client command, as well as to install any libraries that are required to build the `pg` driver for use with `rails`.

```
brew install postgresql
```

By default, the database configuration is set up for use with Docker. For manual setup, edit `config/database.yml` and remove the following from `default`:

```
host: sb_db
username: postgres
password: password
```

### Ruby and Rails

This application utilizes Ruby 2.6.8 and Rails 5.2.6. These can be installed through a variety of methods using different package managers, choose the right one for your system and preferences.

### Start

Now that you have PostgreSQL, Ruby and Rails installed you can start up PostgreSQL (or run Postgres.app) and create a new database named `clio_third_party_integration_dev`

```
psql --command="CREATE DATABASE clio_third_party_integration_dev"
```

Run the install bundle:

```
bundle install
```

Run the application:

```
rails s -p 3013
```

The example third-party application should now be running at http://localhost:3013/.
