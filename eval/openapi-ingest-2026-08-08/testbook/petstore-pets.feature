# Test book -- Swagger Petstore, /pet operations.
#
# REQUIREMENT SOURCE: the OpenAPI 3.0.4 document at `sources/petstore-openapi-1.0.27.json`,
# frozen and hashed in REQUIREMENT-SOURCE.json. Nothing else. No request was sent to the Petstore
# server: it is not ours.
#
# Every scenario below states what the SPECIFICATION PROMISES. None states what the API does --
# confirming or refuting that is `contract-probe`'s job, and merging the two turns a specification
# into a rubber stamp.
#
# Scope: the four /pet operations that carry enough schema to derive from. The remaining 15
# operations of the document are not covered here; this book is a derivation sample, not a suite.
#
# Open questions -- the specification contradicts itself or is silent. NONE is resolved by
# guessing. A specification-derived book that quietly picks a reading is worse than a prose-derived
# one, because its precision is misleading.
#
#   Q1  `GET /pet/findByStatus`: the `status` parameter is `required: true` AND carries
#       `default: "available"`. If it is required the default is unreachable; if the default
#       applies it is not required. The document does not say which wins, so no scenario asserts
#       the behaviour when `status` is omitted.
#   Q2  `Pet.status` is an enum of `available|pending|sold`. The same-named query parameter of
#       `POST /pet/{petId}` is typed `string` with no enum. Two promises about one field.
#   Q3  **Nine of the nineteen operations declare a `security` scheme, and not one operation in
#       the whole document declares a 401 or a 403.** The entire authorization refusal path is
#       unspecified -- and that is where the interesting defects live.
#   Q4  `Pet.id` has no `readOnly` and no constraint. Whether a client may choose its own
#       identifier on creation is not stated.
#   Q5  `photoUrls` is required and typed as an array of strings, with no `minItems` and no
#       `format: uri`. An empty array and the string "x" both satisfy it.

Feature: Petstore /pet operations, as the specification promises them

  Background:
    Given the Swagger Petstore OpenAPI document version 1.0.27
    And the Pet schema requires the fields "name" and "photoUrls"

  @QAIA-OAS-001 @findByStatus @partition @P1
  Scenario Outline: findByStatus accepts each value of its declared enum
    When a client calls GET /pet/findByStatus with status "<status>"
    Then the specification declares a 200 response carrying an array of Pet

    Examples:
      | status    |
      | available |
      | pending   |
      | sold      |

  @QAIA-OAS-002 @findByStatus @partition @negative @P1
  Scenario: findByStatus rejects a value outside its enum
    # The invalid partition of an enum is the half that finds defects. The document declares
    # 400 "Invalid status value" for this operation, so the expected outcome is stated, not guessed.
    When a client calls GET /pet/findByStatus with status "extinct"
    Then the specification declares a 400 response

  @QAIA-OAS-003 @findByStatus @P2
  Scenario: findByStatus omitted entirely
    # open: Q1 -- required and defaulted at once. No outcome is asserted because the document
    # states two incompatible ones. This scenario exists to carry the question, not to pass.
    When a client calls GET /pet/findByStatus with no status parameter
    Then the outcome is undetermined by the specification

  @QAIA-OAS-004 @create @P1
  Scenario: A pet carrying every required field is accepted
    When a client calls POST /pet with a body carrying "name" and "photoUrls"
    Then the specification declares a 200 response carrying the created Pet

  @QAIA-OAS-005 @create @negative @P1
  Scenario Outline: A pet missing one required field is refused
    # One refusal path per required field, omitted in turn. The document declares 400
    # "Invalid input" and 422 "Validation exception" for this operation without stating which
    # applies to which case, so the scenario asserts refusal, not a particular code.
    When a client calls POST /pet with a body omitting "<field>"
    Then the specification declares a refusal response for this operation

    Examples:
      | field     |
      | name      |
      | photoUrls |

  @QAIA-OAS-006 @create @negative @P2
  Scenario: A pet whose status is outside the Pet enum
    When a client calls POST /pet with status "extinct"
    Then the specification declares a refusal response for this operation

  @QAIA-OAS-007 @read @P1
  Scenario: A pet is readable by its identifier
    When a client calls GET /pet/{petId} with an existing integer identifier
    Then the specification declares a 200 response carrying one Pet

  @QAIA-OAS-008 @read @negative @P1
  Scenario: An unknown identifier is refused with a stated code
    # Unlike the json-server campaign, where no status code was documented anywhere, this
    # specification states 404 "Pet not found" explicitly. The expected value is the document's,
    # not ours -- that is the whole gain of a formal source.
    When a client calls GET /pet/{petId} with an identifier that exists for no pet
    Then the specification declares a 404 response

  @QAIA-OAS-009 @read @negative @limits @P1
  Scenario Outline: A non-integer identifier is refused
    # `petId` is typed integer/int64 with no minimum and no maximum, so the only derivable
    # invalid class is the wrong type. The int64 bounds are a format, not a stated constraint --
    # asserting them would be inventing the requirement.
    When a client calls GET /pet/{petId} with the identifier "<value>"
    Then the specification declares a 400 response

    Examples:
      | value |
      | abc   |
      | 1.5   |

  @QAIA-OAS-010 @delete @P1
  Scenario: Deleting a pet by its identifier
    When a client calls DELETE /pet/{petId} with an existing integer identifier
    Then the specification declares a 200 response

  @QAIA-OAS-011 @security @negative @P1
  Scenario: A secured operation called with no credential
    # open: Q3 -- the operation declares `petstore_auth` with the scopes `write:pets` and
    # `read:pets`, and the document declares no 401 and no 403 anywhere. The refusal is therefore
    # required by the security block and unspecified by the response block. No code is asserted.
    When a client calls DELETE /pet/{petId} with no credential
    Then the outcome is undetermined by the specification
