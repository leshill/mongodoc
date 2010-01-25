Feature: Removing Documents

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
    And a Place document named 'hashrocket_hq' :
      | Name       | Type    |
      | Hashrocket | company |
    And 'hashrocket_hq' has one Address as address (identified by 'hq_address'):
      | Street                 | City               | State | Zip Code |
      | 1 Main St.             | Jacksonville       | FL    | 32218    |
    And I save the document 'hashrocket_hq'

  Scenario: Simple Remove
    Given the document 'contractor' roundtrips
    When I remove 'contractor'
    Then the document 'contractor' is not found

  Scenario: Embedded Remove
    When the document 'hashrocket_hq' roundtrips
    Then an exception is raised if I remove 'hq_address'
