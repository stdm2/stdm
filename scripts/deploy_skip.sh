echo "Checking whether $TRAVIS_COMMIT_RANGE changed only docs"

if [ -z "$TRAVIS_TAG" ]; then
    git diff --name-only $TRAVIS_COMMIT_RANGE | grep -qvE '(\.md$|^(docs)/)' || {
    echo "Only docs were updated, stopping build process."
    exit
    }
fi