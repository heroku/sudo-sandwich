Rails.application.config.session_store :cookie_store, expire_after: 90.minutes # recommended interval at https://devcenter.heroku.com/articles/add-on-single-sign-on#signing-in-the-user-on-redirect
