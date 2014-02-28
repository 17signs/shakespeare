Feature: Visitor starts research

  As a visitor
  I want to research in our Metadata
  So that I get information about our data

  Scenario: open index
    Given I am not logged in
    When I open the shakespeare index page
    Then I should see index page