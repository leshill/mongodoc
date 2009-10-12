Feature: MongoDoc::Base

  Scenario: saving a simple document
    Given a valid connection to the 'test' database
    And an empty Address document collection
    And an Address document named 'hashrocket' :
      | Street                 | City               | State | Zip Code |
      | 320 First Street North | Jacksonville Beach | FL    | 32250    |
    When I save the document 'hashrocket'
    Then 'hashrocket' is not a new record
    And the Address collection should have 1 document
    And the document 'hashrocket' roundtrips
