#!/bin/bash
PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

READ_USERNAME() {
echo -e "Enter your username:"
read USERNAME

if [[ -z $USERNAME ]]
then
  READ_USERNAME
else
  CHECK_USERNAME=$($PSQL "SELECT username FROM users WHERE username='$USERNAME'")
  if [[ -z $CHECK_USERNAME ]]
  then
    INSERT_USER=$($PSQL "INSERT INTO users(username) VALUES('$USERNAME')")
    echo -e "Welcome $USERNAME! It looks like this is your first time here."
  else
    USER_INFO=$($PSQL "SELECT username, COALESCE(MAX(game_id),0) AS games_played, COALESCE(MIN(number_of_guesses),0) AS best_game FROM users LEFT JOIN games ON users.user_id=games.user_id WHERE username='$USERNAME' GROUP BY username")
    echo $USER_INFO | while IFS="|" read USERNAME GAMES_PLAYED BEST_GAME
    do
      echo "Welcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
    done
  fi
fi
}

RANDOM_NUMBER=$[$RANDOM % 1000 + 1]
READ_USERNAME
