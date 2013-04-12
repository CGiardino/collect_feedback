# Semplice guida di fast-prototyping

by: Carmine Giardino, [@carminegiardino](https://twitter.com/CarmineGiardino)  

**Creeremo una semplice chat tramite login di Facebook.**  

La demo è disponibile all'indirizzo [here](http://startupariano.meteor.com/)


## Nota
Se avete bisogno di una mano per ottenere mentoring o coaching potete contattarmi all'indirizzo: carmine.giardino@gmail.com

## Fase 1: new project

Avete bisogno di installare meteor seguendo le istruzioni @ [website](http://meteor.com/). O semplicemente eseguire il seguente comando da terminale:
  
    $ curl https://install.meteor.com | sh
   
Fatto questo, create un nuovo progetto ed eseguitelo

    $ meteor create meteor-berlinjs
    $ cd meteor-berlinjs
    $ meteor
    
Andate su un browser e navigate all'indirizzo `http://localhost:3000/`.


## Fase 2. Pacchetti che abbiamo bisogno

Aggiungete predefiniti pacchetti tramite il comando:

    $ meteor add <package_name>

per ognuno dei seguenti: 

    accounts-ui
    accounts-facebook
    coffeescript
    stylus
    bootstrap
    
Packages come coffeescript stylus e bootstrap non sono necessari, ma aiutano ad implementare il codice in modo professionale.

## Fase 3: struttura dei files
  
Aprite il codice in un file editor, e strutturate cartelle e files nel modo seguente:

    - meteor-berlinjs
      - client
        - javascripts
            main.coffee
        - stylesheets
            styles.styl
        layout.html
      - public
          empty
      - server
          server.coffee
      models.coffee
      
Separiamo il client dal server, ed utilizziamo il model come file condiviso da entrambi.


## Fase 4. Aggiungiamo il login Facebook

Apriamo `layout.html` e aggiungiamo da qualche parte:

    {{loginButtons}}
    
Questo si prenderà cura di effettuare il login tramite facebook e visuallizare la persona loggata.

Adesso avete bisogno di creare una nuova applicazione Facebook [here](https://developers.facebook.com/docs/technical-guides/opengraph/opengraph-tutorial/#create-app).
Dal sito prendiamo appId e secret key. Apriamo `server.coffee` ed aggiungiamo:

    # Per rimuovere le configurazioni di default di Facebook
    Accounts.loginServiceConfiguration.remove
      service: "facebook"

    Accounts.loginServiceConfiguration.insert
      service: "facebook"
      appId: "<your_fb_app_id>"
      secret: "<your_fb_app_secret>"
      
In questa guida trovate solo le cose più importanti, per il resto bisogna andare a vedere il codice.

Potete sempre fare il deploy dell'applicazione su meteor tramite il seguente commando:

    $ meteor deploy <your_app_name>


## Fase 5. Visualizzare tutti gli users

Vogliamo visualizzare nome e foto dell'utente. Per fare questo abbiamo bisogno di un hack creando accounts èer utenti. Aggiungiamo questo codice al 'server.coffee' file.

    # durante la creazione del nuovo utente, prendiamo la foto da facebook e la salviamo in user object
    Accounts.onCreateUser (options, user) ->
      if (options.profile)
        options.profile.picture = getFbPicture( user.services.facebook.accessToken )

        # Ancora vogliamo il default hook's 'profile'.
        user.profile = options.profile;
      return user

    # prendiamo la foto dal facebook api.
    getFbPicture = (accessToken) ->
      result = Meteor.http.get "https://graph.facebook.com/me",
        params:
          access_token: accessToken
          fields: 'picture'

      if(result.error)
        throw result.error

      return result.data.picture.data.url
      
Adesso abbiamo bisogno di scrivere qualche html. Aggiungi questo codice al file `layout.html`.

    {{#if currentUser}}
      {{> allUsers}}
    {{/if}}
        
    <template name="allUsers">
      <h3>All users:</h3>
      <ul>
      {{#each users}}
        <li>
          <img src="{{profile.picture}}" alt="picture">
          <span>{{profile.name}}</span>
        </li>    
      {{/each}}
      </ul>
      
    </template>
    
Alla fine aggiamo bisogno di prendere i dati degli utenti e passarli al template. Aggiungi questo codice al file 'main.coffee'.

    Template.allUsers.users = ->
      Meteor.users.find({})

Questo è tutto. Provate a loggarvi nell'app con due differenti browsers e differenti account facebook.


## Fase 6. Aggiungi un semplice sistema di chat.

Chating è basato su messaggi. Allora abbiamo bisogno di aggiungere Messaggi nel modello corrispondente al file 'model.coffee'.

    @Messages = new Meteor.Collection('messages')
    Messages.allow
      'insert': (userId,doc) -> return true

Si, questo è tutto quello che abbiamo bisogno per creare una nuova collection di dati in meteor.js!

In seguito, abbiamo bisogno di aggiungere alcuni file html per inserire i messagi e visualizzarli. Aggiungi questo codice al file 'layout.html'.

    {{#if currentUser}}
      {{> chatBox}}
    {{/if}}
    
    <template name="chatBox">
      <h3>Let's chat:</h3>
      
      <form id="add-message-form">
        <input type="text" id="message-input" placeholder="Your Message" />
        <button>Send</button>
      </form>
      
      <h3>Messages:</h3>
      <ul>
        {{#each messages}}
          <li>
              <img src="{{author.profile.picture}}" alt="picture">
              <div class="message-author">{{author.profile.name}}</div>
              <div class="message-body">{{body}}</div>
          </li>
        {{/each}}
      </ul>
    </template>

Ottimo. L'unica cosa mancante è la parte logica per salvare i messaggi spediti e visualizzarli nella lista di messaggi. Aggiungiamo la funzione per salvare i messaggi insieme con l'autore del messaggio. Aggiungi questo codice al file 'main.coffee'.

    # add new message
    newMessage = () ->
      input = document.getElementById('message-input')

      if input.value != ''

        Messages.insert
          author: Meteor.user()
          body: input.value
          time: Date.now()

      input.value = ''
      
Adesso abbiamo bisogno di chiamare 'newMessage' sull'azione dello user. Aggiungiamo gli eventi del template nel file 'main.coffee'.

    # add message events
      Template.chatBox.events =
        'keydown #add-message-form input': (e) ->
          if e.which == 13
            newMessage()

        'click #add-message-form button': (e) ->
          e.preventDefault()
          newMessage()

Alla fine abbiamo bisogno di prendere tutti i messaggi e visualizzarli. Aggiungi questo codice al file 'main.coffee'.

      # get all messages
      Template.chatBox.messages = ->
        Messages.find( {}, { sort: { time: -1 }} )

E' tutto gente. Nel codice troverete più styling. Spero che sia tutto chiaro e per qualsiasi problema aprite un github issue per il progetto.

* * *
Se ti piace, considera di sequirmi [su twitter](https://twitter.com/CarmineGiardino).  