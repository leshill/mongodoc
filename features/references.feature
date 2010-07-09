Feature: References

  Background:
    Given an empty Person document collection
    And a Person document named 'Fry' :
      | Name          |
      | Philip J. Fry |
    And an empty Address document collection
    And an Address document named 'office' :
      | City              |
      | New New York City |

  Scenario: Automatically dereferenced
    When I save the document 'office'
    And 'Fry' references 'office' as 'address'
    And I save the document 'Fry'
    And the document 'Fry' is reloaded
    Then 'Fry' refers to 'office' as 'address'
