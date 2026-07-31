
### S1 sign-in: visible text
Sign in
Email
Password

Sign in

### S1 sign-in: interactive controls
[
  {
    "tag": "INPUT",
    "id": "email",
    "type": "email",
    "text": "",
    "required": false,
    "placeholder": "",
    "title": ""
  },
  {
    "tag": "INPUT",
    "id": "password",
    "type": "password",
    "text": "",
    "required": false,
    "placeholder": "",
    "title": ""
  },
  {
    "tag": "BUTTON",
    "id": "login-btn",
    "type": "submit",
    "text": "Sign in",
    "title": ""
  }
]

### S1 sign-in: any help/docs affordance?
{
  "linksInDoc": [],
  "elementsMentioningHelp": []
}

### S1 H5: click "Sign in" with BOTH fields empty -> DOM state
{
  "messageEl": "invalid credentials",
  "anyVisibleMsg": [
    {
      "sel": "msg error",
      "text": "invalid credentials",
      "hidden": false
    }
  ],
  "appSectionHidden": true,
  "emailValidity": true
}

### S1 H9: wrong password -> message shown to the user (verbatim)
{
  "messages": [
    "invalid credentials"
  ],
  "bodyTextAfter": "Sign in\nEmail\nPassword\n\nSign in"
}

### CW step 2: time from click to slots screen (ms)
73

### S2 slots: visible text
Signed in as patient@demo · Sign out

Available slots
Filter by specialty
All
Cardiology
Dermatology
Dr. Ada Reed — cardiology — 31/07/2026 03:45:04
Book
Dr. Ada Reed — cardiology — 31/07/2026 01:45:04
Book
Dr. Ben Cole — cardiology — 31/07/2026 05:45:04
Book
Dr. Cara Ng — dermatology — 31/07/2026 04:45:04
Book
Dr. Ada Reed — cardiology — 01/08/2026 02:45:04
Book
invalid credentials
My appointments

### S2 slots: raw HTML of the first slot row
<div class="slot" role="listitem" data-slot-id="s1"><span>Dr. Ada Reed — cardiology — 31/07/2026 03:45:04</span><button data-testid="book-s1">Book</button></div>

### S2 slots: all slot rows (text + button label + disabled)
[
  {
    "text": "Dr. Ada Reed — cardiology — 31/07/2026 03:45:04 | Book",
    "buttons": [
      {
        "label": "Book",
        "disabled": false
      }
    ]
  },
  {
    "text": "Dr. Ada Reed — cardiology — 31/07/2026 01:45:04 | Book",
    "buttons": [
      {
        "label": "Book",
        "disabled": true
      }
    ]
  },
  {
    "text": "Dr. Ben Cole — cardiology — 31/07/2026 05:45:04 | Book",
    "buttons": [
      {
        "label": "Book",
        "disabled": false
      }
    ]
  },
  {
    "text": "Dr. Cara Ng — dermatology — 31/07/2026 04:45:04 | Book",
    "buttons": [
      {
        "label": "Book",
        "disabled": false
      }
    ]
  },
  {
    "text": "Dr. Ada Reed — cardiology — 01/08/2026 02:45:04 | Book",
    "buttons": [
      {
        "label": "Book",
        "disabled": false
      }
    ]
  }
]

### S2 "My appointments" region content when empty
{
  "html": "",
  "text": ""
}

### CW step 3 / H1: DOM 500ms INTO the (artificially slowed) booking request
{
  "firstSlotHTML": "<div class=\"slot\" role=\"listitem\" data-slot-id=\"s1\"><span>Dr. Ada Reed — cardiology — 31/07/2026 03:45:04</span><button data-testid=\"book-s1\">Book</button></div>",
  "clickedButtonDisabled": false,
  "clickedButtonLabel": "Book",
  "messageRegion": "invalid credentials",
  "anySpinnerOrBusy": 0
}

### CW step 4 / H1: DOM AFTER the booking completed
{
  "messageRegion": "Booking confirmed with Dr. Ada Reed",
  "appointments": "Dr. Ada Reed — 31/07/2026 03:45:04 — booked\nCancel",
  "appointmentsHTML": "<div class=\"slot\" role=\"listitem\"><span>Dr. Ada Reed — 31/07/2026 03:45:04 — booked</span><button data-testid=\"cancel-a3\">Cancel</button></div>"
}

### CW: the button label clicked to book was
Book

### H3: controls available on the created appointment
[
  {
    "tag": "BUTTON",
    "text": "Cancel",
    "href": null
  }
]

### H3: every button present anywhere on the signed-in screen
[
  "Sign in",
  "Sign out",
  "Book",
  "Book",
  "Book",
  "Book",
  "Cancel"
]

### S2 (minor, no guardian): slot rows as rendered BEFORE clicking
[
  {
    "text": "Dr. Ada Reed — cardiology — 31/07/2026 01:45:04 | Book",
    "buttons": [
      {
        "label": "Book",
        "disabled": true
      }
    ]
  },
  {
    "text": "Dr. Ben Cole — cardiology — 31/07/2026 05:45:04 | Book",
    "buttons": [
      {
        "label": "Book",
        "disabled": false
      }
    ]
  },
  {
    "text": "Dr. Cara Ng — dermatology — 31/07/2026 04:45:04 | Book",
    "buttons": [
      {
        "label": "Book",
        "disabled": false
      }
    ]
  },
  {
    "text": "Dr. Ada Reed — cardiology — 01/08/2026 02:45:04 | Book",
    "buttons": [
      {
        "label": "Book",
        "disabled": false
      }
    ]
  }
]

### H9: business-rule rejection message (verbatim)
{
  "message": "practitioner not authorized for minors",
  "messageHTML": "practitioner not authorized for minors"
}

### H2: full visible page text on the signed-in screen (jargon scan)
MediBook

Signed in as minor-noguardian@demo · Sign out

Available slots
Filter by specialty
All
Cardiology
Dermatology
Dr. Ada Reed — cardiology — 31/07/2026 01:45:04
Book
Dr. Ben Cole — cardiology — 31/07/2026 05:45:04
Book
Dr. Cara Ng — dermatology — 31/07/2026 04:45:04
Book
Dr. Ada Reed — cardiology — 01/08/2026 02:45:04
Book
practitioner not authorized for minors
My appointments

### Console errors observed during the whole session
[
  "Failed to load resource: the server responded with a status of 401 (Unauthorized)",
  "Failed to load resource: the server responded with a status of 401 (Unauthorized)",
  "Failed to load resource: the server responded with a status of 422 (Unprocessable Entity)"
]