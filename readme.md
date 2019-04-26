### Robophone

Like a party line but for making up stories with strangers. Using a short text as input calls a number of people using their transcribed reply as source for the next one. You end up with a story that is a little bit an exquisite cadaver and a little bit a broken telephone game, by telephone.

![Screen Shot](doc/screen-shot.png)

The project uses the [Twilio API](https://www.twilio.com/docs/usage/api) and [WebSockets](https://developer.mozilla.org/en-US/docs/Web/API/WebSockets_API) to send calls an receive transcripts. You can see the messages appear in the story page as people reply live.

[▶️ See how it works](https://github.com/marcelinollano/robocall/raw/master/doc/demo.mp4)

_This was presented live at [Poetry Slash II](https://poesia.javier.is), 27 Apr 2019. An event of [Libros Mutantes 2019](https://librosmutantes.com) book fair at [La casa encendida](https://www.lacasaencendida.es) (Madrid)._

#### How to install

To make this work you need [Ruby](https://ruby-lang.org), [SQLite](https://en.wikipedia.org/wiki/SQLite), a [Twilio account](https://twilio.com) and you also need to validate a phone number through their to make calls. For production deployment I included a [Dockerfile](Dockerfile).

To install on your machine run:

1. `bundle install` to install the rubygems
2. Copy `.env.sample -> .env` and edit the configuration
3. `foreman start` to run the app
4. Visit `http://localhost:5000`, voilà!
