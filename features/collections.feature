Feature: Collection with Criteria

  Scenario: saving a ruby object
    Given a new collection named 'test'
    And an object 'movie'
    When I save the object 'movie'
    And I query the collection 'test' with the criteria where(:title => 'Gone with the Wind')
    Then the query result has 1 documents

