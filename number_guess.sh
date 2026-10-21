#!/bin/bash
PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

NUMBER=$(( $RANDOM % 1000 + 1 ))

GAME() {
  echo "Enter your username:"
  read USERNAME
  if [[ -z $USERNAME ]]
  then 
    echo "Please enter a valid username:"
  else
    USER_ID=$($PSQL "SELECT user_id FROM users WHERE name = '$USERNAME';")
      if [[ -z $USER_ID ]]
      then
        $PSQL "INSERT INTO users(name) VALUES('$USERNAME');" > /dev/null
        echo "Welcome, $USERNAME! It looks like this is your first time here."
        USER_ID=$($PSQL "SELECT user_id FROM users WHERE name = '$USERNAME';")
      else
        RESULT=$($PSQL "SELECT COUNT(*), MIN(number_of_tries) 
                        FROM users
                        INNER JOIN games USING(user_id)
                        WHERE user_id = $USER_ID;"
        )
        IFS='|' read -r GAMES_PLAYED BEST_GAME <<< "$RESULT"
        echo "Welcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
      fi
    GUESS=0
    TRIES=0
    echo "Guess the secret number between 1 and 1000:"
      while (( $GUESS != $NUMBER ))
      do
        read GUESS
        if [[ ! $GUESS =~ ^[0-9][0-9]*$ ]]
        then 
          echo "That is not an integer, guess again:"
          continue
        else
          (( TRIES++ ))
          if (( $GUESS > $NUMBER ))
          then
            echo "It's lower than that, guess again:"
          elif (( $GUESS < $NUMBER ))
          then
            echo "It's higher than that, guess again:"
          else
            break
          fi
        fi
      done
      echo "You guessed it in $TRIES tries. The secret number was $NUMBER. Nice job!"
      $PSQL "INSERT INTO games(number_to_guess, number_of_tries, user_id) VALUES($NUMBER, $TRIES, $USER_ID);" > /dev/null
  fi
}
GAME
