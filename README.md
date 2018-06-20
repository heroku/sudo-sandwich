# Sudo Sandwich is an example Heroku Add-on

Example Heroku add-on built with Rails for the Add-on Partner API v3.

This add-on is meant to demonstrate integrations. Integrations can be written in
any language or framework. We don't officially support this beyond that it's
an example of how an add-on might be built.

This add-on was built following instructions found at
https://devcenter.heroku.com/articles/building-an-add-on.

See [CONTRIBUTING.md](CONTRIBUTING.md) for information on how to set up and run
the code for this application.

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
all other controllers inherit from, because the Add-on Partner API sends basic
auth credentials with all requests. Basic auth is selectively skipped for the
single sign-on views, which are accessed by Heroku customers who are using the
add-on rather than the Add-on Partner API.

The username and password for basic auth are being accessed via environment
variables whose values match the `slug` and `password` fields in the manifest.

## The provisioning request

### Heroku docs

* https://devcenter.heroku.com/articles/building-an-add-on#the-provisioning-request
* https://devcenter.heroku.com/articles/getting-started-with-asynchronous-provisioning#implementation
* https://devcenter.heroku.com/articles/add-on-partner-api-reference#add-on-action-create-provision
* https://devcenter.heroku.com/articles/platform-api-reference#add-on-action-provision

### Related code

The Sudo Sandwich add-on is provisioned synchronously or asynchronously
depending on the plan that is selected. This somewhat artificial plan slug
distinction is just to demonstrate the process of provisioning plans
asynchronously and synchronously.

For both types of provisioning, the `base_url` key in the add-on manifest
specifies a path of `/heroku/resources`, which is routed to the
[`Heroku::ResourcesController`](app/controllers/heroku/resources_controller.rb)
`#create` method in this codebase. This is the endpoint that Heroku hits when a
customer creates an add-on resource.

#### Synchronous provisioning

The controller looks for the `plan` param, and if it matches
`Sandwich::BASE_PLAN` it returns a status code of 200, which tells Heroku that
the add-on is being provisioned synchronously, and a message that tells
the add-on customer that their add-on is available immediately.

#### Asynchronous provisioning

For all other plans, a status code of 202 is returned, which tells
Heroku that the add-on is being provisioned asynchronously. For plans that are
being provisioned asynchronously, an `access_token` is required. Retrieving an
`access_token` is covered in the "Grant code exchange" section.

Once the `access_token` is available, a plan is marked as `provisioned` by
running the [`ProvisionPlanJob`](app/jobs/provision_plan_job.rb). This
background job calls [`PlanProvisioner`](app/services/plan_provisioner.rb),
which sends a POST request to the Add-on Partner API. This request includes the
`uuid` of the provisioned resource, telling the Add-on Partner API to mark that
resource as provisioned.

## Grant code exchange

### Heroku docs

* https://devcenter.heroku.com/articles/add-on-partner-api-reference#grant-code-exchange

### Related code

When the provisioning request comes in to this app at the
`/heroku/resources` endpoint, Heroku sends an OAuth Grant Code in the request.
The OAuth Grant Code is used to obtain a `refresh_token` and `access_token` for
the add-on resource being provisioned. The process by which those are obtained
is called the grant code exchange.

This application saves the OAuth Grant Code on the Sandwich record when it is
created in the
[`Heroku::ResourcesController`](app/controllers/heroku/resources_controller.rb)
`create` method. The controller then enqueues the
[`ExchangeGrantTokenJob`](app/jobs/exchange_grant_token_job.rb) with the
`sandwich_id`. That job calls the
[`GrantCodeExchanger`](app/services/grant_code_exchanger.rb) service class,
which sends a POST request to `https://id.heroku.com/oauth/token` with the grant
code. The API responds with the `refresh_token` and `access_token`. An example of
this response is included in [the
fixtures](spec/support/fixtures/grant_code_exchange_response.json).

`GrantCodeExchanger` saves the `access_token`, `refresh_token`, and an
expiration timestamp for the `access_token` on the Sandwich record. Once the
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
`#update` method. The controller updates the plan of the Sandwich record that corresponds with the
`heroku_uuid` sent with the request so that the plan matches the `plan` param
sent with the request.

## Single sign on

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
resource.
