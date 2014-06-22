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

Environment 
-----------

Be sure to create a secret_key_base environment variable 

    % export SECRET_KEY_BASE="xxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"

in your ``.env`` file.

Be sure to install ImageMagick for Paperclip photo attachments.

    brew install imagemagick

and have the lastest libtool since Paperclip require this.

    brew install libtool

Be sure to setup environment variables for Twilio

    export TWILIO_ACCOUNT_SID="AC2fbca92xxxxxxe45a5dedbe414bec340"
    export TWILIO_AUTH_TOKEN="4ae82bb084f1d99cf7b6c82c14baxxxx"
    export TWILIO_PHONE_NUMBER="+16175555555"

Be sure to setup environment variables for creating the hashid for the vote short_url

    export HASHID_MINIMUM_LENGTH=6
    export HASHID_SALT="MARCO POLO, the subject of this memoir, was born at Venice in the year 1 254."

Note that all but ``SECRET_KEY_BASE`` will default to certain values, but can be overidden by environment settings.

Sample .env file
----------------

You can setup a ``.env`` file for these variable settings.

    export SECRET_KEY_BASE="xxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"

    export HASHID_MINIMUM_LENGTH=6
    export HASHID_SALT="MARCO POLO, the subject of this memoir, was born at Venice in the year 1 254."

    export TWILIO_ACCOUNT_SID="AC2fbca92xxxxxxe45a5dedbe414bec340"
    export TWILIO_AUTH_TOKEN="4ae82bb084f1d99cf7b6c82c14baxxxx"
    export TWILIO_PHONE_NUMBER="+16175555555"


Guidelines
----------

Use the following guides for getting things done, programming well, and
programming in style.

* [Protocol](http://github.com/thoughtbot/guides/blob/master/protocol)
* [Best Practices](http://github.com/thoughtbot/guides/blob/master/best-practices)
* [Style](http://github.com/thoughtbot/guides/blob/master/style)

Models
======

* **Poll** - Asks a question or shows photo, presents choices and has people cast votes for their choice 
* **Choice** - An option with a title such as "Yes" or "No"
* **Author** - Creates a poll for people to vote on. They have a device id.
* **Device** - Represents the author and an id identifying their mobile phone
* **Voter** - Casts a vote for a choice
* **Vote** - Belongs to a single voter and a poll. It contains their choice.

Cardinality
-----------

    Poll
      Device 
        Author 
      Choices (0..n) -- but should be 2
      Votes (0..n) -- one for each poll phone_number notified
        Voter 
        Choice

Poll
----

A poll asks a question or shows a photo. It must have one or the other; it can also choice both a question and photo.

A poll has many choices. There is no limit to the number of choices, but a poll should have two choices with titles, typically "Yes" or "No". However, the choice title can be any text, such as "Red" or "Black". Poll choices are ordered reverse alphabetically by title so that "Yes" comes before "No".

A poll must have an author. An author has a device whose device_id is a value that identifies their mobile device.

A poll must have an array of phone numbers. When published poll will create votes and a voter for each phone number provided. This allows the voter to cast their vote for one of the choices.

Phone numbers are used to SMS the voter via Twilio. There is no current validation of phone numbers. Note that Twilio only supports US phone numbers.

This is performed by calling

    @poll.delay.publish_to_voters

using Delayed Job to queue up sending each SMS.

A vote belongs to a specific voter and is identified by a short_url hashid. This hashid is used to view the vote in a browser such as

    /votes/MEgvV4

Hashids are based on the vote's id and hashed according to the settings in the `config/initializers/hashids.rb` initializer.

    HASHID_MINIMUM_LENGTH = ENV['HASHID_MINIMUM_LENGTH'] || 6
    HASHID_SALT = ENV['HASHID_SALT'] || "MARCO POLO, the subject of this memoir, was born at Venice in the year 1 254."

The length and salt used can be changed via environments variables.

**Important** If you change the HASHID_MINIMUM_LENGTH value, you will need to adjust the route constraints to match:
    
    Rails.application.routes.draw do
      ...
      get '/:short_url', to: 'votes#show', as: "vote_short_url", constraints: { short_url: /[a-zA-Z0-9]{6}/ }
      ...
    end

When a vote is cast, a voter cannot change their vote. 

Based on vote count, the popularity and winning/leading choice is determined in quantity (number of votes) and percentage.

Polls are open until closed by the author or all votes have been cast.

When a poll is closed, it can no longer be voted on.

Photos
------

A poll can have a photo that is saved via Paperclip as an attachment.

When a photo is saved, the original is kept and two other styles: medium and thumb are created.

Photos are currnetly limited to 2MB in size.

A poll will include urls to these photo locations:

    if poll.has_photo?
        json.photo_url do
          json.original poll.photo_url(:original)
          json.medium poll.photo_url(:medium)
          json.thumb poll.photo_url(:thumb)
        end
    end

TODO: AWS??

Authorization
------------

Most API calls need to be authorized so that auhtors can only access their polls and close only polls they own.

You should not be able to get, view or close a poll you do not own.

A controller authorizes requests in a before action:

    before_action :authenticate, except: [ :create ]

and authenticates it by finding a Device with the device_id provided as a HTTP_AUTHORIZATION token

    def authenticate
        authenticate_or_request_with_http_token do |token, options|
          @device = Device.find_by({ device_id: token })
        end
    end

In the HTTP request, the following headers are

    headers = { "CONTENT_TYPE" => "application/json",
                'HTTP_AUTHORIZATION' => ActionController::HttpAuthentication::Token.encode_credentials(author.device_id) }

for example, this is a rendered header (note the missing HTTP_):

    CONTENT_TYPE:application/json 
    AUTHORIZATION:Token token="58b722db8ae281907e8da73cb9bb1cb5d996f759"

If a request is Unauthorized, the response will include a Forbidden 403 HTTP response status code.

JSON API
========

With the exception of the request to create a new poll, all other requess must be authoized as descibed above by sending a valid HTTP_AUTHORIZATION header.

The API is a versioned namespace. The current version is "v1".

Reponse Status Codes
--------------------

* If the request succeeds, the response with have a status code of 200.
* If the request is unauthorized, the response with have a status code of 403.
* If the request fails for validation reasons, the response with have a status * code of 422 and the body with contain a list of error messages.

Photos
------

Photo image data should be Base64 encoded in a data uri.

    "photo":"data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAUAAAAFCAYAAACNbyblAAAAHElEQVQI12P4//8/w38GIAXDIBKE0DHxgljNBAAO9TXL0Y4OHwAAAABJRU5ErkJggg=="

The content type should be image/png, image/jpeg etc.

The endcoded data should be strictly encoded with no \n within or at the end of the data.

Polls
------

Get My Polls
------------

    get '/v1/polls.json', nil, headers

Get One of My Polls
-------------------

    get "/v1/polls/#{poll.id}.json", nil, headers

Create a New Poll
-----------------

    post "/v1/polls/", poll_json, headers

Where poll_json is the JSON as referenced below in API Requests, such as: Create Poll with Question.

Close One of My Polls
---------------------

    put "/v1/polls/#{poll.id}/close.json", nil, headers

Votes
-----

A Vote API has built in the event that a user may cast a vote via the mobile app, but is not complete.

For example, a Voter would need to have a Device register to be an authorized user.

Also, data securty would need to be added to the API VotesController to ensure that a voter can view and update only their votes.

JSON Examples
=============

Responses
--------

Question and Photo
------------------

    [
      {
        "poll": {
          "author": {
            "name": "Marco Polo"
          },
          "photo_url": {
            "original": "/system/polls/photos/000/000/003/original/marco-polo-600x450.jpg?1403459623",
            "medium": "/system/polls/photos/000/000/003/medium/marco-polo-600x450.jpg?1403459623",
            "thumb": "/system/polls/photos/000/000/003/thumb/marco-polo-600x450.jpg?1403459623"
          },
          "votes_cast_count": 0,
          "votes_remaining_count": 3,
          "is_closed": false,
          "top_choice": {
            "title": "Tied",
            "votes_count": 0,
            "popularity": 0,
            "popularity_percentage": "0%"
          },
          "choices": [
            {
              "choice": {
                "title": "No",
                "votes_count": 0,
                "popularity": 0,
                "popularity_percentage": "0%"
              }
            },
            {
              "choice": {
                "title": "Yes",
                "votes_count": 0,
                "popularity": 0,
                "popularity_percentage": "0%"
              }
            }
          ],
          "votes": [
            {
              "vote": {
                "voter_phone_number": "16175550002",
                "short_url": "YPZeE6"
              }
            },
            {
              "vote": {
                "voter_phone_number": "12125550003",
                "short_url": "2PQqPQ"
              }
            },
            {
              "vote": {
                "voter_phone_number": "12025550004",
                "short_url": "YEwoED"
              }
            }
          ]
        }
      }
    ]

Note: when in staging or production, photo urls may change to be publically available full urls on a CDN such as Cloudinary.

Question only
--------------

    [
      {
        "poll": {
          "author": {
            "name": "Marco Polo"
          },
          "question": "Do you forgive me?",
          "votes_cast_count": 0,
          "votes_remaining_count": 3,
          "is_closed": false,
          "top_choice": {
            "title": "Tied",
            "votes_count": 0,
            "popularity": 0,
            "popularity_percentage": "0%"
          },
          "choices": [
            {
              "choice": {
                "title": "No",
                "votes_count": 0,
                "popularity": 0,
                "popularity_percentage": "0%"
              }
            },
            {
              "choice": {
                "title": "Yes",
                "votes_count": 0,
                "popularity": 0,
                "popularity_percentage": "0%"
              }
            }
          ],
          "votes": [
            {
              "vote": {
                "voter_phone_number": "16175550002",
                "short_url": "MEgvV4"
              }
            },
            {
              "vote": {
                "voter_phone_number": "12125550003",
                "short_url": "eV9LOX"
              }
            },
            {
              "vote": {
                "voter_phone_number": "12025550004",
                "short_url": "qPvxV6"
              }
            }
          ]
        }
      }
    ]

Photo Only
----------

    [
        {
            "poll": {
                "author": {
                    "name": "Marco Polo"
                },
                "photo_url": {
                    "original": "/system/polls/photos/000/000/003/original/marco-polo-600x450.jpg?1403459623",
                    "medium": "/system/polls/photos/000/000/003/medium/marco-polo-600x450.jpg?1403459623",
                    "thumb": "/system/polls/photos/000/000/003/thumb/marco-polo-600x450.jpg?1403459623"
                },
                "votes_cast_count": 1,
                "votes_remaining_count": 2,
                "is_closed": false,
                "top_choice": {
                    "title": "Yes",
                    "votes_count": 1,
                    "popularity": 1,
                    "popularity_percentage": "100%"
                },
                "choices": [
                    {
                        "choice": {
                            "title": "No",
                            "votes_count": 0,
                            "popularity": 0,
                            "popularity_percentage": "0%"
                        }
                    },
                    {
                        "choice": {
                            "title": "Yes",
                            "votes_count": 1,
                            "popularity": 1,
                            "popularity_percentage": "100%"
                        }
                    }
                ],
                "votes": [
                    {
                        "vote": {
                            "voter_phone_number": "12125550003",
                            "short_url": "2PQqPQ"
                        }
                    },
                    {
                        "vote": {
                            "voter_phone_number": "12025550004",
                            "short_url": "YEwoED"
                        }
                    },
                    {
                        "vote": {
                            "voter_phone_number": "16175550002",
                            "short_url": "YPZeE6",
                            "choice_title": "Yes"
                        }
                    }
                ]
            }
        }
    ]

Builder
-------

See _poll.json.jbuilder in app/views/polls for the structure.

    json.poll do
      json.author do
        json.name poll.author_name
      end

      if poll.has_question?
        json.question poll.question
      end

      if poll.has_photo?
        json.photo_url do
          json.original poll.photo_url(:original)
          json.medium poll.photo_url(:medium)
          json.thumb poll.photo_url(:thumb)
        end
      end

      json.votes_cast_count poll.votes_cast_count
      json.votes_remaining_count poll.votes_remaining_count
      json.is_closed poll.over?

      if poll.top_choice
        json.top_choice do
          json.title poll.top_choice.title
          json.votes_count poll.top_choice.votes.count
          json.popularity poll.top_choice.popularity
          json.popularity_percentage poll.top_choice.decorate.to_percentage
        end
      end

      json.choices ChoiceDecorator.decorate_collection(poll.choices) do |choice|
        json.choice do
          json.title choice.title
          json.votes_count choice.votes.count
          json.popularity choice.popularity
          json.popularity_percentage choice.to_percentage
        end
      end

      json.votes poll.votes do |vote|
        json.vote do
          json.voter_phone_number vote.voter_phone_number
          json.short_url vote.short_url
          json.choice_title vote.choice.title if vote.cast?
        end
      end
    end

For API Requests
================

Create Poll with Question
-------------------------

    {
      "poll":{
        "author_name":"Britney Lee",
        "author_device_id":"5f5b566bd39b39ad764ee74516e298d8783128c2",
        "question":"Will you go out with me?",
        "choices_attributes":[
          {
            "title":"Yes"
          },
          {
            "title":"No"
          }
        ],
        "phone_numbers":["16175551212", "12125551212", "12025551212"]
      }
    }


Create Poll with Photo
-----------------------

    {
      "poll":{
        "author_name":"Britney Lee",
        "author_device_id":"5f5b566bd39b39ad764ee74516e298d8783128c2",
        "choices_attributes":[
          {
            "title":"Yes"
          },
          {
            "title":"No"
          }
        ],
        "phone_numbers":["16175551212", "12125551212", "12025551212"],
        "photo":"data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAUAAAAFCAYAAACNbyblAAAAHElEQVQI12P4//8/w38GIAXDIBKE0DHxgljNBAAO9TXL0Y4OHwAAAABJRU5ErkJggg=="
      }
    }

Create Poll with Question and Photo
-----------------------------------

    {
      "poll":{
        "author_name":"Britney Lee",
        "author_device_id":"5f5b566bd39b39ad764ee74516e298d8783128c2",
        "question":"Will you go out with me?",
        "choices_attributes":[
          {
            "title":"Yes"
          },
          {
            "title":"No"
          }
        ],
        "phone_numbers":["16175551212", "12125551212", "12025551212"],
        "photo":"data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAUAAAAFCAYAAACNbyblAAAAHElEQVQI12P4//8/w38GIAXDIBKE0DHxgljNBAAO9TXL0Y4OHwAAAABJRU5ErkJggg=="
      }
    }

Web View for Voting
===================

Voters interact with a web view to cast their vote. They access it at by using the short_url value on their vote:

    /:short_url

for example

    /YEwoED

Anyone with this hashid can potentially cast a vote.

It is a simply view that shows the question, photo (if any), and choices.

A voter clicks on a choice to cast their vote.

Twilio
======

Polo uses the [twilio-ruby](https://github.com/twilio/twilio-ruby) for communicating with the Twilio API gem to send text messages (SMS).

The account phone number is used to send messages with the following body to each phone number saved to the poll.

    TWILIO.account.messages.create(
      from: TWILIO_PHONE_NUMBER,
      to: phone_number,
      body: "#{author_name} wants to know, \"#{question}\""
    )

This call is found within the `publish_to_voters` method on a poll which should be called as a DelayedJob. 

Account Info
-------------

TODO Message ...

Deployment
===========

Heroku
-------

When deploying to Heroku, will need to setup the necessary environment values as Heroku config settings.

Procfile
--------

    web: bundle exec unicorn -p $PORT -c ./config/unicorn.rb
    worker: bundle exec rake jobs:work

A worker needs to be running in order to process DelayedJobs to send a SMS  to Twilio.

Testing
=======

Run 

    rake

to execute intergration and feature tests of the API, models, and web interaction.

All tests and fixtures used can be found in the ``spec`` directory.

SimpleCOV is used and generates a code coverage report.

TODO
====

TODO

* Finalize SMS message copy (question, photo, question/photo cases)
* How to present a tied vote?
* Markup and style web view to cast vote
* Determine photo transform styles (300x300 etc)
* Where to store/host images. On S3? $$$ associated with this.
* What happens if invalid Twilio phone number? Delete vote? Intersect phone numbers on poll with voter numbers to show author who never got asked?
