#!/usr/bin/env bash

player_1="X"
player_2="O"

empty_squares=9
squares=( 1 2 3 4 5 6 7 8 9 )
with_cpu=false
save_file="game_save.txt"

print_board () {
  echo "============="
  echo " ${squares[0]} | ${squares[1]} | ${squares[2]} "
  echo "-----------"
  echo " ${squares[3]} | ${squares[4]} | ${squares[5]} "
  echo "-----------"
  echo " ${squares[6]} | ${squares[7]} | ${squares[8]} "
  echo "============="
}

load_game() {
  if [ ! -f "$save_file" ]; then
      echo "$save_file does not exist."
      get_game_type
  fi
  { read with_cpu; read -a squares; read empty_squares; } <$save_file
}

get_game_type() {
  echo -n "Play against (c)omputer, (p)layer or (l)oad ?"

  read user_input

  if [ "$user_input" == "c" ]; then
    with_cpu=true
    return
  fi

  if [ "$user_input" == "p" ]; then
    with_cpu=false
    return
  fi

  if [ "$user_input" == "l" ]; then
    load_game
    return
  fi

  echo "Not valid choice."
  get_game_type
}


cpu_game(){
  player_turn $player_1
  print_board
  check_winner
  
  computer_turn
  print_board
  check_winner
}

player_game(){
  player_turn $player_1
  print_board
  check_winner
  player_turn $player_2

  print_board
  check_winner
}

save_to_file () {
    echo "${with_cpu}" >$save_file
    echo "${squares[*]}" >>$save_file
    echo "${empty_squares}" >>$save_file
}


player_turn(){
  echo -n "$1 PICK A SQUARE: "

  read user_input

  if [ "$user_input" == "s" ]; then
    save_to_file
    player_turn "$1"
  fi

  if [ "$user_input" == "l" ]; then
    load_from_file
    print_board
    player_turn "$1"
  fi

  if [[ ! $user_input =~ ^-?[0-9]+$ ]]
  then
    echo "Not a valid square."
    echo "Try 1 to 9."
    player_turn "$1"
  fi
  choice=$user_input-1

  at_place=${squares[(choice)]} 

  if [[ ! $at_place =~ ^[0-9]+$  ]]
  then 
    echo "Not a empty square."
    player_turn "$1"
  fi
  squares[$choice]=$1
  ((empty_squares=empty_squares-1))

}


computer_turn(){
    choice=$(( $RANDOM % 8 + 1 ))
    at_place=${squares[($choice)]}

    if [[ ! $at_place =~ ^[0-9]+$  ]]
    then 
        echo "retry"
        computer_turn
    fi
    squares[$choice]=$player_2
    ((empty_squares=empty_squares-1))
}



check_game() {
    first=false
    second=false

    if [[ ${squares[$1]} == $player_1 ]] || [[ ${squares[$1]} == $player_2 ]]; then
        first=true
        # echo "condition one"
    fi
    if [[ ${squares[$1]} == ${squares[$2]} ]] && [[ ${squares[$2]} == ${squares[$3]} ]]; then
        second=true
        # echo "condition two"
    fi

    if [ "$first" = true ] && [ "$second" = true ]; then
        echo "Player ${squares[$1]} wins!"
    exit
    fi
}

check_winner(){
  check_game 0 4 8
  check_game 2 4 6
  check_game 0 3 6
  check_game 1 4 7
  check_game 2 5 8
  check_game 0 1 2
  check_game 3 4 5
  check_game 6 7 8
  if [ "$empty_squares" -eq "0" ]; then
   echo "Draw!";
   exit;
  fi
}


get_game_type
print_board
while true
do
    if [ "$with_cpu" = true ]; then
        cpu_game
    else
        player_game
    fi
done