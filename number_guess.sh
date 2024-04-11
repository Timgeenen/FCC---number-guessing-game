#!/bin/bash
PSQL="psql --username=freecodecamp --dbname=number_guessing_game -t -c"
NUMBER=$(( 1 + $RANDOM % 1000 ))

echo "Enter your username:"
read USERNAME

DATA=$($PSQL "SELECT username, games_played, best_game_turns FROM users WHERE username = '$USERNAME'")

if [[ -z $DATA ]]
then
  echo "$($PSQL "INSERT INTO users(username, games_played, best_game_turns) VALUES('$USERNAME', 1, null)")"
  echo Welcome, $USERNAME! It looks like this is your first time here.
else
  read USERNAME BAR GAMES_PLAYED BAR BEST_GAME <<< $DATA
  echo "Welcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
fi

echo "Guess the secret number between 1 and 1000:"

TRIES=1

NUMBER_GUESS() {

  if [[ $1 ]]
  then
    echo $1
  fi

  read GUESS

  if [[ ! $GUESS =~ ^[0-9]+$ ]]
  then
    NUMBER_GUESS "That is not an integer, guess again:"
  fi
  
  if [[ $GUESS != $NUMBER ]]
  then
    TRIES=$((TRIES + 1))

    if [[ $GUESS < $NUMBER ]]
    then
      NUMBER_GUESS "It's higher than that, guess again:"
    elif [[ $GUESS > $NUMBER ]]
    then
      NUMBER_GUESS "It's lower than that, guess again:"
    fi
  
  elif [[ $GUESS == $NUMBER ]]
  then

    if [[ $TRIES < $BEST_GAME || $BEST_GAME == "" ]]
    then
      BEST_GAME=$TRIES
    fi

    GAMES_PLAYED=$((GAMES_PLAYED + 1))

    echo "$($PSQL "UPDATE users SET games_played = $GAMES_PLAYED, best_game_turns = $BEST_GAME WHERE username = '$USERNAME'")"
    echo You guessed it in $TRIES tries. The secret number was $NUMBER. Nice job!

  fi
}
NUMBER_GUESS