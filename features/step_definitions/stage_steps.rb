Given(/^I have a Heroku\-enabled app$/) do
  app = fixtures.create('helloworld')

  app.heroku_create_app
  app.heroku_set_config(foo: 'bar', one: 'two')
  app.heroku_add_addons('heroku-postgresql')
  app.checkout('v1')
  app.deploy
end

Given(/^it's released to Heroku$/) do
  pending
end

When(/^I stage another release$/) do
  pending
end

Then(/^a new staging environment is created$/) do
  pending
end

Then(/^the new release is deployed to it$/) do
  pending
end
