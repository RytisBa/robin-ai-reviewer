#!/usr/bin/env bash

source "$HOME_DIR/src/utils.sh"
source "$HOME_DIR/src/github.sh"
source "$HOME_DIR/src/gpt.sh"

##? Auto-reviews a Pull Request
##?
##? Usage:
##?   main.sh --github_token=<token> --open_ai_api_key=<token> --gpt_model_name=<name> --github_api_url=<url> --files_to_ignore=<files>
main() {
  eval "$(/root/bin/docpars -h "$(grep "^##?" "$HOME_DIR/src/main.sh" | cut -c 5-)" : "$@")"

  utils::verify_required_env_vars

  export GITHUB_TOKEN="$github_token"
  export GITHUB_API_URL="$github_api_url"
  export OPEN_AI_API_KEY="$open_ai_api_key"
  export GPT_MODEL="$gpt_model_name"

  local -r pr_number=$(github::get_pr_number)
  local -r commit_diff=$(github::get_commit_diff "$pr_number" "$files_to_ignore")

  if [ -z "$commit_diff" ]; then
    echo "Nothing in the commit diff."
    exit
  fi

  local -r gpt_response=$(gpt::prompt_model "$commit_diff")

  if [ -z "$gpt_response" ]; then
    echoerr "GPT's response was NULL. Double check your API key and billing details."
    exit 1
  fi

  github::comment "$gpt_response" "$pr_number"

  exit $?
}
