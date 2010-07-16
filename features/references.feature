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
    And an Address document named 'old_office' :
      | City          |
      | New York City |

  Scenario: Automatically dereferences in references association
    When I save the document 'office'
    And 'Fry' references 'office' as 'address'
    And I save the document 'Fry'
    And the document 'Fry' is reloaded
    Then 'Fry' refers to 'office' as 'address'

  Scenario: Automatically dereferences in references_many association
    When I save the document 'old_office'
    And 'Fry' references 'old_office' through 'previous_addresses'
    And I save the document 'Fry'
    And the document 'Fry' is reloaded
    Then 'Fry' has 'previous_addresses' that include 'old_office'
