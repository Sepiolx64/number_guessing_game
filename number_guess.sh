#!/bin/bash
PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

echo "Enter your username:"
read USERNAME

CHECK_USERNAME=$($PSQL "SELECT username FROM users WHERE username='$USERNAME'")

if [[ $CHECK_USERNAME ]]
then
  USER_INFO=$($PSQL "SELECT username, COUNT(*) AS games_played, MIN(number_of_guesses) AS best_game FROM users LEFT JOIN games ON users.user_id=games.user_id WHERE username='$USERNAME' GROUP BY username")
  echo $USER_INFO | while IFS="|" read USERNAME GAMES_PLAYED BEST_GAME
    do
      echo -e "\nWelcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
    done
else
  echo -e "\nWelcome $USERNAME! It looks like this is your first time here."
fi

RANDOM_NUMBER=$[$RANDOM % 1000 + 1]
echo $RANDOM_NUMBER
echo -e "\nGuess the secret number between 1 and 1000:"

READ_SECRET_NUMBER() {
  NUMBER_OF_GUESSES=$((NUMBER_OF_GUESSES + 1))

  if [[ $1 ]]
  then
    echo -e "\n$1"
  fi

  read SECRET_NUMBER

  if [[ ! $SECRET_NUMBER  =~ ^[0-9]+$ ]]
  then
    READ_SECRET_NUMBER "That is not an integer, guess again:"
  elif [[ $SECRET_NUMBER > $RANDOM_NUMBER ]]
  then
    READ_SECRET_NUMBER "It's lower than that, guess again:"
  elif [[ $SECRET_NUMBER < $RANDOM_NUMBER ]]
  then
    READ_SECRET_NUMBER "It's higher than that, guess again:"
  else
    echo "You guessed it in $NUMBER_OF_GUESSES tries. The secret number was $RANDOM_NUMBER. Nice job!"
    INPUT_USER=$($PSQL "INSERT INTO users(username) VALUES('$USERNAME')")
    USER_ID=$($PSQL "SELECT user_id FROM users WHERE username='$USERNAME'")
    INPUT_CORRECT_GUESS=$($PSQL "INSERT INTO games(user_id, number_of_guesses) VALUES($USER_ID, $NUMBER_OF_GUESSES)")
  fi
}

READ_SECRET_NUMBER
