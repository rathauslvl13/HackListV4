#!/bin/bash

# Function to generate random numbers
generate_random_numbers() {
    local LENGTH="$1"
    tr -dc '0-9' < /dev/urandom | fold -w "$LENGTH" | head -n 1
}

# Function to generate random letters
generate_random_letters() {
    local LENGTH="$1"
    tr -dc 'a-zA-Z' < /dev/urandom | fold -w "$LENGTH" | head -n 1
}

# Function to generate random words from English word list file
generate_random_words() {
    local LENGTH="$1"
    local WORD=$(shuf -n 1 ~/Desktop/english_words.txt)
    echo "$WORD"
}

# Function to generate dates for the specified year
generate_dates() {
    local YEAR="$1"
    local START_DATE="$YEAR-01-01"
    local END_DATE="$YEAR-12-31"
    local CURRENT_DATE="$START_DATE"
    
    while [[ "$CURRENT_DATE" != "$END_DATE" ]]; do
        local FORMATTED_DATE="$(date -d "$CURRENT_DATE" +%d.%m.%Y)"
        echo "$FORMATTED_DATE"
        CURRENT_DATE="$(date -d "$CURRENT_DATE + 1 day" +%Y-%m-%d)"
    done
    
    # Add the last date
    echo "$(date -d "$END_DATE" +%d.%m.%Y)"
}

# Function to generate password wordlist using template
generate_wordlist() {
    local TEMPLATE="$1"
    local COUNT="$2"
    local OPTION="$3"
    local WORDLIST_FILE="$TEMPLATE"_wordlist.txt
    
    echo "Generating $COUNT passwords using template '$TEMPLATE' and option '$OPTION'..."
    
    # Create empty wordlist file
    touch "$WORDLIST_FILE"
    
    # Generate passwords based on the selected option
    case "$OPTION" in
        1)
            read -p "Enter the number of random numbers to add (1-10): " NUMBERS_COUNT
            for ((i = 1; i <= COUNT; i++)); do
                RANDOM_NUMBERS=$(generate_random_numbers "$NUMBERS_COUNT")
                PASSWORD="$TEMPLATE$RANDOM_NUMBERS"
                echo "$PASSWORD" >> "$WORDLIST_FILE"
            done
            ;;
        2)
            read -p "Do you want to add a dot between the template and the random word? (y/n): " DOT_OPTION
            for ((i = 1; i <= COUNT; i++)); do
                RANDOM_WORD=$(generate_random_words)
                if [[ "$DOT_OPTION" == "y" ]]; then
                    PASSWORD="$TEMPLATE.$RANDOM_WORD"
                else
                    PASSWORD="$TEMPLATE$RANDOM_WORD"
                fi
                echo "$PASSWORD" >> "$WORDLIST_FILE"
            done
            ;;
        3)
            read -p "Enter the number of random letters to add (1-10): " LETTERS_COUNT
            for ((i = 1; i <= COUNT; i++)); do
                RANDOM_LETTERS=$(generate_random_letters "$LETTERS_COUNT")
                PASSWORD="$TEMPLATE$RANDOM_LETTERS"
                echo "$PASSWORD" >> "$WORDLIST_FILE"
            done
            ;;
        4)
            read -p "Enter the year to include dates from (e.g., 2008): " YEAR
            read -p "Do you want the date with dot (y/n)? " DOT
            read -p "Do you want the full year (y/n)? " FULL_YEAR
            generate_wordlist_with_dates "$TEMPLATE" "$COUNT" "$YEAR" "$DOT" "$FULL_YEAR"
            return
            ;;
        *)
            echo "Invalid option. Exiting."
            exit 1
            ;;
    esac
    
    echo "Wordlist generated: $WORDLIST_FILE"
}

# Function to generate password wordlist using template with dates
generate_wordlist_with_dates() {
    local TEMPLATE="$1"
    local COUNT="$2"
    local YEAR="$3"
    local DOT="$4"
    local FULL_YEAR="$5"
    local WORDLIST_FILE="$TEMPLATE"_wordlist.txt
    
    echo "Generating passwords using template '$TEMPLATE' and dates from $YEAR..."
    
    # Create empty wordlist file
    touch "$WORDLIST_FILE"
    
    # Generate dates for the specified year
    local DATES=($(generate_dates "$YEAR"))
    
    # Generate passwords with dates appended
    for DATE in "${DATES[@]}"; do
        if [[ "$DOT" == "y" ]]; then
            if [[ "$FULL_YEAR" == "y" ]]; then
                PASSWORD="$TEMPLATE.$DATE"
            else
                PASSWORD="$TEMPLATE.$(echo "$DATE" | cut -d'.' -f1-2).$(echo "$DATE" | cut -d'.' -f3)"
            fi
        else
            if [[ "$FULL_YEAR" == "y" ]]; then
                PASSWORD="$TEMPLATE$DATE"
            else
                PASSWORD="$TEMPLATE$(echo "$DATE" | cut -d'.' -f1-2).$(echo "$DATE" | cut -d'.' -f3)"
            fi
        fi
        echo "$PASSWORD" >> "$WORDLIST_FILE"
    done
    
    echo "Wordlist generated: $WORDLIST_FILE"
}

# Cool ASCII Art Header
echo "    __  __           __   __    _      __ "
echo "   / / / /___ ______/ /__/ /   (_)____/ /_"
echo "  / /_/ / __ \`/ ___/ //_/ /   / / ___/ __/"
echo " / __  / /_/ / /__/ ,< / /___/ (__  ) /_  "
echo "/_/ /_/\__,_/\___/_/|_/_____/_/____/\__/  "
echo "                                           "
echo "               H A C K L I S T             "
echo "                                           "

# Main script

# Ask user for template, count, and option
read -p "Enter the template name: " TEMPLATE
read -p "Enter the number of passwords to generate: " COUNT

# Ask user for option
echo "Select an option for password generation:"
echo "1. Add random numbers to the template (e.g., $TEMPLATE1234)"
echo "2. Add random words to the template (e.g., $TEMPLATE.football)"
echo "3. Add random letters to the template (e.g., $TEMPLATEabc)"
echo "4. Add dates from a specified year to the template (e.g., $TEMPLATE.20.09.2008)"
read -p "Enter the option number: " OPTION

# Call function to generate wordlist
generate_wordlist "$TEMPLATE" "$COUNT" "$OPTION"
