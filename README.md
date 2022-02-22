# Example Third-Party Application

**By using this sample code, you acknowledge that you have read, accepted and agree to be bound by and comply with the terms and conditions set out in the [Clio Developer Terms of Service](https://www.clio.com/partnerships/developers/developer-terms-service/).**

This is an example third-party application that demonstrates the ability to use single sign-on (SSO) with Clio's authentication services. 

SSO makes it easy for Clio users to securely sign in and access your application at the click of a button using their Clio credentials, as opposed to having them create entirely new accounts and credentials for each third-party application they wish to utilize.

Also included in this example application is making use of the access token obtained during SSO to make a successful API request.

Note that this example code isn't in an ideal, refactored state. We've taken a "show your work" approach, clearly identifying the steps taken. In line with this we've also opted not to use some Ruby gems that might hide implementation details (such as `oauth2` that can automate part of the SSO flow for you).

## Requirements

Whether you're a private developer or a company looking to integrate with Clio, the first step is to complete our [registration form](https://www.clio.com/partnerships/developers/get-started/). If you're looking to offer your integration to Clio customers, keep an eye out for an automatic follow-up email with instructions to setup your Developer Account on Clio Manage and Clio Identity.

If you're already a Clio customer and are just looking to use our API for private use, you can get started right away.

### Clio Manage API Keys

Clio Manage is the cloud-based legal practice management software that makes running a firm, organizing cases, and collaborating with clients from one place possible.

Once your Developer Account has been set up, navigate to your [Developer Portal](http://app.clio.com/settings/developer_applications) within Clio Manage and follow our [intructions for creating a Clio application](https://app.clio.com/api/v4/documentation#section/Authorization-with-OAuth-2.0/Create-a-Clio-Application) on our Clio Manage API Documentation. Creating a Clio application will generate an application key and secret, which will be used to authorize your application with Clio and communicate with our Clio Manage API.

### Clio Identity API Keys

Clio Identity is Clio's authentication service and identity provider. Similar to how you may see a "Login with GitHub" or "Login with Google" button when authenticating with an application on the web, third-party developers can leverage Clio Identity as an identity provider, cutting the time needed to write and maintain an authentication system for an application.

A self-serve Developer Portal for Clio Identity is available through Clio My Account and is currently in a private beta phase. In the interim, please contact us directly at api@clio.com to request a Clio Identity API key.

### PostgreSQL

This application utilizes [PostgreSQL](https://www.postgresql.org/) as it's database system. 

For macOS users, we recommend using [Postgres.app](https://postgresapp.com/), which is a simple, native macOS app that runs in the menubar without the need of an installer. Open the app, and you have a PostgreSQL server ready and awaiting new connections. Close the app, and the server shuts down.

On macOS installing the `postgresql` package is also required to be able to use the `psql` client command, as well as to install any libraries that are required to build the `pg` driver for use with `rails`.

```
brew install postgresql
```

### Ruby and Rails

This application utilizes Ruby 2.6.8 and Rails 5.2.6. These can be installed through a variety of methods using different package managers, choose the right one for your system and preferences.  

## Installation

To get the example third-party application running on your local environment, ensure that you have valid API key pairs for both Clio Manage and Clio Identity, and that you have PostgreSQL, Ruby and Rails installed, as described in the Requirements section above.

Clone the repository to your local environment:

```
git clone https://github.com/clio/example-third-party-application.git
```

Update the environment variables in `config/local_env.yml`:
1. Update the `CLIO_MANAGE_CLIENT_ID` and `CLIO_MANAGE_CLIENT_SECRET` values with your Clio Manage API Key and Secret
2. Update the `CLIO_MANAGE_SITE_URL` value with the region specific URL of your Clio Manage account:
    * `https://app.clio.com/` for the United States
    * `https://ca.app.clio.com/` for Canada
    * `https://eu.app.clio.com/` for Europe
3. Update the `CLIO_IDENTITY_CLIENT_ID` and `CLIO_IDENTITY_CLIENT_SECRET` values with your Clio Identity API Key and Secret

Start up PostgreSQL (or run Postgres.app) and create a new database named `clio_third_party_integration_dev`


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

## Example Entry Point

### SSO

Both authentication with Clio Identity and authorization with Clio Manage start their flows in the `ApplicationController` (`app/controllers/application_controller.rb`). This file takes you through the steps outlined in our [Integrating with Clio Identity](https://developers.support.clio.com/hc/en-us/articles/4405288237723-Integrating-with-Clio-Identity-Single-Sign-on-with-Clio-) documentation (for performing authentication) and our [API Documentation](https://app.clio.com/api/v4/documentation#section/Authorization-with-OAuth-2.0/Obtaining-Authorization) (for obtaining authorization).

### API Requests

The `ProfileController` (`app/controllers/profile_controller.rb`) uses the Clio Manage access token to make a simple API request to the `api/v4/users/who_am_i` endpoint.

Meanwhile the `MatterController` (`app/controllers/matter_controller.rb`) uses the Clio Manage access token to make an API request to the `api/v4/matters` endpoint using [Unlimited Cursor Pagination](https://app.clio.com/api/v4/documentation#section/Paging/Unlimited-Cursor-Pagination).

## Support

For technical inquiries, visit our [Clio Developers Help Center](https://developers.support.clio.com/hc/en-us), send us an email at api@clio.com, or visit our community-driven Slack workspace at [clio-public.slack.com](https://join.slack.com/t/clio-public/shared_invite/zt-qgkswsia-fyTprPgHGBR0TLAk7PENJw).

For business and partnership inquiries, visit [https://www.clio.com/partnerships/developers/](https://www.clio.com/partnerships/developers/).
