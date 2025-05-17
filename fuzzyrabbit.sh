#!/bin/bash

# --- Configuration ---
FFUF_COMMAND="ffuf" # Path to ffuf if not in PATH

# --- Colors and Styles ---
# Check if terminal supports colors
if [ -t 1 ]; then
    NCOLORS=$(tput colors)
    if [ -n "$NCOLORS" ] && [ "$NCOLORS" -ge 8 ]; then
        BOLD=$(tput bold)
        UNDERLINE=$(tput smul)
        STANDOUT=$(tput smso)
        NORMAL=$(tput sgr0)
        BLACK=$(tput setaf 0)
        RED=$(tput setaf 1)
        GREEN=$(tput setaf 2)
        YELLOW=$(tput setaf 3)
        BLUE=$(tput setaf 4)
        MAGENTA=$(tput setaf 5)
        CYAN=$(tput setaf 6)
        WHITE=$(tput setaf 7)
        BG_RED=$(tput setab 1)
        BG_GREEN=$(tput setab 2)
        BG_YELLOW=$(tput setab 3)
        BG_BLUE=$(tput setab 4)
        BG_MAGENTA=$(tput setab 5)
        BG_CYAN=$(tput setab 6)
        BG_WHITE=$(tput setab 7)
    fi
fi

# Function to check if gum is installed
gum_exists() {
    command -v gum >/dev/null 2>&1
}

# Function to get input, using gum if available
get_input() {
    local prompt_message="$1"
    local default_value="$2"
    local var_name="$3"
    local is_password="${4:-false}" # Optional: true for password-style input

    echo -e -n "${CYAN}${BOLD}${prompt_message}${NORMAL}"
    if [ -n "$default_value" ]; then
        echo -e -n " ${YELLOW}[${default_value}]${NORMAL}"
    fi
    echo -e -n ": "

    if gum_exists; then
        local gum_opts=()
        if [ -n "$default_value" ]; then
            gum_opts+=(--value "$default_value")
        fi
        if [ "$is_password" = "true" ]; then
            gum_opts+=(--password)
        fi
        # Gum's prompt is part of the input command itself
        # So we adjust the prompt message for gum
        local gum_prompt="${prompt_message}"
        if [ -n "$default_value" ]; then
            gum_prompt+=" [Default: ${default_value}]"
        fi

        # Use a temporary variable to capture gum's output
        # This prevents gum from messing with subsequent `read` if it fails or is empty
        local temp_val
        temp_val=$(gum input --prompt "$gum_prompt> " "${gum_opts[@]}")
        # If user cancels (ESC), gum returns non-zero. Handle this.
        if [ $? -ne 0 ]; then
            echo -e "${RED}Input cancelled.${NORMAL}"
            # Assign default if exists, otherwise empty, to prevent script errors
            eval "$var_name=\"$default_value\""
            return 1 # Indicate cancellation or failure
        fi
        eval "$var_name=\"$temp_val\""

    else
        read -r input_value
        if [ -z "$input_value" ] && [ -n "$default_value" ]; then
            eval "$var_name=\"$default_value\""
        else
            eval "$var_name=\"$input_value\""
        fi
    fi
     # If input_value is empty AND no default_value was provided, then var_name becomes ""
    if [ -z "${!var_name}" ] && [ -z "$default_value" ]; then
        eval "$var_name=\"\""
    fi
    return 0
}


# Function to get yes/no, using gum if available
get_yes_no() {
    local prompt_message="$1"
    local default_choice="$2" # "y" or "n"
    local var_name="$3"

    local yn_prompt="${CYAN}${BOLD}${prompt_message}${NORMAL}"
    if [ "$default_choice" == "y" ]; then
        yn_prompt+=" ${YELLOW}[Y/n]${NORMAL}: "
    elif [ "$default_choice" == "n" ]; then
        yn_prompt+=" ${YELLOW}[y/N]${NORMAL}: "
    else
        yn_prompt+=" ${YELLOW}[y/n]${NORMAL}: "
    fi

    if gum_exists; then
        # Gum confirm returns 0 for yes, 1 for no
        if gum confirm "$prompt_message" --default="$([ "$default_choice" == "y" ] && echo true || echo false)"; then
            eval "$var_name=y"
        else
            eval "$var_name=n"
        fi
    else
        echo -e -n "$yn_prompt"
        read -r answer
        answer=$(echo "$answer" | tr '[:upper:]' '[:lower:]')
        if [ -z "$answer" ]; then
            answer="$default_choice"
        fi
        eval "$var_name=\"$answer\""
    fi
}

# Function to choose from options, using gum if available
get_choice() {
    local prompt_message="$1"
    shift
    local var_name="$1"
    shift
    local options=("$@")

    if gum_exists; then
        # Gum choose returns the chosen option directly
        local chosen_option
        chosen_option=$(gum choose "${options[@]}" --header "$prompt_message")
        if [ $? -ne 0 ] || [ -z "$chosen_option" ]; then
             echo -e "${RED}No selection made or cancelled.${NORMAL}"
             eval "$var_name=\"\"" # Assign empty if cancelled
             return 1
        fi
        eval "$var_name=\"$chosen_option\""
    else
        echo -e "${CYAN}${BOLD}${prompt_message}${NORMAL}"
        select opt in "${options[@]}" "Skip"; do
            case $opt in
                "Skip")
                    eval "$var_name=\"\""
                    break
                    ;;
                *)
                    if [[ " ${options[*]} " =~ " ${opt} " ]]; then
                        eval "$var_name=\"$opt\""
                        break
                    else
                        echo -e "${RED}Invalid option. Try again.${NORMAL}"
                    fi
                    ;;
            esac
        done
    fi
    return 0
}


# --- Main Logic ---
clear
echo -e "${MAGENTA}${BOLD}=====================================${NORMAL}"
echo -e "${MAGENTA}${BOLD}🚀 FFUF Command Crafter for CTFs 🚀${NORMAL}"
echo -e "${MAGENTA}${BOLD}=====================================${NORMAL}"
echo -e "Let's build your FFUF command step-by-step."
echo -e "Press ${YELLOW}Enter${NORMAL} to accept defaults or skip optional fields.\n"

# --- Initialize command parts ---
ffuf_parts=("$FFUF_COMMAND")

# --- Target URL ---
echo -e "${GREEN}${UNDERLINE}Target Configuration${NORMAL}"
get_input "Enter Target URL (use ${MAGENTA}FUZZ${NORMAL} for the fuzzing point, e.g., http://target.com/FUZZ)" "http://localhost/FUZZ" TARGET_URL
if [ -n "$TARGET_URL" ]; then
    ffuf_parts+=("-u" "\"$TARGET_URL\"")
else
    echo -e "${RED}Target URL is mandatory! Exiting.${NORMAL}"
    exit 1
fi

# --- Wordlist ---
get_input "Enter Wordlist Path" "/usr/share/wordlists/dirbuster/directory-list-2.3-medium.txt" WORDLIST_PATH
if [ -n "$WORDLIST_PATH" ]; then
    ffuf_parts+=("-w" "\"$WORDLIST_PATH\"")
else
    echo -e "${RED}Wordlist is mandatory! Exiting.${NORMAL}"
    exit 1
fi
echo

# --- Request Configuration ---
echo -e "${GREEN}${UNDERLINE}Request Configuration${NORMAL}"
COMMON_METHODS=("GET" "POST" "PUT" "HEAD" "OPTIONS")
get_choice "Select HTTP Method (or type one)" HTTP_METHOD "${COMMON_METHODS[@]}"
if [ -n "$HTTP_METHOD" ] && [ "$HTTP_METHOD" != "GET" ]; then # GET is default, no -X needed
    ffuf_parts+=("-X" "$HTTP_METHOD")
fi

if [ "$HTTP_METHOD" == "POST" ] || [ "$HTTP_METHOD" == "PUT" ]; then
    get_input "Enter POST/PUT Data (e.g., '{\"user\":\"FUZZ\",\"pass\":\"FUZZ\"}')" "" POST_DATA
    if [ -n "$POST_DATA" ]; then
        ffuf_parts+=("-d" "'$POST_DATA'")
    fi
fi

add_headers="n"
get_yes_no "Add custom Headers (e.g., Host, User-Agent, Authorization)?" "n" add_headers
if [ "$add_headers" == "y" ]; then
    echo -e "${CYAN}Enter headers one by one (e.g., ${MAGENTA}'Host: FUZZ.target.com'${NORMAL} or ${MAGENTA}'Authorization: Bearer <token>'${NORMAL}). Press Enter on an empty line to finish.${NORMAL}"
    header_count=0
    while true; do
        header_count=$((header_count + 1))
        get_input "Header ${header_count}" "" current_header
        if [ -z "$current_header" ]; then
            break
        fi
        ffuf_parts+=("-H" "\"$current_header\"")
    done
fi
echo

# --- Fuzzing Behavior ---
echo -e "${GREEN}${UNDERLINE}Fuzzing Behavior${NORMAL}"
get_input "Extensions to append (comma-separated, e.g., .php,.txt,.bak)" "" EXTENSIONS
if [ -n "$EXTENSIONS" ]; then
    ffuf_parts+=("-e" "$EXTENSIONS")
fi

get_input "Threads" "40" THREADS
if [ -n "$THREADS" ] && [ "$THREADS" != "40" ]; then # 40 is default
    ffuf_parts+=("-t" "$THREADS")
fi

get_yes_no "Enable Recursion?" "n" RECURSION
if [ "$RECURSION" == "y" ]; then
    ffuf_parts+=("-recursion")
    get_input "Recursion Depth (default: FFUF's own default)" "" RECURSION_DEPTH
    if [ -n "$RECURSION_DEPTH" ]; then
        ffuf_parts+=("-recursion-depth" "$RECURSION_DEPTH")
    fi
fi
echo

# --- Filtering & Matching ---
echo -e "${GREEN}${UNDERLINE}Filtering & Matching${NORMAL}"
get_input "Match Status Codes (comma-separated, e.g., 200,301,403)" "200,204,301,302,307,401,403,500" MATCH_CODES
if [ -n "$MATCH_CODES" ]; then
    ffuf_parts+=("-mc" "$MATCH_CODES")
fi

get_input "Filter Status Codes (comma-separated, e.g., 404,400)" "404" FILTER_CODES
if [ -n "$FILTER_CODES" ]; then
    ffuf_parts+=("-fc" "$FILTER_CODES")
fi

get_input "Filter by Size (e.g., 0,1200)" "" FILTER_SIZE
if [ -n "$FILTER_SIZE" ]; then
    ffuf_parts+=("-fs" "$FILTER_SIZE")
fi
echo

# --- Output & Display ---
echo -e "${GREEN}${UNDERLINE}Output & Display${NORMAL}"
get_yes_no "Enable FFUF's Color Output?" "y" FFUF_COLOR
if [ "$FFUF_COLOR" == "y" ]; then
    ffuf_parts+=("-c")
fi

get_yes_no "Enable Verbose Output?" "n" FFUF_VERBOSE
if [ "$FFUF_VERBOSE" == "y" ]; then
    ffuf_parts+=("-v")
fi

get_input "Output File Path (e.g., results.json, leave blank for no file)" "" OUTPUT_FILE
if [ -n "$OUTPUT_FILE" ]; then
    ffuf_parts+=("-o" "\"$OUTPUT_FILE\"")
    get_input "Output Format (json, ejson, html, md, csv, ecsv; default: based on file extension or json)" "" OUTPUT_FORMAT
    if [ -n "$OUTPUT_FORMAT" ]; then
        ffuf_parts+=("-of" "$OUTPUT_FORMAT")
    fi
fi
echo

# --- Final Command Review ---
BUILT_COMMAND="${ffuf_parts[*]}"

echo -e "${MAGENTA}${BOLD}=====================================${NORMAL}"
echo -e "${MAGENTA}${BOLD}         Final FFUF Command          ${NORMAL}"
echo -e "${MAGENTA}${BOLD}=====================================${NORMAL}"
echo -e "${YELLOW}${BOLD}$BUILT_COMMAND${NORMAL}\n"

# --- Execute ---
run_command="n"
get_yes_no "Execute this command now?" "y" run_command

if [ "$run_command" == "y" ]; then
    echo -e "${GREEN}Executing...${NORMAL}"
    # Using eval to correctly interpret quotes around paths/URLs
    eval "$BUILT_COMMAND"
else
    echo -e "${CYAN}Command copied to clipboard (if xclip/pbcopy is available) and ready to be pasted.${NORMAL}"
    # Try to copy to clipboard
    if command -v xclip >/dev/null 2>&1; then
        echo -n "$BUILT_COMMAND" | xclip -selection clipboard
        echo -e "${GREEN}(Copied using xclip)${NORMAL}"
    elif command -v pbcopy >/dev/null 2>&1; then
        echo -n "$BUILT_COMMAND" | pbcopy
        echo -e "${GREEN}(Copied using pbcopy)${NORMAL}"
    else
        echo -e "${YELLOW}(Please copy the command manually. xclip or pbcopy not found.)${NORMAL}"
    fi
fi

echo -e "\n${MAGENTA}${BOLD}Happy Fuzzing! 🚀${NORMAL}"
