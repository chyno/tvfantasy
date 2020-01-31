# https://github.com/sporto/elm-example-app/tree/master/src

## You Create a Tv Network. ...
## You prepare your Network by scouting shows. ...
## You build your Network team by buying shows. ...
## Your your network  comepetes for shows ratings. ...
## You make moves to improve your team. ...
##  Your Network wins by having the best ratings.

## Elm Graph
### graph ql https://github.com/dillonkearns/elm-graphql
### https://package.elm-lang.org/packages/dillonkearns/elm-graphql/latest/Graphql-SelectionSet

###  ********************* Material
### https://material.io/components/chips/#usage
### Material https://github.com/aforemny/elm-mdc/blob/master/demo/Demo.elm
### https://css-tricks.com/snippets/css/complete-guide-grid/
### https://github.com/gdotdesign/elm-ui/blob/development/source/Ui/DropdownMenu.elm

###  ********************* 

## Code Generation
## elm-graphql https://graphql.fauna.com/graphql --header "Authorization:Bearer fnADbMd3RLACEpjT90hoJSn6SXhN281PIgIZg375"

## Add User
### "_id": "247852697206653458",
 mutation createUser {
   createUser(data: {
    walletAddress : "aaa"
    userName : "user123"
  }) {
    userName
    _id
  }
  
}
# "_id": "256085179511079444"

mutation createGame {
  createGame(data: {
     gameName: "game 2"
  walletAmount: 1
  networkName: "network 2"
  networkDescription: "network descr 2"
    user: {
      connect : 256085179511079444
    }
  }) {
    _id
  }
}
## 256085588225032724




query {
  allUsers {
    data {
      userName
      walletAddress
      games {
        data {
          _id
          gameName
          networkName
          networkDescription
          shows {
            name
            
          }
        }
      }
    }
  }
}
## Create scheme.gql
### https://fauna.com/blog/abac-graphql