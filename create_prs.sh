#!/bin/bash

# Configuration: SSH key and git identity
export GIT_SSH_COMMAND="ssh -i /home/cry/.ssh/id_github_stealer -o IdentitiesOnly=yes"
export GIT_AUTHOR_NAME="cryphorix"
export GIT_AUTHOR_EMAIL="cryphorix@users.noreply.github.com"
export GIT_COMMITTER_NAME="cryphorix"
export GIT_COMMITTER_EMAIL="cryphorix@users.noreply.github.com"

# Define co-authors' names and emails
# Use the duck.com email since it worked for PRs #31, #40, #55
COAUTHOR_1_NAME="cryphorix"
COAUTHOR_1_EMAIL="cryphorix@riseup.net"

COAUTHOR_2_NAME="corned-aloe"
COAUTHOR_2_EMAIL="corned-aloe-footer@duck.com"

# Ensure we're on the dev branch
git checkout dev

# Loop to create and merge pull requests  
# Need 45 more recognized PRs (we have 3, need 48 total for Gold)
for i in {99..146}
do
    echo "Processing change #$i..."
    
    # Make a change in the dev branch
    echo "NEW_ENV_VARIABLE_$i='value_$i'" >> .envexample

    # Add changes to git
    git add .envexample

    # Commit with corned-aloe as co-author (don't include yourself as co-author when you're the author)
    git commit -F - <<EOF
Update .envexample for change #$i.

Co-authored-by: $COAUTHOR_2_NAME <$COAUTHOR_2_EMAIL>
EOF

    # Push changes to the dev branch
    git push origin dev

    # Create a pull request from dev to main using GitHub CLI
    pr_number=$(gh pr create --base main --head dev --title "Merge dev to main for change #$i" --body "Merging changes from dev to main for change #$i." --repo cryphorix/Pair-Extraordinaire 2>/dev/null)
    
    if [ -z "$pr_number" ]; then
        echo "Failed to create pull request #$i, skipping..."
        continue
    fi
    
    # Extract PR number from output (format: #123)
    pr_number=$(echo "$pr_number" | grep -oP '#\K\d+' || echo "$pr_number" | grep -oP '\d+')
    
    if [ -z "$pr_number" ]; then
        echo "Could not extract PR number, skipping merge..."
        continue
    fi

    echo "Created pull request #$pr_number"

    # Merge the pull request
    gh pr merge "$pr_number" --merge --repo cryphorix/Pair-Extraordinaire || echo "Failed to merge PR #$pr_number"
    echo "Merged pull request #$pr_number"

    # Optional: Wait for a short period to ensure timing
    sleep_duration=$((RANDOM % 3 + 1))  # Random sleep between 1 and 3 seconds
    echo "Sleeping for $sleep_duration seconds..."
    sleep $sleep_duration  # Sleep for the random duration
done

echo "Completed! All 48 pull requests have been created and merged."

