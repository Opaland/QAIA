# US-ID: RAD-PUBOBJ | source: state/03-design.md conditions AC1-C1..JRN-C1, state/04-priorities.md
# Target: restful-api.dev public objects API — https://api.restful-api.dev/objects
# Scope: P1 + P2 (29 conditions). P3 deferred by default scope (5 conditions, listed in coverage-matrix.md).
# Knowledge base: absent — no BR-KB-nnn rule applied.
# Every mutation below operates on an object THIS suite created. Reserved demo ids 1-13 are never
# mutated: their mutability is open question Q2 (see synthesis.md).
Feature: restful-api.dev public objects API honours its documented CRUD contract

  Background:
    Given no authentication credentials are sent with the request

  # ---------------------------------------------------------------------------
  # AC1 — the reserved demonstration catalogue
  # ---------------------------------------------------------------------------

  @QAIA-RAD-PUBOBJ-001 @AC1 @P2 @ep
  # condition: AC1-C1
  Scenario: Listing the public catalogue returns an array of objects with string ids
    Given the public objects catalogue is published
    When a client sends GET /objects
    Then the response status is 200
    And the body is a JSON array in which every element carries a string "id" and a "name"

  @QAIA-RAD-PUBOBJ-002 @AC1 @P2 @ep
  # condition: AC1-C2
  Scenario: A catalogue entry whose data is null is returned with data null
    Given the catalogue contains an entry whose "data" is null
    When a client sends GET /objects
    Then that entry appears in the array with "data" exactly null, neither omitted nor replaced by an empty object

  @QAIA-RAD-PUBOBJ-003 @AC1 @P2 @metamorphic
  # condition: AC1-C3
  # metamorphic relation: the documentation promises neither an ordering nor a size for the
  # catalogue, so no literal list can be asserted without inventing a promise; the checkable
  # relation is that the same request twice yields the same set of ids.
  Scenario: Two consecutive identical catalogue reads return the same set of ids
    Given a first GET /objects has been recorded
    When a client sends GET /objects a second time with no intervening write
    Then the set of ids in the second response equals the set of ids in the first, ignoring order

  @QAIA-RAD-PUBOBJ-004 @AC1 @P1 @ep @low-confidence
  # condition: AC1-C4
  # open: Q2 -- the documentation calls ids 1-13 a "reserved selection ... for demonstration
  # purposes" while also stating that POST/PUT/PATCH/DELETE are supported on the public API.
  # Whether the public API may mutate them is unresolved; this scenario only OBSERVES them.
  Scenario: The reserved demonstration objects remain readable
    Given the documented reserved object id 7 is part of the demonstration catalogue
    When a client sends GET /objects/7
    Then the response status is 200 and the body carries id "7" with a non-empty "name"

  # ---------------------------------------------------------------------------
  # AC2 — multi-id filtering
  # ---------------------------------------------------------------------------

  @QAIA-RAD-PUBOBJ-005 @AC2 @P1 @ep
  # condition: AC2-C1
  Scenario: Filtering by several ids returns those objects and excludes all others
    Given the catalogue contains the objects with ids 3, 5 and 10
    When a client sends GET /objects?id=3&id=5&id=10
    Then the response contains exactly the objects with ids 3, 5 and 10 and no other object

  @QAIA-RAD-PUBOBJ-006 @AC2 @P1 @boundary @low-confidence
  # condition: AC2-C3
  # assumption: Q7 -- the documentation does not state the response shape when a filter matches
  # nothing; the proposed safe default is an empty collection rather than an error.
  Scenario: A filter matching no object returns an empty collection rather than an error
    Given no object exists for the requested id
    When a client sends GET /objects with only that unmatched id as a filter
    Then the response status is 200 and the body is an empty JSON array

  @QAIA-RAD-PUBOBJ-007 @AC2 @P1 @error-guessing @low-confidence
  # condition: AC2-C4
  # assumption: Q8 -- ids are documented as strings but every example is numeric, so the
  # behaviour on a non-numeric id value is undefined; only the absence of a server fault and
  # the absence of unrelated data are asserted.
  Scenario: A non-numeric id filter value does not cause a server fault
    Given "abc" is not a valid object id in the catalogue
    When a client sends GET /objects?id=abc
    Then the response status is below 500
    And the body carries no object other than one whose id is "abc"

  # ---------------------------------------------------------------------------
  # AC3 — single read
  # ---------------------------------------------------------------------------

  @QAIA-RAD-PUBOBJ-008 @AC3 @P2 @ep
  # condition: AC3-C1
  Scenario: Reading an existing object returns its id, name and data
    Given an object exists in the catalogue
    When a client sends GET /objects for that object's id
    Then the response status is 200 and the body carries that same id, a "name" and a "data" member

  @QAIA-RAD-PUBOBJ-009 @AC3 @P1 @negative @error-guessing @low-confidence
  # condition: AC3-C2 [req-neg]
  # assumption: Q1 -- no status code is documented anywhere for a non-existent id; the proposed
  # safe default is a client-error refusal. The exact code and error body are NOT asserted,
  # because the source documents none. @oracle:rfc9110 grounds the 4xx class only.
  Scenario: Reading a non-existent object is refused
    Given no object exists for a freshly deleted or never-created id
    When a client sends GET /objects for that id
    Then the request is refused with a 4xx client-error status
    And the body carries no object payload

  @QAIA-RAD-PUBOBJ-010 @AC3 @P1 @error-guessing @low-confidence
  # condition: AC3-C3
  # assumption: Q8 -- same undefined territory as scenario 007, on the path parameter.
  Scenario: A malformed object id in the path does not cause a server fault
    Given "not-an-id" is not a valid object id
    When a client sends GET /objects/not-an-id
    Then the response status is below 500

  # ---------------------------------------------------------------------------
  # AC4 — creation
  # ---------------------------------------------------------------------------

  @QAIA-RAD-PUBOBJ-011 @AC4 @P1 @crud
  # condition: AC4-C1 @oracle:iso-8601
  Scenario: Creating an object returns the submitted payload plus a generated id and creation timestamp
    Given a request body carrying a "name" and a "data" object
    When a client sends POST /objects with that body
    Then the response succeeds and echoes the submitted "name" and "data" unchanged
    And the response adds an "id" and a "createdAt" timestamp in ISO 8601 date-time form

  @QAIA-RAD-PUBOBJ-012 @AC4 @P1 @negative @crud @low-confidence
  # condition: AC4-C2 [req-neg]
  # assumption: Q3 -- the documentation never states that "name" is required; the proposed safe
  # default is that a nameless creation is refused.
  Scenario: Creating an object without a name is refused
    Given a request body that carries a "data" object but no "name"
    When a client sends POST /objects with that body
    Then the request is refused with a client-error status and no object is created

  @QAIA-RAD-PUBOBJ-013 @AC4 @P1 @negative @error-guessing
  # condition: AC4-C3 [req-neg] @oracle:rfc9110
  # Grounded on RFC 9110: a syntactically invalid client payload is a client fault; answering 5xx
  # would attribute the caller's error to the server. Which 4xx is chosen is not asserted.
  Scenario: Creating an object from a syntactically invalid JSON body is refused as a client error
    Given a request body that is not valid JSON
    When a client sends POST /objects with that body
    Then the request is refused with a 4xx client-error status
    And the response status is not a 5xx server error

  @QAIA-RAD-PUBOBJ-014 @AC4 @P1 @negative @error-guessing @low-confidence
  # condition: AC4-C4 [req-neg]
  # assumption: the source documents no media-type rule; a JSON API refusing a non-JSON
  # content type is the proposed safe default.
  Scenario: Creating an object with a non-JSON content type is refused
    Given a well-formed JSON payload sent under the content type text/plain
    When a client sends POST /objects with that request
    Then the request is refused with a client-error status and no object is created

  # ---------------------------------------------------------------------------
  # AC5 — "the data field accepts any valid JSON structure"
  # ---------------------------------------------------------------------------

  @QAIA-RAD-PUBOBJ-015 @AC5 @P1 @domain-analysis
  # conditions: AC5-C1, AC5-C2 (merged: same behaviour, same priority P1, same confidence)
  # The only assertable oracle for "any valid JSON structure" is round-trip identity: the source
  # promises acceptance of the structure, not any particular stored value.
  Scenario Outline: A data field of any JSON structure round-trips unchanged
    Given a creation payload whose "data" member is <structure>
    When a client sends POST /objects with that payload and reads the created object back
    Then the returned "data" is structurally identical to the submitted one

    Examples:
      | structure                                          |
      | a JSON array of three heterogeneous elements       |
      | an object nested three levels deep                 |

  @QAIA-RAD-PUBOBJ-016 @AC5 @P2 @domain-analysis
  # conditions: AC5-C3, AC5-C4 (merged: same behaviour, same priority P2, same confidence)
  # The source's own examples already use the spaced key "CPU model", and the reserved catalogue
  # already contains an entry with data null, so both rows are grounded in the source.
  Scenario Outline: An unusual but valid data payload is accepted and returned unchanged
    Given a creation payload whose "data" member is <payload>
    When a client sends POST /objects with that payload and reads the created object back
    Then the returned "data" is structurally identical to the submitted one

    Examples:
      | payload                                             |
      | an object with a spaced key and a non-ASCII key     |
      | the JSON literal null                               |

  # ---------------------------------------------------------------------------
  # AC6 — complete replacement
  # ---------------------------------------------------------------------------

  @QAIA-RAD-PUBOBJ-017 @AC6 @P1 @state-transition
  # condition: AC6-C1
  # This is the only assertion that distinguishes PUT from PATCH: "completely replaces" means a
  # key present before and absent from the PUT body must disappear.
  Scenario: Replacing an object drops the data keys absent from the request body
    Given an object created by this suite whose "data" carries the keys "year" and "price"
    When a client sends PUT for that object with a "data" carrying only "price"
    Then the stored object's "data" no longer carries "year"

  @QAIA-RAD-PUBOBJ-018 @AC6 @P2 @state-transition @low-confidence
  # condition: AC6-C3
  # assumption: AC5's "any valid JSON structure" freedom is documented for POST only; extending
  # it to PUT is an extrapolation from the cross-AC pass.
  Scenario: Replacing an object may change the JSON shape of its data
    Given an object created by this suite whose "data" is a JSON object
    When a client sends PUT for that object with a "data" that is a JSON array
    Then the stored object's "data" is that JSON array

  @QAIA-RAD-PUBOBJ-019 @AC6 @P1 @negative @state-transition @low-confidence
  # condition: AC6-C4 [req-neg]
  # open: Q4 -- upsert-versus-refuse on PUT is undocumented and both behaviours are defensible.
  # Generated on the tie-break default (refusal) and flagged; the vendor must arbitrate.
  Scenario: Replacing a non-existent object is refused rather than silently creating it
    Given no object exists for the target id
    When a client sends PUT for that id with a complete body
    Then the request is refused with a client-error status and no object is created for that id

  # ---------------------------------------------------------------------------
  # AC7 — partial modification
  # ---------------------------------------------------------------------------

  @QAIA-RAD-PUBOBJ-020 @AC7 @P1 @state-transition
  # condition: AC7-C1
  Scenario: Patching only the name leaves the data block untouched
    Given an object created by this suite whose "data" carries several keys
    When a client sends PATCH for that object with a body carrying only a new "name"
    Then the stored object's "data" is unchanged in every key and value

  @QAIA-RAD-PUBOBJ-021 @AC7 @P1 @state-transition @low-confidence
  # condition: AC7-C3
  # assumption: Q9 -- the documented PATCH example never supplies a "data" key, so the merge
  # depth is undefined. Proposed safe default: depth-1 merge, i.e. a supplied "data" replaces
  # the whole data object. This is the assumption most likely to be plausible-but-wrong.
  Scenario: Patching with a data key replaces the whole data object rather than deep-merging it
    Given an object created by this suite whose "data" carries the keys "year" and "price"
    When a client sends PATCH for that object with a "data" carrying only "colour"
    Then the stored object's "data" carries "colour" and no longer carries "year" or "price"

  @QAIA-RAD-PUBOBJ-022 @AC7 @P1 @negative @error-guessing @low-confidence
  # condition: AC7-C4 [req-neg]
  # assumption: Q1 -- undocumented not-found behaviour; a silent success here would be a phantom write.
  Scenario: Patching a non-existent object is refused
    Given no object exists for the target id
    When a client sends PATCH for that id with a partial body
    Then the request is refused with a client-error status and no object is created for that id

  # ---------------------------------------------------------------------------
  # AC8 — permanent deletion
  # ---------------------------------------------------------------------------

  @QAIA-RAD-PUBOBJ-023 @AC8 @P2 @crud
  # condition: AC8-C1
  Scenario: Deleting an object returns a confirmation naming that object's id
    Given an object created by this suite
    When a client sends DELETE for that object
    Then the response succeeds and its message names that object's id as deleted

  @QAIA-RAD-PUBOBJ-024 @AC8 @P1 @negative @state-transition @low-confidence
  # condition: AC8-C2 [req-neg]
  # assumption: Q1 -- "removes permanently" is only verifiable through the follow-up read, whose
  # status code is undocumented.
  Scenario: Reading a deleted object is refused
    Given an object created by this suite has been deleted
    When a client sends GET for that object's id
    Then the request is refused with a client-error status and the object is not returned

  @QAIA-RAD-PUBOBJ-025 @AC8 @P1 @negative @state-transition @low-confidence
  # condition: AC8-C3 [req-neg]
  # assumption: Q1 -- terminal-state re-entrance (cell "deleted x DELETE" of the state table in
  # 03-design.md). A success message for an operation that deleted nothing would be a false report.
  Scenario: Deleting an already-deleted object is refused rather than reported as a success
    Given an object created by this suite has already been deleted
    When a client sends DELETE for that same id a second time
    Then the request is refused with a client-error status
    And no message claiming the object has been deleted is returned

  # ---------------------------------------------------------------------------
  # AC10 — transport
  # ---------------------------------------------------------------------------

  @QAIA-RAD-PUBOBJ-026 @AC10 @P2 @negative @boundary
  # condition: AC10-C1 [req-neg]
  # contract: "Secure connections via SSL/TLS for all API endpoints" — the boundary is the
  # protocol itself, so the meaningful test is the plain-HTTP side of it.
  Scenario: A plain HTTP request does not serve API content
    Given a client that addresses the objects endpoint over plain HTTP instead of HTTPS
    When that client sends the request
    Then no API payload is served over the unencrypted connection

  # ---------------------------------------------------------------------------
  # Journey (excluded from atomicity accounting and from the negative ratio)
  # ---------------------------------------------------------------------------

  @QAIA-RAD-PUBOBJ-027 @AC4 @AC6 @AC7 @AC8 @P2 @smoke @crud
  # condition: JRN-C1
  Scenario: A client completes the full public object lifecycle end to end
    Given a client with no account on the public API
    When that client creates an object, reads it back, replaces it, patches it and deletes it
    Then the lifecycle completes with the object no longer retrievable at the end
