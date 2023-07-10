#! /bin/bash

PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"


MAIN_MENU() {
  if [[ $1 ]]
  then
    echo -e "\n$1"
  fi
  
  SERVICE_LIST=$($PSQL "SELECT service_id, name FROM services ORDER BY service_id")
  echo "$SERVICE_LIST" | while read SERVICE_ID BAR NAME
  do
    echo "$SERVICE_ID) $NAME"
  done
  
  read SERVICE_ID_SELECTED
  
  # check if service in service list
  SERVICE_AVAILABILITY_TEST=$($PSQL "SELECT service_id FROM services WHERE service_id=$SERVICE_ID_SELECTED")
  
  if [[ -z $SERVICE_AVAILABILITY_TEST ]]
  then
    MAIN_MENU "I could not find that service. What would you like today?"
  else 
    MAKE_APPOINTMENT  
  fi
}

MAKE_APPOINTMENT() {
  # get customer info
  echo -e "\nWhat's your phone number?"
  read CUSTOMER_PHONE
  
  CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone='$CUSTOMER_PHONE'")

  #if not found
  if [[ -z $CUSTOMER_NAME ]]
  then 
    # get their name
    echo -e "\nI don't have a record for that phone number, what's your name?"
    read CUSTOMER_NAME

    #add to customer table
    ADD_CUSTOMER=$($PSQL "INSERT INTO customers(phone, name) VALUES('$CUSTOMER_PHONE', '$CUSTOMER_NAME')")
    
  fi
  

  # ask for appointment time
  echo -e "\nWhat time would you like your cut, $(echo $CUSTOMER_NAME? | sed -r 's/^ *| *$//g')"
  read SERVICE_TIME

  #set_appointment
  CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE'")
  SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id = '$SERVICE_ID_SELECTED'")
  APPT_INFO=$($PSQL "INSERT INTO appointments(customer_id, time, service_id) VALUES($CUSTOMER_ID, '$SERVICE_TIME', $SERVICE_ID_SELECTED)")


  echo -e "\nI have put you down for a $(echo $SERVICE_NAME | sed -r 's/^ *| *$//g') at $(echo $SERVICE_TIME | sed -r 's/^ *| *$//g'), $(echo $CUSTOMER_NAME | sed -r 's/^ *| *$//g')."

}

echo -e "\n~~~~~ MY SALON ~~~~~\n"
echo -e "Welcome to My Salon, how can I help you?\n" 
MAIN_MENU