Feature: Partial Updates

  Background:
    Given an empty Contact document collection
    And a Contact document named 'hashrocket' :
      | Name       | Type    | Note                            |
      | Hashrocket | company | Premier Rails development shop! |
    And 'hashrocket' has interests, an array of:
      | Interest      |
      | ruby          |
      | rails         |
      | employment    |
      | contract work |
      | restaurants   |
      | hotels        |
      | flights       |
      | car rentals   |
    And 'hashrocket' has many addresses :
      | Street                 | City               | State | Zip Code |
      | 320 First Street North | Jacksonville Beach | FL    | 32250    |
      | 1 Lake Michigan Street | Chicago            | IL    | 60611    |
      | 1 Main Street          | Santiago           | Chile |          |
    And I save the document 'hashrocket'
    And a Contact document named 'rocketeer' :
      | Name           | Note                |
      | Rocketeer Mike | Fantastic developer |
    And 'rocketeer' has interests, an array of:
      | Interest    |
      | ruby        |
      | rails       |
      | restaurants |
      | employment  |
    And 'rocketeer' has many addresses :
      | Street                 | City               | State | Zip Code |
      | 1 Main Street          | Atlantic Beach     | FL    | 32233    |
    And I save the document 'rocketeer'
    And a Contact document named 'contractor' :
      | Name           | Note          |
      | Contractor Joe | Knows MongoDB |
    And 'contractor' has interests, an array of:
      | Interest      |
      | ruby          |
      | rails         |
      | contract work |
      | flights       |
      | car rentals   |
      | hotels        |
      | restaurants   |
    And 'contractor' has many addresses :
      | Street                 | City               | State | Zip Code |
      | 1 Main St.             | Jacksonville       | FL    | 32218    |
    And I save the document 'contractor'
    And an empty Place document collection
    And a Place document named 'hashrocket_hq' :
      | Name       | Type    |
      | Hashrocket | company |
    And 'hashrocket_hq' has one Address as address (identified by 'hq_address'):
      | Street                 | City               | State | Zip Code |
      | 1 Main St.             | Jacksonville       | FL    | 32218    |
    And I save the document 'hashrocket_hq'

  Scenario: Naive Update
    When I update the 'note' for 'contractor' to 'Knows MongoDB and MongoDoc'
    Then the document 'contractor' roundtrips

  Scenario: Naive Update on a has one
    When I update the 'street' for 'hq_address' to '320 1st Street North'
    Then the document 'hashrocket_hq' roundtrips

  Scenario: Naive Update on a has many
    When 'hq_address' is the first address of 'hashrocket'
    And I update the 'street' for 'hq_address' to '320 1st Street North'
    Then the document 'hashrocket' roundtrips

  Scenario: Strict Update
    When I strict update the 'note' for 'contractor' to 'Knows MongoDB and MongoDoc'
    Then the document 'contractor' roundtrips

  Scenario: Strict Update on a has one
    When I strict update the 'street' for 'hq_address' to '320 1st Street North'
    Then the document 'hashrocket_hq' roundtrips

  Scenario: Strict Update on a has many
    When 'hq_address' is the first address of 'hashrocket'
    And I strict update the 'street' for 'hq_address' to '320 1st Street North'
    Then the document 'hashrocket' roundtrips

  Scenario: Failing Strict Update on a has one
    When someone else changes the Address 'address' of 'hashrocket_hq' to 
      | Street                 | City               | State | Zip Code |
      | 1 Ocean Blvd.          | Jacksonville       | FL    | 32218    |
    And I strict update the 'street' for 'hq_address' to '320 1st Street North'
    Then the last return value is false
    And the document 'hashrocket_hq' does not roundtrip

  Scenario: Failing Strict Update on a has many
    When 'hq_address' is the first address of 'hashrocket'
    And someone else changes the addresses of 'hashrocket':
      | Street                 | City               | State | Zip Code |
      | 320 1st N, #712        | Jacksonville Beach | FL    | 32250    |
      | 1001 Mulligan Street   | Chicago            | IL    | 60611    |
      | 345 Avenida Grande     | Santiago           | Chile |          |
    And I strict update the 'street' for 'hq_address' to '320 1st Street North'
    Then the last return value is false
    And the document 'hashrocket' does not roundtrip
