#!/bin/bash

# Ensure script stops on first error
set -e

# Extract current version from pubspec.yaml
CURRENT_VERSION=$(grep '^version: ' pubspec.yaml | sed 's/version: //')

if [ -z "$CURRENT_VERSION" ]; then
  echo "❌ Could not find version in pubspec.yaml"
  exit 1
fi

# Split version into major, minor, patch
IFS='.' read -r major minor patch <<< "$CURRENT_VERSION"

# Increment patch version
NEW_PATCH=$((patch + 1))
NEW_VERSION="$major.$minor.$NEW_PATCH"

echo "🦅 Bumping version: $CURRENT_VERSION -> $NEW_VERSION"

# Update pubspec.yaml using sed (macOS version)
sed -i '' "s/^version: .*/version: $NEW_VERSION/" pubspec.yaml

echo "✅ Version updated in pubspec.yaml."

# Add changes to git
git add pubspec.yaml

# Commit the version bump
git commit -m "chore: bump version to $NEW_VERSION"

# Create an annotated tag
git tag -a "v$NEW_VERSION" -m "Release v$NEW_VERSION"

echo "🚀 Pushing commit and tag to GitHub..."
git push origin HEAD
git push origin "v$NEW_VERSION"

echo "🎉 Successfully pushed v$NEW_VERSION! This will trigger your GitHub Actions CI."
