Feature: MongoDoc::Base

  Scenario: creating a simple document
    Given a valid connection to the 'test' database
    And an empty Address document collection
    And a hash named 'hashrocket':
      | Street                 | City               | State | Zip Code |
      | 320 First Street North | Jacksonville Beach | FL    | 32250    |
    When I create an Address 'address' from the hash 'hashrocket'
    Then 'address' is not a new record
    And the Address collection should have 1 document
    And the document 'address' roundtrips

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

  Scenario: updating an attribute of a simple document
    Given a valid connection to the 'test' database
    And an empty Address document collection
    And an Address document named 'hashrocket' :
      | Street                 | City               | State | Zip Code |
      | 320 First Street North | Jacksonville Beach | FL    | 32250    |
    And a hash named 'street':
      | Street         |
      | 320 First St N |
    And I save the document 'hashrocket'
    When I update the document 'hashrocket' with the hash named 'street'
    And the document 'hashrocket' roundtrips
    Then the attribute 'street' of 'hashrocket' is '320 First St N'
