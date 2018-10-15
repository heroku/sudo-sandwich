# Sudo Sandwich is an example Heroku Add-on

[![Build Status](https://travis-ci.org/heroku/sudo-sandwich.svg?branch=master)](https://travis-ci.org/heroku/sudo-sandwich)

Example Heroku add-on for the v3 of the Platform API for Partners built with
Ruby on Rails.

This add-on is meant to demonstrate integrations. Integrations can be written in
any language or framework. We don't officially support this beyond that it's
an example of how an add-on might be built.

This add-on was built following instructions found at
https://devcenter.heroku.com/articles/building-an-add-on.

See [Set up](#set-up) for information on how to set up and run
the code for this application.

To install this add-on to an existing Heroku app, run the following:

```
heroku addons:create sudo-sandwich
```

To test the app yourself, you can use this button:

[![Deploy](https://www.herokucdn.com/deploy/button.svg)](https://heroku.com/deploy)

## Set up

### macOS

Install [Homebrew].

Install [Heroku CLI].

```
brew install heroku/brew/heroku
```

Install and start PostgreSQL.

```
brew install postgresql
brew services start postgresql
```

[Homebrew]: https://brew.sh/
[Heroku CLI]: https://devcenter.heroku.com/articles/heroku-cli

### Ruby on Rails

This application is built using [Ruby on Rails].

Your system will require [Ruby] to develop on the application.

The required Ruby version is listed in the [.ruby-version](.ruby-version) file.

If you do not have this binary, [use this guide to get set up on MacOS].

[Ruby on Rails]: http://rubyonrails.org
[Ruby]: https://www.ruby-lang.org/en/
[use this guide to get set up on MacOS]: http://installfest.railsbridge.org/installfest/macintosh

### Configuring the Application

After cloning this repo, run: `bin/setup`.

## Day-to-day Development

### Local Server

* Run the server(s): `bin/rails start`
* Visit [your local server](http://localhost:3000)
* Run tests: `rake`

## Add-on manifest

### Heroku docs

* https://devcenter.heroku.com/articles/building-an-add-on#step-1-generate-your-add-on-manifest

### Related code

The manifest is not checked into version control because it contains secrets. A
copy of the manifest with fake keys is located at
[addon-manifest-example.json](addon-manifest-example.json). Although it is not
checked into version control, it is helpful to know that the real manifest is
named `addon-manifest.json` and will be called "the manifest" from this point
forward.

## Basic auth

### Heroku docs

* https://devcenter.heroku.com/articles/building-an-add-on#basic-authentication

### Related code

Basic auth is implemented via the [`HttpBasicAuth`
concern](app/controllers/concerns/http_basic_auth.rb). This concern is included
in [`ApplicationController`](app/controllers/application_controller.rb), which
all other controllers inherit from, because the Platform API for Partners sends
basic auth credentials with all requests.

The username and password for basic auth are accessed via environment variables
whose values match the `slug` and `password` fields in the manifest.

Basic auth is selectively skipped for the single sign-on views, which are
accessed by Heroku customers who use an add-on resource rather than the
Platform API for Partners.

## The provisioning request

### Heroku docs

* https://devcenter.heroku.com/articles/building-an-add-on#the-provisioning-request
* https://devcenter.heroku.com/articles/getting-started-with-asynchronous-provisioning#implementation
* https://devcenter.heroku.com/articles/add-on-partner-api-reference#add-on-action-create-provision
* https://devcenter.heroku.com/articles/platform-api-reference#add-on-action-provision

### Related code

The Sudo Sandwich add-on can be provisioned synchronously or asynchronously
depending on the plan that is selected. This somewhat artificial plan slug
distinction is just to demonstrate the process of provisioning plans
asynchronously and synchronously.

For both types of provisioning, the `base_url` key in the add-on manifest
specifies a path of `/heroku/resources`. A POST to this path is routed to the
[`Heroku::ResourcesController`](app/controllers/heroku/resources_controller.rb)
`#create` method in this codebase. This is the endpoint that Heroku hits when a
customer creates an add-on resource.

#### Synchronous provisioning

The controller looks for the `plan` param, and if it matches
`Sandwich::BASE_PLAN` (currently `test`), we return:

* A status code of 200,
* An example config var that's included in an app's environment, and
* A message that's displayed to customers telling them the add-on is
  immediately available.

The 200 status code tells Heroku that the add-on resource has been provisioned
and that the config variables returned should be set on a release for all apps
associated with the resource.  It also sets the internal state of the add-on to
`provisioned`, which is represented to customers as `created`.

#### Asynchronous provisioning

For all other plans, we return:

* A status code of 202, and
* A message telling the customer that the add-on is being provisioned and will
  be available shortly.

A 202 status tells Heroku that the add-on is being provisioned asynchronously
and sets its state internally to `provisioning`, which is represented to
customers as `creating`.

We DO NOT return a config variable, as it's expected you don't know it until
your add-on resource is fully created in your infrastructure.

The sudo-sandwich add-on enqueues additional background jobs that mimic how
async provisioning might work for plans that take a longer time to initialize.

For plans that are being provisioned asynchronously, an `access_token` is
required to complete the provisioning process as an add-on partner. Retrieving
an `access_token` is covered in the "Grant code exchange" section.

Once the `access_token` is available, a plan is marked as `provisioned` by
running the [`ProvisionPlanJob`](app/jobs/provision_plan_job.rb).

This background job calls
[`AsyncPlanProvisioner`](app/services/async_plan_provisioner.rb), which:

* Sends a PATCH request to the Platform API for Partners [add-on config
  update](https://devcenter.heroku.com/articles/add-on-partner-api-reference#add-on-config-update)
  endpoint with relevant config vars, and
* Sends a POST request to the Platform API for Partners to [mark the add-on
  resource as
  provisioned](https://devcenter.heroku.com/articles/add-on-partner-api-reference#add-on-action-create-provision).

A release is cut for all apps associated with an add-on resource once the PATCH
request is sent to update config variables. You should be sure to mark the
resource as provisioned too, add-on resources stuck in `provisioning` are
deprovisioned after around 12 hours.

Both endpoints use the `heroku_uuid` value to uniquely identify an add-on
resource.

## Grant code exchange

### Heroku docs

* https://devcenter.heroku.com/articles/add-on-partner-api-reference#grant-code-exchange

### Related code

When the provisioning request comes in to this app at the
`/heroku/resources` endpoint, Heroku sends an OAuth Grant Code in the request.
The OAuth Grant Code is used to obtain a `refresh_token` and `access_token` for
the add-on resource being provisioned. The process by which those are obtained
is called the "grant code exchange".

Obtaining a `refresh_token` and `access_token` is advised whether they are
going to be used immediately or not. For example, if an add-on ever needs to
rotate credentials, an `access_token` would be required to update the config
for the add-on resource.

This application saves the OAuth Grant Code on the Sandwich record when it is
created in the
[`Heroku::ResourcesController`](app/controllers/heroku/resources_controller.rb)
`create` method. Because the OAuth Grant Code expires after five minutes, the
controller immediately enqueues the
[`ExchangeGrantTokenJob`](app/jobs/exchange_grant_token_job.rb) with the
`sandwich_id`. That job calls the
[`GrantCodeExchanger`](app/services/grant_code_exchanger.rb) service class,
which sends a POST request to `https://id.heroku.com/oauth/token` with the grant
code. The Platform API for Partners responds with the `refresh_token` and
`access_token`. An example of this response is included in [the
fixtures](spec/support/fixtures/grant_code_exchange_response.json).

`GrantCodeExchanger` saves the `access_token`, `refresh_token`, and an
expiration timestamp for the `access_token` on the Sandwich record. The
`access_token` and `refresh_token` are encrypted at rest using the
[`attr_encrypted`](https://github.com/attr-encrypted/attr_encrypted) gem. Once the
`access_token` is expired, a new one can be obtained using the `refresh_token`.

In the Sudo Sandwich app, we use the `access_token` for async provisioning. The
`access_token` is also required for accessing other endpoints in the Platform
API for Partners. Those endpoints are not accessed in Sudo Sandwich but you can
learn more about them by reading [the Platform API for Partners
documentation](https://devcenter.heroku.com/articles/platform-api-for-partners#list-of-standard-platform-api-endpoints).

## The deprovisioning request

### Heroku docs

* https://devcenter.heroku.com/articles/building-an-add-on#the-deprovisioning-request

### Related code

Deprovisioning happens via the
[`Heroku::ResourcesController`](app/controllers/heroku/resources_controller.rb)
`#destroy` method. The controller deletes the Sandwich record that corresponds with the
`heroku_uuid` sent with the request and returns a status of `204` to indicate
that the request was successfully received and processed.

## The plan change request

### Heroku docs

* https://devcenter.heroku.com/articles/building-an-add-on#the-plan-change-request-upgrade-downgrade

### Related code

Plan changes happen via the
[`Heroku::ResourcesController`](app/controllers/heroku/resources_controller.rb)
`#update` method. The controller updates the plan of the Sandwich record that
corresponds with the `heroku_uuid` so that the plan matches the `plan` param
sent with the request.

## Single sign on dashboard

### Heroku docs

* https://devcenter.heroku.com/articles/add-on-single-sign-on

### Related code

The Sudo Sandwich single sign on (SSO) endpoint is indicated via the `sso_url`
key in the manifest as `/sso/login`. That path is routed to the
[`Sso::LoginsController`](app/controllers/sso/logins_controller.rb)
`#create` method. The controller calls the
[`ResourceTokenCreator`](app/services/resource_token_creator.rb) service class,
which creates a `resource_token` using the `resource_uuid` and `timestamp` sent
with the request as well as the `salt`, which comes from the
`addon-manifest.json` file. The formula for creating the `resource_token` is
discussed in depth in [the
docs](https://devcenter.heroku.com/articles/add-on-single-sign-on#creating-the-resource-token-under-v3).

The controller compares the generated `resource_token` with the `resource_token`
sent with the request. If they match, a session variable is set and the user is
redirected to the
[`Heroku::DashboardController#show`](app/controllers/heroku/dashboard_controller.rb)
action. In this view, the end user can see information about their add-on
resource. This is where you'd build your add-on resource dashboard.

## Usage reporting

This is a feature that is under active development (pre-alpha).

The `ReportUsageJob` calls the `UsageReporter` service class, which sends usage
data to `https://addons-staging.herokuapp.com`. The data is sent to the
`/api/v3/addons/#{slug}/usage_batches` endpoint in the add-ons staging instance.
Basic authentication credentials are sent via the headers. The username and
password must match the Manifest credentials for the `Addon` for which usage
data is being reported. See [the
docs](https://devcenter.heroku.com/articles/building-an-add-on#basic-authentication)
for more info on basic auth.

In order to test this against staging, the following data must first exist in
`addons-staging.heroku.com`:

- An `Addon` with a slug that matches the slug sent in the
  `/api/v3/addons/#{slug}/usage_batches` endpoint (currently hard-coded to
`sudo-sandwich` in the service class).
- A `Plan` record that belongs to the `Addon` and has the `usage` attribute set
  to true.
- A `Unit` record belongs to the `Addon`.
- A `Pricing` record for the `Plan` and `Unit` above. The `Pricing` must have
  an `effective_at` datetime attribute that is older than the beginning of the
  previous hour.
- An `AddonResource` for the `Addon`.
- An `AddonResourcePlan` for the `AddonResource` and `Plan`. Must have an
  `effective_at` datetime attribute that is older than the beginning of the
  previous hour.

In order to test this against staging, the following data must first exist in
the Sudo Sandwich database from which you are testing:

- A `Sandwich` record the a `heroku_uuid` attribute that matches the
  `AddonResource#uuid` above.
- A `Usage` record that belongs to the `Sandwich` record, and a timestamp that
  is equal to the hour boundary of the previous hour (in Ruby,
  `DateTime.now.beginning_of_hour - 1.hour`), and a `unit` attribute that is
  equal to the `Unit#name` above.

The JSON body sent with the request to the usage endpoint contains a `timestamp`
and an array of `usages`. The timestamp, which represents the datetime that
the usage data s being reporting for, must be in `YYYY-MM-DDThh:mm:ssZ` format
and must be hour boundary of previous hour (cannot be for further in past or for
future).

The `usages` array contains usage records. Each record must contain the
`quantity`, `uuid` of the associated `AddonResource`, and `Unit#name`. The JSON is
formatted as follows:

```
{
 "timestamp": "2018-07-11T03:00:00Z"
  "usages": [
    {
      "quantity": 5,
      "resource": {"id": "addon-resource-uuid"},
      "unit": {"name": "nibbles"},
    }
  ]
}
```

Each JSON object in the `usages` array must be unique the that timestamp,
resource, and unit tuple. Duplicates will be rejected.

After running the job, you will know if a `Usage` was reported properly if the
`reported` attribute is set to `true` (defaults to `false`). If it is `false`,
the `errors` attribute of the `Usage` record should explain why it was not
reported properly.

*NOTE*: the current implementation does not handle all edge cases at this time.
If you send invalid data, it is possible for it to silently fail.

## How to fork this add-on to create your own SudoSandwich instance on Heroku

If you want to run your own add-on based on this codebase, you should follow these instructions. These instructions are for deploying your add-on to Heroku, which is not required. You may have to modify the deploy instructions for other environments.

To start, you may wish to fork the codebase to your own private GitHub repo, so that you can make changes for your specific add-on's use case. If you intend to do local development, see [Set up](#set-up).

Create a Heroku app. Typically, we name the Heroku app after the slug (or command line identifier) for the add-on. If I was creating an add-on with the slug of `sudo-sandwich`, I'd probably name the Heroku app `sudo-sandwich` as well. This is not required; and you can name it whatever you'd like. Please note that `sudo-sandwich` is already taken, and slugs are both immutable and must be globally unique!

Install the Heroku CLI, if you haven't already, [from the instructions for your platform](https://devcenter.heroku.com/articles/heroku-cli#download-and-install).

```
heroku apps:create your-app-slug
```

You'll need a Heroku Postgresql database to store data in:

```
heroku addons:create heroku-postgresql --app your-app-slug
```

You will also want to scale the `worker` dyno up so that async provisioning can be handled in the background:

```
heroku ps:scale worker=1 --app your-app-slug
```

Deploying the code to Heroku either [using git](https://devcenter.heroku.com/articles/git) or [the Heroku Dashboard with the GitHub integration](https://devcenter.heroku.com/articles/github-integration).

Generate a manifest with the [addons-admin](https://github.com/heroku/heroku-cli-addons-admin) CLI plugin. (See the linked repo for plugin install instructions.) After install, run `heroku addons:admin:manifest:generate` and follow the prompts.

Allow the `addons-admin` CLI plugin to generate a secret and SSO salt for you. It will save a new file called `addon-manifest.json`. Edit the `addon-manifest.json` to change the `"api.production.base_url"` and `"api.production.sso_url"` keys to point at your Heroku app. This might look like:

```json
    "production": {
      "sso_url": "https://your-app-slug.herokuapp.com/sso/login",
      "base_url": "https://your-app-slug.herokuapp.com/heroku/resources"
    },
```

You may also need to edit this file to suit your local dev environment's port, inside the `"api.test.sso_url"` and `"api.test.base_url"` keys. For more details on editing this file, see the [Manifest](https://devcenter.heroku.com/articles/add-on-manifest) docs.

Set secrets from the `addon-manifest.json` on your newly-created app under the following config vars:

```
heroku config:set SLUG=<slug-from-manifest> PASSWORD=<password-from-manifest> SSO_SALT=<salt-from-manifest> --app your-app-slug
```

You'll also have to generate an encryption key for the database to store secrets with. In a Ruby terminal (pry or irb), run `require 'securerandom'; SecureRandom.hex(32)` to generate an encryption key of the appropriate length. Then set that key on the Heroku app:

```
heroku config:set ENCRYPTION_KEY=<value-from-securerandom> --app your-app-slug
```

Once you've completed the above, you should be ready to push the manifest to the Heroku API. First, make sure that you've signed up at the [Partner Portal](https://addons-next.heroku.com) as an Add-on Partner. Then push your manifest up to the server:

```
heroku addons:admin:manifest:push
```

You will need to go to the [Partner Portal](https://addons-next.heroku.com) and add [plans](https://github.com/heroku/sudo-sandwich/blob/master/app/models/sandwich.rb#L2-L8) to your add-on based on the hardcoded values in the `Sandwich` class. You may wish to modify these and deploy the changes, for example, to create a plan called `async` for testing async provisioning.

The [Building an Add-on](https://devcenter.heroku.com/articles/building-an-add-on) guide and [Manifest](https://devcenter.heroku.com/articles/add-on-manifest) docs have more info on developing an add-on, and the implementation of each feature in Sudo Sandwich can be see above in this document.

### Staging add-on

Often, you'll want an add-on instance to test changes on. We call this the 'staging add-on' unofficially, and it still runs in a 'production' environment on Heroku. Typically, you create another add-on based on instructions above, but with `-staging` appended to the slug. We keep back this add-on in alpha, which keeps it hidden. As the add-on partner, you can provision this add-on while customers cannot, which gives you a way to test changes to your add-on before deploying them to the real, production add-on slug.

For more best practices, see the [Add-on Partner Technical Best Practices](https://devcenter.heroku.com/articles/add-on-partner-technical-best-practices) guide.
