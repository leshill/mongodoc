Feature: saving an object

  Scenario: saving simple json
    Given a new collection named 'test'
    When I save the json '{"name":"name"}'
    Then the collection should have 1 document
    And the json '{"name":"name"}' roundtrips

  Scenario: saving a ruby object
    Given a new collection named 'test'
    And an object 'movie'
    When I save the object 'movie'
    Then the collection should have 1 document
    And the object 'movie' roundtrips

