# https://github.com/sporto/elm-example-app/tree/master/src

## You Create a Tv Network. ...
## You prepare your Network by scouting shows. ...
## You build your Network team by buying shows. ...
## Your your network  comepetes for shows ratings. ...
## You make moves to improve your team. ...
##  Your Network wins by having the best ratings.

### Css framework https://bulma.io/documentation/
### https://bulmatemplates.github.io/bulma-templates/templates/admin.html
### https://github.com/BulmaTemplates/bulma-templates/blob/master/css/admin.css
### graph ql https://github.com/dillonkearns/elm-graphql


### https://material.io/components/chips/#usage
### Material https://github.com/aforemny/elm-mdc/blob/master/demo/Demo.elm
### https://css-tricks.com/snippets/css/complete-guide-grid/
### https://github.com/gdotdesign/elm-ui/blob/development/source/Ui/DropdownMenu.elm

## elm-graphql https://graphql.fauna.com/graphql --header "Authorization:Bearer fnADbMd3RLACEpjT90hoJSn6SXhN281PIgIZg375"

## Add Networks
### "_id": "247852697206653458",
mutation foo {
  createAvailableNetwork(data : {
    
    name: "CBS"
    rating: 3
    description: "CBS Network"
  
  })
  {
    _id
    name
  }
}
## Create game
 mutation bar {
  createGame(data : {
    userName: "john123",
    network: "CBS"
  })
  {
    _id
    userName
  }
}

## read game
query {
  allGames {
    data  {
    _id
    userName
      network
      shows {
        name
      }
  }
  }
}


