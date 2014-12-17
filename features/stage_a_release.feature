Feature: Stage a release
  As a tech team
  We want to stage releases to a production-like environment
  So that we have confidence that they will succeed on production

Scenario: Stage a release on Heroku
  Given I have a Heroku-enabled app
  And it's released to Heroku
  When I stage another release
  Then a new staging environment is created
  And the new release is deployed to it

