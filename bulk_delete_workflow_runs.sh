#!/bin/basg

gh_bulk_delete_workflow_runs() {
  repo='telicent-oss/telicent-base-images'

  if [[ -z "$repo" ]]; then
    echo "Usage: gh_bulk_delete_workflow_runs <owner/repo>"
    return 1
  fi

  runs=$(gh api repos/$repo/actions/runs --paginate | jq -r '.workflow_runs[] | .id')

  while IFS= read -r run; do
    echo "Deleting run $run..."
    gh api -X DELETE repos/$repo/actions/runs/$run --silent
  done <<< "$runs"

  echo "All workflow runs for $repo have been deleted."
}

gh_bulk_delete_workflow_runs
