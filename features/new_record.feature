Feature: New record

  Scenario: saving a has_many children document
    Given an empty Contact document collection
    And a Contact document named 'hashrocket' :
      | Name       |
      | Hashrocket |
    And 'hashrocket' has many addresses :
      | Street                 | City               | State | Zip Code |
      | 320 First Street North | Jacksonville Beach | FL    | 32250    |
      | 1 Main Street          | Santiago           | Chile |          |
    When I save the document 'hashrocket'
    Then the first address of 'hashrocket' is not a new record

  Scenario: saving a has_one child document
    Given an empty Place document collection
    And a Place document named 'hashrocket' :
      | Name       |
      | Hashrocket |
    And 'hashrocket' has one Address as address :
      | Street                 | City               | State | Zip Code |
      | 320 First Street North | Jacksonville Beach | FL    | 32250    |
    When I save the document 'hashrocket'
    Then the address of 'hashrocket' is not a new record

  Scenario: id is roundtripped when saving a has_one child document
    Given an empty Place document collection
    And a Place document named 'hashrocket' :
      | Name       |
      | Hashrocket |
    And 'hashrocket' has one Address as address :
      | Street                 | City               | State | Zip Code |
      | 320 First Street North | Jacksonville Beach | FL    | 32250    |
    When I save the document 'hashrocket'
    Then the address of 'hashrocket' roundtrips

