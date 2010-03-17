Feature: Indexes

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

  Scenario: Simple index
    When I create an index named name on the Contact collection
    Then there is an index on name on the Contact collection

