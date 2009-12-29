Feature: MongoDoc::Base

  Scenario: creating a simple document
    Given an empty Address document collection
    And a hash named 'hashrocket':
      | Street                 | City               | State | Zip Code |
      | 320 First Street North | Jacksonville Beach | FL    | 32250    |
    When I create an Address 'address' from the hash 'hashrocket'
    Then 'address' is not a new record
    And the Address collection should have 1 document
    And the document 'address' roundtrips

  Scenario: saving a simple document
    Given an empty Address document collection
    And an Address document named 'hashrocket' :
      | Street                 | City               | State | Zip Code |
      | 320 First Street North | Jacksonville Beach | FL    | 32250    |
    When I save the document 'hashrocket'
    Then 'hashrocket' is not a new record
    And the Address collection should have 1 document
    And the document 'hashrocket' roundtrips

  Scenario: updating an attribute of a simple document
    Given an empty Address document collection
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

  Scenario: failing to update an attribute of a simple document
    Given an empty Address document collection
    And an Address document named 'hashrocket' :
      | Street                 | City               | State | Zip Code |
      | 320 First Street North | Jacksonville Beach | FL    | 32250    |
    And a hash named 'street':
      | Street         |
      | 320 First St N |
    And I save the document 'hashrocket'
    And I set the id on the document 'hashrocket' to 1
    When I update the document 'hashrocket' with the hash named 'street'
    Then the last return value is false

  Scenario: saving a has_many document
    Given an empty Contact document collection
    And a Contact document named 'hashrocket' :
      | Name       |
      | Hashrocket |
    And 'hashrocket' has many addresses :
      | Street                 | City               | State | Zip Code |
      | 320 First Street North | Jacksonville Beach | FL    | 32250    |
      | 1 Main Street          | Santiago           | Chile |          |
    When I save the document 'hashrocket'
    Then 'hashrocket' is not a new record
    And the Contact collection should have 1 document
    And the document 'hashrocket' roundtrips

  Scenario: saving from a child document
    Given an empty Contact document collection
    And a Contact document named 'hashrocket' :
      | Name       |
      | Hashrocket |
    And 'hashrocket' has many addresses :
      | Street                 | City               | State | Zip Code |
      | 320 First Street North | Jacksonville Beach | FL    | 32250    |
      | 1 Main Street          | Santiago           | Chile |          |
    When I save the last document
    Then 'hashrocket' is not a new record
    And the Contact collection should have 1 document
    And the document 'hashrocket' roundtrips

  Scenario: failing to update attributes from a has_many child document
    Given an empty Contact document collection
    And a Contact document named 'hashrocket' :
      | Name       |
      | Hashrocket |
    And 'hashrocket' has many addresses :
      | Street                 | City               | State | Zip Code |
      | 320 First Street North | Jacksonville Beach | FL    | 32250    |
      | 1 Main Street          | Santiago           | Chile |          |
    And I save the last document
    And that @last is named 'chile'
    And a hash named 'street':
      | Street         |
      | 1a Calle       |
    When I update the document 'chile' with the hash named 'street'
    Then the last return value is false

  Scenario: update attributes from a has_one child document
    Given an empty Place document collection
    And a Place document named 'hashrocket' :
      | Name       |
      | Hashrocket |
    And 'hashrocket' has one Address as address :
      | Street                 | City               | State | Zip Code |
      | 320 First Street North | Jacksonville Beach | FL    | 32250    |
    And I save the last document
    And that @last is named 'address'
    And a hash named 'street':
      | Street         | City    |
      | 320 1st St. N. | Jax Bch |
    When I update the document 'address' with the hash named 'street'
    Then the Place collection should have 1 document
    And the document 'hashrocket' roundtrips

  Scenario: Finder
    Given an empty Contact document collection
    And a Contact document named 'hashrocket' :
      | Name       | Type    |
      | Hashrocket | company |
    And I save the last document
    When I query contacts with find {:where => {'type' => 'company'}}
    Then the size of the last return value is 1
