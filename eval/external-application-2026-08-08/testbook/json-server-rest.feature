# Test book -- json-server, the documented REST API.
#
# REQUIREMENT SOURCE, SINGLE AND EXTERNAL: the README.md of `typicode/json-server` at commit
# 8fb0f72 (2024-05-13). Nothing else. Neither the code, nor the project's own tests, nor its
# issues, nor its fix commits were read before this book was written.
#
# This book was not written to catch a known defect: it was written to cover a published
# contract. That is the only way its result means anything.
#
# Open questions -- the README does not settle them. They are marked `# open: Qn` on the
# scenarios they touch and NONE is resolved by assumption (ADR 0001: an ambiguity is declared,
# not guessed).
#
#   Q1  Operators are listed `lt`, `lte`, `gt`, `gte`, `ne`, but the example writes
#       `?views_gt=9000`. Is the prefix the field name or a standalone underscore?
#       Taken here: `field_op`, the only form an example shows.
#   Q2  Pagination is listed `page`, `per_page` and shown `_page`, `_per_page`. Same for range:
#       listed `start`, `end`, `limit`, shown `_start`, `_end`, `_limit`. Taken: the shown form.
#   Q3  **The shape of a paginated response is documented nowhere.** An array? an envelope with
#       a total? No scenario asserts the shape: that would be inventing the requirement.
#   Q4  **No status code is documented, for any route.** Not success, not absence, not invalid
#       input. Scenarios below assert a code only where the README promises behaviour that is
#       observable some other way (response body, effect on the data).
#   Q5  `_per_page` defaults to 10. Behaviour past the last page is not stated.
#   Q6  `_embed=post` (singular) is shown for `comments` without the naming rule -- plural to
#       singular, foreign key `postId` -- ever being stated.
#   Q7  `_dependent=comments` deletes dependants; neither the response nor the fate of orphaned
#       dependants when the parent does not exist is stated.
#
# Reference database: the one published in the README (posts with `views` 100 and 200, two
# comments attached to post 1, a singular `profile` object).

Feature: Serve a JSON file as a REST API

  Background:
    Given a database holding post 1 with 100 views and post 2 with 200 views
    And two comments attached to post 1
    And a singular profile object

  @QAIA-EXT-001 @routes @P1
  Scenario: The whole collection is returned
    When I request GET /posts
    Then I receive both posts, 1 and 2

  @QAIA-EXT-002 @routes @P1
  Scenario: An item is returned by its identifier
    When I request GET /posts/1
    Then I receive post 1 with the title "a title"

  @QAIA-EXT-003 @routes @P1 @negative
  Scenario: A missing identifier returns no resource
    # open: Q4 -- the README states no code. The assertion holds to what it does promise:
    # there is no post 999, so the response cannot be a post 999.
    When I request GET /posts/999
    Then the response carries no resource with identifier 999

  @QAIA-EXT-004 @routes @P1 @negative
  Scenario: A missing collection returns no data
    When I request GET /nonexistent
    Then the response carries no resource

  @QAIA-EXT-005 @routes @P1
  Scenario: The singular profile object is readable
    When I request GET /profile
    Then I receive an object whose name is "typicode"

  @QAIA-EXT-006 @write @P1
  Scenario: An identifier is generated when missing
    # README, "Notable differences": id is always a string and will be generated if missing
    When I create a post with no identifier
    Then the created resource carries an identifier
    And that identifier is a string

  @QAIA-EXT-007 @write @P1
  Scenario: An identifier is always a string
    When I request GET /posts
    Then every post identifier is a string

  @QAIA-EXT-008 @write @P1
  Scenario: PUT replaces the resource
    When I replace an existing post with the title "replaced"
    Then reading that post back gives the title "replaced"

  @QAIA-EXT-009 @write @P1
  Scenario: PATCH changes one field and keeps the others
    When I patch only the title of an existing post with 42 views
    Then reading it back gives the new title
    And its view count is still 42

  @QAIA-EXT-010 @write @P1
  Scenario: DELETE removes the resource
    When I delete an existing post
    Then that post is no longer in the collection

  @QAIA-EXT-011 @write @P1
  Scenario: PATCH on the singular profile object
    When I patch the profile with the name "changed"
    Then reading the profile back gives the name "changed"

  @QAIA-EXT-012 @conditions @P1
  Scenario: Implicit equality on a field
    When I request GET /posts?views=200
    Then I receive post 2 only

  @QAIA-EXT-013 @conditions @P1
  Scenario: Greater than
    When I request GET /posts?views_gt=100
    Then I receive post 2 only

  @QAIA-EXT-014 @conditions @P1 @boundary
  Scenario: Greater than excludes the exact value
    # Boundary: 200 is a post's exact value and must be excluded by `gt`.
    When I request GET /posts?views_gt=200
    Then I receive no post

  @QAIA-EXT-015 @conditions @P1 @boundary
  Scenario: Greater than or equal includes the exact value
    When I request GET /posts?views_gte=200
    Then I receive post 2 only

  @QAIA-EXT-016 @conditions @P1
  Scenario: Less than
    When I request GET /posts?views_lt=200
    Then I receive post 1 only

  @QAIA-EXT-017 @conditions @P1 @boundary
  Scenario: Less than or equal includes the exact value
    When I request GET /posts?views_lte=100
    Then I receive post 1 only

  @QAIA-EXT-018 @conditions @P1 @negative
  Scenario: Not equal excludes the given value
    When I request GET /posts?views_ne=100
    Then I receive post 2 only

  @QAIA-EXT-019 @conditions @P1
  Scenario: Two conditions on the same field combine
    # The README documents the operators without forbidding their combination; two bounds
    # framing post 2 alone is the weakest reading available.
    When I request GET /posts?views_gt=100&views_lt=300
    Then I receive post 2 only

  @QAIA-EXT-020 @conditions @P1 @negative
  Scenario: A condition on an absent field returns nothing
    When I request GET /posts?absent_field=value
    Then I receive no post

  @QAIA-EXT-021 @range @P1
  Scenario: _limit bounds the number of items
    When I request GET /posts?_limit=1
    Then I receive exactly one post

  @QAIA-EXT-022 @range @P1
  Scenario: _start shifts the beginning
    When I request GET /posts?_start=1
    Then I receive post 2 only

  @QAIA-EXT-023 @range @P1 @boundary
  Scenario: _start and _end delimit a slice
    When I request GET /posts?_start=0&_end=1
    Then I receive post 1 only

  @QAIA-EXT-024 @pagination @P1
  Scenario: A page of size one carries one item
    # open: Q3 -- the response shape is undocumented, so the assertion holds to the number of
    # data items, whatever envelope carries them.
    When I request GET /posts?_page=1&_per_page=1
    Then the response carries exactly one post

  @QAIA-EXT-025 @pagination @P1
  Scenario: The second page carries the next item
    When I request GET /posts?_page=2&_per_page=1
    Then the response carries post 2 only

  @QAIA-EXT-026 @sort @P1
  Scenario: Ascending sort on a numeric field
    When I request GET /posts?_sort=views
    Then the posts arrive in the order 1 then 2

  @QAIA-EXT-027 @sort @P1
  Scenario: A minus prefix reverses the sort
    When I request GET /posts?_sort=-views
    Then the posts arrive in the order 2 then 1

  @QAIA-EXT-028 @embed @P1
  Scenario: A post embeds its comments
    When I request GET /posts?_embed=comments
    Then post 1 carries both of its comments

  @QAIA-EXT-029 @embed @P1
  Scenario: A comment embeds its post
    # open: Q6 -- the naming rule is not stated, only the example is.
    When I request GET /comments?_embed=post
    Then every comment carries post 1

  @QAIA-EXT-030 @cascade @P1
  Scenario: _dependent deletes the dependent resources
    When I delete a post with _dependent=comments
    Then no comment attached to that post remains

  @QAIA-EXT-031 @nested @P2
  Scenario: Filtering on a nested field
    # README: GET /foo?a.b=bar
    Given a foo resource whose a.b is "bar"
    When I request GET /foo?a.b=bar
    Then I receive that resource only

  @QAIA-EXT-032 @nested @P2
  Scenario: Filtering on an array element by index
    # README: GET /foo?arr[0]=bar
    Given a foo resource whose first array element is "bar"
    When I request GET /foo?arr[0]=bar
    Then I receive that resource only
