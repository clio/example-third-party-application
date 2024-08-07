## Manual Setup

Before continuing with this setup, ensure that you have your valid API key pairs for both Clio Manage and Clio Identity, have cloned the example application repository and updated the environment variables as outlined in the [readme](../README.md).

### Ruby and Rails

This application utilizes Ruby `3.1.6` and Rails `7.0.8.4`. These can be installed through a variety of methods using different package managers, choose the right one for your system and preferences.

### Start

Now that you have Ruby and Rails installed you can run the install bundle:

```
bundle install
```

Run the application:

```
bundle exec rails s -p 3013
```

The example third-party application should now be running at http://localhost:3013/.
