# US-EVAL-007 | source: state/03-design.md, conditions AC1-C1..AC3-C2 (P1+P2 default scope)
# Target: http://broken-workshop.dequelabs.com/ (Deque Broken Workshop public demo, purpose-built
# for a11y training -- exploration only, no automated scan/exploit performed)
Feature: Recipe-edit dialog accessibility (Awesome Recipes demo)

  @QAIA-US-EVAL-007-001 @AC1 @P1 @ep
  # condition: AC1-C1
  # known-defect: confirmed live on two independent opens, see state/00-source.md Finding 1 --
  # this scenario asserts the AC's target behavior, expected to currently fail on the live demo.
  Scenario: The edit-recipe dialog exposes an accessible name and is marked modal
    Given the "Edit Chocolate Cake" dialog is open
    Then the dialog's accessible name equals its visible heading text
    And the dialog's "aria-modal" attribute equals "true"

  @QAIA-US-EVAL-007-002 @AC2 @P1 @ep
  # condition: AC2-C1
  # known-defect: confirmed live, see state/00-source.md Finding 2.
  Scenario: Closing the dialog with Escape returns focus to the triggering Edit control
    Given the "Edit Chocolate Cake" dialog is open, having been opened from its recipe's "Edit" control
    When the dialog is closed by pressing Escape
    Then keyboard focus returns to the "Edit" control that opened the dialog

  @QAIA-US-EVAL-007-003 @AC2 @P2 @ep @low-confidence
  # condition: AC2-C2, AC2-C3
  # open: Q1 -- whether the Close icon-button and Cancel button return focus the same way Escape
  # is confirmed NOT to is not confirmed by any source. Proposed default generated below (same
  # broken behavior as Escape): human arbitration or a follow-up direct observation needed.
  Scenario Outline: Closing the dialog via a visible button returns focus to the triggering Edit control (proposed default, unconfirmed)
    Given the "Edit Chocolate Cake" dialog is open, having been opened from its recipe's "Edit" control
    When the dialog is closed using the "<close control>"
    Then keyboard focus returns to the "Edit" control that opened the dialog

    Examples:
      | close control |
      | Close icon    |
      | Cancel button |

  @QAIA-US-EVAL-007-004 @AC3 @P1 @negative @error-guessing
  # condition: AC3-C1
  # known-defect: confirmed live on two independent opens, see state/00-source.md Finding 3 --
  # the live demo currently shows "Ingredient must not be empty" for this case instead.
  Scenario: Leaving an Instruction field empty and saving shows an error naming the Instruction field
    Given the "Edit Chocolate Cake" dialog is open with a required Instruction field left empty
    When the "Save" button is clicked
    Then the "Save" action displays a validation error naming the "Instruction" field as empty
    And the recipe is not saved

  @QAIA-US-EVAL-007-005 @AC3 @P2 @negative @error-guessing @low-confidence
  # condition: AC3-C2
  # open: Q2 -- whether an emptied Ingredient field's error text correctly names "Ingredient" (as
  # opposed to some other mismatch) is not confirmed by any source; only the Instruction-field
  # mismatch (scenario 004) was directly observed. Proposed default generated below (correct
  # wording, hardcoded-string theory from state/02-understanding.md Q2): human arbitration needed.
  Scenario: Leaving an Ingredient field empty and saving shows an error naming the Ingredient field (proposed default, unconfirmed)
    Given the "Edit Chocolate Cake" dialog is open with a required Ingredient field left empty
    When the "Save" button is clicked
    Then the "Save" action displays a validation error naming the "Ingredient" field as empty
    And the recipe is not saved
