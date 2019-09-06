#!/usr/bin/env bash
# Push HTML files to gh-pages automatically.

# Fill this out with the correct org/repo
ORG=kngeno
REPO=stdm2
GH-PAGES=gh-pages
# This probably should match an email for one of your users.
EMAIL=kngeno.kevin@gmail.com

set -e

setup_git() {
  git config --global user.email "travis@travis-ci.org"
  git config --global user.name "Travis CI"
}

commit_website_files() {
  cd ..
  echo "Cloning master branch"
  git clone "https://$STDM_TOKEN@github.com/$ORG/$REPO.git" gh-pages > /dev/null
  cd gh-pages
  git push origin --delete gh-pages
  git checkout -b gh-pages

}

upload_files() {
  git remote add origin-pages https://$STDM_TOKEN@github.com/$ORG/$REPO.git > /dev/null 2>&1
  git push --quiet --set-upstream origin-pages gh-pages 
}

setup_git
commit_website_files
upload_files

# Clone the gh-pages branch outside of the repo and cd into it.


echo "Allow files with underscore https://help.github.com/articles/files-that-start-with-an-underscore-are-missing/" > .nojekyll
echo "[View live](https://kngeno.github.io/stdm2/)"

# Copy in the HTML.  You may want to change this with your documentation path.
echo "project path..."

ls -lah
pwd

cp -R docs/* ./ || :
rm -rf docs/ images/ scripts/ stdm/ || :
rm .coveragerc .coveralls.yml .readthedocs.yml .gitignore *.yml *.txt *.inv *.sh *.md CONTRIBUTORS.rst || :
echo "clean github pages"

# Add and commit changes.
git add -A .
git commit -m "[travis skip] Autodoc commit for $TRAVIS_BUILD_NUMBER $COMMIT."

if [ "$1" != "dry" ]; then
    # -q is very important, otherwise you leak your GH_TOKEN
    git push -fq origin gh-pages > /dev/null
    echo "updated github pages...."
fi