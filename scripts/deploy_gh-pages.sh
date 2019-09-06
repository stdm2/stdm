#!/usr/bin/env bash
# Push HTML files to gh-pages automatically.

# Fill this out with the correct org/repo
ORG=kngeno
REPO=stdm2
# This probably should match an email for one of your users.
EMAIL=kngeno.kevin@gmail.com

set -e

# Clone the gh-pages branch outside of the repo and cd into it.
cd ..
echo "Cloning master branch"
git clone -b gh-pages "https://$STDM_TOKEN@github.com/$ORG/$REPO.git" gh-pages > /dev/null
cd gh-pages

# git-delete-branch() 
# { 
#     if [[ -n "gh-pages" ]]; then
#         git checkout master > /dev/null;
#         branch_name="gh-pages";
#         echo "Deleting local $branch_name branch...";
#         git branch -D "$branch_name";
#         echo "Deleting remote $branch_name branch...";
#         git push origin --delete "$branch_name";
#         git remote prune origin;
#         echo "Your current branches are:";
#         git branch -a;
#     else
#         echo "Usage: git-delete-branch <branch_name>";
#     fi
# }

# echo "Create gh-pages branch..."
# git checkout -b gh-pages
# git push origin gh-pages > /dev/null
# git push --set-upstream origin gh-pages > /dev/null
# echo "Set upstream gh-pages branch..."


echo "Allow files with underscore https://help.github.com/articles/files-that-start-with-an-underscore-are-missing/" > .nojekyll
echo "[View live](https://kngeno.github.io/stdm2/)"

# Update git configuration so I can push.
if [ "$1" != "dry" ]; then
    # Update git config.
    git config user.name "$ORG"
    git config user.email "$EMAIL"
fi

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