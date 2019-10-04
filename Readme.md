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
### graph ql https://graphql.fauna.com/graphql

mutation createGame  {
  createGame(data: {
       username: "chyno2"
    shows : ["show1", "show2"]
  } ),
  { username
    _id}
}

### Querries
query	 {
  findGameByID(id: 245316277651898900) {
    username
    shows
  }
}

{
  "data": {
    "findGameByID": {
      "username": "chyno2",
      "shows": [
        "show1",
        "show2"
      ]
    }
  }
}