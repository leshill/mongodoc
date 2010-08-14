Feature: DBReferences

  Background:
    Given an empty Character document collection
    And a Character document named 'Fry' :
      | Name          |
      | Philip J. Fry |
    And an empty Address document collection
    And an Address document named 'office' :
      | City              |
      | New New York City |
    And an Address document named 'old_office' :
      | City          |
      | New York City |

  Scenario: Automatically dereferences in db_references association
    When I save the document 'office'
    And 'Fry' references 'office' as 'address'
    And I save the document 'Fry'
    And the document 'Fry' is reloaded
    Then 'Fry' refers to 'office' as 'address'
