Feature: Polymorphic Collections

  Background:
    Given an empty Person document collection
    And a Person document named 'Fry' :
      | Name          |
      | Philip J. Fry |
    And a VIP document named 'Leela' :
      | Name          | Title   |
      | Turanga Leela | Captain |

  Scenario: Subclassed documents are in the same collection
    Given I save the document 'Fry'
    And I save the document 'Leela'
    When I query people with count
    Then the query result is 2 documents
