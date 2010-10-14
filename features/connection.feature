Feature: Setting a Connection Manually

  Scenario: Setting the connection manually
    Given a new connection to the database "with_auth" with user "test" and password "test"
    And a new collection named 'test'
    And an object 'movie'
    When I save the object 'movie'
    And I query the collection 'test' with the criteria where(:title => 'Gone with the Wind')
    Then the query result has 1 documents

  Scenario: Failing auth with manual connection
    When a new connection to the database "with_auth" with user "test" and password "bad"
    Then a "Mongo::AuthenticationError" exception is thrown
