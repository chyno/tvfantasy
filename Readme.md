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
### "_id": "246935131080622610",
 mutation  createCurrentNetworks {
createCurrentNetworks(data: {
  NetworkNames : ["Galaxy Network", 
    "US Fantasy", 
    "Sports Now", "CHYNO Network"]
})
  {
    _id,
    NetworkNames
  }
}

 



 ## **********************************************************
 ## Create User
 ###  "_id": "246935414112256530",
 mutation  createUser {
createUser(data : {
  username : "testchyno"
  walletAddress : ""
 
  
})
  {
    _id
    username
  }
}

# **********************************************************************
# Greate Game
mutation  createGame {
 createGame(data: {
   user: {connect: 246935414112256530}
  network : "my network"
  amount : 42
  start: "2018-11-11"
  end: "2018-12-11"
})
  {
    _id
    
  }
}

# *************************************************************
# Query User by Id
query qryUserInfo {
  findUserByID(id: 246935414112256530) {
    username
    walletAddress
    id
    games {
      data {
        amount
        network
        start
        end
        shows {
          data {
            name
            rating
            description
          }
        }
      }
    }
   
  }
}