# Produced by contract-probe (plugins/qaia-playwright/skills/contract-probe/SKILL.md), step 5.
# Each scenario below reproduces a CONFIRMED deviation between restful-api.dev's own documented
# promise and its observed behaviour on 2026-07-30. Every `# contract:` comment cites the exact
# promise, and every `# observed:` line cites the real response captured in probe/*.log.
# No fix was applied to the target — contract-probe proposes evidence, a human decides (D26/D35).
# ID space @QAIA-CP-NNN is separate from the spec-first book's @QAIA-RAD-PUBOBJ-NNN.
Feature: restful-api.dev deviations from its own documented contract

  Background:
    Given no authentication credentials are sent with the request

  @QAIA-CP-001 @negative @AC10 @error-guessing
  # contract: restful-api.dev homepage, feature grid, "HTTPS Support" tile —
  #   "Secure connections via SSL/TLS for all API endpoints."
  # observed: probe/probe-part1.log P11 — GET http://api.restful-api.dev/objects/7 (plain HTTP)
  #   answered HTTP/1.1 200 OK and served the complete JSON body over the unencrypted
  #   connection. No redirect to HTTPS, and probe-part4.log P36 confirms no
  #   Strict-Transport-Security header is set on the HTTPS response either.
  # This is the same condition as AC10-C1 / @QAIA-RAD-PUBOBJ-026, which therefore FAILS.
  Scenario: The API serves content over plain HTTP despite promising TLS on all endpoints
    Given the documentation promises SSL/TLS for all API endpoints
    When a client requests an object over plain http instead of https
    Then the response status is 200 and the full object payload is served unencrypted

  @QAIA-CP-002 @negative @AC4 @error-guessing
  # contract: restful-api.dev public endpoint "Add a new object" (bundle main.d176a2fe.js,
  #   response constant Sp) documents the creation response as
  #   {"id":"7","name":"...","data":{...},"createdAt":"2022-11-21T20:06:23.986Z"}
  #   — createdAt is an ISO-8601 date-time STRING.
  # observed: probe/probe-part1.log P5 — the real response carried
  #   "createdAt":1785452985631, a bare epoch-milliseconds NUMBER. Reproduced on every
  #   creation in the run (P5, P6, P8, P13, P14, P26, P27, P35).
  Scenario: The creation response returns createdAt as an epoch number rather than the documented ISO-8601 string
    Given a valid creation payload carrying a name and a data object
    When a client sends POST /objects with that payload
    Then the response "createdAt" is a JSON number of epoch milliseconds
    And it is not the ISO-8601 date-time string the documentation shows

  @QAIA-CP-003 @negative @AC6 @error-guessing
  # contract: public endpoints "Update an object" / "Partially update an object" (constants
  #   Cp and Tp) both document "updatedAt":"2022-12-25T21:08:41.986Z" — an ISO-8601 string.
  # observed: probe/probe-part3.log P29 returned "updatedAt":1785453084842 and P31 returned
  #   "updatedAt":1785453085399 — epoch-millisecond numbers, same deviation as CP-002.
  Scenario: The update response returns updatedAt as an epoch number rather than the documented ISO-8601 string
    Given an object created by this suite
    When a client sends PUT for that object with a complete body
    Then the response "updatedAt" is a JSON number of epoch milliseconds
    And it is not the ISO-8601 date-time string the documentation shows

  @QAIA-CP-004 @negative @AC5 @boundary
  # contract: public endpoint "Add a new object" — "The data field accepts any valid JSON
  #   structure - objects, arrays, or key-value pairs - allowing flexible and custom data
  #   formats." (emphasised in the source with <strong><u>).
  # observed: a payload whose only unusual feature is a non-ASCII character in a data VALUE,
  #   sent as raw UTF-8 bytes under the canonical media type `application/json`, is refused
  #   with 400 {"error":"Invalid request body"} — probe-part1.log P7 and probe-part3.log P25,
  #   reproduced twice. The payload is well-formed JSON: RFC 8259 s8.1 requires JSON exchanged
  #   between systems to be UTF-8, and the `application/json` media type defines NO charset
  #   parameter. Isolation (single-variable probes) proves the trigger is the character
  #   encoding, not the JSON structure:
  #     probe-part2.log P13 depth-4 nesting, ASCII         -> 200
  #     probe-part2.log P14 spaced key "deep key"          -> 200
  #     probe-part3.log P26 same char, charset=utf-8 stated-> 200
  #     probe-part4.log P35 same char as à ASCII escape-> 200
  #   Only the raw-UTF-8-without-charset combination fails.
  Scenario: Well-formed UTF-8 JSON is refused unless the client redundantly declares a charset
    Given a creation payload whose data value contains a non-ASCII character as raw UTF-8
    When a client sends POST /objects with the canonical content type application/json
    Then the request is refused with a 400 client-error status
    And the same payload is accepted when the client adds charset=utf-8 to the content type
