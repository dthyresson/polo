Polo
====

Polo is a back end for an poll and voting Android app.

It provides the JSON API for the app and a web front end to cast a vote.

Getting Started
---------------

This repository comes equipped with a self-setup script:

    % ./bin/setup

After setting up, you can run the application using [foreman]:

    % foreman start

[foreman]: http://ddollar.github.io/foreman/

Be sure to create a secret_key_base environment variable 

    % export SECRET_KEY_BASE="xxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"

in your ``.env`` file.

Guidelines
----------

Use the following guides for getting things done, programming well, and
programming in style.

* [Protocol](http://github.com/thoughtbot/guides/blob/master/protocol)
* [Best Practices](http://github.com/thoughtbot/guides/blob/master/best-practices)
* [Style](http://github.com/thoughtbot/guides/blob/master/style)

---

#[fit]Poll

---

##Which running shoes should I buy?
- Nike
- Adidas

![](nike_adidas.jpg)

---

##Which running shoes should I buy?
- Nike **82%**
- Adidas **18%**

So ...

You should buy the Nikes. Just do it.

![](nike_adidas.jpg)

---
# Actors

- **Author** - Owner and user of the app that creates a **Poll** and sends it to several contacts for voting over SMS/MMS.
- **Voter** - A contact who receives the **Poll** and is prompted to visit a web form to vote for a choice
- **SMS/MMS Gateway (Twilio)** - Sends the poll detail to recipients.

---

# Entities

- **Poll**
- **Choice**
- **Vote**
- **Poll Result**

---

# **Poll**

- A **Poll** poses a question with only at least two possible **Choices** (UI can limit to two)
- **Choices** can be any text
- A **Poll** may or may not have an accompanying image to support the question.
- A **Poll** author submits a **Poll** via the Android App and selects from a list of contact phone numbers (**Voters**) to whom the **Poll** should be sent via text (SMS/MMS) to **Vote**

---

# **Poll** ...

- The **Poll** author can manually close the **Poll** at anytime
- Manually setting the **Poll** to closed is the only way to halt voting (ie, the **Poll** does not automatically expire)

---

# **Vote**

- **Voter** votes on the **Outcome** in response to the question asked
- **Voter** votes via a web form interface outside of the app and apart from the text message

---

# Choice

- Each recipient will be sent a **unique url** where when visited then can **Vote**
- Uniqueness may be via a token stored on this entity
- The **Choice** belongs to the **Poll** and the **Voter**
- Once the **Poll** is closed, **Votes** cannot be cast

---

# **Poll Results**

- The collection and aggregate results of all Choices
- The **Poll** author will receive live results showing the voting progress
- The winning result is the **Choice** with a major of **Votes** (or tie)
- The **Poll** author doesn't necessarily need to know who voted one way or the other, but this data should be available

---

# JSON API

- POST poll with textual question, optional image and list of recepient phone numbers
- GET "my" polls
- GET "my" poll with result
- UPDATE poll to close it

---

# Rails Back End

- Create poll with textual question, optional image, and voting options and list of contact phone numbers
- Generate **Votes** for each **Recipient** where the **Choice** is not yet set
- Images for Twilio gateway need to be a publically accessible URL
- Images therefore need to be stored on a CDN or AWS

---

# Rails Back End ...

- Generate unique url for each recipient with token identifying them and the poll
- Update **Vote** for **Voter** with **Choice**
- Calculate popularity of **Choice** when **Vote** is cast
- Queue up delayed jobs to send to SMS/MMS Gateway

---

# Web UI

- Form for a **Vote** where the **Voter** picks a **Choice**
- Must gracefully handle if voting is closed
- After submit shows current results?

---

# Models

---

# Author

+ has_many :devices
- name : string
- phone_number : string


---

# Device
- belongs_to :author
- device_id : string

---

# Voter

- phone_number : string

---

#Poll

- author : references
- question : text
- photo : attachment
- styles : {web, app, mms}

+ has_many :choices
+ has_many votes, through: :choices

---

# Poll ... methods

- #closed?
- .for_author(author)

---

# Choice
- title : string

+ belongs_to :poll
+ belongs_to :voter
+ has_many :votes

- popularity : float
- votes_count : integer (counter cache?)
- calculate_popularity - delayed method calculate 

---

# Vote

- voter : belongs_to
- poll : belongs_to
- choice : belongs_to
- url_token : string

Thinking that toekn can be the hashid

+ notify - delayed method to send a SMS/MMS that grabs content from :poll and :author (who sent, photo, question text)


