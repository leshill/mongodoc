Feature: Named Scopes

  Background:
    Given an empty Contact document collection
    And a Contact document named 'hashrocket' :
      | Name       | Type    |
      | Hashrocket | company |
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
      | Name           |
      | Rocketeer Mike |
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
      | Name          |
      | Contractor Joe |
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

  Scenario: Simple named scope
    When I query contacts with scope 'rubyists'
    Then the query result has 3 documents

  Scenario: Simple chained scope
    When I query contacts with scopes 'rubyists, contract_work'
    Then the query result has 2 documents
    And one of the query results is the document 'contractor'
